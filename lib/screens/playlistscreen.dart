import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
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
          GestureDetector(
            onTap: (){
              showPlaylistDialog(context);
            },
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                decoration: BoxDecoration(
                  color: colortheme.theme.tab,
                  borderRadius: BorderRadius.circular(20)
                ),
                child: Center(child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                  children: [
                    Icon(Icons.add,color: colortheme.theme.text,),
                    Text("add Playlist",style: TextStyle(color: colortheme.theme.text),),
                  ],
                            ),
                )),),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: GestureDetector(
              onTap: (){
                Box<Song> box=Hive.box<Song>('likedsongs');
                print("likedsongs is tapped");
                Navigator.push(context,
                    MaterialPageRoute(builder: (context)=>ChangeNotifierProvider(
                        create: (context)=>Songlistprovider(box)
                        ,child: playlistsongs(nameofplaylist: "Liked Songs"))));
              },
              child: Container(
                decoration: BoxDecoration(
                    color: colortheme.theme.tab,
                    borderRadius: BorderRadius.circular(20)
                ),
                child: Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Hero(
                        tag: "Liked Songs",
                        child: Image.asset("assets/music.png",width: 80,
                        height: 80,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Column(
                      children: [
                        Text("🩷 Liked Songs",style: TextStyle(color: colortheme.theme.text,fontSize: 20,fontWeight: FontWeight.bold),),
                      ],
                    )
                  ],
                ),

               ),
            ),
          ),
           Wrap(
             spacing: 1000.0,
             runSpacing: 1.0,
             children: playlist.playlists.map((playlistitem){

               return Padding(
                 padding: const EdgeInsets.all(10.0),
                 child: GestureDetector(
                   onTap: ()async{
                     await Hive.openBox<Song>(playlistitem);
                     Box<Song> box=Hive.box<Song>(playlistitem);
                     print("$playlistitem is tapped");
                     Navigator.push(context,
                         MaterialPageRoute(builder: (context)=>ChangeNotifierProvider(
                             create: (context)=>Songlistprovider(box)
                             ,child: playlistsongs(nameofplaylist:playlistitem))));
                   },
                   child: Container(
                     decoration: BoxDecoration(
                         color: colortheme.theme.tab,
                         borderRadius: BorderRadius.circular(20)
                     ),
                     child: Dismissible(
                       key: Key(playlistitem),
                       direction: DismissDirection.endToStart,
                       onDismissed: (direction){
                         playlist.deleteplaylist(playlistitem);
                       },
                       background: Container(
                         decoration: BoxDecoration(
                           borderRadius: BorderRadius.circular(20),
                           color: Colors.red,
                         ),

                         alignment: Alignment.centerRight,
                         padding: EdgeInsets.symmetric(horizontal: 20),
                         child: const Icon(Icons.delete,color: Colors.white,),
                       ),
                       child: Row(
                         children: [
                           Padding(
                             padding: const EdgeInsets.all(8.0),
                             child: Hero(
                               tag: "$playlistitem",
                               child: Image.asset("assets/music.png",width: 80,
                                 height: 80,
                                 fit: BoxFit.cover,
                               ),
                             ),
                           ),
                           Column(
                             children: [
                               Text("${playlistitem}",style: TextStyle(color: colortheme.theme.text,fontSize: 20,fontWeight: FontWeight.bold),),
                             ],
                           )
                         ],
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
   showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text("Enter Playlist Name"),
        content: TextField(
          controller: playlistController,
          decoration: const InputDecoration(hintText: "Playlist Name"),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close the dialog
            },
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () async{
              String playlistName = playlistController.text.trim();
              if (playlistName.isNotEmpty) {
                // Handle playlist creation logic here
               playlist.addplaylist(playlistController.text);
               if(song != null)
                 {
                   Box<Song> box=await Hive.openBox(playlistName);
                   addSongtoplaylist(song, box);
                   box.close();
                   showToast("song added to $playlistName");
                 }
                Navigator.pop(context); // Close the dialog
              }
            },
            child: const Text("Create"),
          ),
        ],
      );
    },
  );


}


//playlistsongs screen
class playlistsongs extends StatefulWidget {
 String nameofplaylist;
  playlistsongs({super.key,required this.nameofplaylist});

  @override
  State<playlistsongs> createState() => _playlistsongsState();
}

class _playlistsongsState extends State<playlistsongs> {
  @override
  Widget build(BuildContext context) {
    final songProvider = Provider.of<Songlistprovider>(context);
    final colortheme=Provider.of<Themeprovider>(context);
    final currentplayprovider=Provider.of<currentplay>(context);
    return Material(
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
                child: Text(
                  widget.nameofplaylist,
                  style: TextStyle(color: colortheme.theme.text),
                ),
              ),
            ),

          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
                  (context, index){
                    if(index<songProvider.Songlist.length)
                      {

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
                              onTap: (){
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
                        // else
                        //   return GestureDetector(
                        //     onTap: (){
                        //       currentplayprovider.changesong(songProvider.Songlist[index]);
                        //     },
                        //     child: ListTile(
                        //       title: Row(
                        //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        //         crossAxisAlignment: CrossAxisAlignment.center,
                        //         children: [
                        //           ClipRRect(
                        //               borderRadius: BorderRadius.circular(10),
                        //               child: buildSongImage(base64Image:songProvider.Songlist[index].Image)),
                        //           SizedBox(width: 10,),
                        //           Expanded(child: Text("${songProvider.Songlist[index].title}",style: TextStyle(color: colortheme.theme.text),overflow: TextOverflow.ellipsis,maxLines: 2,softWrap: true,))
                        //         ],
                        //       ),),
                        //   );


                      }
                       else
                         return GestureDetector(
                           onTap: (){

                           },
                           child: ListTile(
                             title: Padding(
                               padding: const EdgeInsets.symmetric(horizontal: 16,vertical:8 ),
                               child: Card(
                                 shape: RoundedRectangleBorder(
                                   borderRadius: BorderRadius.circular(15)
                                 ),
                                 color: colortheme.theme.background,
                                 child: Container(
                                   padding: EdgeInsets.all(16),
                                   width: 60,
                                   height: 60,
                                   child: Row(
                                     mainAxisAlignment: MainAxisAlignment.center,
                                     crossAxisAlignment: CrossAxisAlignment.center,
                                     children: [
                                       ClipRRect(
                                           borderRadius: BorderRadius.circular(10),
                                           child: Icon(Icons.add,size: 35,color: colortheme.theme.tab,)
                                        ),
                                       SizedBox(width: 10,),
                                       Text("Add Song",style: TextStyle(color: colortheme.theme.text),overflow: TextOverflow.ellipsis,maxLines: 2,softWrap: true,)
                                     ],
                                   ),
                                 ),
                               ),
                             ),),
                         );

              },
              childCount: songProvider.Songlist.length+1,
            )
          ),

        ],
      ),
    );
  }
}


