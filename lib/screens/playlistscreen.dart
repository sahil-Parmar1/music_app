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
            child: Container(
              decoration: BoxDecoration(
                  color: colortheme.theme.tab,
                  borderRadius: BorderRadius.circular(20)
              ),
              child: Hero(
                tag: "playlist",
                child: GestureDetector(
                          onTap: (){

                          Box<Song> box=Hive.box<Song>('likedsongs');
                          print("likedsongs is tapped");
                                Navigator.push(context,
                                MaterialPageRoute(builder: (context)=>ChangeNotifierProvider(
                                create: (context)=>Songlistprovider(box)
                                ,child: playlistsongs())));
                          },
                  child: Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Image.asset("assets/music.png",width: 80,
                        height: 80,
                          fit: BoxFit.cover,
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
                     child: Hero(
                       tag: "playlist",
                       child: GestureDetector(
                         onTap: ()async{
                           Box<Song> box=await Hive.openBox(playlistitem);
                           Navigator.push(context,
                           MaterialPageRoute(builder: (context)=>playlistsongs())
                           );
                         },
                         child: Row(
                           children: [
                             Padding(
                               padding: const EdgeInsets.all(8.0),
                               child: Image.asset("assets/music.png",width: 80,
                                 height: 80,
                                 fit: BoxFit.cover,
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


//playlistsongs screen
class playlistsongs extends StatefulWidget {

  playlistsongs({super.key});

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
      child: songProvider.Songlist.length>0?ListView.builder(
          itemCount: songProvider.Songlist.length,
          itemBuilder: (context,index){
            if(currentplayprovider.song.path == songProvider.Songlist[index].path)
              return GestureDetector(
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
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(50)
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: ClipRRect(
                              borderRadius: BorderRadius.circular(90),
                              child: buildSongImage(base64Image:songProvider.Songlist[index].Image,width: 50,height: 50)),
                        ),
                      ),
                      SizedBox(width: 10,),
                      Expanded(child: Text("${songProvider.Songlist[index].title}",style: TextStyle(color: currentplayprovider.Theme.tab),overflow: TextOverflow.ellipsis,maxLines: 2,softWrap: true,))
                    ],
                  ),),
              );
            else
              return GestureDetector(
                onTap: (){
                  currentplayprovider.changesong(songProvider.Songlist[index]);
                },
                child: ListTile(
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: buildSongImage(base64Image:songProvider.Songlist[index].Image)),
                      SizedBox(width: 10,),
                      Expanded(child: Text("${songProvider.Songlist[index].title}",style: TextStyle(color: colortheme.theme.text),overflow: TextOverflow.ellipsis,maxLines: 2,softWrap: true,))
                    ],
                  ),),
              );
          }):Center(child: Text("No Songs are Found! Restart the App",style: TextStyle(color: colortheme.theme.tab),),),
    );
  }
}
