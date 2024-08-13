import 'package:all_in_music/api/yandex_api/yandex_api.dart';
import 'package:all_in_music/components/custom_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:go_router/go_router.dart';

class YandexLoginPage extends StatefulWidget {
  const YandexLoginPage({super.key});

  @override
  State<YandexLoginPage> createState() => _YandexLoginPageState();
}

class _YandexLoginPageState extends State<YandexLoginPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        leading: IconButton(
          icon: const Icon(Icons.chevron_left), 
          onPressed: (){context.pop();},
        ),
        title: 'Yandex auth',
      ),
      body: SafeArea(
        child: InAppWebView(
          initialUrlRequest: URLRequest(
            url: WebUri("https://oauth.yandex.ru/authorize?response_type=token&client_id=23cabbbdc6cd418abb4b39c32c41195d"),
          ),
          onLoadStop: (InAppWebViewController controller, WebUri? action) async {
            if (action == null) {
              return;
            }
            String url = action.toString();
            String? token = extractAccessTokenYandex(url);
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
            final userId = await getYandexUserId(token);
            final tracks = await getYandexFavorites(token, userId!);

            if (mounted) {
              context.pop(tracks);
            }
          },
        )
      ),
    );
  }
}