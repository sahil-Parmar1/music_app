import 'package:flutter_test/flutter_test.dart';
import 'package:audio_service/audio_service.dart';
import 'package:music_app_2/audio_notification_service.dart';
import 'package:music_app_2/store/songs.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AudioPlayerHandler Notification Tests', () {
    test('AudioPlayerHandler invokes attached callbacks', () async {
      final handler = AudioPlayerHandler();
      bool playCalled = false;
      bool pauseCalled = false;
      bool nextCalled = false;
      bool prevCalled = false;
      bool stopCalled = false;
      Duration? seekTarget;

      handler.onPlay = () async {
        playCalled = true;
      };
      handler.onPause = () async {
        pauseCalled = true;
      };
      handler.onNext = () async {
        nextCalled = true;
      };
      handler.onPrev = () async {
        prevCalled = true;
      };
      handler.onSeek = (pos) async {
        seekTarget = pos;
      };
      handler.onStop = () async {
        stopCalled = true;
      };

      await handler.play();
      expect(playCalled, isTrue);

      await handler.pause();
      expect(pauseCalled, isTrue);

      await handler.skipToNext();
      expect(nextCalled, isTrue);

      await handler.skipToPrevious();
      expect(prevCalled, isTrue);

      await handler.seek(const Duration(seconds: 45));
      expect(seekTarget, equals(const Duration(seconds: 45)));

      await handler.stop();
      expect(stopCalled, isTrue);
    });

    test('setSongMetadata correctly updates mediaItem stream', () async {
      final handler = AudioPlayerHandler();
      final song = Song(
        path: '/storage/emulated/0/Music/test_track.mp3',
        title: 'Dream On',
        artist: 'Aerosmith',
        album: 'Aerosmith (1973)',
      );

      handler.setSongMetadata(
        song: song,
        duration: const Duration(minutes: 4, seconds: 28),
      );

      final item = handler.mediaItem.value;
      expect(item, isNotNull);
      expect(item!.id, equals(song.path));
      expect(item.title, equals('Dream On'));
      expect(item.artist, equals('Aerosmith'));
      expect(item.album, equals('Aerosmith (1973)'));
      expect(item.duration, equals(const Duration(minutes: 4, seconds: 28)));
    });

    test('updatePlaybackState correctly updates playing and paused controls', () async {
      final handler = AudioPlayerHandler();

      // Test playing state
      handler.updatePlaybackState(
        isPlaying: true,
        position: const Duration(seconds: 15),
      );

      var state = handler.playbackState.value;
      expect(state.playing, isTrue);
      expect(state.updatePosition, equals(const Duration(seconds: 15)));
      expect(state.controls.length, equals(3));
      expect(state.controls[0], equals(MediaControl.skipToPrevious));
      expect(state.controls[1], equals(MediaControl.pause));
      expect(state.controls[2], equals(MediaControl.skipToNext));
      expect(state.androidCompactActionIndices, equals([0, 1, 2]));

      // Test paused state
      handler.updatePlaybackState(
        isPlaying: false,
        position: const Duration(seconds: 30),
      );

      state = handler.playbackState.value;
      expect(state.playing, isFalse);
      expect(state.updatePosition, equals(const Duration(seconds: 30)));
      expect(state.controls[1], equals(MediaControl.play));
    });
  });
}
