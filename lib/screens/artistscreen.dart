// ==============================================================================
// File: lib/screens/artistscreen.dart
// ------------------------------------------------------------------------------
// PURPOSE:
//   Extracts, stores, and presents songs grouped by their Artist ID3 metadata tag,
//   and provides the fallback placeholder screen (`NoArtistsScreen`) for empty states.
//
// FLOW & ARCHITECTURE:
//   1. Data Extraction (`loadArtist()`):
//      - Reads all tracks from the master 'songs' Hive box.
//      - Extracts distinct artist names and persists the list in `SharedPreferences`
//        under the key 'artist'.
//      - Creates or opens a dedicated Hive box for each artist name and saves the
//        corresponding `Song` objects.
//      - Invoked during app startup in `main.dart` and on pull-to-refresh in `SongScreen`.
//
//   2. Artist Presentation (`Artistscreen` widget):
//      - Consumes `playlistprovider` initialized with the "artist" key.
//      - Displays a list of artist cards featuring:
//          * Cover art from the first song by the artist (or fallback 'assets/singer.png').
//          * Artist name and dynamic song counter (`calculatesongs()`).
//          * Swipe-to-delete support.
//      - If empty, displays `NoArtistsScreen(artist: true)`.
//
//   3. Navigation:
//      - Tapping an artist card opens its Hive box and navigates to `playlistsongs`,
//        scoped to that artist's `Songlistprovider`.
//
//   4. NoArtistsScreen Component:
//      - Reusable empty state view displayed when either no artists or no albums exist.
// ==============================================================================

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
  State<Artistscreen> createState() => _ArtistscreenState();
}

class _ArtistscreenState extends State<Artistscreen> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final albumprovier=Provider.of<playlistprovider>(context);
    final colortheme=Provider.of<Themeprovider>(context);
    return albumprovier.playlists.length>0?Wrap(
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
                              child: BoxThumbnail(
                                boxName: playlistitem,
                                placeholderAsset: "assets/singer.png",
                              ),
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
                                    final count = snapshot.data;
                                    final text = count != null
                                        ? "$count songs"
                                        : (snapshot.connectionState == ConnectionState.waiting
                                            ? "Calculating..."
                                            : "0 songs");

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
    ):NoArtistsScreen(artist: true,);
  }
}


class NoArtistsScreen extends StatelessWidget {
  bool artist;
  NoArtistsScreen({required this.artist});
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            artist?"assets/singer.png":"assets/album.png", // Add an appropriate placeholder image
            width: 150,
            height: 150,
            gaplessPlayback: true,
          ),
          SizedBox(height: 16),
          Text(
            artist?"No Artists Available":"No Album Available",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
          SizedBox(height: 8),
          Text(
            artist?"Add new songs  to see artist here.":"Add new songs  to see album here.",
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
          SizedBox(height: 8),
          Text(
            "Or Refresh the Song Screen",
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),

        ],
      ),
    );
  }
}
