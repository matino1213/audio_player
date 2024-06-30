import 'dart:ui';

import 'package:audio_service/audio_service.dart';
import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../controllers/page_manager.dart';

// ignore: must_be_immutable
class MusicPlayerScreen extends StatelessWidget {
  MusicPlayerScreen(this.controller, this._pageManager, {super.key});

  final PageController controller;
  final PageManager _pageManager;
  late Size size;

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
    return Stack(
      children: [
        ValueListenableBuilder(
          valueListenable: _pageManager.currentSongDetailNotifier,
          builder: (context, MediaItem value, child) {
            if (value.id == '-1') {
              return SizedBox(
                height: size.height,
                width: size.width,
                child: Image.asset(
                  'assets/images/default.jpg',
                  fit: BoxFit.cover,
                ),
              );
            } //
            else {
              String image = value.artUri.toString();
              return SizedBox(
                  height: size.height,
                  width: size.width,
                  child: FadeInImage(
                    placeholder: const AssetImage('assets/images/default.jpg'),
                    image: NetworkImage(image),
                    fit: BoxFit.cover,
                  ));
            }
          },
        ),
        BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
          child: Container(
            color: Colors.black26,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Column(
                  children: [
                    const SizedBox(
                      height: 10,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          onPressed: () {
                            controller.animateToPage(0,
                                duration: const Duration(milliseconds: 800),
                                curve: Curves.bounceOut);
                          },
                          icon: const Icon(
                            Icons.arrow_back_outlined,
                            color: Colors.white,
                          ),
                        ),
                        const Text(
                          'Now playing',
                          style: TextStyle(color: Colors.white, fontSize: 30),
                        ),
                        IconButton(
                          onPressed: () {},
                          icon: const Icon(
                            Icons.menu,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 60,
                    ),
                    ValueListenableBuilder(
                      valueListenable: _pageManager.currentSongDetailNotifier,
                      builder: (context, MediaItem value, child) {
                        if (value.id == '-1') {
                          return const CircleAvatar(
                            radius: 150,
                            backgroundImage:
                                AssetImage('assets/images/default.jpg'),
                          );
                        } //
                        else {
                          String image = value.artUri.toString();
                          return CircleAvatar(
                            radius: 150,
                            backgroundImage: const AssetImage('assets/images/default.jpg'),
                            // backgroundImage: NetworkImage(image),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(200),
                              child: FadeInImage(
                                placeholder:
                                    const AssetImage('assets/images/default.jpg'),
                                image: NetworkImage(image),
                              ),
                            ),
                          );
                        }
                      },
                    ),
                    const SizedBox(
                      height: 80,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          ValueListenableBuilder(
                            valueListenable:
                                _pageManager.currentSongDetailNotifier,
                            builder: (context, MediaItem value, child) {
                              String title = value.title;
                              String artist = value.artist ?? '';
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    artist,
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 35,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    title,
                                    style: const TextStyle(
                                        color: Colors.grey, fontSize: 20),
                                  ),
                                ],
                              );
                            },
                          ),
                          IconButton(
                              onPressed: () {},
                              icon: const Icon(
                                CupertinoIcons.heart_fill,
                                color: Colors.white,
                                size: 35,
                              ))
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: ValueListenableBuilder<ProgressBarState>(
                          valueListenable: _pageManager.progressNotifier,
                          builder: (context, value, _) {
                            return ProgressBar(
                              progress: value.current,
                              total: value.total,
                              buffered: value.loading,
                              thumbColor: Colors.white,
                              progressBarColor: Colors.redAccent,
                              thumbGlowColor: Colors.white24,
                              baseBarColor: Colors.grey,
                              bufferedBarColor:
                                  Colors.redAccent.withOpacity(0.3),
                              onSeek: _pageManager.seek,
                              timeLabelTextStyle: const TextStyle(
                                  color: Colors.white, fontSize: 16),
                            );
                          },
                        )),
                    const SizedBox(
                      height: 20,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          ValueListenableBuilder(
                            valueListenable: _pageManager.repeatStateNotifier,
                            builder: (context, value, child) {
                              switch (value) {
                                case repeatState.off:
                                  return IconButton(
                                    onPressed: _pageManager.onRepeatPressed,
                                    icon: const Icon(
                                      CupertinoIcons.repeat,
                                      color: Colors.white,
                                      size: 30,
                                    ),
                                  );
                                case repeatState.one:
                                  return IconButton(
                                    onPressed: _pageManager.onRepeatPressed,
                                    icon: const Icon(
                                      CupertinoIcons.repeat_1,
                                      color: Colors.white,
                                      size: 30,
                                    ),
                                  );
                                case repeatState.random:
                                  return IconButton(
                                    onPressed: _pageManager.onRepeatPressed,
                                    icon: const Icon(
                                      CupertinoIcons.shuffle,
                                      color: Colors.white,
                                      size: 30,
                                    ),
                                  );
                              }
                            },
                          ),
                          ValueListenableBuilder(
                            valueListenable: _pageManager.isFirstSongNotifier,
                            builder: (context, bool value, child) => IconButton(
                              icon: const Icon(
                                Icons.skip_previous,
                                color: Colors.white,
                                size: 30,
                              ),
                              onPressed:
                                  value ? null : _pageManager.previousMusic,
                            ),
                          ),
                          InkWell(
                            onTap: () {},
                            child: Container(
                              height: 70,
                              width: 70,
                              decoration: BoxDecoration(
                                borderRadius:
                                    const BorderRadius.all(Radius.circular(40)),
                                gradient: LinearGradient(
                                    colors: [
                                      Colors.redAccent.withOpacity(0.8),
                                      Colors.black12
                                    ],
                                    begin: Alignment.bottomRight,
                                    end: Alignment.topLeft),
                              ),
                              child: Center(
                                  child: ValueListenableBuilder<ButtonState>(
                                valueListenable: _pageManager.buttonNotifier,
                                builder: (context, ButtonState value, _) {
                                  switch (value) {
                                    case ButtonState.loading:
                                      return const CircularProgressIndicator(
                                        color: Colors.white,
                                      );
                                    case ButtonState.paused:
                                      return IconButton(
                                        icon: const Icon(
                                          CupertinoIcons.play_arrow_solid,
                                          color: Colors.white,
                                          size: 30,
                                        ),
                                        onPressed: _pageManager.play,
                                      );
                                    case ButtonState.playing:
                                      return IconButton(
                                        icon: const Icon(
                                          Icons.pause,
                                          color: Colors.white,
                                          size: 30,
                                        ),
                                        onPressed: _pageManager.pause,
                                      );
                                  }
                                },
                              )),
                            ),
                          ),
                          ValueListenableBuilder(
                            valueListenable: _pageManager.isLastSongNotifier,
                            builder: (context, bool value, child) => IconButton(
                              onPressed: value ? null : _pageManager.nextMusic,
                              icon: const Icon(
                                Icons.skip_next,
                                color: Colors.white,
                                size: 30,
                              ),
                            ),
                          ),
                          ValueListenableBuilder(
                            valueListenable: _pageManager.volumeStateNotifier,
                            builder: (context, value, child) {
                              if (value == volumeState.on) {
                                return IconButton(
                                  onPressed: _pageManager.onVolumePressed,
                                  icon: const Icon(
                                    Icons.volume_up,
                                    color: Colors.white,
                                    size: 30,
                                  ),
                                );
                              } //
                              else if (value == volumeState.half) {
                                return IconButton(
                                  onPressed: _pageManager.onVolumePressed,
                                  icon: const Icon(
                                    Icons.volume_down,
                                    color: Colors.white,
                                    size: 30,
                                  ),
                                );
                              } //
                              else {
                                return IconButton(
                                  onPressed: _pageManager.onVolumePressed,
                                  icon: const Icon(
                                    Icons.volume_off,
                                    color: Colors.white,
                                    size: 30,
                                  ),
                                );
                              }
                            },
                          )
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
