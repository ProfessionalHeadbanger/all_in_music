import 'package:all_in_music/components/auth_button.dart';
import 'package:all_in_music/components/custom_app_bar.dart';
import 'package:flutter/material.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

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
                  onPressed: (){}
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