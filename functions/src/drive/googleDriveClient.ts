import { google, drive_v3 } from "googleapis";

/**
 * Creates an authenticated Google Drive client using the Firebase
 * Functions default service account (Application Default Credentials).
 *
 * Enable the Google Drive API in GCP and share the target folder with
 * the service account email (…@PROJECT_ID.iam.gserviceaccount.com).
 */
export function createDriveClient(): drive_v3.Drive {
  const auth = new google.auth.GoogleAuth({
    scopes: ["https://www.googleapis.com/auth/drive.file"],
  });

  return google.drive({ version: "v3", auth });
}

export async function uploadBufferToDrive(params: {
  drive: drive_v3.Drive;
  folderId: string;
  fileName: string;
  mimeType: string;
  buffer: Buffer;
}): Promise<string> {
  const { drive, folderId, fileName, mimeType, buffer } = params;

  const response = await drive.files.create({
    requestBody: {
      name: fileName,
      parents: [folderId],
    },
    media: {
      mimeType,
      body: bufferToStream(buffer),
    },
    fields: "id",
  });

  if (!response.data.id) {
    throw new Error("Google Drive upload succeeded but returned no file id.");
  }

  return response.data.id;
}

function bufferToStream(buffer: Buffer): NodeJS.ReadableStream {
  const { Readable } = require("stream");
  const stream = new Readable();
  stream.push(buffer);
  stream.push(null);
  return stream;
}
