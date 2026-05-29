import '../constants/app_assets.dart';

/// Curated wedding content for the guest experience.
///
/// Image paths point at bundled assets (see [AppAssets]); remote URLs are also
/// supported transparently by the presentation layer's `AppImage` widget.
String _str(Map<String, dynamic> map, String key) => (map[key] ?? '').toString();

class LoveStoryChapter {
  const LoveStoryChapter({
    required this.title,
    required this.date,
    required this.body,
    required this.imageUrl,
  });

  final String title;
  final String date;
  final String body;
  final String imageUrl;

  factory LoveStoryChapter.fromMap(Map<String, dynamic> map) => LoveStoryChapter(
        title: _str(map, 'title'),
        date: _str(map, 'date'),
        body: _str(map, 'body'),
        imageUrl: _str(map, 'image'),
      );

  Map<String, dynamic> toMap() => {
        'title': title,
        'date': date,
        'body': body,
        'image': imageUrl,
      };
}

class GalleryPhoto {
  const GalleryPhoto({
    required this.imageUrl,
    required this.caption,
    required this.date,
    required this.message,
  });

  final String imageUrl;
  final String caption;
  final String date;
  final String message;

  factory GalleryPhoto.fromMap(Map<String, dynamic> map) => GalleryPhoto(
        imageUrl: _str(map, 'image'),
        caption: _str(map, 'caption'),
        date: _str(map, 'date'),
        message: _str(map, 'message'),
      );

  Map<String, dynamic> toMap() => {
        'image': imageUrl,
        'caption': caption,
        'date': date,
        'message': message,
      };
}

class WeddingVideo {
  const WeddingVideo({
    required this.asset,
    required this.title,
    required this.subtitle,
  });

  /// Bundled asset path or a remote (Storage) URL — see [isRemote].
  final String asset;
  final String title;
  final String subtitle;

  bool get isRemote =>
      asset.startsWith('http://') || asset.startsWith('https://');

  factory WeddingVideo.fromMap(Map<String, dynamic> map) => WeddingVideo(
        asset: _str(map, 'video'),
        title: _str(map, 'title'),
        subtitle: _str(map, 'subtitle'),
      );

  Map<String, dynamic> toMap() => {
        'video': asset,
        'title': title,
        'subtitle': subtitle,
      };
}

class LoveNote {
  const LoveNote({required this.text, this.author});

  final String text;
  final String? author;

  factory LoveNote.fromMap(Map<String, dynamic> map) {
    final author = (map['author'] ?? '').toString().trim();
    return LoveNote(
      text: _str(map, 'text'),
      author: author.isEmpty ? null : author,
    );
  }

  Map<String, dynamic> toMap() => {
        'text': text,
        if (author != null && author!.isNotEmpty) 'author': author,
      };
}

/// A printed program page (order of service / order of program) shown as a
/// zoomable image so guests can follow the day's flow.
class ProgramPage {
  const ProgramPage({
    required this.image,
    required this.title,
    required this.subtitle,
  });

  final String image;
  final String title;
  final String subtitle;

  factory ProgramPage.fromMap(Map<String, dynamic> map) => ProgramPage(
        image: _str(map, 'image'),
        title: _str(map, 'title'),
        subtitle: _str(map, 'subtitle'),
      );

  Map<String, dynamic> toMap() => {
        'image': image,
        'title': title,
        'subtitle': subtitle,
      };
}

abstract final class WeddingContent {
  static const loveStoryChapters = [
    LoveStoryChapter(
      title: 'How We Met',
      date: 'Where it began',
      body:
          'A chance encounter became the beginning of everything. '
          'In your smile, I found a home I never knew I was searching for.',
      imageUrl: AppAssets.storyMet,
    ),
    LoveStoryChapter(
      title: 'Our Journey',
      date: 'Growing together',
      body:
          'Through seasons of laughter, growth, and quiet strength, '
          'we learned that love is not just a feeling — it is a choice we make every day.',
      imageUrl: AppAssets.storyJourney,
    ),
    LoveStoryChapter(
      title: 'The Proposal',
      date: 'She said yes',
      body:
          'Surrounded by roses and the people we love, I knelt and asked the '
          'question my heart had known long before my lips could speak it. You said yes.',
      imageUrl: AppAssets.storyProposal,
    ),
    LoveStoryChapter(
      title: 'Forever Begins',
      date: 'Today',
      body:
          'Today we stand before everyone we love and promise forever. '
          'This is not an ending — it is our most beautiful beginning.',
      imageUrl: AppAssets.storyForever,
    ),
  ];

  static const preWeddingPhotos = [
    GalleryPhoto(
      imageUrl: AppAssets.white1,
      caption: 'Two hearts, one journey',
      date: 'Pre-wedding shoot',
      message: 'Every moment with you feels like a dream I never want to wake from.',
    ),
    GalleryPhoto(
      imageUrl: AppAssets.trad1,
      caption: 'Proudly ours, beautifully us',
      date: 'Traditional',
      message: 'Two families, one love story — wrapped in culture and joy.',
    ),
    GalleryPhoto(
      imageUrl: AppAssets.embrace,
      caption: 'Closer than words',
      date: 'Pre-wedding shoot',
      message: 'In your arms is my favourite place to be.',
    ),
    GalleryPhoto(
      imageUrl: AppAssets.proposalKneel,
      caption: 'Will you marry me?',
      date: 'The proposal',
      message: 'The easiest yes of my whole life.',
    ),
    GalleryPhoto(
      imageUrl: AppAssets.white3,
      caption: 'Laughter is our love language',
      date: 'Pre-wedding shoot',
      message: 'With you, even the quiet moments are full of joy.',
    ),
    GalleryPhoto(
      imageUrl: AppAssets.trad3,
      caption: 'Rooted in love & tradition',
      date: 'Traditional',
      message: 'Looking at you, I see my forever.',
    ),
    GalleryPhoto(
      imageUrl: AppAssets.elegantBlue,
      caption: 'Effortless, together',
      date: 'Pre-wedding shoot',
      message: 'Hand in hand, heart to heart.',
    ),
    GalleryPhoto(
      imageUrl: AppAssets.white2,
      caption: 'My peace, my person',
      date: 'Pre-wedding shoot',
      message: 'You are the calm in every storm.',
    ),
    GalleryPhoto(
      imageUrl: AppAssets.trad2,
      caption: 'A love worth celebrating',
      date: 'Traditional',
      message: 'Every culture, every colour — chosen for you.',
    ),
    GalleryPhoto(
      imageUrl: AppAssets.trad4,
      caption: 'Bold, regal, ours',
      date: 'Traditional',
      message: 'Standing tall, side by side.',
    ),
    GalleryPhoto(
      imageUrl: AppAssets.portraitBride,
      caption: 'Radiant',
      date: 'Pre-wedding shoot',
      message: 'The most beautiful chapter of my life.',
    ),
    GalleryPhoto(
      imageUrl: AppAssets.proposalRing1,
      caption: 'She said yes!',
      date: 'The proposal',
      message: 'Forever officially began here.',
    ),
    GalleryPhoto(
      imageUrl: AppAssets.proposalCelebrate,
      caption: 'Surrounded by love',
      date: 'The proposal',
      message: 'Held close, while the world cheered us on.',
    ),
    GalleryPhoto(
      imageUrl: AppAssets.casual1,
      caption: 'Just the two of us',
      date: 'Our everyday',
      message: 'Ordinary days made extraordinary by you.',
    ),
    GalleryPhoto(
      imageUrl: AppAssets.casual4,
      caption: 'Always smiling with you',
      date: 'Our everyday',
      message: 'You are my favourite hello and hardest goodbye.',
    ),
  ];

  static const programPages = [
    ProgramPage(
      image: AppAssets.programService,
      title: 'Church Ceremony',
      subtitle: 'Order of service · ministers · hymns · photography',
    ),
    ProgramPage(
      image: AppAssets.programReception,
      title: 'Reception',
      subtitle: 'Order of program · 12:00 noon',
    ),
  ];

  static const weddingVideos = [
    WeddingVideo(
      asset: AppAssets.loveStory1,
      title: 'Our Love Story',
      subtitle: 'A short film',
    ),
    WeddingVideo(
      asset: AppAssets.loveStory2,
      title: 'Joyce & Emeka',
      subtitle: 'Moments together',
    ),
    WeddingVideo(
      asset: AppAssets.clip1,
      title: 'Our Moments',
      subtitle: 'In motion',
    ),
    WeddingVideo(
      asset: AppAssets.clip2,
      title: 'Caught Smiling',
      subtitle: 'Behind the scenes',
    ),
    WeddingVideo(
      asset: AppAssets.clip3,
      title: 'Forever Begins',
      subtitle: 'A little clip of us',
    ),
  ];

  static const loveNotes = [
    LoveNote(
      text:
          'Our story wasn\'t written by chance; every step led us to each other.',
    ),
    LoveNote(
      text: 'You became my answered prayer and my forever home.',
    ),
    LoveNote(
      text: 'We laughed, we grew, and now we begin forever.',
    ),
    LoveNote(
      text: 'In your eyes I found the courage to believe in forever.',
      author: 'With all my love',
    ),
  ];
}

/// All curated guest-facing content, sourced from Firestore when available and
/// falling back to the bundled [WeddingContent] defaults. Held by the guest
/// app's content cubit and edited by the admin app.
class WeddingContentBundle {
  const WeddingContentBundle({
    required this.loveStory,
    required this.gallery,
    required this.videos,
    required this.loveNotes,
    required this.program,
  });

  final List<LoveStoryChapter> loveStory;
  final List<GalleryPhoto> gallery;
  final List<WeddingVideo> videos;
  final List<LoveNote> loveNotes;
  final List<ProgramPage> program;

  static const WeddingContentBundle defaults = WeddingContentBundle(
    loveStory: WeddingContent.loveStoryChapters,
    gallery: WeddingContent.preWeddingPhotos,
    videos: WeddingContent.weddingVideos,
    loveNotes: WeddingContent.loveNotes,
    program: WeddingContent.programPages,
  );

  WeddingContentBundle copyWith({
    List<LoveStoryChapter>? loveStory,
    List<GalleryPhoto>? gallery,
    List<WeddingVideo>? videos,
    List<LoveNote>? loveNotes,
    List<ProgramPage>? program,
  }) {
    return WeddingContentBundle(
      loveStory: loveStory ?? this.loveStory,
      gallery: gallery ?? this.gallery,
      videos: videos ?? this.videos,
      loveNotes: loveNotes ?? this.loveNotes,
      program: program ?? this.program,
    );
  }
}
