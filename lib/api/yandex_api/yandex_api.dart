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

      // Разделим треки на несколько частей, чтобы запрашивать их пакетами
      const int batchSize = 50;
      for (int i = 0; i < tracks.length; i += batchSize) {
        List<String> trackIds = [];
        List<String> albumIds = [];

        for (int j = i; j < i + batchSize && j < tracks.length; j++) {
          trackIds.add(tracks[j]['id']);
          albumIds.add(tracks[j]['albumId']);
        }

        // Запрашиваем информацию о нескольких треках сразу
        List<Audio?> trackInfos = await getYandexTrackInfoBulk(trackIds, albumIds, accessToken);

        // Добавляем только успешные треки
        favoriteTracks.addAll(trackInfos.whereType<Audio>());
      }
    } else {
      print('Failed to load tracks: ${response.statusMessage}');
    }
  } catch (e) {
    print('Error: $e');
  }

  return favoriteTracks;
}

Future<List<Audio?>> getYandexTrackInfoBulk(List<String> trackIds, List<String> albumIds, String accessToken) async {
  final dio = Dio();
  List<Audio?> tracks = [];

  try {
    // Формируем запрос с несколькими ID треков
    final response = await dio.get(
      'https://api.music.yandex.net/tracks',
      queryParameters: {
        'trackIds': trackIds.join(','),
        'albumIds': albumIds.join(','),
      },
      options: Options(
        headers: {
          'Authorization': 'OAuth $accessToken',
        },
      ),
    );

    if (response.statusCode == 200) {
      List<dynamic> trackDataList = response.data['result'];

      for (int i = 0; i < trackDataList.length; i++) {
        final trackData = trackDataList[i];
        final albumData = trackData['albums'][0];

        Audio? track = audioFromYandex(trackData, albumData);
        tracks.add(track);
      }
    } else {
      print('Failed to fetch tracks info: ${response.statusMessage}');
    }
  } catch (e) {
    print('Error: $e');
  }

  return tracks;
}