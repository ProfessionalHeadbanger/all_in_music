import 'dart:convert';
import 'package:collection/collection.dart';

class Audio {
  final String id;
  final String title;
  final String artist;
  final int duration;
  final Set<String> sources;
  String? coverUrl;
  String? mp3Url;
  Map<String, String> trackLinks;

  Audio({required this.id, required this.title, required this.artist, required this.duration, required this.sources, this.coverUrl, this.mp3Url, required this.trackLinks});

  Audio copyWith({
    String? id,
    String? title,
    String? artist,
    int? duration,
    Set<String>? sources,
    String? coverUrl,
    String? mp3Url,
    Map<String, String>? trackLinks,
  }) {
    return Audio(
      id: id ?? this.id,
      title: title ?? this.title,
      artist: artist ?? this.artist,
      duration: duration ?? this.duration,
      sources: sources ?? this.sources,
      coverUrl: coverUrl ?? this.coverUrl,
      mp3Url: mp3Url ?? this.mp3Url,
      trackLinks: trackLinks ?? this.trackLinks,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other.runtimeType != runtimeType) return false;
    return other is Audio &&
      other.title == title &&
      other.artist == artist &&
      other.duration == duration &&
      other.coverUrl == coverUrl &&
      const SetEquality().equals(other.sources, sources) && 
      const MapEquality().equals(other.trackLinks, trackLinks);
  }

  @override
  int get hashCode => Object.hash(title, artist, duration, coverUrl, sources, trackLinks);

  void addSource(String source) {
    sources.add(source);
  }

  String toJson() {
    return json.encode({
      'id': id,
      'title': title,
      'artist': artist,
      'duration': duration,
      'sources': sources.toList(),
      'coverUrl': coverUrl,
      'mp3Url': mp3Url,
      'trackLinks': trackLinks,
    });
}

  factory Audio.fromJson(String jsonStr) {
    final jsonMap = json.decode(jsonStr);
    return Audio(
      id: jsonMap['id'],
      title: jsonMap['title'],
      artist: jsonMap['artist'],
      duration: jsonMap['duration'],
      sources: Set<String>.from(jsonMap['sources']),
      coverUrl: jsonMap['coverUrl'],
      mp3Url: jsonMap['mp3Url'],
      trackLinks: Map<String, String>.from(jsonMap['trackLinks']),
    );
  }
}

Audio audioFromVk(Map<String, dynamic> vkTrack) {
  String artists = vkTrack['artist'].replaceAll(RegExp(r'\s*(feat\.|ft\.)\s*', caseSensitive: false), ', ');

  String? vkLink;
  if (vkTrack.containsKey('release_audio_id')) {
    vkLink = 'https://vk.com/audio${vkTrack['release_audio_id']}';
  } else {
    vkLink = 'https://vk.com/audio${vkTrack['owner_id']}_${vkTrack['id']}';
  }

  return Audio(
    id: vkTrack['id'].toString(), 
    title: vkTrack['title'],
    artist: artists,
    duration: vkTrack['duration'],
    sources: {'VK'},
    coverUrl: null,
    mp3Url: vkTrack['url'],
    trackLinks: {'VK': vkLink},
  );
}

Audio audioFromYandex(Map<String, dynamic> yandexTrack, Map<String, dynamic> yandexAlbum) {
  final artists = (yandexTrack['artists'] as List)
          .map((artist) => artist['name'])
          .join(', ');

  String yandexLink = 'https://music.yandex.ru/album/${yandexAlbum['id']}/track/${yandexTrack['id']}';

  return Audio(
        id: yandexTrack['id'].toString(),
        title: yandexTrack['title'],
        artist: artists,
        duration: yandexTrack['durationMs'] ~/ 1000,
        sources: {'YandexMusic'},
        coverUrl: yandexAlbum['coverUri'] != null 
            ? 'https://${yandexAlbum['coverUri'].replaceAll('%%', '1000x1000')}'
            : null,
        mp3Url: null,
        trackLinks: {'YandexMusic' : yandexLink},
      );
}