import 'package:flutter/material.dart';

import '../../core/constants/firebase_constants.dart';
import '../../core/content/wedding_content.dart';

enum ContentMediaKind { none, image, video }

class ContentField {
  const ContentField(
    this.key,
    this.label, {
    this.multiline = false,
    this.required = true,
  });

  final String key;
  final String label;
  final bool multiline;
  final bool required;
}

/// Describes one editable content section so a single editor screen can render
/// the right fields and media picker for each.
class ContentSectionSpec {
  const ContentSectionSpec({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.fields,
    required this.titleKey,
    required this.defaults,
    this.media = ContentMediaKind.none,
    this.mediaKey = '',
  });

  final String id;
  final String title;
  final String subtitle;
  final IconData icon;
  final List<ContentField> fields;

  /// Field key used as the title in the items list.
  final String titleKey;
  final ContentMediaKind media;
  final String mediaKey;

  /// Current default items (used to seed the editor before first save).
  final List<Map<String, dynamic>> Function() defaults;

  bool get hasMedia => media != ContentMediaKind.none;
  bool get isVideo => media == ContentMediaKind.video;
}

abstract final class ContentSpecs {
  static final List<ContentSectionSpec> all = [
    loveStory,
    gallery,
    videos,
    loveNotes,
    program,
  ];

  static ContentSectionSpec byId(String id) =>
      all.firstWhere((s) => s.id == id);

  static final loveStory = ContentSectionSpec(
    id: ContentSections.loveStory,
    title: 'Love Story',
    subtitle: 'Chapters of your journey',
    icon: Icons.auto_stories_outlined,
    fields: const [
      ContentField('title', 'Title'),
      ContentField('date', 'Caption (e.g. "Where it began")'),
      ContentField('body', 'Story', multiline: true),
    ],
    titleKey: 'title',
    media: ContentMediaKind.image,
    mediaKey: 'image',
    defaults: () =>
        WeddingContentBundle.defaults.loveStory.map((e) => e.toMap()).toList(),
  );

  static final gallery = ContentSectionSpec(
    id: ContentSections.gallery,
    title: 'Pre-Wedding Gallery',
    subtitle: 'Photos guests browse',
    icon: Icons.photo_library_outlined,
    fields: const [
      ContentField('caption', 'Caption'),
      ContentField('date', 'Label (e.g. "Traditional")'),
      ContentField('message', 'Message', multiline: true, required: false),
    ],
    titleKey: 'caption',
    media: ContentMediaKind.image,
    mediaKey: 'image',
    defaults: () =>
        WeddingContentBundle.defaults.gallery.map((e) => e.toMap()).toList(),
  );

  static final videos = ContentSectionSpec(
    id: ContentSections.videos,
    title: 'Videos',
    subtitle: 'Moments in motion',
    icon: Icons.movie_outlined,
    fields: const [
      ContentField('title', 'Title'),
      ContentField('subtitle', 'Subtitle', required: false),
    ],
    titleKey: 'title',
    media: ContentMediaKind.video,
    mediaKey: 'video',
    defaults: () =>
        WeddingContentBundle.defaults.videos.map((e) => e.toMap()).toList(),
  );

  static final loveNotes = ContentSectionSpec(
    id: ContentSections.loveNotes,
    title: 'Love Notes',
    subtitle: 'Short heartfelt notes',
    icon: Icons.favorite_border,
    fields: const [
      ContentField('text', 'Note', multiline: true),
      ContentField('author', 'Author (optional)', required: false),
    ],
    titleKey: 'text',
    defaults: () =>
        WeddingContentBundle.defaults.loveNotes.map((e) => e.toMap()).toList(),
  );

  static final program = ContentSectionSpec(
    id: ContentSections.program,
    title: 'Wedding Program',
    subtitle: 'Order of the day',
    icon: Icons.menu_book_outlined,
    fields: const [
      ContentField('title', 'Title'),
      ContentField('subtitle', 'Subtitle'),
    ],
    titleKey: 'title',
    media: ContentMediaKind.image,
    mediaKey: 'image',
    defaults: () =>
        WeddingContentBundle.defaults.program.map((e) => e.toMap()).toList(),
  );
}
