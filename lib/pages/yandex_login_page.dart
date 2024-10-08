import 'package:all_in_music/api/yandex_api/yandex_api.dart';
import 'package:all_in_music/assets/app_vectors.dart';
import 'package:all_in_music/components/custom_app_bar.dart';
import 'package:all_in_music/providers/auth_provider.dart';
import 'package:all_in_music/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class YandexLoginPage extends StatefulWidget {
  const YandexLoginPage({super.key});

  @override
  State<YandexLoginPage> createState() => _YandexLoginPageState();
}

class _YandexLoginPageState extends State<YandexLoginPage> {
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        leading: IconButton(
          icon: SvgPicture.asset(
                  AppVectors.chevronLeft,
                  color: AppColors.primaryIcon,
                  width: 21,
                  height: 21,
                ), 
          onPressed: (){context.pop();},
        ),
        title: 'Yandex auth',
      ),
      body: SafeArea(
        child: isLoading
        ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Loading, don\'t close this window', style: TextStyle(fontSize: 18),),
                  SizedBox(height: 10,),
                  CircularProgressIndicator(),
                ],
              )
            )
        : InAppWebView(
          initialUrlRequest: URLRequest(
            url: WebUri("https://oauth.yandex.ru/authorize?response_type=token&client_id=23cabbbdc6cd418abb4b39c32c41195d"),
          ),
          shouldOverrideUrlLoading: (controller, navigationAction) async {
            String url = navigationAction.request.url.toString();
            String? token = extractAccessTokenYandex(url);
            if (token != null) {
              setState(() {
                isLoading = true;
              });
              context.read<AuthProvider>().setYandexAccessToken(token);
              final userId = await getYandexUserId(token);
              final tracks = await getYandexFavorites(token, userId!);
              if (mounted) {
                context.pop(tracks);
              }
              return NavigationActionPolicy.CANCEL;
            }
            return NavigationActionPolicy.ALLOW;
          },
        )
      ),
    );
  }
}