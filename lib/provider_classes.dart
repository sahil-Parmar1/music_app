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

class Songlistprovider extends ChangeNotifier
{
  List<Song> Songlist=[];
  Box<Song> songBox;
  Songlistprovider(this.songBox){

    _loadSongs();
  }
//frist load songs from hive
  Future<void> _loadSongs()async
  {
    Songlist=songBox!.values.toList();
    notifyListeners();
  }

  void Refresh()
  {
    _loadSongs();
  }
  void addSong(Song song) {
    for(Song oldsong in Songlist)
      {
        if(oldsong.path == song.path)
          return;
      }
    songBox!.add(song); // Save to Hive
    Songlist = songBox!.values.toList();
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
  Themeprovider(){
    _loadtheme();
  }
  Future<void> _loadtheme()async
  {
    SharedPreferences prefs=await SharedPreferences.getInstance();
    String color=prefs.getString('theme')??'darkgreen';
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

  Future<void> settheme(String color)async
  {
    savetoStringShared_preference(string: color, key: 'theme');
    _loadtheme();
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
  currentplay(this.songBox)
  {
      player.onPositionChanged.listen((Duration newPosition){
        positionNotifier.value=newPosition;
        if(duration != null && newPosition.inSeconds >= duration!.inSeconds -2)
          {
            print("Song finished, playing next");
            nextsong();
          }
      });

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

  void playSong()async
  {

       try
           {
             await player.play(DeviceFileSource(song.path));
             duration= await  player.getDuration();
             print("duration of song :${duration?.inMinutes}:${duration?.inSeconds.remainder(60)}");
             isplaying.value=true;
           }
        catch(e)
        {
          print("error in $e");
          showToast("song not found ! try to Refresh it");
        }


  }
  void stop()async
  {
    await player.stop();
    isplaying.value=false;
    //notifyListeners();
  }
  void pause()async
  {
    await player.pause();
    isplaying.value=false;
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
    playSong();
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
  playlistprovider(){
    _loadplaylists();
  }
  void _loadplaylists()async
  {
    playlists=await getfromShared_preference(key: key)??[];
    notifyListeners();
  }
  void addplaylist(String playlistname)async
  {
    List<String> newplaylist=await getfromShared_preference(key: key)??[];
    newplaylist.add(playlistname);
    savetoShared_preference(string: newplaylist, key: key);
    _loadplaylists();
  }
  void deleteplaylist(String playlistname)async
  {
    List<String> newplaylist=await getfromShared_preference(key: key)??[];
    newplaylist.remove(playlistname);
    savetoShared_preference(string: newplaylist, key: key);
    showToast("$playlistname was deleted");
    _loadplaylists();
  }
  Future<int> calculatesongs(String boxname)async{
    Box<Song> box;
    bool isBoxOpen = Hive.isBoxOpen(boxname);
    if (isBoxOpen) {
     box=Hive.box<Song>(boxname);
    } else {
    box=await Hive.openBox<Song>(boxname);
    }
     int len=box.values.length;
      return len;
    }
}


