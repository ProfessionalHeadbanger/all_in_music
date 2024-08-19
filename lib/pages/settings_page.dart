import 'package:all_in_music/api/vk_api/vk_api.dart';
import 'package:all_in_music/api/yandex_api/yandex_api.dart';
import 'package:all_in_music/models/audio_model.dart';
import 'package:all_in_music/components/auth_button.dart';
import 'package:all_in_music/components/custom_app_bar.dart';
import 'package:all_in_music/providers/audio_provider.dart';
import 'package:all_in_music/providers/auth_provider.dart';
import 'package:all_in_music/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  String? _vkAvatarUrl;
  String? _yandexAvatarUrl;

  Future<void> _checkAndFetchAvatars() async {
  final authProvider = Provider.of<AuthProvider>(context, listen: false);

  final vkToken = authProvider.vkAccessToken;
  final yandexToken = authProvider.yandexAccessToken;

  if (vkToken != null) {
    final vkAvatarUrl = await getVkUserAvatar(vkToken);
    if (vkAvatarUrl != null) {
      setState(() {
        _vkAvatarUrl = vkAvatarUrl;
      });
    }
  }

  if (yandexToken != null) {
    final yandexAvatarUrl = await getYandexUserAvatar(yandexToken);
    if (yandexAvatarUrl != null) {
      setState(() {
        _yandexAvatarUrl = yandexAvatarUrl;
      });
    }
  }
}

  @override
  void initState() {
    super.initState();
    _checkAndFetchAvatars();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Settings',
      ),
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          return Column(
            children: [
              Center(
                child: Column(
                  children: [
                    const SizedBox(height: 10,),
                    const Text('Services Auth'), 
                    const SizedBox(height: 10,),
                    AuthButton(
                      label: 'VK Music', 
                      iconPath: 'assets/images/vkLogo.png',
                      userAvatarUrl: _vkAvatarUrl,
                      buttonColor: AppColors.vkColor,
                      onPressed: () async {
                        final result = await context.push('/settings/vk-auth') as List<Audio>?;
                        if (result != null) {
                          context.read<AudioProvider>().updateAudioList(result);
                        }
                        _checkAndFetchAvatars();
                      }
                    ),
                    const SizedBox(height: 10,),
                    AuthButton(
                      label: 'Yandex Music', 
                      iconPath: 'assets/images/yandexMusicLogo.png',
                      userAvatarUrl: _yandexAvatarUrl,
                      buttonColor: AppColors.yandexColor,
                      onPressed: () async {
                        final result = await context.push('/settings/yandex-auth') as List<Audio>?;
                        if (result != null) {
                          context.read<AudioProvider>().updateAudioList(result);
                        }
                        _checkAndFetchAvatars();
                      }
                    ),
                    const SizedBox(height: 40,),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}