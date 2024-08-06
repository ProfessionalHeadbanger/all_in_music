import 'package:dio/dio.dart';

const String vkAPIallUserFields =
    "activities, about, blacklisted, blacklisted_by_me, books, bdate, can_be_invited_group, can_post, can_see_all_posts, can_see_audio, can_send_friend_request, can_write_private_message, career, common_count, connections, contacts, city, country, crop_photo, domain, education, exports, followers_count, friend_status, has_photo, has_mobile, home_town, photo_100, photo_200, photo_200_orig, photo_400_orig, photo_50, sex, site, schools, screen_name, status, verified, games, interests, is_favorite, is_friend, is_hidden_from_feed, last_seen, maiden_name, military, movies, music, nickname, occupation, online, personal, photo_id, photo_max, photo_max_orig, quotes, relation, relatives, timezone, tv, universities";

String? extractAccessToken(String input) {
  if (input.startsWith("vk1")) {
    return input;
  }

  Match? tokenMatch = RegExp(
    r"access_token=([^&]+)",
  ).firstMatch(
    input,
  );

  if (tokenMatch == null) return null;

  String token = tokenMatch.group(1).toString();

  if (!token.startsWith("vk1")) return null;

  return token;
}

Future<void> fetchAudio(String accessToken) async {
  final dio = Dio(
    BaseOptions(
      headers: {
        "User-Agent": "KateMobileAndroid/109.1 lite-550 (Android 13; SDK 33; x86_64; Google Pixel 5; ru)",
      }
    )
  );
  const url = 'https://api.vk.com/method/audio.get';
  final params = {'access_token' : accessToken, 'v' : '5.199'};

  try {
    final response = await dio.get(url, queryParameters: params);
    if (response.statusCode == 200) {
      final data = response.data;
      final List<dynamic> audioList = data['response']['items'];
      for (var audio in audioList) {
        print(audio);
      }
    }
    else {
      print('Failed to load audio: ${response.statusMessage}');
    }
  }
  catch (e) {
    print('Error: $e');
  }
}