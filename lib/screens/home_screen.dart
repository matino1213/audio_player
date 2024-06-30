import 'package:audio_player/controllers/page_manager.dart';
import 'package:audio_service/audio_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen(this._pageManager, this.controller, {super.key});

  final PageController controller;
  final PageManager _pageManager;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          Container(
            color: Colors.transparent,
            width: MediaQuery.of(context).size.width,
            height: 70,
            child: const Center(
              child: Text(
                'Playlist',
                style: TextStyle(fontSize: 25, color: Colors.white),
              ),
            ),
          ),
          Expanded(
            child: ValueListenableBuilder(
              valueListenable: _pageManager.playListNotifier,
              builder: (context, List<MediaItem> song, child) {
                if (song.isEmpty) {
                  return Container();
                } //
                else {
                  return ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    itemCount: song.length,
                    itemBuilder: (context, index) {
                      return Container(
                        margin: const EdgeInsets.all(1),
                        child: Card(
                          shadowColor: Colors.transparent,
                          shape: const Border(
                              top: BorderSide(color: Colors.white, width: 1)),
                          color: Colors.transparent,
                          child: ListTile(
                            tileColor: Colors.transparent,
                            title: Text(
                              song[index].title,
                              style: const TextStyle(color: Colors.white),
                            ),
                            subtitle: Text(
                              song[index].artist ?? '',
                              style: const TextStyle(color: Colors.grey),
                            ),
                            // leading: CircleAvatar(
                            //   radius: 20,
                            //   child: CircleAvatar(
                            //     radius: 18,
                            //     backgroundColor: Colors.white,
                            //     child: Text('${index + 1}'),
                            //   ),
                            // ),
                            onTap: () {
                              controller.animateToPage(1,
                                  duration: const Duration(milliseconds: 800),
                                  curve: Curves.bounceOut);
                              _pageManager.playInHomeScreen(index);
                            },
                          ),
                        ),
                      );
                    },
                  );
                }
              },
            ),
          ),
          ValueListenableBuilder(
            valueListenable: _pageManager.currentSongDetailNotifier,
            builder: (context, MediaItem audio, _) {
              if (audio.id == '-1') {
                return Container();
              } //
              else {
                return Container(
                  decoration: const BoxDecoration(
                    color: Colors.transparent,
                    border: Border(
                      top: BorderSide(color: Colors.white, width: 1),
                    ),
                  ),
                  child: ListTile(
                    onTap: () {
                      controller.animateToPage(1,
                          duration: const Duration(milliseconds: 800),
                          curve: Curves.bounceOut);
                    },
                    leading: CircleAvatar(
                      backgroundColor: Colors.transparent,
                      radius: 45,
                      backgroundImage: NetworkImage(audio.artUri.toString()),
                    ),
                    title: Text(
                      audio.title,
                      style: const TextStyle(color: Colors.white),
                    ),
                    subtitle: Text(
                      audio.artist ?? '',
                      style: const TextStyle(color: Colors.grey),
                    ),
                    trailing: Padding(
                        padding: const EdgeInsets.only(right: 20),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ValueListenableBuilder<ButtonState>(
                              valueListenable: _pageManager.buttonNotifier,
                              builder: (context, ButtonState value, _) {
                                switch (value) {
                                  case ButtonState.loading:
                                    return const CircularProgressIndicator(
                                      color: Colors.white,
                                    );
                                  case ButtonState.paused:
                                    return IconButton(
                                      padding: EdgeInsets.zero,
                                      icon: const Icon(
                                        CupertinoIcons.play_circle,
                                        color: Colors.white,
                                        size: 35,
                                      ),
                                      onPressed: _pageManager.play,
                                    );
                                  case ButtonState.playing:
                                    return IconButton(
                                      padding: EdgeInsets.zero,
                                      icon: const Icon(
                                        CupertinoIcons.pause_circle,
                                        color: Colors.white,
                                        size: 35,
                                      ),
                                      onPressed: _pageManager.pause,
                                    );
                                }
                              },
                            ),
                            ValueListenableBuilder(
                              valueListenable: _pageManager.isLastSongNotifier,
                              builder: (context, bool value, child) =>
                                  IconButton(
                                onPressed:
                                    value ? null : _pageManager.nextMusic,
                                icon: const Icon(
                                  Icons.skip_next_outlined,
                                  color: Colors.white,
                                  size: 30,
                                ),
                                padding: EdgeInsets.zero,
                              ),
                            ),
                          ],
                        )),
                  ),
                );
              }
            },
          )
        ],
      ),
    );
  }
}
