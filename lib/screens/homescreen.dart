import 'package:flutter/material.dart';
import 'package:music_app_2/main.dart';
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
    return Scaffold(
      backgroundColor: colortheme.theme.background,
      body: NestedScrollView(
          headerSliverBuilder: (context,innerBoxIsScrolled)=>[
            SliverAppBar(
              expandedHeight: 60.0,
              backgroundColor: colortheme.theme.background,
              floating: true,
              snap: true,
             pinned: false,
              flexibleSpace: FlexibleSpaceBar(
               titlePadding: EdgeInsets.only(left: 10, right: 10),
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        ClipOval(
                          child: Image.asset(
                           //'https://th.bing.com/th/id/OIP.AotjEfWpHSZoqpMhu2uvDQAAAA?rs=1&pid=ImgDetMain',
                           'assets/music-player.png',
                            width: 30, // Slightly smaller
                            height: 30,
                            fit: BoxFit.cover,
                          ),
                        ),

                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            "Music Player",
                            style: TextStyle(
                              color: colortheme.theme.text,
                              fontSize: 20, // Slightly reduced
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Row(
                       children: [
                         IconButton(
                           onPressed: () {},
                           icon: Icon(CupertinoIcons.search, size: 20, color: colortheme.theme.text), // Smaller icon
                           padding: EdgeInsets.zero,
                           constraints: BoxConstraints(),
                         ),
                         IconButton(
                           onPressed: () {
                             showModalBottomSheet(
                                 shape: RoundedRectangleBorder(
                                     borderRadius: BorderRadius.vertical(top: Radius.circular(20))
                                 ),
                                 backgroundColor: colortheme.theme.background,
                                 context: context,
                                 builder: (context){
                                   //theme
                                   final Map<String,ThemeColor> themes={
                                     "darkblue":DarkBlue(),
                                     "darkgreen":DarkGreen(),
                                     "darkpink":DarkPink(),
                                     "darkorange":DarkOrange(),
                                     "darkred":DarkRed(),
                                     "whiteblue":WhiteBlue(),
                                     "whitegreen":WhiteGreen(),
                                     "whitepink":WhitePink(),
                                     "whiteorange":WhiteOrange(),
                                     "whitered":WhiteRed(),
                                   };
                                   return Padding(
                                     padding: const EdgeInsets.all(16.0),
                                     child: Column(
                                       mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                       crossAxisAlignment: CrossAxisAlignment.start,
                                       children: [
                                         Padding(
                                           padding: const EdgeInsets.only(top: 2.0,bottom: 8.0),
                                           child: Text("Theme",textAlign:TextAlign.center,style: TextStyle(fontSize: 23,color: colortheme.theme.tab),),
                                         ),
                                         Padding(
                                           padding: const EdgeInsets.all(8.0),
                                           child: ListView.builder(
                                             scrollDirection: Axis.horizontal,
                                              itemCount:themes.length,
                                               itemBuilder: (context,index){
                                               String themekey=themes.keys.elementAt(index);
                                               ThemeColor theme=themes[themekey]!;
                                                 return GestureDetector(
                                                   onTap: (){

                                                   },
                                                   child: Container(
                                                     width: 50,
                                                     height: 50,
                                                     decoration: BoxDecoration(
                                                     color: theme.tab,
                                                     borderRadius: BorderRadius.circular(50),
                                                   ),),
                                                 );
                                           }),
                                         )

                                       ],
                                     ),
                                   );
                                 });
                           },
                           icon: Icon(CupertinoIcons.settings, size: 20, color: colortheme.theme.text), // Smaller icon
                           padding: EdgeInsets.zero,
                           constraints: BoxConstraints(),
                         ),
                       ],
                     )
                  ],
                ),
              ),

            ),
            SliverAppBar(
               backgroundColor: colortheme.theme.background,

              floating: false,
              pinned: true,
              toolbarHeight: 5.0,
              flexibleSpace: FlexibleSpaceBar(
                titlePadding: EdgeInsets.only(left: 10,bottom: 5,top: 0),
                title:SizedBox(
                  height: 45,
                  child: ListView.builder(
                      scrollDirection:Axis.horizontal,
                      itemCount:pages.length,
                      itemBuilder: (context,index){

                        return Padding(
                          padding: const EdgeInsets.only(top: 5),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 2.0),
                            child: GestureDetector(
                              onTap: (){
                                _pageController.animateToPage(index, duration: Duration(milliseconds: 500), curve: Curves.easeInOut);
                                _currentPage=index;
                                  },
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 9,horizontal: 15),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(25),
                                  color:  _currentPage==index?colortheme.theme.tab:colortheme.theme.background,
                                ),
                                child:Text("${pages[index]}",style: TextStyle(fontSize: 16,color: _currentPage==index?Colors.black:colortheme.theme.text),) ,),
                            ),
                          ),
                        );

                      }),
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
              Playlist(),
              Album(),
            ],
          ),
      ),
      bottomNavigationBar: currentplayprovider.song.path!=''?BottomAppBar(
        height: 100,
        color: Colors.transparent,
        child: GestureDetector(
          onTap: (){
            print("tapped...");
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => PlayerScreen()),
            );
          },
          child: Hero(
            tag: 'player',
            child: Container(
              decoration: BoxDecoration(
                color: currentplayprovider.Theme.background,
                borderRadius: BorderRadius.circular(20)
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: buildSongImage(base64Image:currentplayprovider.song.Image)
                    ),
                    SizedBox(width: 5,),
                    Expanded(child: Text("${currentplayprovider.song.title}",style:TextStyle(color: currentplayprovider.Theme.text,fontSize: 18),overflow: TextOverflow.ellipsis,maxLines: 2,softWrap: true,)),
                    Row(
                      children: [
                        IconButton(onPressed: (){
                          currentplayprovider.prevsong();
                        }, icon: Icon(CupertinoIcons.backward_fill,color: currentplayprovider.Theme.tab,)),
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
                                    size: 30,
                                  ),
                                ),
                              );
                            }),

                        IconButton(onPressed: (){
                                 currentplayprovider.nextsong();
                        }, icon: Icon(CupertinoIcons.forward_fill,color: currentplayprovider.Theme.tab)),
                      ],
                    ),

                  ],
                ),
              )
            ),
          ),
        )
      ):SizedBox.shrink(),

    );
  }
}



class Playlist extends StatefulWidget {
  const Playlist({super.key});

  @override
  State<Playlist> createState() => _PlaylistState();
}

class _PlaylistState extends State<Playlist> {
  @override
  Widget build(BuildContext context) {
    return Center(child: Text("Playlist"),);
  }
}
class Album extends StatefulWidget {
  const Album({super.key});

  @override
  State<Album> createState() => _AlbumState();
}

class _AlbumState extends State<Album> {
  @override
  Widget build(BuildContext context) {
    return Center(child: Text("Playlist"),);
  }
}


