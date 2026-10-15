// ==============================================================================
// File: lib/screens/homescreen.dart
// ------------------------------------------------------------------------------
// PURPOSE:
//   Main navigation dashboard for the music app. Houses the top action bar,
//   the theme selector, the tabbed page view for library browsing, and the
//   persistent bottom `MiniPlayer`.
//
// FLOW & ARCHITECTURE:
//   1. Layout & Scaffold:
//      - Wrapped in `GlobalScaffold` to maintain uniform background colors and
//        display the `MiniPlayer` at the bottom of the screen.
//      - Built with a `NestedScrollView` featuring two sliver headers:
//          * Header 1: App branding, Search action icon (navigates to `searchScreen`),
//                      and Theme settings icon (opens a bottom sheet with color palettes).
//          * Header 2: Horizontal scrollable tab buttons ("Songs", "Playlists", "Albums", "Artist").
//
//   2. PageView Navigation:
//      - Page 0: `SongScreen`     - Complete list of all songs on device.
//      - Page 1: `Playlistscreen` - Custom user-created playlists and Liked Songs.
//      - Page 2: `Album`          - Songs organized by album tags.
//      - Page 3: `Artistscreen`   - Songs organized by artist tags.
//
//   3. MiniPlayer Component:
//      - Listens to `currentplay` provider. If a song is active:
//          * Displays thumbnail artwork, title, previous, play/pause, and next buttons.
//          * Tapping anywhere on the bar navigates to the full `PlayerScreen` via
//            a smooth Hero transition with corner radius interpolation.
// ==============================================================================

import 'package:flutter/material.dart';
import 'package:music_app_2/global_scaffold.dart';
import 'package:music_app_2/main.dart';
import 'package:music_app_2/screens/albumscreen.dart';
import 'package:music_app_2/screens/artistscreen.dart';
import 'package:music_app_2/screens/playlistscreen.dart';
import 'package:music_app_2/screens/searchscreen.dart';
import 'package:music_app_2/screens/songscreen.dart';
import 'package:provider/provider.dart';
import 'package:music_app_2/provider_classes.dart';
import 'package:cupertino_icons/cupertino_icons.dart';
import 'package:flutter/cupertino.dart';
import 'dart:io';
import 'package:music_app_2/theme/colors.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const List<String> pages = ["Songs", "Playlists", "Albums", "Artist"];
  static const List<IconData> pageIcons = [
    CupertinoIcons.music_note_2,
    CupertinoIcons.music_albums,
    CupertinoIcons.square_stack_3d_down_right,
    CupertinoIcons.person_2_fill,
  ];

  final PageController _pageController = PageController();
  int _currentPage = 0;

  Color _getContrastingTextColor(Color background) {
    return background.computeLuminance() > 0.45 ? Colors.black87 : Colors.white;
  }

  Widget _buildActionIconButton({
    required IconData icon,
    required String tooltip,
    required Color color,
    required Color backgroundColor,
    required VoidCallback onTap,
  }) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(22),
          child: Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: backgroundColor,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 20,
              color: color,
            ),
          ),
        ),
      ),
    );
  }

  static final Map<String, ({ThemeColor theme, String label})> _darkThemes = {
    "darkblue": (theme: DarkBlue(), label: "Dark Blue"),
    "darkgreen": (theme: DarkGreen(), label: "Emerald"),
    "darkpink": (theme: DarkPink(), label: "Magenta"),
    "darkorange": (theme: DarkOrange(), label: "Sunset"),
    "darkred": (theme: DarkRed(), label: "Crimson"),
  };

  static final Map<String, ({ThemeColor theme, String label})> _lightThemes = {
    "whiteblue": (theme: WhiteBlue(), label: "Sky Blue"),
    "whitegreen": (theme: WhiteGreen(), label: "Mint"),
    "whitepink": (theme: WhitePink(), label: "Rose"),
    "whiteorange": (theme: WhiteOrange(), label: "Peach"),
    "whitered": (theme: WhiteRed(), label: "Coral"),
  };

  void _showThemeModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (modalContext) {
        return Consumer<Themeprovider>(
          builder: (context, colortheme, child) {
            return Container(
              decoration: BoxDecoration(
                color: colortheme.theme.background,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Top drag handle
                      Container(
                        width: 44,
                        height: 4,
                        decoration: BoxDecoration(
                          color: colortheme.theme.text.withValues(alpha: 0.25),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(CupertinoIcons.paintbrush_fill, color: colortheme.theme.tab, size: 22),
                          const SizedBox(width: 8),
                          Text(
                            "Select Theme",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: colortheme.theme.text,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "DARK PALETTES",
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.2,
                            color: colortheme.theme.text.withValues(alpha: 0.55),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 14,
                        runSpacing: 12,
                        alignment: WrapAlignment.center,
                        children: _darkThemes.entries.map((entry) {
                          return _buildThemeItem(
                            themeKey: entry.key,
                            theme: entry.value.theme,
                            label: entry.value.label,
                            isSelected: colortheme.currentThemeKey == entry.key,
                            onTap: () => colortheme.settheme(entry.key),
                            activeColor: colortheme.theme.tab,
                            textColor: colortheme.theme.text,
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 18),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "LIGHT PALETTES",
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.2,
                            color: colortheme.theme.text.withValues(alpha: 0.55),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 14,
                        runSpacing: 12,
                        alignment: WrapAlignment.center,
                        children: _lightThemes.entries.map((entry) {
                          return _buildThemeItem(
                            themeKey: entry.key,
                            theme: entry.value.theme,
                            label: entry.value.label,
                            isSelected: colortheme.currentThemeKey == entry.key,
                            onTap: () => colortheme.settheme(entry.key),
                            activeColor: colortheme.theme.tab,
                            textColor: colortheme.theme.text,
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 14),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildThemeItem({
    required String themeKey,
    required ThemeColor theme,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    required Color activeColor,
    required Color textColor,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: theme.background,
              border: Border.all(
                color: isSelected ? theme.tab : theme.tab.withValues(alpha: 0.3),
                width: isSelected ? 3.0 : 1.5,
              ),
            ),
            child: Center(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: isSelected ? 24 : 20,
                height: isSelected ? 24 : 20,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: theme.tab,
                ),
                child: isSelected
                    ? Icon(
                        Icons.check,
                        size: 15,
                        color: _getContrastingTextColor(theme.tab),
                      )
                    : null,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              color: isSelected ? activeColor : textColor.withValues(alpha: 0.75),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colortheme = Provider.of<Themeprovider>(context);

    return GlobalScaffold(
      child: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          // 1. Sleek Main Top Bar (No shadow, no extra labels)
          SliverAppBar(
            backgroundColor: colortheme.theme.background,
            surfaceTintColor: Colors.transparent,
            shadowColor: Colors.transparent,
            floating: true,
            snap: true,
            pinned: false,
            elevation: 0,
            scrolledUnderElevation: 0,
            toolbarHeight: 64,
            titleSpacing: 16,
            title: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(
                    'assets/music-player.png',
                    width: 38,
                    height: 38,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  "Music Player",
                  style: TextStyle(
                    color: colortheme.theme.text,
                    fontSize: 21,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.2,
                  ),
                ),
              ],
            ),
            actions: [
              _buildActionIconButton(
                icon: CupertinoIcons.search,
                tooltip: "Search songs",
                color: colortheme.theme.text,
                backgroundColor: colortheme.theme.text.withValues(alpha: 0.08),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChangeNotifierProvider(
                        create: (context) => searchProvider(),
                        child: const searchScreen(),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(width: 10),
              _buildActionIconButton(
                icon: CupertinoIcons.paintbrush_fill,
                tooltip: "App Theme",
                color: colortheme.theme.tab,
                backgroundColor: colortheme.theme.tab.withValues(alpha: 0.15),
                onTap: () => _showThemeModal(context),
              ),
              const SizedBox(width: 16),
            ],
          ),

          // 2. Pinned Flat Tab Bar (Proper padding, proper margins, no tricky shadows)
          SliverPersistentHeader(
            pinned: true,
            delegate: _TabHeaderDelegate(
              height: 48.0,
              backgroundColor: colortheme.theme.background,
              child: SizedBox(
                height: 38,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  separatorBuilder: (_, __) => const SizedBox(width: 10),
                  itemCount: pages.length,
                  itemBuilder: (context, index) {
                    final isSelected = _currentPage == index;
                    return GestureDetector(
                      onTap: () {
                        _pageController.animateToPage(
                          index,
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                        setState(() {
                          _currentPage = index;
                        });
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        curve: Curves.easeInOut,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: isSelected
                              ? colortheme.theme.tab
                              : colortheme.theme.text.withValues(alpha: 0.08),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              pageIcons[index],
                              size: 16,
                              color: isSelected
                                  ? _getContrastingTextColor(colortheme.theme.tab)
                                  : colortheme.theme.text.withValues(alpha: 0.8),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              pages[index],
                              style: TextStyle(
                                fontSize: 13.5,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                color: isSelected
                                    ? _getContrastingTextColor(colortheme.theme.tab)
                                    : colortheme.theme.text.withValues(alpha: 0.8),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      body: PageView(
        controller: _pageController,
        onPageChanged: (index){
          WidgetsBinding.instance.addPostFrameCallback((_) {
            setState(() {
              _currentPage=index;
            }); // ✅ Delays the state update
          });
        },
        children: [
          SongScreen(),
          Playlistscreen(),
          ChangeNotifierProvider(create: (context)=>playlistprovider("album"),
            child: Album(),
          ),
          ChangeNotifierProvider(create: (context)=>playlistprovider("artist"),
            child: Artistscreen(),
          ),
        ],
      ),
    ));
  }
}

class _TabHeaderDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;
  final double height;
  final Color backgroundColor;

  _TabHeaderDelegate({
    required this.child,
    this.height = 56.0,
    required this.backgroundColor,
  });

  @override
  double get minExtent => height;

  @override
  double get maxExtent => height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: backgroundColor,
      alignment: Alignment.center,
      child: child,
    );
  }

  @override
  bool shouldRebuild(covariant _TabHeaderDelegate oldDelegate) {
    return oldDelegate.backgroundColor != backgroundColor ||
        oldDelegate.child != child ||
        oldDelegate.height != height;
  }
}


//mini player
class MiniPlayer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final currentPlayProvider = Provider.of<currentplay>(context);

    if (currentPlayProvider.song.path.isEmpty) return SizedBox.shrink();

    return BottomAppBar(
      height: 100,
      color: Colors.transparent,
      child: GestureDetector(
        onTap: () {
          Navigator.of(context).push(
            PageRouteBuilder(
              opaque: true,
              transitionDuration: const Duration(milliseconds: 320),
              reverseTransitionDuration: const Duration(milliseconds: 280),
              pageBuilder: (context, animation, secondaryAnimation) =>
                  const PlayerScreen(),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                return FadeTransition(
                  opacity: CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeInOut,
                  ),
                  child: child,
                );
              },
            ),
          );
        },
        child: Container(
          decoration: BoxDecoration(
            color: currentPlayProvider.Theme.background,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Hero(
                  tag: 'current_song_artwork',
                  flightShuttleBuilder: buildArtworkHeroShuttle,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: buildSongImage(
                      base64Image: currentPlayProvider.song.Image,
                    ),
                  ),
                ),
                SizedBox(width: 5),
                Expanded(
                  child: Material(
                    color: currentPlayProvider.Theme.background,
                    child: Text(
                      "${currentPlayProvider.song.title}",
                      style: TextStyle(
                        color: currentPlayProvider.Theme.text,
                        fontSize: 18,
                        decoration: TextDecoration.none,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                      softWrap: true,
                    ),
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      onPressed: () => currentPlayProvider.prevsong(),
                      icon: Icon(
                        CupertinoIcons.backward_fill,
                        color: currentPlayProvider.Theme.tab,
                      ),
                    ),
                    ValueListenableBuilder<bool>(
                      valueListenable: currentPlayProvider.isplaying,
                      builder: (context, playing, child) {
                        return AnimatedSwitcher(
                          duration: Duration(milliseconds: 500),
                          transitionBuilder: (child, animation) =>
                              ScaleTransition(scale: animation, child: child),
                          child: IconButton(
                            key: ValueKey<bool>(playing),
                            onPressed: () => playing
                                ? currentPlayProvider.pause()
                                : currentPlayProvider.playSong(),
                            icon: Icon(
                              playing
                                  ? CupertinoIcons.pause_fill
                                  : CupertinoIcons.play_arrow_solid,
                              color: currentPlayProvider.Theme.tab,
                              size: 30,
                            ),
                          ),
                        );
                      },
                    ),
                    IconButton(
                      onPressed: () => currentPlayProvider.nextsong(),
                      icon: Icon(
                        CupertinoIcons.forward_fill,
                        color: currentPlayProvider.Theme.tab,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}



