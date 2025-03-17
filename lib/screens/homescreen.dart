import 'package:flutter/material.dart';
import 'package:music_app_2/main.dart';
import 'package:provider/provider.dart';
import 'package:music_app_2/provider_classes.dart';
import 'package:cupertino_icons/cupertino_icons.dart';
import 'package:flutter/cupertino.dart';
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
    final songProvider = Provider.of<Songlistprovider>(context);
    final colortheme=Provider.of<Themeprovider>(context);
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
                          child: Image.network(
                            'https://th.bing.com/th/id/OIP.AotjEfWpHSZoqpMhu2uvDQAAAA?rs=1&pid=ImgDetMain',
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
                              fontFamily: 'Signery',
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
                           onPressed: () {},
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
                titlePadding: EdgeInsets.only(left: 10,bottom: 2,top: 0),
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
                                _pageController.animateToPage(index, duration: Duration(milliseconds: 700), curve: Curves.easeInOut);
                                _currentPage=index;
                                  },
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 9,horizontal: 15),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(25),
                                  color:  _currentPage==index?colortheme.theme.tab:colortheme.theme.background,
                                ),
                                child:Text("${pages[index]}",style: TextStyle(fontSize: 16,color: _currentPage==index?Colors.black:colortheme.theme.text,fontFamily: 'Signery'),) ,),
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
              setState(() {
                _currentPage=index;
              });
            },
            children: [
              SongScreen(),
              Playlist(),
              Album(),
            ],
          ),
      ),
    );
  }
}


class SongScreen extends StatefulWidget {
  const SongScreen({super.key});

  @override
  State<SongScreen> createState() => _SongState();
}

class _SongState extends State<SongScreen> {
  @override
  Widget build(BuildContext context) {
    return Center(child: Text("Song",style: TextStyle(color: Colors.white),),);
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


