class Audio {
  final String title;
  final String artist;
  final int duration;
  final String url;

  Audio({required this.title, required this.artist, required this.duration, required this.url});

  factory Audio.fromJson(Map<String, dynamic> json) {
    return Audio(title: json['title'], artist: json['artist'], duration: json['duration'], url: json['url']);
  }
}