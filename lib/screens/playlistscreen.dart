import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';
import 'package:music_app_2/provider_classes.dart';
import 'package:music_app_2/main.dart';
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
            child: Container(
              decoration: BoxDecoration(
                  color: colortheme.theme.tab,
                  borderRadius: BorderRadius.circular(20)
              ),
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: GestureDetector(
                      onTap: (){

                      },
                      child: Image.asset("assets/music.png",width: 80,
                      height: 80,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Column(
                    children: [
                      Text("🩷 Liked Songs",style: TextStyle(color: colortheme.theme.text,fontSize: 20,fontWeight: FontWeight.bold),),
                      Text("No songs yet",style: TextStyle(color: colortheme.theme.text),)
                    ],
                  )
                ],
              ),

             ),
          ),
           Wrap(
             spacing: 1000.0,
             runSpacing: 1.0,
             children: playlist.playlists.map((playlistitem){
               return Padding(
                 padding: const EdgeInsets.all(10.0),
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
                           child: GestureDetector(
                             onTap: (){

                             },
                             child: Image.asset("assets/music.png",width: 80,
                               height: 80,
                               fit: BoxFit.cover,
                             ),
                           ),
                         ),
                         Column(
                           children: [
                             Text("${playlistitem}",style: TextStyle(color: colortheme.theme.text,fontSize: 20,fontWeight: FontWeight.bold),),
                             Text("No songs yet",style: TextStyle(color: colortheme.theme.text),)
                           ],
                         )
                       ],
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
void showPlaylistDialog(context) {
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


