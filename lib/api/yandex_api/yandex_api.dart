import 'package:all_in_music/models/audio_model.dart';
import 'package:dio/dio.dart';

String? extractAccessTokenYandex(String input) {
  Match? tokenMatch = RegExp(r"access_token=([^&]+)",).firstMatch(input,);

  if (tokenMatch == null) return null;

  String token = tokenMatch.group(1).toString();

  if (!token.startsWith("y0")) return null;

  return token;
}

Future<String?> getYandexUserId(String accessToken) async {
  final dio = Dio();

  try {
    final response = await dio.get(
      'https://api.music.yandex.net/account/status',
      options: Options(
        headers: {
          'Authorization': 'OAuth $accessToken',
        },
      ),
    );

    if (response.statusCode == 200) {
      return response.data['result']['account']['uid'].toString();
    } else {
      print('Failed to get user ID: ${response.statusMessage}');
      return null;
    }
  } catch (e) {
    print('Error: $e');
    return null;
  }
}

Future<List<Audio>> getYandexFavorites(String accessToken, String userId) async {
  final dio = Dio();
  List<Audio> favoriteTracks = [];

  try {
    final response = await dio.get(
      'https://api.music.yandex.net/users/$userId/likes/tracks',
      options: Options(
        headers: {
          'Authorization': 'OAuth $accessToken',
        },
      ),
    );

    if (response.statusCode == 200) {
      List<dynamic> tracks = response.data['result']['library']['tracks'];

      for (var track in tracks) {
        String trackId = track['id'];
        String albumId = track['albumId'];

        Audio? trackInfo = await getYandexTrackInfo(trackId, albumId, accessToken);

        if (trackInfo != null) {
          favoriteTracks.add(trackInfo);
        } else {
          print('Failed to retrieve info for trackId: $trackId, albumId: $albumId');
        }
      }
    } else {
      print('Failed to load tracks: ${response.statusMessage}');
    }
  } catch (e) {
    print('Error: $e');
  }

  return favoriteTracks;
}

Future<Audio?> getYandexTrackInfo(String trackId, String albumId, String accessToken) async {
  final dio = Dio();

  try {
    final response = await dio.get(
      'https://api.music.yandex.net/tracks/$trackId',
      queryParameters: {
        'albumId': albumId,
      },
      options: Options(
        headers: {
          'Authorization': 'OAuth $accessToken',
        },
      ),
    );

    if (response.statusCode == 200) {
      final trackData = response.data['result'][0];
      final albumData = trackData['albums'][0];

      return audioFromYandex(trackData, albumData);
    } else {
      print('Failed to fetch track info: ${response.statusMessage}');
      return null;
    }
  } catch (e) {
    print('Error: $e');
    return null;
  }
}