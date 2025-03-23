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

class _PlaylistscreenState extends State<Playlistscreen> {
  @override
  Widget build(BuildContext context) {
    final colortheme=Provider.of<Themeprovider>(context);
    final playlist=Provider.of<playlistprovider>(context);
    return SingleChildScrollView(
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
                              child: FutureBuilder(
                                  future: loadFirstImage("likedsongs"),
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
                                      "assets/music.png",
                                      width: 70,
                                      height: 70,
                                      fit: BoxFit.cover,
                                    ):Image.asset(
                                      "assets/music.png",
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
                                              "assets/music.png",
                                              width: 70,
                                              height: 70,
                                              fit: BoxFit.cover,
                                            ):Image.asset(
                                              "assets/music.png",
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
                                          future: playlist.calculatesongs(boxname),
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
           )
        ],
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
              Navigator.pop(context); // Close the dialog
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
                Navigator.pop(context); // Close the dialog
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
 String nameofplaylist;
 String box;
  playlistsongs({super.key,required this.nameofplaylist,required this.box});

  @override
  State<playlistsongs> createState() => _playlistsongsState();
}

class _playlistsongsState extends State<playlistsongs> {
  @override
  Widget build(BuildContext context) {
    final songProvider = Provider.of<Songlistprovider>(context);
    final colortheme=Provider.of<Themeprovider>(context);
    final currentplayprovider=Provider.of<currentplay>(context);

    return GlobalScaffold(child: Material(
      color: colortheme.theme.background,
      child: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 250.0,
            floating: false,
            pinned: false,
            snap: false,
            automaticallyImplyLeading: true,
            leading: IconButton(
              icon: Icon(Icons.arrow_back_ios, color: colortheme.theme.text, size: 24), // Custom icon
              onPressed: () {
                Navigator.pop(context); // Navigates back
              },
            ),
            backgroundColor: colortheme.theme.background,
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: true, // Ensures title is centered properly
              title: Align(
                alignment: Alignment.bottomCenter, // Centered horizontally at the bottom
                child: Hero(
                  tag: "${widget.nameofplaylist}",
                  child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: songProvider.Songlist.length>0?buildSongImage(base64Image:songProvider.Songlist[0].Image,width: 140,height: 140):Image.asset("assets/music.png",width: 140,height: 140,fit: BoxFit.cover,)),
                ),
              ),
            ),

          ),
          SliverAppBar(
            expandedHeight: 30.0,
            floating: true,
            pinned: true,
            toolbarHeight: 5.0,
            automaticallyImplyLeading: false,
            backgroundColor: colortheme.theme.background,
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: true, // Ensures title is centered properly
              title: Align(
                  alignment: Alignment.bottomCenter, // Centered horizontally at the bottom
                  child: SizedBox(
                    width: double.infinity, // Ensures it takes full width
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        widget.nameofplaylist,
                        style: TextStyle(color: colortheme.theme.text),
                      ),
                    ),
                  )


              ),
            ),

          ),
          SliverList(
              delegate: SliverChildBuilderDelegate(
                    (context, index){
                  return Dismissible(
                    key: Key(songProvider.Songlist[index].path),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      color: Colors.red,
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.symmetric(horizontal:20 ),
                      child: const Icon(Icons.delete,color: Colors.white,),
                    ),
                    onDismissed: (direction){
                      songProvider.deletesong(songProvider.Songlist[index]);
                    },
                    child: GestureDetector(
                      onTap: ()async{
                        Box<Song> box=Hive.box<Song>(widget.box);
                        currentplayprovider.changebox(box);
                        currentplayprovider.changesong(songProvider.Songlist[index]);
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
                                color: currentplayprovider.song.path == songProvider.Songlist[index].path?Colors.black:Colors.transparent,
                                borderRadius: currentplayprovider.song.path == songProvider.Songlist[index].path?BorderRadius.circular(50):BorderRadius.circular(20),
                              ),
                              child: Padding(
                                padding: currentplayprovider.song.path == songProvider.Songlist[index].path?EdgeInsets.all(16.0):EdgeInsets.all(2.0),
                                child: ClipRRect(
                                    borderRadius: currentplayprovider.song.path == songProvider.Songlist[index].path?BorderRadius.circular(90):BorderRadius.circular(20),
                                    child: buildSongImage(base64Image:songProvider.Songlist[index].Image,width: currentplayprovider.song.path == songProvider.Songlist[index].path?50:100,height: currentplayprovider.song.path == songProvider.Songlist[index].path?50:100)),
                              ),
                            ),
                            SizedBox(width: 10,),
                            Expanded(child: Text("${songProvider.Songlist[index].title}",style: TextStyle(color: currentplayprovider.song.path == songProvider.Songlist[index].path?currentplayprovider.Theme.tab:colortheme.theme.text),overflow: TextOverflow.ellipsis,maxLines: 2,softWrap: true,))
                          ],
                        ),),
                    ),
                  );


                },
                childCount: songProvider.Songlist.length,
              )
          ),

        ],
      ),
    ));
    // return Material(
    //   color: colortheme.theme.background,
    //   child: CustomScrollView(
    //     slivers: [
    //       SliverAppBar(
    //         expandedHeight: 250.0,
    //         floating: false,
    //         pinned: false,
    //         snap: false,
    //         automaticallyImplyLeading: true,
    //         leading: IconButton(
    //           icon: Icon(Icons.arrow_back_ios, color: colortheme.theme.text, size: 24), // Custom icon
    //           onPressed: () {
    //             Navigator.pop(context); // Navigates back
    //           },
    //         ),
    //         backgroundColor: colortheme.theme.background,
    //         flexibleSpace: FlexibleSpaceBar(
    //           centerTitle: true, // Ensures title is centered properly
    //           title: Align(
    //             alignment: Alignment.bottomCenter, // Centered horizontally at the bottom
    //             child: Hero(
    //               tag: "${widget.nameofplaylist}",
    //               child: ClipRRect(
    //                   borderRadius: BorderRadius.circular(20),
    //                   child: songProvider.Songlist.length>0?buildSongImage(base64Image:songProvider.Songlist[0].Image,width: 140,height: 140):Image.asset("assets/music.png",width: 140,height: 140,fit: BoxFit.cover,)),
    //             ),
    //           ),
    //         ),
    //
    //       ),
    //       SliverAppBar(
    //         expandedHeight: 30.0,
    //         floating: true,
    //         pinned: true,
    //         toolbarHeight: 5.0,
    //         automaticallyImplyLeading: false,
    //         backgroundColor: colortheme.theme.background,
    //         flexibleSpace: FlexibleSpaceBar(
    //           centerTitle: true, // Ensures title is centered properly
    //           title: Align(
    //             alignment: Alignment.bottomCenter, // Centered horizontally at the bottom
    //             child: SizedBox(
    //               width: double.infinity, // Ensures it takes full width
    //               child: FittedBox(
    //                 fit: BoxFit.scaleDown,
    //                 child: Text(
    //                   widget.nameofplaylist,
    //                   style: TextStyle(color: colortheme.theme.text),
    //                 ),
    //               ),
    //             )
    //
    //
    //           ),
    //         ),
    //
    //       ),
    //       SliverList(
    //         delegate: SliverChildBuilderDelegate(
    //               (context, index){
    //                  return Dismissible(
    //                         key: Key(songProvider.Songlist[index].path),
    //                         direction: DismissDirection.endToStart,
    //                         background: Container(
    //                           color: Colors.red,
    //                           alignment: Alignment.centerRight,
    //                           padding: const EdgeInsets.symmetric(horizontal:20 ),
    //                           child: const Icon(Icons.delete,color: Colors.white,),
    //                         ),
    //                         onDismissed: (direction){
    //                           songProvider.deletesong(songProvider.Songlist[index]);
    //                         },
    //                         child: GestureDetector(
    //                           onTap: ()async{
    //                             Box<Song> box=Hive.box<Song>(widget.box);
    //                             currentplayprovider.changebox(box);
    //                             currentplayprovider.changesong(songProvider.Songlist[index]);
    //                           },
    //                           child: ListTile(
    //                             title: Row(
    //                               mainAxisAlignment: MainAxisAlignment.spaceBetween,
    //                               crossAxisAlignment: CrossAxisAlignment.center,
    //                               children: [
    //                                 Container(
    //                                   width: 70,
    //                                   height: 70,
    //                                   decoration: BoxDecoration(
    //                                       color: currentplayprovider.song.path == songProvider.Songlist[index].path?Colors.black:Colors.transparent,
    //                                       borderRadius: currentplayprovider.song.path == songProvider.Songlist[index].path?BorderRadius.circular(50):BorderRadius.circular(20),
    //                                   ),
    //                                   child: Padding(
    //                                     padding: currentplayprovider.song.path == songProvider.Songlist[index].path?EdgeInsets.all(16.0):EdgeInsets.all(2.0),
    //                                     child: ClipRRect(
    //                                         borderRadius: currentplayprovider.song.path == songProvider.Songlist[index].path?BorderRadius.circular(90):BorderRadius.circular(20),
    //                                         child: buildSongImage(base64Image:songProvider.Songlist[index].Image,width: currentplayprovider.song.path == songProvider.Songlist[index].path?50:100,height: currentplayprovider.song.path == songProvider.Songlist[index].path?50:100)),
    //                                   ),
    //                                 ),
    //                                 SizedBox(width: 10,),
    //                                 Expanded(child: Text("${songProvider.Songlist[index].title}",style: TextStyle(color: currentplayprovider.song.path == songProvider.Songlist[index].path?currentplayprovider.Theme.tab:colortheme.theme.text),overflow: TextOverflow.ellipsis,maxLines: 2,softWrap: true,))
    //                               ],
    //                             ),),
    //                         ),
    //                       );
    //
    //
    //           },
    //           childCount: songProvider.Songlist.length,
    //         )
    //       ),
    //
    //     ],
    //   ),
    // );
  }
}




//function to load frist image of list
Future<String?> loadFirstImage(String boxName) async {
  var box = Hive.isBoxOpen(boxName)
      ? Hive.box<Song>(boxName)
      : await Hive.openBox<Song>(boxName);
  return box.values.isNotEmpty ? box.values.first.Image : null;
}
