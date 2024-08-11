import 'package:all_in_music/models/audio_model.dart';
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

Future<List<Audio>> getFavoriteTracks(String accessToken) async {
  final dio = Dio();
  List<Audio> allTracks = [];
  String url = 'https://api.spotify.com/v1/me/tracks';
  int limit = 50;
  int maxRetries = 3;

  Future<Response?> fetchWithRetry(String url, Map<String, dynamic> queryParameters) async {
    int retryCount = 0;
    while (retryCount < maxRetries) {
      try {
        final response = await dio.get(
          url,
          queryParameters: queryParameters,
          options: Options(
            headers: {
              'Authorization': 'Bearer $accessToken',
            },
          ),
        );
        return response;
      } catch (e) {
        if (e is DioException && (e.response?.statusCode == 401 || e.response?.statusCode == 429)) {
          print('Authentication error or rate limit exceeded, retrying...');
          retryCount++;
          await Future.delayed(Duration(seconds: 2 * retryCount));
        } else {
          print('Error fetching tracks: $e');
          break;
        }
      }
    }
    return null;
  }

  final initialResponse = await fetchWithRetry(url, {'limit': 1, 'offset': 0});
  if (initialResponse == null || initialResponse.statusCode != 200) {
    return [];
  }

  int totalTracks = initialResponse.data['total'];
  int numRequests = (totalTracks / limit).ceil();

  List<Future<Response?>> futures = [];
  for (int i = 0; i < numRequests; i++) {
    futures.add(fetchWithRetry(url, {'limit': limit, 'offset': i*limit}));
  }
  List<Response?> responses = await Future.wait(futures);
  for (var response in responses) {
    if (response != null && response.statusCode == 200) {
      final List<dynamic> items = response.data['items'];
      List<Audio> tracks = items.map((json) => audioFromSpotify(json)).toList();
      allTracks.addAll(tracks);
    } else {
      print('Skipping response due to error');
    }
  }

  return allTracks;
}