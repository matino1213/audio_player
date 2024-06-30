import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';

Future<AudioHandler> initAudioService() async {
  return await AudioService.init(
    builder: () => MyAudioHandler(),
    config: const AudioServiceConfig(
      androidNotificationChannelId: 'com.example.audio_player',
      androidNotificationChannelName: 'Music Player',
      androidStopForegroundOnPause: true,
      androidNotificationOngoing: true,
    ),
  );
}

class MyAudioHandler extends BaseAudioHandler {
  final _audioPlayer = AudioPlayer();
  final _playlist = ConcatenatingAudioSource(children: []);

  MyAudioHandler() {
    _loadEmptyList();
    _notifyAudioHandlerPlaybackEvent();
    _listenToChangeIndexSong();
    _listenToChangeInDuration();
    _listenSequenceStateChanges();
  }

  _loadEmptyList() async {
    await _audioPlayer.setAudioSource(_playlist);
  }

  void _notifyAudioHandlerPlaybackEvent() {
    _audioPlayer.playbackEventStream.listen((PlaybackEvent event) {
      final playing = _audioPlayer.playing;
      playbackState.add(
        playbackState.value.copyWith(
          controls: [
            MediaControl.skipToPrevious,
            if (playing) MediaControl.pause else MediaControl.play,
            MediaControl.stop,
            MediaControl.skipToNext,
          ],
          systemActions: const {
            MediaAction.seek,
          },
          androidCompactActionIndices: const [0, 1, 3],
          processingState: const {
            ProcessingState.idle: AudioProcessingState.idle,
            ProcessingState.loading: AudioProcessingState.loading,
            ProcessingState.buffering: AudioProcessingState.buffering,
            ProcessingState.completed: AudioProcessingState.completed,
            ProcessingState.ready: AudioProcessingState.ready,
          }[_audioPlayer.processingState]!,
          repeatMode: const {
            LoopMode.off: AudioServiceRepeatMode.none,
            LoopMode.one: AudioServiceRepeatMode.one,
            LoopMode.all: AudioServiceRepeatMode.all,
          }[_audioPlayer.loopMode]!,
          playing: playing,
          updatePosition: _audioPlayer.position,
          bufferedPosition: _audioPlayer.bufferedPosition,
          queueIndex: _audioPlayer.currentIndex,
        ),
      );
    });
  }

  _listenToChangeIndexSong() {
    _audioPlayer.currentIndexStream.listen((index) {
      final playlist = queue.value;
      if (playlist.isEmpty) return;
      mediaItem.add(playlist[index ?? 0]);
    });
  }

  _listenToChangeInDuration() {
    _audioPlayer.durationStream.listen((duration) {
      final index = _audioPlayer.currentIndex;
      final newQueue = queue.value;
      if (index == null || newQueue.isEmpty) return;
      final oldMediaItem = newQueue[index];
      final newMediaItem = oldMediaItem.copyWith(duration: duration);
      newQueue[index] = newMediaItem;
      queue.add(newQueue);
      mediaItem.add(newMediaItem);
    });
  }

  _listenSequenceStateChanges() {
    _audioPlayer.sequenceStateStream.listen((sequenceState) {
      final sequence = sequenceState!.effectiveSequence;
      if (sequence.isEmpty || sequence == null) return;
      final items = sequence.map((item) => item.tag as MediaItem);
      queue.add(items.toList());
    });
  }

  @override
  Future<void> addQueueItems(List<MediaItem> mediaItems) async {
    final audioSource = mediaItems
        .map(
          (mediaItem) => AudioSource.uri(
            Uri.parse(mediaItem.extras!['url']),
            tag: mediaItem,
          ),
        )
        .toList();
    if (_playlist.length < mediaItems.length) {
      _playlist.addAll(audioSource);
    }

    if (queue.value.length < mediaItems.length) {
      final newQueue = queue.value..addAll(mediaItems);
      queue.add(newQueue);
    }
  }

  @override
  Future<void> play() async {
    _audioPlayer.play();
  }

  @override
  Future<void> pause() async {
    _audioPlayer.pause();
  }

  @override
  Future<void> skipToNext() async {
    _audioPlayer.seekToNext();
  }

  @override
  Future<void> skipToPrevious() async {
    _audioPlayer.seekToPrevious();
  }

  @override
  Future<void> setRepeatMode(AudioServiceRepeatMode repeatMode) async {
    switch (repeatMode) {
      case AudioServiceRepeatMode.none:
        _audioPlayer.setLoopMode(LoopMode.off);
      case AudioServiceRepeatMode.one:
        _audioPlayer.setLoopMode(LoopMode.one);
      case AudioServiceRepeatMode.group:
      case AudioServiceRepeatMode.all:
        _audioPlayer.setLoopMode(LoopMode.all);
    }
  }

  @override
  Future<void> androidSetRemoteVolume(int volumeIndex) async {
    if (volumeIndex == 0) {
      _audioPlayer.setVolume(0);
    } //
    else if (volumeIndex == 1) {
      _audioPlayer.setVolume(0.4);
    } //
    else {
      _audioPlayer.setVolume(1);
    }
  }

  @override
  Future<void> seek(Duration position) async {
    _audioPlayer.seek(position);
  }

  @override
  Future<void> skipToQueueItem(int index) async {
    _audioPlayer.seek(Duration.zero, index: index);
  }
}
