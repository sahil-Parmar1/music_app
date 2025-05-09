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
  List<String> pages=["Songs","Playlists","Albums","Artist"];
  final PageController _pageController=PageController();
  int _currentPage=0;

  @override
  Widget build(BuildContext context) {

    final colortheme=Provider.of<Themeprovider>(context);
    final currentplayprovider=Provider.of<currentplay>(context);
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return GlobalScaffold(child: NestedScrollView(
      headerSliverBuilder: (context,innerBoxIsScrolled)=>[


        SliverAppBar(
          expandedHeight: MediaQuery.of(context).size.height * 0.08, // 8% of screen height
          backgroundColor: colortheme.theme.background,
          floating: true,
          snap: true,
          pinned: false,
          flexibleSpace: FlexibleSpaceBar(
            titlePadding: EdgeInsets.symmetric(
              horizontal: MediaQuery.of(context).size.width * 0.03, // 3% of screen width
              vertical: 8.0, // Fixed vertical padding for consistency
            ),
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Profile Image
                ClipOval(
                  child: Image.asset(
                    'assets/music-player.png',
                    width: MediaQuery.of(context).size.width * 0.08, // 8% of screen width
                    height: MediaQuery.of(context).size.width * 0.08,
                    fit: BoxFit.cover,
                  ),
                ),
                SizedBox(width: MediaQuery.of(context).size.width * 0.02), // 2% spacing

                // Title
                Expanded(
                  child: Text(
                    "Music Player",
                    style: TextStyle(
                      color: colortheme.theme.text,
                      fontSize: MediaQuery.of(context).size.width * 0.045, // 4.5% of screen width
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                 SizedBox(width: MediaQuery.of(context).size.width * 0.02), // 2% spacing

                // Search Icon
                IconButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChangeNotifierProvider(
                          create: (context) => searchProvider(),
                          child: searchScreen(),
                        ),
                      ),
                    );
                  },
                  icon: Icon(
                    CupertinoIcons.search,
                    size: MediaQuery.of(context).size.width * 0.06, // 6% of screen width
                    color: colortheme.theme.text,
                  ),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),

                // Settings Icon
                IconButton(
                  onPressed: () {
                    showModalBottomSheet(
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                      ),
                      backgroundColor: colortheme.theme.background,
                      context: context,
                      builder: (context) {
                        final Map<String, ThemeColor> themes = {
                          "darkblue": DarkBlue(),
                          "darkgreen": DarkGreen(),
                          "darkpink": DarkPink(),
                          "darkorange": DarkOrange(),
                          "darkred": DarkRed(),
                          "whiteblue": WhiteBlue(),
                          "whitegreen": WhiteGreen(),
                          "whitepink": WhitePink(),
                          "whiteorange": WhiteOrange(),
                          "whitered": WhiteRed(),
                        };
                        return Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 8.0),
                                child: Text(
                                  "Select Theme",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 23,
                                    fontWeight: FontWeight.bold,
                                    color: colortheme.theme.tab,
                                  ),
                                ),
                              ),
                              Wrap(
                                spacing: 12,
                                runSpacing: 12,
                                alignment: WrapAlignment.center,
                                children: themes.entries.map((entry) {
                                  String themekey = entry.key;
                                  ThemeColor theme = entry.value;
                                  return GestureDetector(
                                    onTap: () => colortheme.settheme(themekey),
                                    child: AnimatedContainer(
                                      duration: const Duration(milliseconds: 300),
                                      width: 60,
                                      height: 60,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: theme.tab,
                                        boxShadow: [
                                          BoxShadow(
                                            color: colortheme.theme.background,
                                            blurRadius: 8,
                                            spreadRadius: 2,
                                            offset: const Offset(2, 4),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                              const SizedBox(height: 20),
                            ],
                          ),
                        );
                      },
                    );
                  },
                  icon: Icon(
                    CupertinoIcons.settings,
                    size: MediaQuery.of(context).size.width * 0.06, // 6% of screen width
                    color: colortheme.theme.text,
                  ),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),
        ),

        SliverAppBar(
          backgroundColor: colortheme.theme.background,
          floating: false,
          pinned: true,
          toolbarHeight: MediaQuery.of(context).size.height * 0.02, // Adjusted height
          flexibleSpace: FlexibleSpaceBar(
            titlePadding: EdgeInsets.only(
              left: MediaQuery.of(context).size.width * 0.02, // Dynamic padding
              bottom: MediaQuery.of(context).size.height * 0.005,
            ),
            title: SizedBox(
              height: MediaQuery.of(context).size.height * 0.06, // Responsive height
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: pages.length,
                itemBuilder: (context, index) {
                  bool isSelected = _currentPage == index;

                  return Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: MediaQuery.of(context).size.width * 0.01,
                      vertical: MediaQuery.of(context).size.height * 0.005,
                    ),
                    child: GestureDetector(
                      onTap: () {
                        _pageController.animateToPage(
                          index,
                          duration: Duration(milliseconds: 500),
                          curve: Curves.easeInOut,
                        );
                        _currentPage = index;
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          vertical: MediaQuery.of(context).size.height * 0.012,
                          horizontal: MediaQuery.of(context).size.width * 0.04,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(25),
                          color: isSelected
                              ? colortheme.theme.tab
                              : colortheme.theme.background,
                        ),
                        child: Text(
                          "${pages[index]}",
                          style: TextStyle(
                            fontSize: MediaQuery.of(context).size.width * 0.04,
                            color: isSelected ? Colors.black : colortheme.theme.text,
                          ),
                        ),
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
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => PlayerScreen()),
          );
        },
        child: Hero(
          tag: 'player',
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
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: buildSongImage(base64Image: currentPlayProvider.song.Image),
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
      ),
    );
  }
}



