import 'package:all_in_music/api/spotify_api/spotify_api.dart';
import 'package:all_in_music/components/custom_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:go_router/go_router.dart';

class SpotifyLoginPage extends StatelessWidget {
  final String clientId;
  final String clientSecret;
  final String redirectUri;
  const SpotifyLoginPage({super.key, required this.clientId, required this.redirectUri, required this.clientSecret});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        leading: IconButton(
          icon: const Icon(Icons.chevron_left),
          onPressed: (){context.pop();},
        ),
        title: 'Spotify auth',
      ),
      body: SafeArea(
        child: InAppWebView(
          initialUrlRequest: URLRequest(
            url: WebUri(getSpotifyAuthUrl(clientId, redirectUri)),
          ),
          onLoadStop: (InAppWebViewController controller, WebUri? action) async {
            if (action == null) {
              return;
            }
            String url = action.toString();
            if (!url.startsWith(redirectUri)) {
              return;
            }
            String? authCode = Uri.parse(url).queryParameters['code'];
            if (authCode == null) {
              showDialog(
                context: context, 
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text('Unable to auth'),
                    actions: [
                      TextButton(onPressed: (){context.pop();}, child: const Text('OK'))
                    ],
                  );
                }
              );
              return;
            }
            String? accessToken = await getAccessToken(clientId, clientSecret, authCode, redirectUri);
            if (accessToken == null) {
              showDialog(
                context: context, 
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text('Unable to auth'),
                    actions: [
                      TextButton(onPressed: (){context.pop();}, child: const Text('OK'))
                    ],
                  );
                }
              );
              return;
            }
            
            final tracks = await getFavoriteTracks(accessToken);
            context.pop(tracks);
          },
        ),
      )
    );
  }
}