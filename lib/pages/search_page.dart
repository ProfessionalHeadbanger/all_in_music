import 'package:all_in_music/components/custom_app_bar.dart';
import 'package:all_in_music/components/mini_player.dart';
import 'package:all_in_music/components/song_tile.dart';
import 'package:all_in_music/models/audio_model.dart';
import 'package:all_in_music/providers/audio_provider.dart';
import 'package:all_in_music/providers/current_audio_provider.dart';
import 'package:all_in_music/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  String _searchQuery = '';
  List<Audio> _searchResults = [];
  List<Audio> _audioList = [];

  @override
  void initState() {
    super.initState();
    _loadAudioList();
  }

  Future<void> _loadAudioList() async {
    await context.read<AudioProvider>().loadTracksFromStorage();
    setState(() {
      _audioList = context.read<AudioProvider>().audioList;
    });
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
      _searchResults = _performSearch(query);
    });
  }

  List<Audio> _performSearch(String query) {
    return _searchQuery.isEmpty
    ? []
    : _audioList.where((audio) => audio.title.toLowerCase().contains(query.toLowerCase()) 
    || audio.artist.toLowerCase().contains(query.toLowerCase())).toList();
  }

  void _onSongSelected(Audio audio) {
    context.read<CurrentAudioProvider>().setAudio(audio);
    context.read<CurrentAudioProvider>().playAudio(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Search',
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: TextField(
                  onChanged: _onSearchChanged,
                  style: const TextStyle(color: AppColors.primary),
                  decoration: InputDecoration(
                    hintText: 'Enter artist or song title...',
                    hintStyle: const TextStyle(color: AppColors.primary),
                    fillColor: AppColors.searchBar,
                    filled: true,
                    suffixIcon: const Icon(Icons.search, color: AppColors.primary,),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                  ),
                ),
              ),
              const SizedBox(height: 10,),
              Expanded(
                child: _searchResults.isEmpty && _searchQuery.isNotEmpty 
                  ? const Center(child: Text('No results found'),)
                  : ListView.builder(
                  itemCount: _searchResults.length,
                  itemBuilder: (context, index) {
                    final audio = _searchResults[index];
                    return SongTile(
                      title: audio.title, 
                      artist: audio.artist, 
                      duration: audio.duration, 
                      sources: audio.sources, 
                      coverUrl: audio.coverUrl,
                      onTap: () => _onSongSelected(audio),
                    );
                  },
                ),
              ),
            ],
          ),
          if (context.watch<CurrentAudioProvider>().currentAudio != null) Align(
            alignment: Alignment.bottomCenter,
            child: MiniPlayer(
              audio: context.watch<CurrentAudioProvider>().currentAudio!,
              audioPlayer: context.watch<CurrentAudioProvider>().audioPlayer!,
              onTap: () {
                context.push('/player');
              },
            ),
          ),
        ], 
      ),
    );
  }
}