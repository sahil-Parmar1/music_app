// ==============================================================================
// File: lib/audio_notification_service.dart
// ------------------------------------------------------------------------------
// PURPOSE:
//   Provides notification player integration using `audio_service`.
//   Manages the native Android MediaSession / Notification MediaStyle controls
//   (Play, Pause, Next, Previous, Seek) and synchronizes them directly with the
//   app's existing playback state without creating a secondary player.
// ==============================================================================

import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:audio_service/audio_service.dart';
import 'package:flutter/services.dart';
import 'package:music_app_2/store/songs.dart';
import 'package:path_provider/path_provider.dart';

class AudioPlayerHandler extends BaseAudioHandler with SeekHandler {
  Future<void> Function()? onPlay;
  Future<void> Function()? onPause;
  Future<void> Function()? onNext;
  Future<void> Function()? onPrev;
  Future<void> Function(Duration position)? onSeek;
  Future<void> Function()? onStop;

  @override
  Future<void> play() async {
    if (onPlay != null) {
      await onPlay!();
    }
  }

  @override
  Future<void> pause() async {
    if (onPause != null) {
      await onPause!();
    }
  }

  @override
  Future<void> skipToNext() async {
    if (onNext != null) {
      await onNext!();
    }
  }

  @override
  Future<void> skipToPrevious() async {
    if (onPrev != null) {
      await onPrev!();
    }
  }

  @override
  Future<void> seek(Duration position) async {
    if (onSeek != null) {
      await onSeek!(position);
    }
  }

  @override
  Future<void> stop() async {
    if (onStop != null) {
      await onStop!();
    }
    await super.stop();
  }

  /// Sets the metadata (title, artist, album, art, duration) in the notification.
  void setSongMetadata({
    required Song song,
    Duration? duration,
    Uri? artUri,
  }) {
    mediaItem.add(
      MediaItem(
        id: song.path,
        album: song.album?.isNotEmpty == true ? song.album! : 'Unknown Album',
        title: song.title?.isNotEmpty == true ? song.title! : 'Unknown Title',
        artist: song.artist?.isNotEmpty == true ? song.artist! : 'Unknown Artist',
        duration: duration,
        artUri: artUri,
      ),
    );
  }

  /// Updates the playback state (playing/paused, position, controls) in the notification.
  void updatePlaybackState({
    required bool isPlaying,
    Duration? position,
    bool isStopped = false,
  }) {
    playbackState.add(
      PlaybackState(
        controls: [
          MediaControl.skipToPrevious,
          isPlaying ? MediaControl.pause : MediaControl.play,
          MediaControl.skipToNext,
        ],
        systemActions: const {
          MediaAction.seek,
          MediaAction.seekForward,
          MediaAction.seekBackward,
        },
        androidCompactActionIndices: const [0, 1, 2],
        processingState: isStopped
            ? AudioProcessingState.idle
            : AudioProcessingState.ready,
        playing: isPlaying,
        updatePosition: position ?? Duration.zero,
        bufferedPosition: position ?? Duration.zero,
        speed: 1.0,
      ),
    );
  }
}

/// Helper to save base64 artwork into a temporary file for the notification media session.
Future<Uri?> getArtworkUri(Song song) async {
  try {
    if (song.Image != null && song.Image!.isNotEmpty) {
      final tempDir = await getTemporaryDirectory();
      final fileName = 'song_art_${song.path.hashCode.abs()}.jpg';
      final file = File('${tempDir.path}/$fileName');
      if (!await file.exists()) {
        final bytes = base64Decode(song.Image!);
        await file.writeAsBytes(bytes, flush: true);
      }
      return Uri.file(file.path);
    }
  } catch (e) {
    // Graceful fallback on decode error
  }
  return null;
}

/// Fallback artwork uri using the app's default music icon.
Future<Uri?> getDefaultArtworkUri() async {
  try {
    final tempDir = await getTemporaryDirectory();
    final file = File('${tempDir.path}/default_music_art.png');
    if (!await file.exists()) {
      final byteData = await rootBundle.load('assets/default-music.png');
      final bytes = byteData.buffer.asUint8List(
        byteData.offsetInBytes,
        byteData.lengthInBytes,
      );
      await file.writeAsBytes(bytes, flush: true);
    }
    return Uri.file(file.path);
  } catch (e) {
    return null;
  }
}

/// Initializes the `audio_service` background notification handler.
Future<AudioPlayerHandler?> initAudioNotificationService() async {
  try {
    return await AudioService.init(
      builder: () => AudioPlayerHandler(),
      config: const AudioServiceConfig(
        androidNotificationChannelId: 'com.example.music_app_2.audio',
        androidNotificationChannelName: 'Music Playback',
        androidNotificationChannelDescription: 'Music playback controls',
        androidNotificationOngoing: false,
        androidStopForegroundOnPause: false,
        androidNotificationIcon: 'drawable/ic_music_note',
        notificationColor: Color(0xFF2594FC), // Matches app's DarkBlue accent
        androidNotificationClickStartsActivity: true,
      ),
    );
  } catch (e) {
    return null;
  }
}
