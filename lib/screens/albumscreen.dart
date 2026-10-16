// ==============================================================================
// File: lib/screens/albumscreen.dart
// ------------------------------------------------------------------------------
// PURPOSE:
//   Extracts, stores, and presents songs grouped by their Album ID3 metadata tag.
//
// FLOW & ARCHITECTURE:
//   1. Data Extraction (`loadAlbum()`):
//      - Reads all tracks from the master 'songs' Hive box.
//      - Extracts distinct album names and persists the list in `SharedPreferences`
//        under the key 'album'.
//      - Creates or opens a dedicated Hive box for each album name and populates it
//        with the corresponding `Song` objects.
//      - Invoked during initial startup in `main.dart` and on pull-to-refresh in `SongScreen`.
//
//   2. Album Presentation (`Album` widget):
//      - Consumes `playlistprovider` initialized with the "album" key.
//      - Displays a list of album cards featuring:
//          * Cover art from the first song in the album (via `loadFirstImage()`).
//          * Album title and dynamic song counter (`calculatesongs()`).
//          * Swipe-to-delete support to dismiss albums.
//      - If empty, displays `NoArtistsScreen(artist: false)`.
//
//   3. Navigation:
//      - Tapping an album card opens its Hive box and navigates to `playlistsongs`,
//        scoped to that album's `Songlistprovider`.
// ==============================================================================

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:music_app_2/main.dart';
import 'package:music_app_2/provider_classes.dart';
import 'package:music_app_2/screens/artistscreen.dart';
import 'package:music_app_2/screens/playlistscreen.dart';
import 'package:music_app_2/screens/songscreen.dart';
import 'package:music_app_2/store/songs.dart';
import 'package:provider/provider.dart';


///load the album by checking indivisual song album name
/// and add to album string list in shared prefrerence
Future<void> loadAlbum(context)async
{
  Box<Song> songbox=Hive.box<Song>("songs");
  List<String> existingAlbums = await getfromShared_preference(key: "album");
  Set<String> albumSet = existingAlbums.toSet();
  List<Song> songlist=songbox.values.toList();

  for(var song in songlist)
  {
    String rawAlbum = (song.album != null && song.album!.trim().isNotEmpty)
        ? song.album!.trim()
        : "Unknown Album";
    String albumName = rawAlbum.replaceAll(RegExp(r'[\\/:*?"<>|]'), ' ').trim();
    if (albumName.isEmpty) albumName = "Unknown Album";

    albumSet.add(albumName);

    bool isBoxOpen = Hive.isBoxOpen(albumName);
    Box<Song> box;
    try {
      if (isBoxOpen) {
        box = Hive.box<Song>(albumName);
      } else {
        box = await Hive.openBox<Song>(albumName);
      }
    } catch (e) {
      print("Error opening Hive box for album $albumName: $e");
      continue;
    }

    bool alreadyExists = false;
    for (var check in box.values) {
      if (song.path == check.path) {
        alreadyExists = true;
        break;
      }
    }
    if (!alreadyExists) {
      Song newsong = Song(
        path: song.path,
        album: albumName,
        title: song.title,
        Image: song.Image,
        publisher: song.publisher,
        genre: song.genre,
        artist: song.artist,
      );
      await box.add(newsong);
    }
  }

  savetoShared_preference(string: albumSet.toList(), key: "album"); //save to local storage
}

class Album extends StatefulWidget {
  const Album({super.key});

  @override
  State<Album> createState() => _AlbumState();
}

class _AlbumState extends State<Album> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        Provider.of<playlistprovider>(context, listen: false).loadplaylists();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final albumprovier=Provider.of<playlistprovider>(context);
    final colortheme=Provider.of<Themeprovider>(context);
    return MediaQuery.removePadding(
      context: context,
      removeTop: true,
      child: RefreshIndicator(
        onRefresh: () async {
          await loadAlbum(context);
          if (mounted) {
            Provider.of<playlistprovider>(context, listen: false).loadplaylists();
          }
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.only(top: 4, bottom: 90),
          child: albumprovier.playlists.isNotEmpty
            ? Wrap(
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
                                placeholderAsset: "assets/album.png",
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
            )
          : NoArtistsScreen(artist: false),
        ),
      ),
    );
  }
}
