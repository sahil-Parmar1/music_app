import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:music_app_2/main.dart';
import 'package:music_app_2/provider_classes.dart';
import 'package:music_app_2/screens/playlistscreen.dart';
import 'package:music_app_2/screens/songscreen.dart';
import 'package:music_app_2/store/songs.dart';
import 'package:provider/provider.dart';


///load the album by checking indivisual song album name
/// and add to album string list in shared prefrerence
Future<void> loadArtist(context)async
{
  Box<Song> songbox=Hive.box<Song>("songs");
  List<String> album=await getfromShared_preference(key: "artist")??[];
  List<Song> songlist=songbox.values.toList();

  for(var song in songlist)
  {
    if(!album.contains(song.artist))
    {
      album.add(song.artist??"Unknown");
    }
    bool isBoxOpen = Hive.isBoxOpen(song.artist??"Unknown");
    Box<Song> box;
    if (isBoxOpen) {
      box=Hive.box<Song>(song.artist??"Unknown");
    } else {
      box=await Hive.openBox(song.artist??"Unknown");
    }
    Song newsong=Song(
      path: song.path,
      album: song.album,
      title: song.title,
      Image: song.Image,
      publisher: song.publisher,
      genre: song.genre,
      artist: song.artist,
    );
    List<Song> oldsong=box.values.toList();
    for(var check in oldsong)
      if(newsong.path == check.path)
        return;
    box.add(newsong);
  }

  savetoShared_preference(string: album, key: "artist"); //save to local storage
}

class Artistscreen extends StatefulWidget {
  const Artistscreen({super.key});

  @override
  State<Artistscreen> createState() => _AlbumState();
}

class _AlbumState extends State<Artistscreen> {
  @override
  Widget build(BuildContext context) {
    final albumprovier=Provider.of<playlistprovider>(context);
    final colortheme=Provider.of<Themeprovider>(context);
    return Wrap(
      spacing: 1000.0,
      runSpacing: 1.0,
      children: albumprovier.playlists.map((playlistitem){
        String boxname=playlistitem;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
          child: GestureDetector(
            onTap: () async {
              await Hive.openBox<Song>(playlistitem);
              Box<Song> box = Hive.box<Song>(playlistitem);
              print("$playlistitem is tapped");
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChangeNotifierProvider(
                    create: (context) => Songlistprovider(box),
                    child: playlistsongs(nameofplaylist: playlistitem, box: playlistitem),
                  ),
                ),
              );
            },
            child: Card(
              elevation: 5, // Adds a shadow effect for depth
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Dismissible(
                  key: Key(playlistitem),
                  direction: DismissDirection.endToStart,
                  onDismissed: (direction) {
                    albumprovier.deleteplaylist(playlistitem);
                  },
                  background: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: Colors.red,
                    ),
                    alignment: Alignment.centerRight,
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    splashColor: Colors.grey.withOpacity(0.2),
                    child: Container(
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: colortheme.theme.background.withOpacity(0.8),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          Hero(
                            tag: "$playlistitem",
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: FutureBuilder(
                                  future: loadFirstImage(playlistitem),
                                  builder:(context,snapshot){
                                    bool ispresent;
                                    if (snapshot.connectionState == ConnectionState.waiting) {
                                      ispresent=false;
                                    } else if (snapshot.hasError) {
                                      ispresent=false;
                                    } else {
                                      ispresent=true;
                                    }
                                    return ispresent?snapshot.data!=null?buildSongImage(base64Image: snapshot.data,width: 70,height: 70):Image.asset(
                                      "assets/singer.png",
                                      width: 70,
                                      height: 70,
                                      fit: BoxFit.cover,
                                    ):Image.asset(
                                      "assets/singer.png",
                                      width: 70,
                                      height: 70,
                                      fit: BoxFit.cover,
                                    );
                                  }),
                            ),
                          ),
                          SizedBox(width: 16), // Add spacing
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  playlistitem,
                                  style: TextStyle(
                                    color: colortheme.theme.text,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                SizedBox(height: 4),
                                FutureBuilder<int>(
                                  future: albumprovier.calculatesongs(boxname),
                                  builder: (context, snapshot) {
                                    String text;
                                    if (snapshot.connectionState == ConnectionState.waiting) {
                                      text = "Calculating...";
                                    } else if (snapshot.hasError) {
                                      text = "0 songs";
                                    } else {
                                      text = "${snapshot.data} songs";
                                    }

                                    return Text(
                                      text,
                                      style: TextStyle(
                                        color: colortheme.theme.text.withOpacity(0.7),
                                        fontSize: 14,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                          Icon(Icons.arrow_forward_ios, color: colortheme.theme.text.withOpacity(0.6), size: 18),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );

      }).toList(),
    );
  }
}
