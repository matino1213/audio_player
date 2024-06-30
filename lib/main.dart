import 'package:audio_player/controllers/page_manager.dart';
import 'package:audio_player/screens/home_screen.dart';
import 'package:audio_player/screens/music_player_screen.dart';
import 'package:audio_player/services/service_locator.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

void main() async {
  await setupInitService();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  AudioPlayer audioPlayer = AudioPlayer();
  PageController controller = PageController(initialPage: 0);

  PageManager get _pageManager => PageManager();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(fontFamily: 'Ubuntu'),
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFF3D0050),
                Color(0xFF70026F),
                Color(0xFF3D0050),
                Color(0xFF3D0050),
                Color(0xFF3D0050),
                Color(0xFF70026F),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter
            ),
          ),
          child: PageView(
            controller: controller,
            scrollDirection: Axis.vertical,
            children: [
              HomeScreen(_pageManager, controller),
              WillPopScope(
                  onWillPop: () async {
                    controller.animateToPage(0,
                        duration: const Duration(milliseconds: 800),
                        curve: Curves.bounceOut);
                    return false;
                  },
                  child: MusicPlayerScreen(controller, _pageManager)),
            ],
          ),
        ),
      ),
    );
  }
}
