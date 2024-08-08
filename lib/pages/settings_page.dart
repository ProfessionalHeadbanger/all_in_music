import 'package:all_in_music/api/vk_api/models/audio_model.dart';
import 'package:all_in_music/components/auth_button.dart';
import 'package:all_in_music/components/custom_app_bar.dart';
import 'package:all_in_music/providers/audio_provider.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Settings',
      ),
      body: Column(
        children: [
          Center(
            child: Column(
              children: [
                const SizedBox(height: 10,),
                const Text('Services Auth'),
                const SizedBox(height: 10,),
                AuthButton(
                  label: 'Spotify', 
                  onPressed: (){}
                ),
                const SizedBox(height: 10,),
                AuthButton(
                  label: 'VK Music', 
                  onPressed: () async {
                    final result = await context.push('/settings/vk-auth') as List<Audio>?;
                    if (result != null) {
                      context.read<AudioProvider>().updateAudioList(result);
                    }
                  }
                ),
                const SizedBox(height: 10,),
                AuthButton(
                  label: 'Yandex Music', 
                  onPressed: (){}
                ),
                const SizedBox(height: 40,),
              ],
            ),
          ),
          const Column(
            children: [
              Text('Services Order'),
            ],
          )
        ],
      ),
    );
  }
}