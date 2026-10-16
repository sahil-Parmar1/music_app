// ==============================================================================
// File: lib/screens/playlistscreen.dart
// ------------------------------------------------------------------------------
// PURPOSE:
//   Manages user-created playlists, displays the pinned "Liked Songs" collection,
//   provides playlist creation dialogs, and hosts the detail view (`playlistsongs`)
//   showing the tracks inside any selected playlist, album, or artist collection.
//
// FLOW & ARCHITECTURE:
//   1. Playlistscreen (Library Tab):
//      - "Add Playlist" button: Prompts user via `showPlaylistDialog()` and registers
//        the new name in `playlistprovider` and `SharedPreferences`.
//      - "Liked Songs" card: Pinned entry pointing to the 'likedsongs' Hive box.
//      - User Playlists: Rendered from `playlistprovider.playlists`. Supports swipe-to-delete
//        (`Dismissible`), dynamic song count calculation (`calculatesongs()`), and thumbnail
//        previews (`loadFirstImage()`).
//
//   2. playlistsongs Detail Screen:
//      - Reusable track list screen for any Hive box (custom playlists, liked songs,
//        albums, or artists).
//      - Wrapped in `GlobalScaffold` to maintain background theme and `MiniPlayer`.
//      - Displays a custom sliver app bar with the hero cover art of the first song.
//      - Allows swipe-to-remove (`songProvider.deletesong()`) to delete tracks from that box.
//      - Tapping any track sets `currentplay.changebox(box)` and starts playback from this queue.
//
//   3. Helper Functions:
//      - `showPlaylistDialog()`: Dialog to input a new playlist title and optionally add a song immediately.
//      - `loadFirstImage()`: Retrieves the base64 cover image of the first song in any Hive box.
// ==============================================================================

import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:music_app_2/global_scaffold.dart';
import 'package:provider/provider.dart';
import 'package:music_app_2/provider_classes.dart';
import 'package:music_app_2/main.dart';
import 'package:music_app_2/store/songs.dart';
import 'songscreen.dart';

//list of playlist screen
class Playlistscreen extends StatefulWidget {
  const Playlistscreen({super.key});

  @override
  State<Playlistscreen> createState() => _PlaylistscreenState();
}

class _PlaylistscreenState extends State<Playlistscreen> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final colortheme=Provider.of<Themeprovider>(context);
    final playlist=Provider.of<playlistprovider>(context);
    return MediaQuery.removePadding(
      context: context,
      removeTop: true,
      child: SingleChildScrollView(
        padding: const EdgeInsets.only(top: 4, bottom: 90),
        child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 5.0),
            child: Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Material(
                color: colortheme.theme.background.withOpacity(0.8),
                borderRadius: BorderRadius.circular(16), // Ensures ripple effect is clipped
                child: InkWell(
                  onTap: () {
                    showPlaylistDialog(context);
                  },
                  borderRadius: BorderRadius.circular(16),
                 splashColor: colortheme.theme.tab.withOpacity(0.2),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add, color: colortheme.theme.tab.withOpacity(0.8), size: 30),
                        SizedBox(width: 12),
                        Text(
                          "Add Playlist",
                          style: TextStyle(
                            color: colortheme.theme.text,
                            fontWeight: FontWeight.w600,
                            fontSize: 20,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),


          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0),
            child: GestureDetector(
              onTap: () async{
                await Hive.openBox<Song>('likedsongs');
                Box<Song> box = Hive.box<Song>('likedsongs');
                print("Liked Songs is tapped");
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChangeNotifierProvider(
                      create: (context) => Songlistprovider(box),
                      child: playlistsongs(nameofplaylist: "Liked Songs", box: "likedsongs"),
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
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    splashColor: Colors.grey.withOpacity(0.2),
                    child: Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: colortheme.theme.background.withOpacity(0.8),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          Hero(
                            tag: "Liked Songs",
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: const BoxThumbnail(
                                boxName: "likedsongs",
                                placeholderAsset: "assets/music.png",
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
                                  "🩷 Liked Songs",
                                  style: TextStyle(
                                    color: colortheme.theme.text,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                SizedBox(height: 4),
                                FutureBuilder<int>(
                                  future: playlist.calculatesongs("likedsongs"),
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

          Wrap(
             spacing: 1000.0,
             runSpacing: 1.0,
             children: playlist.playlists.map((playlistitem){
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
                        child: InkWell(
                          borderRadius: BorderRadius.circular(16),
                          splashColor: Colors.grey.withOpacity(0.2),
                          child: Dismissible(
                            key: Key(playlistitem),
                            direction: DismissDirection.endToStart,
                            onDismissed: (direction) {
                              playlist.deleteplaylist(playlistitem);
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
                                        placeholderAsset: "assets/music.png",
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
                                          future: playlist.calculatesongs(boxname),
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
           ),
        ],
      ),
    ),
  );
  }
}


//ask to enter the playlist name
Future<void> showPlaylistDialog(context,{Song? song}) async{
  TextEditingController playlistController = TextEditingController();
  final playlist=Provider.of<playlistprovider>(context,listen: false);
  final colortheme=Provider.of<Themeprovider>(context,listen: false);
   showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text("Create New Playlist",style: TextStyle(color:  colortheme.theme.tab.withOpacity(0.8),fontSize: 20,fontWeight: FontWeight.bold),),
        backgroundColor: colortheme.theme.background,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
        content: TextField(
          controller: playlistController,
          decoration: InputDecoration(hintText: "Enter Playlist Name",hintStyle: TextStyle(
              color:  colortheme.theme.text.withOpacity(0.8)),
                filled: false,
            fillColor: colortheme.theme.text.withOpacity(0.1)
          ),
        style: TextStyle(
          color: colortheme.theme.tab
        ),
        ),

        actions: [
          TextButton(
            onPressed: () {
              if (Navigator.of(context).canPop()) {
                Navigator.of(context).pop();
              }
// Close the dialog
            },
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: colortheme.theme.tab
            ),
            onPressed: () async{
              String playlistName = playlistController.text.trim();
              if (playlistName.isNotEmpty) {
                // Handle playlist creation logic here
               playlist.addplaylist(playlistController.text);
               if(song != null)
                 {
                   Box<Song> box;
                   bool isBoxOpen = Hive.isBoxOpen(playlistName);
                   if (isBoxOpen) {
                     box=Hive.box<Song>(playlistName);
                   } else {
                     box=await Hive.openBox<Song>(playlistName);
                   }
                   addSongtoplaylist(song, box);
                   showToast("song added to $playlistName");
                 }
               if (Navigator.of(context).canPop()) {
                 Navigator.of(context).pop();
               }
                // Close the dialog
              }
            },
            child: Text("Create",style: TextStyle(color: colortheme.theme.text),),

          ),
        ],
      );
    },
  );


}


//playlistsongs screen
class playlistsongs extends StatefulWidget {
  final String nameofplaylist;
  final String box;
  const playlistsongs({super.key, required this.nameofplaylist, required this.box});

  @override
  State<playlistsongs> createState() => _playlistsongsState();
}

class _playlistsongsState extends State<playlistsongs> {
  @override
  Widget build(BuildContext context) {
    final songProvider = Provider.of<Songlistprovider>(context);
    final colortheme = Provider.of<Themeprovider>(context);
    final currentplayprovider = Provider.of<currentplay>(context);

    // Defensive deduplication to ensure unique tracks in album/artist/playlist view
    final Map<String, Song> uniqueSongsMap = {};
    for (var s in songProvider.Songlist) {
      final key = (s.title != null && s.title!.trim().isNotEmpty)
          ? s.title!.trim().toLowerCase()
          : s.path.trim().toLowerCase();
      uniqueSongsMap.putIfAbsent(key, () => s);
    }
    final songs = uniqueSongsMap.values.toList();

    return GlobalScaffold(
      child: Material(
        color: colortheme.theme.background,
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              pinned: true,
              elevation: 0,
              backgroundColor: colortheme.theme.background,
              leading: IconButton(
                icon: Icon(Icons.arrow_back_ios_new_rounded, color: colortheme.theme.text, size: 22),
                onPressed: () {
                  if (Navigator.of(context).canPop()) {
                    Navigator.of(context).pop();
                  }
                },
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 8),
                    // Centered album / artist artwork
                    Center(
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.35),
                              blurRadius: 18,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Hero(
                          tag: widget.nameofplaylist,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: songs.isNotEmpty
                                ? buildSongImage(
                                    base64Image: songs[0].Image,
                                    width: 170,
                                    height: 170,
                                  )
                                : Image.asset(
                                    "assets/music.png",
                                    width: 170,
                                    height: 170,
                                    fit: BoxFit.cover,
                                    gaplessPlayback: true,
                                  ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Perfectly aligned and padded title
                    Text(
                      widget.nameofplaylist,
                      style: TextStyle(
                        color: colortheme.theme.text,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        height: 1.3,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    // Subtitle: Song count
                    Text(
                      "${songs.length} ${songs.length == 1 ? 'song' : 'songs'}",
                      style: TextStyle(
                        color: colortheme.theme.text.withValues(alpha: 0.65),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 22),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.only(bottom: 90, left: 16, right: 16),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final song = songs[index];
                    final isCurrentPlaying = currentplayprovider.song.path == song.path;
                    final activeAccent = colortheme.theme.tab;

                    return Dismissible(
                      key: Key(song.path),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.red.shade700,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: const Icon(Icons.delete, color: Colors.white),
                      ),
                      onDismissed: (direction) {
                        songProvider.deletesong(song);
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: Material(
                          color: isCurrentPlaying
                              ? activeAccent.withValues(alpha: 0.12)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(14),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(14),
                            onTap: () async {
                              Box<Song> box = Hive.box<Song>(widget.box);
                              currentplayprovider.changebox(box);
                              currentplayprovider.changesong(song);
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0),
                              child: Row(
                                children: [
                                  Container(
                                    width: 56,
                                    height: 56,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      border: isCurrentPlaying
                                          ? Border.all(color: activeAccent, width: 2)
                                          : null,
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(isCurrentPlaying ? 10 : 12),
                                      child: buildSongImage(
                                        base64Image: song.Image,
                                        width: 56,
                                        height: 56,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          song.title?.isNotEmpty == true ? song.title! : "Unknown Title",
                                          style: TextStyle(
                                            color: isCurrentPlaying
                                                ? activeAccent
                                                : colortheme.theme.text,
                                            fontSize: 16,
                                            fontWeight: isCurrentPlaying ? FontWeight.bold : FontWeight.w600,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 1,
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          song.artist?.isNotEmpty == true ? song.artist! : "Unknown Artist",
                                          style: TextStyle(
                                            color: colortheme.theme.text.withValues(alpha: 0.65),
                                            fontSize: 13,
                                            fontWeight: FontWeight.w400,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 1,
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (isCurrentPlaying)
                                    ValueListenableBuilder<bool>(
                                      valueListenable: currentplayprovider.isplaying,
                                      builder: (context, playing, _) {
                                        return Icon(
                                          playing ? Icons.equalizer_rounded : Icons.play_arrow_rounded,
                                          color: activeAccent,
                                          size: 24,
                                        );
                                      },
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                  childCount: songs.length,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}




// In-memory cache for first images of boxes to avoid re-reading Hive and flickering
final Map<String, String?> _firstImageCache = {};

// Function to load first image of list with caching
Future<String?> loadFirstImage(String boxName) async {
  if (_firstImageCache.containsKey(boxName)) {
    return _firstImageCache[boxName];
  }
  var box = Hive.isBoxOpen(boxName)
      ? Hive.box<Song>(boxName)
      : await Hive.openBox<Song>(boxName);
  final img = box.values.isNotEmpty ? box.values.first.Image : null;
  _firstImageCache[boxName] = img;
  return img;
}

// Widget to render thumbnail for a Hive box without flickering/blinking
class BoxThumbnail extends StatelessWidget {
  final String boxName;
  final String placeholderAsset;
  final double width;
  final double height;

  const BoxThumbnail({
    super.key,
    required this.boxName,
    required this.placeholderAsset,
    this.width = 70,
    this.height = 70,
  });

  @override
  Widget build(BuildContext context) {
    if (_firstImageCache.containsKey(boxName)) {
      final img = _firstImageCache[boxName];
      if (img != null && img.isNotEmpty) {
        return buildSongImage(base64Image: img, width: width, height: height);
      }
      return Image.asset(
        placeholderAsset,
        width: width,
        height: height,
        fit: BoxFit.cover,
        gaplessPlayback: true,
      );
    }

    if (Hive.isBoxOpen(boxName)) {
      try {
        final box = Hive.box<Song>(boxName);
        final img = box.values.isNotEmpty ? box.values.first.Image : null;
        _firstImageCache[boxName] = img;
        if (img != null && img.isNotEmpty) {
          return buildSongImage(base64Image: img, width: width, height: height);
        }
        return Image.asset(
          placeholderAsset,
          width: width,
          height: height,
          fit: BoxFit.cover,
          gaplessPlayback: true,
        );
      } catch (_) {}
    }

    return FutureBuilder<String?>(
      future: loadFirstImage(boxName),
      builder: (context, snapshot) {
        final img = snapshot.data ?? _firstImageCache[boxName];
        if (img != null && img.isNotEmpty) {
          return buildSongImage(base64Image: img, width: width, height: height);
        }
        return Image.asset(
          placeholderAsset,
          width: width,
          height: height,
          fit: BoxFit.cover,
          gaplessPlayback: true,
        );
      },
    );
  }
}

