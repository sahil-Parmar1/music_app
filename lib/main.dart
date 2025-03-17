import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:music_app_2/store/songs.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import 'dart:async';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'provider_classes.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:id3/id3.dart';
import 'screens/homescreen.dart';

void main()async
{
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  // Register the adapter before opening the box
  Hive.registerAdapter(SongAdapter());
  Box<Song> songBox=await Hive.openBox<Song>('songs');
  runApp(
      MultiProvider(providers: [
        ChangeNotifierProvider(create: (context) =>Themeprovider()),
        ChangeNotifierProvider(create: (context) =>Songlistprovider(songBox)),
      ],
        child: musicApp(),
      )
  );
}

class musicApp extends StatefulWidget {
  const musicApp({super.key});
  @override
  State<musicApp> createState() => _musicAppState();
}

class _musicAppState extends State<musicApp> {
  var songProvider;
  var theme;
  @override
  void initState()
  {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_){
      songProvider=Provider.of<Songlistprovider>(context,listen: false);
      theme=Provider.of<Themeprovider>(context,listen: false);
    });
    startups();
  }

  //for device location like emulated\0\ in android
  Future<void> getDeviceLocation()async
  {
    List<String> storageDirs = [];
    List<Directory> directories = [];

    if (Platform.isAndroid) {
      Directory? internalStorage = await getExternalStorageDirectory();
      if (internalStorage != null) directories.add(internalStorage);

      List<Directory>? externalStorage = await getExternalStorageDirectories();
      if (externalStorage != null) directories.addAll(externalStorage);
    } else if (Platform.isIOS) {
      directories.add(await getApplicationDocumentsDirectory());
    }

    Set<String> uniquePaths = {};
    for (Directory dir in directories) {
      String fullPath = dir.path;
      if (fullPath.startsWith("/storage/emulated/0")) {
        uniquePaths.add("/storage/emulated/0");
      } else {
        RegExp regex = RegExp(r"^(/storage/[^/]+)");
        Match? match = regex.firstMatch(fullPath);
        if (match != null) uniquePaths.add(match.group(1)!);
      }
    }
    savetoShared_preference(string: uniquePaths.toList(), key: "deviceLocations");
  }
  void startups()async
  {
    List<String> deviceLocations=await getfromShared_preference(key: "deviceLocations");
    if(deviceLocations.isEmpty)
    {
      await requestPermission();
      await getDeviceLocation();
    }

    if(songProvider.Songlist.isEmpty)
    {
      print("song list is empty");
      fetchSongslist(context);
    }
    else
    {
      print("${songProvider.Songlist}");
    }

  }

  @override
  Widget build(BuildContext context) {

    return MaterialApp(
      home: HomeScreen()
    );
  }
}


Future<void> requestPermission() async {
  if (Platform.isAndroid) {
    if (await Permission.storage.isDenied || await Permission.storage.isPermanentlyDenied) {
      await Permission.storage.request();
    }

    if (await Permission.manageExternalStorage.isDenied ||
        await Permission.manageExternalStorage.isPermanentlyDenied) {
      await Permission.manageExternalStorage.request();
    }
  }
}


///save the list in shared_pref
void savetoShared_preference({required List<String> string,required String key})async
{
  SharedPreferences prefs=await SharedPreferences.getInstance();
  await prefs.setStringList(key, string);
}


///save the string in shared_pref
void savetoStringShared_preference({required String string,required String key})async
{
  SharedPreferences prefs=await SharedPreferences.getInstance();
  await prefs.setString(key, string);
}

///get the list from shared_pref
Future<List<String>>  getfromShared_preference({required String key})async
{
  SharedPreferences prefs=await SharedPreferences.getInstance();
  return prefs.getStringList(key)??[];
}


///fecth the song list
Future<void> fetchSongslist(context) async {
  List<String> deviceLocations=await getfromShared_preference(key: "deviceLocations");
  print("device locations==>>$deviceLocations");
  final songProvider = Provider.of<Songlistprovider>(context,listen: false);

  for (String path in deviceLocations) {
     print("in path==>$path");
     await for (String song in fetchSongs(path))
       {
         print("song ==>$song");
         Song newsong=await fetchMP3Metadata(song);
         print(newsong.Image);
         print(newsong.path);
         print(newsong.album);
         print(newsong.artist);
         print(newsong.title);
         print(newsong.genre);
         songProvider.addSong(newsong);
       }
       print("all song are fecthed....");
  }
}

///fectching songs
Stream<String> fetchSongs(String path) async* {
  Directory directory = Directory(path);
  yield* getSongs(directory);
}

/// Recursively find songs in directories
Stream<String> getSongs(Directory dir) async* {
  try {
    await for (var entity in dir.list(recursive: false, followLinks: false)) {
      if(entity is File)
        {
          print("entity is file $entity");
        }
      if (entity is Directory) {
        print("in entity :$entity");
        print("enity path ${entity.path}");
        yield* getSongs(entity);
      } else if (entity is File && entity.path.endsWith('.mp3')) {
        print("else entity : $entity");
        yield entity.path;
      }
    }
  } catch (e) {
    print("Skipping inaccessible directory: ${dir.path}, Error: $e");
  }
}

///extract the metadata
Future<Song> fetchMP3Metadata(String filePath) async {
  File file = File(filePath);

  if (!await file.exists()) {
    print("File not found: $filePath");
    Song song=Song(path: '');
    return song;
  }

  List<int> mp3Bytes = await file.readAsBytes();
  MP3Instance mp3Instance = MP3Instance(mp3Bytes);

  if (mp3Instance.parseTagsSync()) {
    Map<String, dynamic>? metadata=mp3Instance.getMetaTags();
    //print("metadata==>${mp3Instance.getMetaTags()}");
    if(metadata!.containsKey("APIC"))
    {
      String? base64Image = metadata["APIC"]["base64"];

      //print("base64Image==>${base64Image}");

      Song song=Song(path: filePath,title: metadata?["Title"] ?? "Unknown",artist:metadata?["Artist"] ?? "Unknown", Image: metadata?["APIC"]?["base64"],publisher: metadata?["Publisher"] ?? "Unknown",genre: metadata?["Genre"] ?? "Unknown",album: metadata?["Album"] ?? "Unknown");

      return song;
    }
  } else {
    print("No metadata found in this file.");
    Song song=Song(path: filePath);
    return song;
  }
  Song song=Song(path: filePath);
  return song;
}

