import 'package:audio_player/services/playlist_repository.dart';
import 'package:audio_player/services/service_locator.dart';
import 'package:audio_service/audio_service.dart';
import 'package:flutter/cupertino.dart';
// import 'package:just_audio/just_audio.dart';

class PageManager {
  final _audioHandler = getIt<AudioHandler>();
  final progressNotifier = ValueNotifier<ProgressBarState>(
    ProgressBarState(
      current: Duration.zero,
      loading: Duration.zero,
      total: Duration.zero,
    ),
  );
  final buttonNotifier = ValueNotifier(ButtonState.paused);
  final currentSongDetailNotifier =
      ValueNotifier<MediaItem>(const MediaItem(id: '-1', title: ''));
  final playListNotifier = ValueNotifier<List<MediaItem>>([]);
  final isFirstSongNotifier = ValueNotifier<bool>(true);
  final isLastSongNotifier = ValueNotifier<bool>(false);
  final repeatStateNotifier = RepeatStateNotifier();
  final volumeStateNotifier = VolumeStateNotifier();

  // late ConcatenatingAudioSource _playList;

  void _init() async {
    _loadPlaylist();
    _listenChangeInPlaylist();
    _listenToCurrentSong();
    _listenToCurrentPosition();
    _listenToBufferedPosition();
    _listenToTotalPosition();
    _listenToPlaybackState();
    // _setInitialPlayList();
    // _listenChangePlayerState();
    // _listenChangeBufferedStream();
    // _listenChangePositionStream();
    // _listenChangeTotalDurationStream();
    // _listenChangeInSequenceState();
  }

  Future _loadPlaylist() async {
    final songRepository = getIt<PlaylistRepository>();
    final playlist = await songRepository.fetchMyPlaylist();
    final mediaItems = playlist
        .map(
          (song) => MediaItem(
            id: song['id'] ?? '',
            title: song['title'] ?? '',
            artist: song['artist'],
            artUri: Uri.parse(song['artUri'] ?? ''),
            extras: {'url': song['url']},
          ),
        )
        .toList();
    _audioHandler.addQueueItems(mediaItems);
  }

  _listenChangeInPlaylist() {
    _audioHandler.queue.listen((playlist) {
      if (playlist.isEmpty) {
        return;
      } //
      else {
        final newList = playlist.map((item) => item).toList();
        playListNotifier.value = newList;
      }
    });
  }

  void _listenToPlaybackState() {
    _audioHandler.playbackState.listen((playbackState) {
      final isPlaying = playbackState.playing;
      final processingState = playbackState.processingState;
      if (processingState == AudioProcessingState.loading ||
          processingState == AudioProcessingState.buffering) {
        buttonNotifier.value = ButtonState.loading;
      } //
      else if (!isPlaying) {
        buttonNotifier.value = ButtonState.paused;
      } //
      else if (processingState != AudioProcessingState.completed) {
        buttonNotifier.value = ButtonState.playing;
      } //
      else {
        _audioHandler.seek(Duration.zero);
        _audioHandler.pause();
      }
    });
  }

  _listenToCurrentSong() {
    _audioHandler.mediaItem.listen((mediaItem) {
      final playlist = _audioHandler.queue.value;
      currentSongDetailNotifier.value =
          mediaItem ?? const MediaItem(id: '-1', title: '');
      if (playlist.isEmpty || mediaItem == null) {
        isFirstSongNotifier.value = true;
        isLastSongNotifier.value = true;
      } //
      else {
        isFirstSongNotifier.value = playlist.first == mediaItem;
        isLastSongNotifier.value = playlist.last == mediaItem;
      }
    });
  }

  _listenToCurrentPosition() {
    AudioService.position.listen((position) {
      final oldState = progressNotifier.value;
      progressNotifier.value = ProgressBarState(
        current: position,
        loading: oldState.loading,
        total: oldState.total,
      );
    });
  }

  _listenToBufferedPosition() {
    _audioHandler.playbackState.listen((playbackState) {
      final oldState = progressNotifier.value;
      progressNotifier.value = ProgressBarState(
        current: oldState.current,
        loading: playbackState.bufferedPosition,
        total: oldState.total,
      );
    });
  }

  _listenToTotalPosition() {
    _audioHandler.mediaItem.listen((mediaItem) {
      final oldState = progressNotifier.value;
      progressNotifier.value = ProgressBarState(
        current: oldState.current,
        loading: oldState.loading,
        total: mediaItem?.duration??Duration.zero,
      );
    });
  }

  // void _setInitialPlayList() async {
  //   // final song1 = Uri.parse(
  //   //     'https://media-vip.my-pishvaz.com/musicfa/tagdl/ali/Behnam%20Bani%20-%202ta%20Dele%20Ashegh%20(320).mp3?st=cej_8MLrkmv_TKOImCvjpA&e=1701273730');
  //   // final song2 = Uri.parse(
  //   //     'https://dl.naslmusic.ir/music/1401/01/Shadmehr%20Aghili%20-%20Bi%20Ehsas%20(320-Naslemusic).mp3');
  //   // final song3 = Uri.parse(
  //   //     'https://dl.rozmusic.com/Music/1402/07/11/Ali%20Yasini%20-%20Mirese%20Khabara.mp3');
  //   // final song4 = Uri.parse(
  //   //     'https://media-vip.my-pishvaz.com/musicfa/tagdl/downloads/Garsha%20Rezaei%20-%20Darya%20Nemiram%20(320).mp3?st=cMGpGFHyxNMltyyaDZVzxQ&e=1701522543');
  //   // _playList = ConcatenatingAudioSource(children: [
  //   //   AudioSource.uri(song1,
  //   //       tag: AudioMetaData(
  //   //           title: 'Dota Del Ashegh',
  //   //           artist: 'Behnam Bani',
  //   //           imageAddress: 'assets/images/bani.jpg')),
  //   //   AudioSource.uri(song2,
  //   //       tag: AudioMetaData(
  //   //           title: 'Bi Ehsas',
  //   //           artist: 'Shadmehr Aghili',
  //   //           imageAddress: 'assets/images/shadmehr.jpg')),
  //   //   AudioSource.uri(song3,
  //   //       tag: AudioMetaData(
  //   //           title: 'Mirese Khabara',
  //   //           artist: 'Ali Yasini',
  //   //           imageAddress: 'assets/images/aliyasini.jpg')),
  //   //   AudioSource.uri(song4,
  //   //       tag: AudioMetaData(
  //   //           title: 'Darya Nemiram',
  //   //           artist: 'Garsha Rezaei',
  //   //           imageAddress: 'assets/images/garsha.jpg')),
  //   // ]);
  //   if (_audioPlayer.bufferedPosition == Duration.zero) {
  //     _audioPlayer.setAudioSource(_playList);
  //   }
  // }
  //
  // void _listenChangePlayerState() {
  //   _audioPlayer.playerStateStream.listen((playerState) {
  //     final playing = playerState.playing;
  //     final processingState = playerState.processingState;
  //     if (processingState == ProcessingState.loading ||
  //         processingState == ProcessingState.buffering) {
  //       buttonNotifier.value = ButtonState.loading;
  //     } //
  //     else if (!playing) {
  //       buttonNotifier.value = ButtonState.paused;
  //     } //
  //     else {
  //       buttonNotifier.value = ButtonState.playing;
  //     }
  //   });
  // }
  //
  // void _listenChangePositionStream() {
  //   _audioPlayer.positionStream.listen((position) {
  //     final oldState = progressNotifier.value;
  //     progressNotifier.value = ProgressBarState(
  //       current: position,
  //       loading: oldState.loading,
  //       total: oldState.total,
  //     );
  //   });
  // }
  //
  // void _listenChangeBufferedStream() {
  //   _audioPlayer.bufferedPositionStream.listen((position) {
  //     final oldState = progressNotifier.value;
  //     progressNotifier.value = ProgressBarState(
  //       current: oldState.current,
  //       loading: position,
  //       total: oldState.total,
  //     );
  //   });
  // }
  //
  // void _listenChangeTotalDurationStream() {
  //   _audioPlayer.durationStream.listen((position) {
  //     final oldState = progressNotifier.value;
  //     progressNotifier.value = ProgressBarState(
  //       current: oldState.current,
  //       loading: oldState.loading,
  //       total: position ?? Duration.zero,
  //     );
  //   });
  // }
  //
  // void _listenChangeInSequenceState() {
  //   _audioPlayer.sequenceStateStream.listen((sequenceState) {
  //     if (sequenceState == null) {
  //       return;
  //     }
  //     final currentItem = sequenceState.currentSource;
  //     final song = currentItem!.tag as AudioMetaData;
  //     currentSongDetailNotifier.value = song;
  //     final playList = sequenceState.effectiveSequence;
  //     final title = playList.map((song) {
  //       return song.tag as AudioMetaData;
  //     }).toList();
  //     playListNotifier.value = title;
  //
  //     if (playList.isEmpty || currentItem == null) {
  //       isFirstSongNotifier.value = true;
  //       isLastSongNotifier.value = true;
  //     } //
  //     else {
  //       isFirstSongNotifier.value = playList.first == currentItem;
  //       isLastSongNotifier.value = playList.last == currentItem;
  //     }
  //
  //     if (_audioPlayer.volume > 0.6) {
  //       volumeStateNotifier.value = volumeState.on;
  //     } //
  //     else if (_audioPlayer.volume > 0) {
  //       volumeStateNotifier.value = volumeState.half;
  //     } //
  //     else {
  //       volumeStateNotifier.value = volumeState.off;
  //     }
  //   });
  // }

  void onVolumePressed() {
    volumeStateNotifier.nextState();
    if (volumeStateNotifier.value == volumeState.on) {
      _audioHandler.androidSetRemoteVolume(2);
    } //
    else if (volumeStateNotifier.value == volumeState.half) {
      _audioHandler.androidSetRemoteVolume(1);
    } //
    else {
      _audioHandler.androidSetRemoteVolume(0);
    }
  }

  void pause() {
    _audioHandler.pause();
  }

  void play() async {
    _audioHandler.play();
  }

  void seek(position) {
    _audioHandler.seek(position);
  }

  void nextMusic() {
    _audioHandler.skipToNext();
  }

  void previousMusic() {
    _audioHandler.skipToPrevious();
  }

  void playInHomeScreen(int index) {
    _audioHandler.skipToQueueItem(index);
  }

  void onRepeatPressed() {
    repeatStateNotifier.nextState();
    if (repeatStateNotifier.value == repeatState.off) {
      _audioHandler.setRepeatMode(AudioServiceRepeatMode.none);
    } //
    else if (repeatStateNotifier.value == repeatState.one) {
      _audioHandler.setRepeatMode(AudioServiceRepeatMode.one);
    } //
    else {
      _audioHandler.setRepeatMode(AudioServiceRepeatMode.all);
    }
  }

  PageManager() {
    _init();
  }
}

// class AudioMetaData {
//   final String title;
//   final String artist;
//   final String imageAddress;
//
//   AudioMetaData(
//       {required this.title, required this.artist, required this.imageAddress});
// }

class ProgressBarState {
  final Duration current;
  final Duration loading;
  final Duration total;

  ProgressBarState(
      {required this.current, required this.loading, required this.total});
}

enum ButtonState { paused, loading, playing }

// ignore: camel_case_types
enum repeatState { one, random, off }

// ignore: camel_case_types
enum volumeState { on, half, off }

class RepeatStateNotifier extends ValueNotifier<repeatState> {
  RepeatStateNotifier() : super(_initialValue);
  static const _initialValue = repeatState.off;

  void nextState() {
    var next = (value.index + 1) % repeatState.values.length;
    value = repeatState.values[next];
  }
}

class VolumeStateNotifier extends ValueNotifier<volumeState> {
  VolumeStateNotifier() : super(_initialValue);
  static const _initialValue = volumeState.on;

  void nextState() {
    var next = (value.index + 1) % volumeState.values.length;
    value = volumeState.values[next];
  }
}
