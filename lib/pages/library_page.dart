import 'package:all_in_music/assets/app_vectors.dart';
import 'package:all_in_music/components/custom_app_bar.dart';
import 'package:all_in_music/components/filter_button.dart';
import 'package:all_in_music/components/song_tile.dart';
import 'package:all_in_music/providers/audio_provider.dart';
import 'package:all_in_music/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  @override
  Widget build(BuildContext context) {
    final audioList = context.watch<AudioProvider>().audioList;

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Your Library',
        actions: [
          IconButton(
            onPressed: (){}, 
            icon: SvgPicture.asset(
              AppVectors.sortIcon,
              color: AppColors.primaryIcon,
              width: 18,
              height: 18,
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                FilterButton(
                  label: 'Spotify',
                  onPressed: (){},
                ),
                FilterButton(
                  label: 'VK Music',
                  onPressed: (){},
                ),
                FilterButton(
                  label: 'Yandex Music',
                  onPressed: (){},
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: audioList.length,
              itemBuilder: (context, index) {
                final audio = audioList[index];
                return SongTile(title: audio.title, artist: audio.artist, duration: audio.duration, sources: audio.sources, coverUrl: audio.coverUrl,);
              },
            ),
          )
        ],
      ),
    );
  }
}