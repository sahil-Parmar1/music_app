// ==============================================================================
// File: lib/provider_classes.dart
// ------------------------------------------------------------------------------
// PURPOSE:
//   Contains the core state management classes (using the `provider` package)
//   and shared business logic for the entire music application:
//     1. Songlistprovider : Song list collection management for any Hive box.
//     2. Themeprovider    : App-wide color theme loading, selection, and persistence.
//     3. currentplay      : Audio playback controller, queue manager, and sleep timer.
//     4. playlistprovider : Playlist, album, and artist categorization and storage.
//     5. searchProvider   : Real-time search filtering on the song catalog.
//
// FLOW & ARCHITECTURE:
//   - Root Registration (`main.dart`):
//       MultiProvider instantiates and exposes `Themeprovider`, `Songlistprovider`,
//       `currentplay`, and `playlistprovider` at the root of the widget tree.
//   - Audio Playback Flow:
//       1. User taps a song in `SongScreen`, `searchScreen`, or `playlistsongs`.
//       2. The screen invokes `currentplay.changebox(box)` and `currentplay.changesong(song)`.
//       3. `currentplay` resets the position, triggers `loadtheme()` (picking a random
//          color scheme S1-S6), and calls `player.play(DeviceFileSource(song.path))`.
//       4. `player.onPositionChanged` streams playback position to `positionNotifier`.
//          When the song reaches the end, `nextsong()` is called automatically to loop
//          or advance to the next track in the active Hive box.
//   - Sleep Timer Flow:
//       - `starttimer(minutes)` starts a periodic 1-second countdown timer.
//       - When countdown reaches 0, `stopTimer()` and `stop()` are invoked.
//   - Helper Utilities:
//       - `getindexofsong()`: Resolves a song's key inside a Hive box.
//       - `showToast()`: Displays toast feedback via `fluttertoast`.
// ==============================================================================

import 'dart:math';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:music_app_2/theme/colors.dart';
import 'package:provider/provider.dart';
import 'package:music_app_2/store/songs.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'main.dart';
import 'package:audioplayers/audioplayers.dart';
import 'dart:io';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:music_app_2/audio_notification_service.dart';

class Songlistprovider extends ChangeNotifier
{
  List<Song> Songlist=[];
  Box<Song> songBox;
  bool isScanning = false;

  Songlistprovider(this.songBox){
    if (songBox.isEmpty) {
      isScanning = true;
    }
    _loadSongs();
  }

  void setIsScanning(bool scanning) {
    if (isScanning != scanning) {
      isScanning = scanning;
      notifyListeners();
    }
  }

//frist load songs from hive
  Future<void> _loadSongs()async
  {
    _pruneDuplicateSongs();
    Songlist=songBox.values.toList();
    if (Songlist.isNotEmpty) {
      isScanning = false;
    }
    notifyListeners();
  }

  void _pruneDuplicateSongs() {
    Set<String> seenPaths = {};
    Set<String> seenTrackSignatures = {};
    List<dynamic> keysToDelete = [];

    for (var key in songBox.keys) {
      final song = songBox.get(key);
      if (song == null) {
        keysToDelete.add(key);
        continue;
      }
      final normPath = song.path.trim().toLowerCase();
      final normTitle = (song.title ?? '').trim().toLowerCase();
      final normArtist = (song.artist ?? '').trim().toLowerCase();
      final normAlbum = (song.album ?? '').trim().toLowerCase();

      bool isDuplicate = false;
      if (normPath.isNotEmpty && seenPaths.contains(normPath)) {
        isDuplicate = true;
      } else if (normTitle.isNotEmpty &&
          normArtist.isNotEmpty &&
          normArtist != 'unknown' &&
          normArtist != 'unknown artist' &&
          seenTrackSignatures.contains('$normTitle|$normArtist')) {
        isDuplicate = true;
      } else if (normTitle.isNotEmpty &&
          normAlbum.isNotEmpty &&
          normAlbum != 'unknown' &&
          normAlbum != 'unknown album' &&
          seenTrackSignatures.contains('$normTitle||$normAlbum')) {
        isDuplicate = true;
      }

      if (isDuplicate) {
        keysToDelete.add(key);
      } else {
        if (normPath.isNotEmpty) seenPaths.add(normPath);
        if (normTitle.isNotEmpty && normArtist.isNotEmpty) {
          seenTrackSignatures.add('$normTitle|$normArtist');
        }
        if (normTitle.isNotEmpty && normAlbum.isNotEmpty) {
          seenTrackSignatures.add('$normTitle||$normAlbum');
        }
      }
    }

    for (var key in keysToDelete) {
      songBox.delete(key);
    }
  }

  void Refresh()
  {
    _loadSongs();
  }
  void addSong(Song song) {
    final newPath = song.path.trim().toLowerCase();
    final newTitle = (song.title ?? '').trim().toLowerCase();
    final newArtist = (song.artist ?? '').trim().toLowerCase();
    final newAlbum = (song.album ?? '').trim().toLowerCase();

    for (Song oldsong in Songlist) {
      final oldPath = oldsong.path.trim().toLowerCase();
      final oldTitle = (oldsong.title ?? '').trim().toLowerCase();
      final oldArtist = (oldsong.artist ?? '').trim().toLowerCase();
      final oldAlbum = (oldsong.album ?? '').trim().toLowerCase();

      final isSamePath = newPath.isNotEmpty && oldPath == newPath;
      final isSameTrack = newTitle.isNotEmpty &&
          ((newArtist.isNotEmpty && newArtist != 'unknown' && newArtist != 'unknown artist' && oldArtist == newArtist) ||
           (newAlbum.isNotEmpty && newAlbum != 'unknown' && newAlbum != 'unknown album' && oldAlbum == newAlbum)) &&
          oldTitle == newTitle;

      if (isSamePath || isSameTrack) {
        bool needsUpdate = false;
        if ((oldsong.artist == null || oldsong.artist == 'Unknown' || oldsong.artist == 'Unknown Artist') &&
            song.artist != null && song.artist != 'Unknown' && song.artist != 'Unknown Artist') {
          oldsong.artist = song.artist;
          needsUpdate = true;
        }
        if ((oldsong.album == null || oldsong.album == 'Unknown' || oldsong.album == 'Unknown Album') &&
            song.album != null && song.album != 'Unknown' && song.album != 'Unknown Album') {
          oldsong.album = song.album;
          needsUpdate = true;
        }
        if ((oldsong.title == null || oldsong.title == 'Unknown') &&
            song.title != null && song.title != 'Unknown') {
          oldsong.title = song.title;
          needsUpdate = true;
        }
        if ((oldsong.Image == null || oldsong.Image!.isEmpty) &&
            song.Image != null && song.Image!.isNotEmpty) {
          oldsong.Image = song.Image;
          needsUpdate = true;
        }
        if (needsUpdate) {
          oldsong.save();
          notifyListeners();
        }
        return;
      }
    }
    songBox.add(song); // Save to Hive
    Songlist = songBox.values.toList();
    print("new song is added..");// Update list
    notifyListeners();
  }
  void deletesong(Song song)async
  {
    int index=getindexofsong(songBox, song);
    if(index>=0)
    {
      await songBox.delete(index);
      Songlist = songBox!.values.toList();
      notifyListeners();
    }
  }


}
class Themeprovider extends ChangeNotifier
{
  ThemeColor theme=DarkBlue();
  String currentThemeKey='darkblue';
  Themeprovider(){
    _loadtheme();
  }

  void _applyTheme(String color)
  {
    currentThemeKey=color;
    switch(color)
    {
      case 'darkblue':theme=DarkBlue();
      break;
      case 'darkgreen':theme=DarkGreen();
      break;
      case 'darkpink':theme=DarkPink();
      break;
      case 'darkorange':theme=DarkOrange();
      break;
      case 'darkred':theme=DarkRed();
      break;
      case 'whiteblue':theme=WhiteBlue();
      break;
      case 'whitegreen':theme=WhiteGreen();
      break;
      case 'whitepink':theme=WhitePink();
      break;
      case 'whiteorange':theme=WhiteOrange();
      break;
      case 'whitered':theme=WhiteRed();
      break;
      default: theme=DarkBlue();
      break;
    }
    notifyListeners();
  }

  Future<void> _loadtheme()async
  {
    SharedPreferences prefs=await SharedPreferences.getInstance();
    String color=prefs.getString('theme')??'darkblue';
    _applyTheme(color);
  }

  Future<void> settheme(String color)async
  {
    _applyTheme(color);
    savetoStringShared_preference(string: color, key: 'theme');
  }
}

class currentplay extends ChangeNotifier
{
  Box<Song> songBox;
  Song song=Song(path: '');
  ThemeColor Theme=S1();
  final ValueNotifier<Duration> positionNotifier=ValueNotifier(Duration.zero);
  Timer? _timer;
  Timer? get timer => _timer;
  ValueNotifier<int> secondsRemaining=ValueNotifier<int>(0);
  final AudioPlayerHandler? audioHandler;

  currentplay(this.songBox, {this.audioHandler})
  {
      _initAudioNotificationCallbacks();

      player.onPositionChanged.listen((Duration newPosition){
        positionNotifier.value=newPosition;
        if(duration != null && newPosition.inSeconds >= duration!.inSeconds -2)
          {
            print("Song finished, playing next");
            nextsong();
          }
      });

      player.onDurationChanged.listen((Duration newDuration){
        duration = newDuration;
        _syncNotificationMediaItem();
      });

      player.onPlayerStateChanged.listen((PlayerState state){
        if (state == PlayerState.playing && !isplaying.value) {
          isplaying.value = true;
          _syncNotificationPlaybackState(isPlaying: true);
        } else if (state == PlayerState.paused && isplaying.value) {
          isplaying.value = false;
          _syncNotificationPlaybackState(isPlaying: false);
        }
      });
  }

  void _initAudioNotificationCallbacks() {
    if (audioHandler == null) return;
    audioHandler!.onPlay = () async {
      await resume();
    };
    audioHandler!.onPause = () async {
      await pause();
    };
    audioHandler!.onNext = () async {
      nextsong();
    };
    audioHandler!.onPrev = () async {
      prevsong();
    };
    audioHandler!.onSeek = (position) async {
      seektoposition(position.inSeconds.toDouble());
    };
    audioHandler!.onStop = () async {
      stop();
    };
  }

  Future<void> _syncNotificationMediaItem() async {
    if (audioHandler == null || song.path.isEmpty) return;
    Uri? artUri = await getArtworkUri(song);
    artUri ??= await getDefaultArtworkUri();

    audioHandler!.setSongMetadata(
      song: song,
      duration: duration,
      artUri: artUri,
    );
  }

  void _syncNotificationPlaybackState({
    required bool isPlaying,
    Duration? position,
    bool isStopped = false,
  }) {
    if (audioHandler == null) return;
    audioHandler!.updatePlaybackState(
      isPlaying: isPlaying,
      position: position ?? positionNotifier.value,
      isStopped: isStopped,
    );
  }

  void changebox(Box<Song> newbox)async
  {
    songBox=newbox;
    notifyListeners();
  }
  final player=AudioPlayer();
  ValueNotifier<bool> isplaying=ValueNotifier(false);

  Duration? duration;
  Duration _currentpositioin=Duration.zero;
  Duration get position => _currentpositioin;

  Future<void> playSong({bool forceRestart = false})async
  {
       if (song.path.isEmpty) return;
       try
           {
             if (!forceRestart && player.state == PlayerState.paused) {
               await player.resume();
             } else {
               await player.play(DeviceFileSource(song.path));
               duration= await  player.getDuration();
             }
             print("duration of song :${duration?.inMinutes}:${duration?.inSeconds.remainder(60)}");
             isplaying.value=true;
             await _syncNotificationMediaItem();
             _syncNotificationPlaybackState(isPlaying: true);
           }
        catch(e)
        {
          print("error in $e");
          showToast("song not found ! try to Refresh it");
        }
  }

  Future<void> resume() async {
    await playSong();
  }

  Future<void> stop()async
  {
    await player.stop();
    isplaying.value=false;
    _syncNotificationPlaybackState(isPlaying: false, isStopped: true);
    //notifyListeners();
  }
  Future<void> pause()async
  {
    await player.pause();
    isplaying.value=false;
    _syncNotificationPlaybackState(isPlaying: false);
    //notifyListeners();
  }

  //sleep timer
  void starttimer(int minutes)async
  {
   secondsRemaining.value=minutes*60;
   _timer=Timer.periodic(const Duration(seconds:  1),(timer){
     if(  secondsRemaining.value >0)
       {
         int min=  secondsRemaining.value~/60;
         int sec=  secondsRemaining.value%60;
         print("time left:$min:${sec.toString().padLeft(2,'0')}");
         secondsRemaining.value--;
       }
     else{
       stopTimer();
       stop();
     }
   });
   notifyListeners();
  }

  //stop timer
  void stopTimer(){
    if(_timer != null)
      {
        _timer!.cancel();
        _timer=null;
        notifyListeners();
        print("timer finished");
      }
  }

  void changesong(Song newsong)
  {
    song=newsong;
    positionNotifier.value=Duration.zero;
    loadtheme();
    playSong(forceRestart: true);
  }

  //function for next song
  void nextsong()async
  {
    int index=getindexofsong(songBox, song);
    if(index>=0)
      {
        var keys=songBox.keys.toList();
         int i=keys.indexOf(index);
         if(i == songBox.keys.length-1)
            i=0;
             else
               i=i+1;
         Song newsong=songBox.get(keys[i])??Song(path: '');
         if(newsong.path != '')
           changesong(newsong);

      }
  }

  //function for prev song
  void prevsong()
  {
    int index=getindexofsong(songBox, song);
    if(index>=0)
    {
      var keys=songBox.keys.toList();
      int i=keys.indexOf(index);
      if(i == 0)
        i=songBox.keys.length-1;
      else
        i=i-1;
      Song newsong=songBox.get(keys[i])??Song(path: '');
      if(newsong.path != '')
        changesong(newsong);

    }
  }

  //load the theme of PlayerScreen
  void loadtheme()
  {
    Random random=Random();
    int randomNumber=random.nextInt(6);
    switch(randomNumber){
      case 0:Theme=S1();
      break;
      case 1:Theme=S2();
      break;
      case 2:Theme=S3();
      break;
      case 3:Theme=S4();
      break;
      case 4:Theme=S5();
      break;
      case 5:Theme=S6();
      break;
      default:Theme=S1();
      break;
    }
    notifyListeners();
  }

  //seeking custom position in playing song
  void seektoposition(double value)
  {
      final newposition=Duration(seconds: value.toInt());
      player.seek(newposition);
      print("seeking to $newposition");
      positionNotifier.value=newposition;
      _syncNotificationPlaybackState(
        isPlaying: isplaying.value,
        position: newposition,
      );
  }

}


//get the index of song in list
int getindexofsong(Box<Song> songBox,Song song)
{
  var keys=songBox.keys.toList();
  for(var key in keys)
  {
    Song mysong=songBox.get(key)??Song(path: '');
    if(song.path == mysong.path)
    {
      return key;
    }
  }
  return -1;
}


//alert message
void showToast(String message) {
  Fluttertoast.showToast(
    msg: message,
    toastLength: Toast.LENGTH_SHORT, // or Toast.LENGTH_LONG
    gravity: ToastGravity.BOTTOM,    // Position: TOP, CENTER, BOTTOM
    backgroundColor: Colors.black54,
    textColor: Colors.white,
    fontSize: 16.0,
  );
}


//playlist provider
class playlistprovider extends ChangeNotifier
{
  List<String> playlists=[];
  String key="playlists";
  playlistprovider(String newkey){
      key=newkey;
    loadplaylists();
  }
  void loadplaylists()async
  {

    playlists=await getfromShared_preference(key: key)??[];
    notifyListeners();
  }

  void addplaylist(String playlistname)async
  {
    List<String> newplaylist=await getfromShared_preference(key: key)??[];
    newplaylist.add(playlistname);
    savetoShared_preference(string: newplaylist, key: key);
    loadplaylists();
  }
  void deleteplaylist(String playlistname)async
  {
    List<String> newplaylist=await getfromShared_preference(key: key)??[];
    newplaylist.remove(playlistname);
    savetoShared_preference(string: newplaylist, key: key);
    showToast("$playlistname was deleted");
    loadplaylists();
  }
  Future<int> calculatesongs(String boxname)async{
    Box<Song> box;
    bool isBoxOpen = Hive.isBoxOpen(boxname);
    if (isBoxOpen) {
      box=Hive.box<Song>(boxname);
    } else {
      box=await Hive.openBox<Song>(boxname);
    }
    Set<String> uniqueTracks = {};
    int count = 0;
    for (var s in box.values) {
      final key = (s.title != null && s.title!.trim().isNotEmpty)
          ? s.title!.trim().toLowerCase()
          : s.path.trim().toLowerCase();
      if (uniqueTracks.add(key)) {
        count++;
      }
    }
    return count;
  }
}



//provider for search screen

class searchProvider extends ChangeNotifier
{
  List<Song> searchlist=[];
  Box<Song> songbox=Hive.box<Song>("songs");
  List<Song> songlist=[];
  searchProvider(){
    songlist= songbox.values.toList();
  }
  Future<void> searchlistfunction(String name)async
  {
    searchlist=songlist.where((song)=>
    song.title!.toLowerCase().contains(name.toLowerCase())
    ).toList();
    notifyListeners();
  }
}
