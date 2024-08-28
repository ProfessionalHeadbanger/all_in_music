import 'package:all_in_music/assets/app_vectors.dart';
import 'package:all_in_music/models/audio_model.dart';
import 'package:all_in_music/components/custom_app_bar.dart';
import 'package:all_in_music/api/vk_api/vk_api.dart';
import 'package:all_in_music/providers/auth_provider.dart';
import 'package:all_in_music/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class VkLoginPage extends StatefulWidget {
  const VkLoginPage({super.key});

  @override
  State<VkLoginPage> createState() => _VkLoginPageState();
}

class _VkLoginPageState extends State<VkLoginPage> {
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
            String? token = extractAccessTokenVK(url);
            if (token == null) {
              return;
            }
            else {
              context.read<AuthProvider>().setVkAccessToken(token);
              List<Audio> audioList = await fetchAudio(token);
              if (mounted) {
                context.pop(audioList);
              }
            }
          },
        )
      ),
    );
  }
}