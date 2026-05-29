import * as admin from "firebase-admin";
import { onDocumentCreated, onDocumentDeleted } from "firebase-functions/v2/firestore";
import { defineSecret } from "firebase-functions/params";
import { createDriveClient, uploadBufferToDrive } from "./drive/googleDriveClient";

admin.initializeApp();

const googleDriveRootFolderId = defineSecret("GOOGLE_DRIVE_ROOT_FOLDER_ID");

interface MemoryDocument {
  imageUrl: string;
  mediaType: "photo" | "video";
  guestName?: string;
  message?: string;
  tableNumber?: string;
  weddingId?: string;
  storagePath?: string;
}

/**
 * When a guest memory is saved to Firestore, download the media from
 * Firebase Storage and mirror it to Google Drive:
 *
 *   Wedding Day/
 *     Photos/
 *     Videos/
 */
export const syncMemoryToGoogleDrive = onDocumentCreated(
  {
    document: "memories/{memoryId}",
    secrets: [googleDriveRootFolderId],
    region: "us-central1",
  },
  async (event) => {
    const snapshot = event.data;
    if (!snapshot) {
      return;
    }

    const data = snapshot.data() as MemoryDocument;
    const memoryId = event.params.memoryId;

    if (!data.imageUrl || !data.mediaType) {
      console.warn(`Memory ${memoryId} missing imageUrl or mediaType. Skipping Drive sync.`);
      return;
    }

    const rootFolderId = googleDriveRootFolderId.value();
    if (!rootFolderId) {
      console.error("GOOGLE_DRIVE_ROOT_FOLDER_ID secret is not set.");
      return;
    }

    try {
      const mediaBuffer = await downloadFromUrl(data.imageUrl);
      const subfolder = data.mediaType === "video" ? "Videos" : "Photos";
      const fileName = buildFileName(memoryId, data);

      const drive = createDriveClient();
      const driveFileId = await uploadBufferToDrive({
        drive,
        folderId: rootFolderId,
        fileName: `${subfolder}/${fileName}`,
        mimeType: guessMimeType(data.mediaType),
        buffer: mediaBuffer,
      });

      await snapshot.ref.update({
        driveSyncStatus: "synced",
        driveFileId,
        driveSyncedAt: admin.firestore.FieldValue.serverTimestamp(),
      });

      console.log(`Synced memory ${memoryId} to Google Drive (${driveFileId}).`);
    } catch (error) {
      console.error(`Failed to sync memory ${memoryId} to Google Drive:`, error);
      await snapshot.ref.update({
        driveSyncStatus: "failed",
        driveSyncError: error instanceof Error ? error.message : "Unknown error",
      });
    }
  },
);

/**
 * When an admin deletes a memory document, remove the backing media file from
 * Firebase Storage so hidden/removed uploads don't linger. Runs with the Admin
 * SDK, so no client Storage permissions are required.
 */
export const cleanupMemoryStorage = onDocumentDeleted(
  {
    document: "memories/{memoryId}",
    region: "us-central1",
  },
  async (event) => {
    const data = event.data?.data() as MemoryDocument | undefined;
    const storagePath = data?.storagePath;
    if (!storagePath) {
      return;
    }
    try {
      await admin.storage().bucket().file(storagePath).delete();
      console.log(`Deleted Storage object ${storagePath}.`);
    } catch (error) {
      console.error(`Failed to delete Storage object ${storagePath}:`, error);
    }
  },
);

async function downloadFromUrl(url: string): Promise<Buffer> {
  const response = await fetch(url);
  if (!response.ok) {
    throw new Error(`Failed to download media: HTTP ${response.status}`);
  }
  const arrayBuffer = await response.arrayBuffer();
  return Buffer.from(arrayBuffer);
}

function buildFileName(memoryId: string, data: MemoryDocument): string {
  const guest = sanitize(data.guestName ?? "guest");
  const table = data.tableNumber ? `_table-${sanitize(data.tableNumber)}` : "";
  const ext = data.mediaType === "video" ? "mp4" : "jpg";
  return `${guest}${table}_${memoryId}.${ext}`;
}

function sanitize(value: string): string {
  return value.replace(/[^a-zA-Z0-9_-]/g, "_").slice(0, 40);
}

function guessMimeType(mediaType: MemoryDocument["mediaType"]): string {
  return mediaType === "video" ? "video/mp4" : "image/jpeg";
}
