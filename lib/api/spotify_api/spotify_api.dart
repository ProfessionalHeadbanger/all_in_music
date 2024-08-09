import 'package:dio/dio.dart';

String getSpotifyAuthUrl(String clientId, String redirectUri) {
  return "https://accounts.spotify.com/authorize"
  "?response_type=code"
  "&client_id=$clientId"
  "&scope=user-library-read"
  "&redirect_uri=$redirectUri";
}

Future<String?> getAccessToken(String clientId, String clientSecret, String authCode, String redirectUri) async {
  final dio = Dio();
  
  final response = await dio.post(
    'https://accounts.spotify.com/api/token',
    data: {
      'grant_type': 'authorization_code',
      'code': authCode,
      'redirect_uri': redirectUri,
      'client_id': clientId,
      'client_secret': clientSecret,
    },
    options: Options(
      contentType: Headers.formUrlEncodedContentType,
    ),
  );

  if (response.statusCode == 200) {
    return response.data['access_token'];
  }
  else {
    return null;
  }
}

Future<List<dynamic>> getFavoriteTracks(String accessToken) async {
  final dio = Dio();
  List<dynamic> allTracks = [];
  String url = 'https://api.spotify.com/v1/me/tracks';
  int limit = 50;
  int offset = 0;

  while (true)
  {
    final response = await dio.get(
      url,
      queryParameters: {
        'limit': limit,
        'offset': offset,
      },
      options: Options(
        headers: {
          'Authorization': 'Bearer $accessToken',
        },
      ),
    );

    if (response.statusCode == 200) {
      final items = response.data['items'];
      allTracks.addAll(items);
      if (response.data['next'] == null) {
        break;
      }
      offset += limit;
    }
    else {
      print('Error fetching tracks: ${response.statusMessage}');
      break;
    }
  }

  return allTracks;
}