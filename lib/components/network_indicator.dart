import 'package:all_in_music/providers/network_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class NetworkIndicator extends StatelessWidget {
  const NetworkIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    final networkProvider = context.watch<NetworkProvider>();
    if (!networkProvider.isConnected) {
      return Align(
        alignment: Alignment.bottomCenter,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 20.0),
          child: Container(
            padding: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              'No internet connection',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
      );
    }
    return const SizedBox.shrink();
  }
}