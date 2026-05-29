enum MediaType {
  photo('photo'),
  video('video');

  const MediaType(this.value);

  final String value;

  static MediaType fromString(String value) {
    return MediaType.values.firstWhere(
      (e) => e.value == value,
      orElse: () => MediaType.photo,
    );
  }
}
