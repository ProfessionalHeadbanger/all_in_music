import 'package:all_in_music/components/auth_button.dart';
import 'package:all_in_music/components/custom_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_login_vk/flutter_login_vk.dart';

class SettingsPage extends StatefulWidget {
  SettingsPage({super.key});

  final plugin = VKLogin(debug: true);

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {

  String? _sdkVersion;
  VKAccessToken? _token;
  VKUserProfile? _profile;
  String? _email;
  bool _sdkInitialized = false;

  @override
  void initState() {
    super.initState();

    _getSdkVersion();
    _initSdk();
  }

  Future<void> _onPressedLogInButton(BuildContext context) async {
    final res = await widget.plugin.logIn(scope: [
      VKScope.email,
    ]);

    if (res.isError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Log In failed: ${res.asError!.error}'),
        ),
      );
    } else {
      final loginResult = res.asValue!.value;
      if (!loginResult.isCanceled) await _updateLoginInfo();
    }
  }

  Future<void> _onPressedLogOutButton() async {
    await widget.plugin.logOut();
    await _updateLoginInfo();
  }

  Future<void> _initSdk() async {
    await widget.plugin.initSdk();
    _sdkInitialized = true;
    await _updateLoginInfo();
  }

  Future<void> _getSdkVersion() async {
    final sdkVersion = await widget.plugin.sdkVersion;
    setState(() {
      _sdkVersion = sdkVersion;
    });
  }

  Future<void> _updateLoginInfo() async {
    if (!_sdkInitialized) return;

    final plugin = widget.plugin;
    final token = await plugin.accessToken;
    final profileRes = token != null ? await plugin.getUserProfile() : null;
    final email = token != null ? await plugin.getUserEmail() : null;

    setState(() {
      _token = token;
      _profile = profileRes?.asValue?.value;
      _email = email;
    });
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
                  onPressed: () => _onPressedLogInButton(context),
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