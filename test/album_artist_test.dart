import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:music_app_2/screens/albumscreen.dart';
import 'package:music_app_2/screens/artistscreen.dart';
import 'package:music_app_2/store/songs.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory tempDir;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('hive_test_');
    Hive.init(tempDir.path);
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(SongAdapter());
    }
    SharedPreferences.setMockInitialValues({});
  });

  tearDown(() async {
    await Hive.close();
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  test('loadAlbum correctly indexes all songs and does not terminate early on duplicates', () async {
    final songBox = await Hive.openBox<Song>('songs');

    // Add multiple songs across different albums, including duplicates
    await songBox.addAll([
      Song(path: '/music/track1.mp3', title: 'Song 1', artist: 'Artist A', album: 'Album 1'),
      Song(path: '/music/track2.mp3', title: 'Song 2', artist: 'Artist B', album: 'Album 2'),
      // Duplicate of track 1:
      Song(path: '/music/track1.mp3', title: 'Song 1', artist: 'Artist A', album: 'Album 1'),
      // Subsequent song that must NOT be skipped:
      Song(path: '/music/track3.mp3', title: 'Song 3', artist: 'Artist C', album: 'Album 3'),
      // Song with special characters in album name:
      Song(path: '/music/track4.mp3', title: 'Song 4', artist: 'AC/DC', album: 'Back in Black / Live'),
    ]);

    await loadAlbum(null);

    final prefs = await SharedPreferences.getInstance();
    final albums = prefs.getStringList('album') ?? [];

    expect(albums, contains('Album 1'));
    expect(albums, contains('Album 2'));
    expect(albums, contains('Album 3'));
    // Verified sanitized name without illegal filesystem slash
    expect(albums.any((a) => a.contains('Back in Black')), isTrue);
    expect(albums.any((a) => a.contains('/')), isFalse);

    // Verify album box content
    final album1Box = Hive.box<Song>('Album 1');
    expect(album1Box.values.length, equals(1)); // duplicate was skipped, not doubled
  });

  test('loadArtist correctly indexes all songs and does not terminate early on duplicates', () async {
    final songBox = await Hive.openBox<Song>('songs');

    await songBox.addAll([
      Song(path: '/music/track1.mp3', title: 'Song 1', artist: 'Eminem', album: 'Recovery'),
      Song(path: '/music/track2.mp3', title: 'Song 2', artist: 'Queen', album: 'A Night at the Opera'),
      // Duplicate of track 1:
      Song(path: '/music/track1.mp3', title: 'Song 1', artist: 'Eminem', album: 'Recovery'),
      // Subsequent song that must NOT be skipped:
      Song(path: '/music/track3.mp3', title: 'Song 3', artist: 'Pink Floyd', album: 'The Wall'),
      // Artist with slash:
      Song(path: '/music/track4.mp3', title: 'Thunderstruck', artist: 'AC/DC', album: 'The Razors Edge'),
    ]);

    await loadArtist(null);

    final prefs = await SharedPreferences.getInstance();
    final artists = prefs.getStringList('artist') ?? [];

    expect(artists, contains('Eminem'));
    expect(artists, contains('Queen'));
    expect(artists, contains('Pink Floyd'));
    expect(artists.any((a) => a.contains('AC DC')), isTrue);
    expect(artists.any((a) => a.contains('/')), isFalse);

    // Verify artist box content
    final eminemBox = Hive.box<Song>('Eminem');
    expect(eminemBox.values.length, equals(1));
  });
}
