// ==============================================================================
// File: lib/screens/songscreen.dart
// ------------------------------------------------------------------------------
// PURPOSE:
//   Contains the primary song listing screen (`SongScreen`), the full-screen music
//   player interface (`PlayerScreen`), and media utilities like image decoders
//   and file deletion checks.
//
// FLOW & ARCHITECTURE:
//   1. SongScreen (Primary Library Tab):
//      - Displays all songs loaded into `Songlistprovider`.
//      - Pull-to-Refresh: Triggers `fetchSongslist()` to scan new tracks,
//        `checkfordelete()` to prune deleted files from Hive, and `loadAlbum()`.
//      - Song Selection: Tapping any item highlights it, switches the active Hive
//        playback box to 'songs', and calls `currentplay.changesong(song)`.
//
//   2. buildSongImage Utility:
//      - Decodes base64-encoded album artwork from ID3 tags.
//      - Gracefully falls back to 'assets/default-music.png' if art is missing or invalid.
//
//   3. PlayerScreen (Full Player Interface):
//      - Reached by tapping `MiniPlayer` from anywhere in the app.
//      - Dynamic Theming: Styled using the randomized `currentplay.Theme` (S1-S6).
//      - Visual Feedback: Animated album cover enlarges when playing and shrinks when paused.
//      - Progress Slider: Subscribes to `currentplay.positionNotifier` for smooth seeking.
//      - Favorite / Liked: Heart icon adds the current song to the 'likedsongs' Hive box.
//      - Playlist Modal: Allows adding the active song to existing or new playlists.
//      - Sleep Timer: Modal bottom sheet allowing 10m, 20m, or custom minute shutdown timers.
//
//   4. Data Synchronization Helpers:
//      - `checkfordelete()`: Verifies local file existence; removes dead entries from Hive.
//      - `addSongtoplaylist()`: Safely adds a song to any target Hive box without duplicates.
// ==============================================================================

import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:music_app_2/main.dart';
import 'package:music_app_2/screens/albumscreen.dart';
import 'package:music_app_2/screens/artistscreen.dart';
import 'package:music_app_2/screens/playlistscreen.dart';
import 'package:music_app_2/theme/colors.dart';
import 'package:provider/provider.dart';
import 'package:music_app_2/provider_classes.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:music_app_2/store/songs.dart';
import 'package:flutter/cupertino.dart';
import 'dart:io';
import 'package:hive_flutter/hive_flutter.dart';


class SongScreen extends StatefulWidget {
  const SongScreen({super.key});

  @override
  State<SongScreen> createState() => _SongState();
}

class _SongState extends State<SongScreen> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  void initState()
  {
    super.initState();

  }
  Future<void> Refresh()async
  {
    await fetchSongslist(context);
    await checkfordelete(context);
    await loadAlbum(context);
    await loadArtist(context);
  }
  @override
  Widget build(BuildContext context) {
    super.build(context);
    final songProvider = Provider.of<Songlistprovider>(context);
    final colortheme = Provider.of<Themeprovider>(context);
    final currentplayprovider = Provider.of<currentplay>(context);

    final songs = songProvider.Songlist;
    final isScanning = songProvider.isScanning;

    Widget content;
    if (songs.isEmpty) {
      if (isScanning) {
        // Shimmer skeleton list while scanning initial songs
        content = ListView.builder(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.only(top: 4, bottom: 90),
          itemCount: 8,
          itemBuilder: (context, index) => ShimmerSongTile(theme: colortheme.theme),
        );
      } else {
        content = ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.only(top: 4, bottom: 90),
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.45,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.music_off_rounded,
                      size: 56,
                      color: colortheme.theme.tab.withValues(alpha: 0.5),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      "No Songs Found",
                      style: TextStyle(
                        color: colortheme.theme.text,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      "Pull down to scan for music files",
                      style: TextStyle(
                        color: colortheme.theme.text.withValues(alpha: 0.6),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      }
    } else {
      // Append trailing shimmer tiles when more songs are actively being scanned one by one
      final extraShimmerCount = isScanning ? 2 : 0;
      final totalItemCount = songs.length + extraShimmerCount;

      content = ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.only(top: 4, bottom: 90),
        itemCount: totalItemCount,
        itemBuilder: (context, index) {
          if (index >= songs.length) {
            // Trailing shimmer tile indicating ongoing loading
            return ShimmerSongTile(theme: colortheme.theme);
          }

          final song = songs[index];
          final isCurrent = currentplayprovider.song.path == song.path;

          if (isCurrent) {
            return GestureDetector(
              onTap: () async {
                Box<Song> box = Hive.box<Song>("songs");
                currentplayprovider.changebox(box);
                currentplayprovider.changesong(song);
              },
              child: ListTile(
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(90),
                          child: buildSongImage(
                            base64Image: song.Image,
                            width: 50,
                            height: 50,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        "${song.title}",
                        style: TextStyle(color: currentplayprovider.Theme.tab),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                        softWrap: true,
                      ),
                    ),
                  ],
                ),
              ),
            );
          } else {
            return GestureDetector(
              onTap: () async {
                Box<Song> box = Hive.box<Song>("songs");
                currentplayprovider.changebox(box);
                currentplayprovider.changesong(song);
              },
              child: ListTile(
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: buildSongImage(base64Image: song.Image),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        "${song.title}",
                        style: TextStyle(color: colortheme.theme.text),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                        softWrap: true,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
        },
      );
    }

    return MediaQuery.removePadding(
      context: context,
      removeTop: true,
      child: RefreshIndicator(
        onRefresh: Refresh,
        color: colortheme.theme.tab,
        backgroundColor: colortheme.theme.background,
        child: content,
      ),
    );
  }
}

// Animated shimmer effect driven by the active theme's colors
class ThemeShimmer extends StatefulWidget {
  final Widget child;
  final ThemeColor theme;

  const ThemeShimmer({
    super.key,
    required this.child,
    required this.theme,
  });

  @override
  State<ThemeShimmer> createState() => _ThemeShimmerState();
}

class _ThemeShimmerState extends State<ThemeShimmer> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.theme.background.computeLuminance() < 0.5;
    final baseColor = isDark
        ? widget.theme.text.withValues(alpha: 0.10)
        : widget.theme.text.withValues(alpha: 0.07);
    final highlightColor = isDark
        ? widget.theme.tab.withValues(alpha: 0.40)
        : widget.theme.tab.withValues(alpha: 0.30);

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              stops: const [0.0, 0.5, 1.0],
              colors: [
                baseColor,
                highlightColor,
                baseColor,
              ],
              transform: _SlidingGradientTransform(slidePercent: _controller.value),
            ).createShader(bounds);
          },
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

class _SlidingGradientTransform extends GradientTransform {
  final double slidePercent;
  const _SlidingGradientTransform({required this.slidePercent});

  @override
  Matrix4? transform(Rect bounds, {TextDirection? textDirection}) {
    return Matrix4.translationValues(bounds.width * (slidePercent * 2 - 1), 0.0, 0.0);
  }
}

// Skeleton placeholder tile that shimmers with the current theme colors
class ShimmerSongTile extends StatelessWidget {
  final ThemeColor theme;

  const ShimmerSongTile({super.key, required this.theme});

  @override
  Widget build(BuildContext context) {
    final isDark = theme.background.computeLuminance() < 0.5;
    final blockColor = isDark
        ? Colors.white.withValues(alpha: 0.08)
        : Colors.black.withValues(alpha: 0.06);

    return ThemeShimmer(
      theme: theme,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Row(
          children: [
            Container(
              width: 65,
              height: 65,
              decoration: BoxDecoration(
                color: blockColor,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    height: 16,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: blockColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 12,
                    width: 130,
                    decoration: BoxDecoration(
                      color: blockColor,
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// In-memory cache for decoded song cover bytes to eliminate re-decoding and blinking
final Map<String, Uint8List> _songImageBytesCache = {};

// Widget to build song profile image with memory caching and gapless playback
Widget buildSongImage({required String? base64Image, double width = 65, double height = 65}) {
  if (base64Image == null || base64Image.isEmpty) {
    return Image.asset(
      'assets/default-music.png',
      fit: BoxFit.cover,
      width: width,
      height: height,
      gaplessPlayback: true,
    );
  }

  try {
    Uint8List? imageBytes = _songImageBytesCache[base64Image];
    if (imageBytes == null) {
      imageBytes = base64Decode(base64Image);
      _songImageBytesCache[base64Image] = imageBytes;
    }

    return Image.memory(
      imageBytes,
      fit: BoxFit.cover,
      width: width,
      height: height,
      gaplessPlayback: true,
    );
  } catch (e) {
    return Image.asset(
      'assets/default-music.png',
      fit: BoxFit.cover,
      width: width,
      height: height,
      gaplessPlayback: true,
    );
  }
}

// Custom Hero flight shuttle builder for smooth, continuous corner radius morphing and glitch-free transitions
Widget buildArtworkHeroShuttle(
  BuildContext flightContext,
  Animation<double> animation,
  HeroFlightDirection flightDirection,
  BuildContext fromHeroContext,
  BuildContext toHeroContext,
) {
  // Use the Hero widget with full/unconstrained dimensions (from PlayerScreen)
  // so the image scales and covers the flying Hero bounds cleanly at every frame.
  final Hero targetHero = (flightDirection == HeroFlightDirection.push
      ? toHeroContext.widget
      : fromHeroContext.widget) as Hero;

  final Widget rawChild = targetHero.child is ClipRRect
      ? (targetHero.child as ClipRRect).child ?? targetHero.child
      : targetHero.child;

  final double startRadius =
      flightDirection == HeroFlightDirection.push ? 10.0 : 16.0;
  final double endRadius =
      flightDirection == HeroFlightDirection.push ? 16.0 : 10.0;

  final curvedAnimation = CurvedAnimation(
    parent: animation,
    curve: Curves.easeInOutCubic,
  );

  return AnimatedBuilder(
    animation: curvedAnimation,
    builder: (context, _) {
      final double radius = Tween<double>(
        begin: startRadius,
        end: endRadius,
      ).evaluate(curvedAnimation);

      return ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: Material(
          type: MaterialType.transparency,
          child: rawChild,
        ),
      );
    },
  );
}


class PlayerScreen extends StatefulWidget {


  const PlayerScreen({super.key});

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  @override
  Widget build(BuildContext context) {
    final currentplayprovider = Provider.of<currentplay>(context);
    final playlist = Provider.of<playlistprovider>(context);
    return Material(
      color: currentplayprovider.Theme.background,
      child: Scaffold(
          backgroundColor: currentplayprovider.Theme.background,
          body: Stack(
            children: [
              Center(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 64),
                      ValueListenableBuilder<bool>(
                          valueListenable: currentplayprovider.isplaying,
                          builder: (context, playing, child) {
                            return Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 400),
                                curve: Curves.easeInOut,
                                width: playing ? 300 : 250,
                                height: playing ? 300 : 250,
                                child: Hero(
                                  tag: 'current_song_artwork',
                                  flightShuttleBuilder: buildArtworkHeroShuttle,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(16),
                                    child: buildSongImage(
                                      base64Image: currentplayprovider.song.Image,
                                      width: double.infinity,
                                      height: double.infinity,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }),

                      const SizedBox(height: 12),

                      // Title, Artist, and Favorite button properly aligned with padding
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    currentplayprovider.song.title?.isNotEmpty == true
                                        ? currentplayprovider.song.title!
                                        : "Unknown Title",
                                    style: TextStyle(
                                      color: currentplayprovider.Theme.tab,
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      height: 1.25,
                                      decoration: TextDecoration.none,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 2,
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    currentplayprovider.song.artist?.isNotEmpty == true
                                        ? currentplayprovider.song.artist!
                                        : "Unknown Artist",
                                    style: TextStyle(
                                      color: currentplayprovider.Theme.text.withValues(alpha: 0.75),
                                      fontSize: 15,
                                      fontWeight: FontWeight.w500,
                                      decoration: TextDecoration.none,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  ),
                                ],
                              ),
                            ),
                              const SizedBox(width: 12),
                              IconButton(
                                onPressed: () async {
                                  var box = Hive.box<Song>("likedsongs");
                                  addSongtoplaylist(currentplayprovider.song, box);
                                  showToast("Liked ${currentplayprovider.song.title}");
                                },
                                icon: Icon(
                                  CupertinoIcons.heart_fill,
                                  color: currentplayprovider.Theme.tab,
                                  size: 28,
                                ),
                              ),
                            ],
                          ),
                        ),

                        ValueListenableBuilder<Duration>(
                            valueListenable: currentplayprovider.positionNotifier,
                            builder: (context, position, child) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                child: Material(
                                  color: currentplayprovider.Theme.background,
                                  child: SliderTheme(
                                    data: SliderThemeData(
                                      activeTrackColor: currentplayprovider.Theme.tab,
                                      thumbColor: currentplayprovider.Theme.tab,
                                      overlayColor: currentplayprovider.Theme.tab.withValues(alpha: 0.2),
                                      thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 0),
                                      trackHeight: 10.0,
                                    ),
                                    child: Slider(
                                      min: 0,
                                      max: currentplayprovider.duration?.inSeconds.toDouble() ?? 1,
                                      value: position.inSeconds.toDouble().clamp(0, currentplayprovider.duration?.inSeconds.toDouble() ?? 1),
                                      onChanged: (value) {
                                        WidgetsBinding.instance.addPostFrameCallback((_) {
                                          currentplayprovider.seektoposition(value);
                                        });
                                      },
                                    ),
                                  ),
                                ),
                              );
                            }),

                        ValueListenableBuilder<Duration>(
                            valueListenable: currentplayprovider.positionNotifier,
                            builder: (context, position, child) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 24),
                                child: Material(
                                  color: currentplayprovider.Theme.background,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        formatDuration(position),
                                        style: TextStyle(
                                          color: currentplayprovider.Theme.text.withValues(alpha: 0.75),
                                          fontSize: 13,
                                        ),
                                      ), // Current Time
                                      Text(
                                        formatDuration(currentplayprovider.duration ?? Duration.zero),
                                        style: TextStyle(
                                          color: currentplayprovider.Theme.text.withValues(alpha: 0.75),
                                          fontSize: 13,
                                        ),
                                      ), // Total Time
                                    ],
                                  ),
                                ),
                              );
                            }),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            IconButton(onPressed: (){
                              currentplayprovider.prevsong();
                            }, icon: Icon(CupertinoIcons.backward_fill,color: currentplayprovider.Theme.tab,size: 45,)),
                            ValueListenableBuilder<bool>(
                                valueListenable: currentplayprovider.isplaying,
                                builder:(context,playing,child){
                                  return AnimatedSwitcher(
                                    duration: Duration(milliseconds: 500), // Smooth transition
                                    transitionBuilder: (Widget child, Animation<double> animation) {
                                      return ScaleTransition(scale: animation, child: child);

                                    },
                                    child: IconButton(
                                      key: ValueKey<bool>(playing), // Prevents unnecessary rebuilds
                                      onPressed: () {
                                        if (playing)
                                          currentplayprovider.pause();
                                        else
                                          currentplayprovider.playSong();
                                      },
                                      icon: Icon(
                                        playing
                                            ? CupertinoIcons.pause_fill
                                            : CupertinoIcons.play_arrow_solid,
                                        color: currentplayprovider.Theme.tab,
                                        size: 45,
                                      ),
                                    ),
                                  );
                                }),
                            IconButton(onPressed: (){
                              currentplayprovider.nextsong();
                            }, icon: Icon(CupertinoIcons.forward_fill,color: currentplayprovider.Theme.tab,size: 45,)),
                          ],
                        ),
                        
                        Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                            IconButton(onPressed: (){}, icon: Icon(Icons.equalizer,color: currentplayprovider.Theme.tab,size: 30,)),
                            IconButton(onPressed: (){
                            //playlist add
                              showModalBottomSheet(
                                  backgroundColor: currentplayprovider.Theme.background,
                                  context: context,
                                  shape: const RoundedRectangleBorder(
                                    borderRadius: BorderRadius.vertical(top: Radius.circular(16))
                                  ),
                                  builder: (context){
                                    return Padding(padding: EdgeInsets.all(16.0),
                                    child: Column(
                                      //mainAxisAlignment: MainAxisAlignment.center,
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Text("Add to Playlist",style: TextStyle(
                                              color: currentplayprovider.Theme.tab,fontSize: 30,fontWeight: FontWeight.bold),),
                                        ),

                                        Flexible(
                                          child: ListView.separated(
                                            shrinkWrap: true,
                                              separatorBuilder: (_,_)=>const SizedBox(height: 2,),
                                              itemCount: playlist.playlists.length+1,
                                            itemBuilder: (context, index) {
                                              if (index < playlist.playlists.length) {
                                                return ListTile(
                                                  leading: ClipRRect(
                                                    borderRadius: BorderRadius.circular(12),
                                                    child: Image.asset(
                                                      "assets/music.png",
                                                      width: 50,
                                                      height: 50,
                                                      fit: BoxFit.cover,
                                                    ),
                                                  ),
                                                  title: Text(
                                                    playlist.playlists[index],
                                                    style: TextStyle(
                                                      color: currentplayprovider.Theme.text,
                                                      fontSize: 18,
                                                    ),
                                                  ),
                                                  onTap: () async{
                                                    // Handle playlist selection
                                                    Box<Song> box=await Hive.box<Song>(playlist.playlists[index]);
                                                    addSongtoplaylist(currentplayprovider.song, box);
                                                    showToast("${currentplayprovider.song.title} was added in ${playlist.playlists[index]}");
                                                    print("${playlist.playlists[index]}");
                                                    if (Navigator.of(context).canPop()) {
                                                      Navigator.of(context).pop();
                                                    }

                                                  },
                                                );
                                              } else {
                                                return ListTile(
                                                  leading: Icon(Icons.add, size: 40, color: currentplayprovider.Theme.tab),
                                                  title: Text(
                                                    "New Playlist",
                                                    style: TextStyle(fontSize: 18, color:currentplayprovider.Theme.text,fontWeight: FontWeight.w500),
                                                  ),
                                                  onTap: () async{
                                                    // Handle creating a new playlist
                                                   showPlaylistDialog(context,song: currentplayprovider.song);

                                                  },
                                                );
                                              }
                                            },
                                              ),
                                        ),
                                      ],
                                    ),
                                    );
                                  });

                            }, icon: Icon(Icons.add_to_photos,color: currentplayprovider.Theme.tab,size: 30,)),
                              IconButton(onPressed: (){
                                showModalBottomSheet(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.vertical(top: Radius.circular(20))
                                  ),
                                    backgroundColor: currentplayprovider.Theme.background,
                                    context: context,
                                    builder: (context){
                                     return Padding(
                                       padding: const EdgeInsets.symmetric(horizontal: 16,vertical: 20),
                                       child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                         crossAxisAlignment: CrossAxisAlignment.start,
                                         children: [
                                           // Title
                                           Center(
                                             child: Text(
                                               "Sleep Timer",
                                               style: TextStyle(
                                                 fontSize: 23,
                                                 fontWeight: FontWeight.bold,
                                                 color: currentplayprovider.Theme.tab,
                                               ),
                                             ),
                                           ),
                                           const SizedBox(height: 16),
                                           // Turn Off Timer Option
                                           _buildOption(
                                             context,
                                             label: "Turn Off",
                                             icon: Icons.cancel,
                                             onTap: () {
                                               currentplayprovider.stopTimer();
                                               if (Navigator.of(context).canPop()) {
                                                 Navigator.of(context).pop();
                                               }

                                               showToast("Sleep Timer turned off");
                                             },
                                           ),

                                           // Predefined Timer Options
                                           _buildOption(
                                             context,
                                             label: "10 Minutes",
                                             icon: Icons.timer,
                                             onTap: () {
                                               currentplayprovider.starttimer(10);
                                               if (Navigator.of(context).canPop()) {
                                                 Navigator.of(context).pop();
                                               }

                                               showToast("Sleep Timer set to 10 Minutes");
                                             },
                                           ),
                                           _buildOption(
                                             context,
                                             label: "20 Minutes",
                                             icon: Icons.timer,
                                             onTap: () {
                                               currentplayprovider.starttimer(20);
                                               if (Navigator.of(context).canPop()) {
                                                 Navigator.of(context).pop();
                                               }

                                               showToast("Sleep Timer set to 20 Minutes");
                                             },
                                           ),
                                           // Custom Timer Option
                                           _buildOption(
                                             context,
                                             label: "Custom",
                                             icon: CupertinoIcons.time,
                                             trailingIcon: CupertinoIcons.right_chevron,
                                             onTap: () async {
                                               if (Navigator.of(context).canPop()) {
                                                 Navigator.of(context).pop();
                                               }

                                               int? customMinutes = await showMinutesInputDialog(context);
                                               if (customMinutes != null) {
                                                 currentplayprovider.starttimer(customMinutes);
                                                 if (Navigator.of(context).canPop()) {
                                                   Navigator.of(context).pop();
                                                 }

                                                 showToast("Sleep Timer set to $customMinutes Minutes");
                                               }
                                             },
                                           ),
                                         ],
                                       ),
                                     );
                                    });
                              }, icon: Column(
                                children: [
                                  Icon(CupertinoIcons.clock_solid,color: currentplayprovider.Theme.tab,size: 30,),
                                  currentplayprovider.timer!=null?ValueListenableBuilder<int>(
                                      valueListenable: currentplayprovider.secondsRemaining,
                                      builder:(context,value,child)
                                      {
                                        int minutes=value~/60;
                                        int seconds=value%60;
                                        String time="$minutes:${seconds.toString().padLeft(2,'0')}";
                                        return Text("$time",style: TextStyle(color: currentplayprovider.Theme.tab),);
                                      }

                                  ):SizedBox.shrink()
                                ],
                              )),
                          ],),
                        )

                      ],
                    ),
                  ),
                ),
              // Top navigation bar with back arrow and title
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () {
                          if (Navigator.of(context).canPop()) {
                            Navigator.of(context).pop();
                          }
                        },
                        icon: Icon(
                          Icons.keyboard_arrow_down_rounded,
                          size: 38,
                          color: currentplayprovider.Theme.tab,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          currentplayprovider.song.title ?? "",
                          style: TextStyle(
                            color: currentplayprovider.Theme.tab,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            decoration: TextDecoration.none,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                      const SizedBox(width: 48),
                    ],
                  ),
                ),
              ),
            ],
          ),
      
      ),
    );
  }
  String formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    return "${twoDigits(duration.inMinutes)}:${twoDigits(duration.inSeconds.remainder(60))}";
  }
  // ✅ Reusable function to create list options
  Widget _buildOption(BuildContext context,
      {required String label, required IconData icon, IconData? trailingIcon, required VoidCallback onTap}) {

    final colortheme=Provider.of<currentplay>(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(icon, size: 30, color:colortheme.Theme.tab ),
                const SizedBox(width: 12),
                Text(
                  label,
                  style: TextStyle(fontSize: 18, color:colortheme.Theme.text ),
                ),
              ],
            ),
            if (trailingIcon != null) Icon(trailingIcon, size: 20, color:colortheme.Theme.tab),
          ],
        ),
      ),
    );
  }


  // ✅ Custom Input Dialog for Custom Timer
  Future<int?> showMinutesInputDialog(BuildContext context) async {
    TextEditingController controller = TextEditingController();

    return await showDialog<int>(
      context: context,
      builder: (BuildContext context) {
        final colortheme=Provider.of<currentplay>(context);
        return AlertDialog(
          backgroundColor: colortheme.Theme.background,
          title: Text("Enter Minutes",style: TextStyle(color: colortheme.Theme.tab),),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.number,

            decoration: InputDecoration(
              hintText: "Enter minutes",
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                if (Navigator.of(context).canPop()) {
                  Navigator.of(context).pop();
                }

              },
              child: Text("Cancel",style: TextStyle(color: colortheme.Theme.text),),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: colortheme.Theme.tab
              ),
              onPressed: () {
                int? minutes = int.tryParse(controller.text.trim());
                if (minutes != null && minutes > 0) {
                  if (Navigator.of(context).canPop()) {
                    Navigator.of(context).pop();
                  }

                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Please enter a valid number")),
                  );
                }
              },
              child:Text("Start",style: TextStyle(color: colortheme.Theme.background),),
            ),
          ],
        );
      },
    );
  }

}


//function to delete the song
Future<void> checkfordelete(context)async
{
  final songlist=Provider.of<Songlistprovider>(context,listen: false);
  var songs=songlist.Songlist;
   for(var song in songs)
     {
       File file=File(song.path);
       bool exitst=await file.exists();
       if(!exitst)
         songlist.deletesong(song);
     }
}



//function to add song in playlist
void addSongtoplaylist(Song song,var songbox) {
  List<Song> songList = songbox.values.cast<Song>().toList(); // Ensure correct type

  final newPath = song.path.trim().toLowerCase();
  final newTitle = (song.title ?? '').trim().toLowerCase();
  final newArtist = (song.artist ?? '').trim().toLowerCase();

  // Check if the song is already in the playlist by path or title+artist
  for (Song oldSong in songList) {
    final oldPath = oldSong.path.trim().toLowerCase();
    final oldTitle = (oldSong.title ?? '').trim().toLowerCase();
    final oldArtist = (oldSong.artist ?? '').trim().toLowerCase();

    if ((newPath.isNotEmpty && oldPath == newPath) ||
        (newTitle.isNotEmpty &&
            oldTitle == newTitle &&
            newArtist.isNotEmpty &&
            newArtist != 'unknown' &&
            newArtist != 'unknown artist' &&
            oldArtist == newArtist)) {
      return;
    }
  }
// Create a new instance before adding
  Song newSong = Song(path: song.path,
   title: song.title,
    artist: song.artist,
    album: song.album,
    Image: song.Image,
    publisher: song.publisher,
    genre: song.genre
  );


  songbox.add(newSong); // Add the new song
  print("New song added: ${song.title} songlist : $songList");
}