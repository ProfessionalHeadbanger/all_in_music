import 'package:all_in_music/api/vk_api/models/audio_model.dart';
import 'package:all_in_music/components/custom_app_bar.dart';
import 'package:all_in_music/api/vk_api/vk_api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:go_router/go_router.dart';

class VkLoginPage extends StatelessWidget {
  const VkLoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        leading: IconButton(
          icon: const Icon(Icons.chevron_left), 
          onPressed: (){context.pop();},
        ),
        title: 'VK auth',
      ),
      body: SafeArea(
        child: InAppWebView(
          initialUrlRequest: URLRequest(
            url: WebUri("https://oauth.vk.com/authorize?client_id=2685278&scope=69634&redirect_uri=https://oauth.vk.com/blank.html&display=page&response_type=token&revoke=1"),
          ),
          onLoadStop: (InAppWebViewController controller, WebUri? action) async {
            if (action == null) {
              return;
            }
            String url = action.toString();
            if (!url.startsWith("https://oauth.vk.com/blank.html")) {
              return;
            }
            String? token = extractAccessToken(url);
            print(token);
            if (token == null) {
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

            List<Audio> audioList = await fetchAudio(token);
            context.pop(audioList);
          },
        )
      ),
    );
  }
}