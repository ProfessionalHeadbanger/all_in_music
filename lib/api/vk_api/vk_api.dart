import 'package:all_in_music/models/audio_model.dart';
import 'package:dio/dio.dart';

String? extractAccessTokenVK(String input) {
  if (input.startsWith("vk1")) {
    return input;
  }

  Match? tokenMatch = RegExp(r"access_token=([^&]+)",).firstMatch(input,);

  if (tokenMatch == null) return null;

  String token = tokenMatch.group(1).toString();

  if (!token.startsWith("vk1")) return null;

  return token;
}

Future<List<Audio>> fetchAudio(String accessToken) async {
  final dio = Dio(
    BaseOptions(
      headers: {
        "User-Agent": "KateMobileAndroid/109.1 lite-550 (Android 13; SDK 33; x86_64; Google Pixel 5; ru)",
      },
    ),
  );

  const url = 'https://api.vk.com/method/audio.get';
  const int count = 6000;
  int offset = 0;
  List<Audio> audioList = [];

  try {
    while (true) {
      final params = {
        'access_token': accessToken,
        'v': '5.199',
        'count': count,
        'offset': offset,
      };

      final response = await dio.get(url, queryParameters: params);

      if (response.statusCode == 200) {
        final data = response.data;
        final List<dynamic> audioListJson = data['response']['items'];

        List<Audio> currentBatch = audioListJson.map((json) => audioFromVk(json)).toList();
        
        audioList.addAll(currentBatch);

        if (currentBatch.length < count) {
          break;
        }

        offset += count;
      } else {
        print('Failed to load audio: ${response.statusMessage}');
        break;
      }
    }

    return audioList;
  } catch (e) {
    print('Error: $e');
    return [];
  }
}

Future<String?> getVkUserAvatar(String accessToken) async {
  final dio = Dio(
    BaseOptions(
      headers: {
        "User-Agent": "KateMobileAndroid/109.1 lite-550 (Android 13; SDK 33; x86_64; Google Pixel 5; ru)",
      },
    ),
  );

  const url = 'https://api.vk.com/method/users.get';
  final params = {
    'access_token': accessToken,
    'v': '5.131',
    'fields': 'photo_200',
  };

  try {
    final response = await dio.get(url, queryParameters: params);

    if (response.statusCode == 200) {
      final data = response.data['response'];
      if (data != null && data.isNotEmpty) {
        return data[0]['photo_200'];
      }
    } else {
      print('Failed to load VK user avatar: ${response.statusMessage}');
    }
  } catch (e) {
    print('Error: $e');
  }
  return null;
}