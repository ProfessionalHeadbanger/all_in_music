class Audio {
  final String id;
  final String title;
  final String artist;
  final int duration;
  final Set<String> sources;
  final String? coverUrl;
  final String? mp3Url;

  Audio({required this.id, required this.title, required this.artist, required this.duration, required this.sources, this.coverUrl, this.mp3Url});

  void addSource(String source) {
    sources.add(source);
  }
}

Audio audioFromVk(Map<String, dynamic> vkTrack) {
  return Audio(
    id: vkTrack['id'].toString(), 
    title: vkTrack['title'],
    artist: vkTrack['artist'],
    duration: vkTrack['duration'],
    sources: {'VK'},
    coverUrl: null,
    mp3Url: vkTrack['url'],
  );
}

Audio audioFromSpotify(Map<String, dynamic> spotifyTrack) {
  return Audio(
    id: spotifyTrack['track']['id'],
    title: spotifyTrack['track']['name'],
    artist: spotifyTrack['track']['artists'][0]['name'],
    duration: spotifyTrack['track']['duration_ms'] ~/ 1000,
    sources: {'Spotify'},
    coverUrl: spotifyTrack['track']['album']['images'][0]['url'],
    mp3Url: null,
  );
}