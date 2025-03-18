import 'dart:math';

import 'package:flutter/material.dart';
import 'package:music_app_2/theme/colors.dart';
import 'package:provider/provider.dart';
import 'package:music_app_2/store/songs.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'main.dart';
import 'package:audioplayers/audioplayers.dart';

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
  currentplay(this.songBox);
  final player=AudioPlayer();
  bool isplaying=false;
  void playSong()async
  {
        await player.play(DeviceFileSource(song.path));
        isplaying=true;
        notifyListeners();
  }
  void stop()async
  {
    await player.stop();
    isplaying=false;
    notifyListeners();
  }
  void pause()async
  {
    await player.pause();
    isplaying=false;
    notifyListeners();
  }
  void changesong(Song newsong)
  {
    song=newsong;
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
}

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