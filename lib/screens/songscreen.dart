import 'dart:convert';
//import 'dart:ffi';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:music_app_2/main.dart';
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

class _SongState extends State<SongScreen> {

  @override
  void initState()
  {
    super.initState();

  }
  Future<void> Refresh()async
  {
    await fetchSongslist(context);
    await checkfordelete(context);
  }
  @override
  Widget build(BuildContext context) {
    final songProvider = Provider.of<Songlistprovider>(context);
    final colortheme=Provider.of<Themeprovider>(context);
    final currentplayprovider=Provider.of<currentplay>(context);
    return RefreshIndicator(
      onRefresh: Refresh,
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

//widget to build song profile image
Widget buildSongImage({required String? base64Image,double width=65,double height=65}) {
  if (base64Image == null || base64Image.isEmpty) {
    return Image.asset('assets/default-music.png', fit: BoxFit.cover,width: width,height:height,); // Default image
  }

  try {
    Uint8List imageBytes = base64Decode(base64Image); // Decode only if not null
    return Image.memory(imageBytes, fit: BoxFit.cover,width: width,height:height,);
  } catch (e) {
    print("Error decoding base64 image: $e");
    return Image.asset('assets/default-music.png', fit: BoxFit.cover,width: width,height: height,); // Fallback in case of error
  }
}


class PlayerScreen extends StatefulWidget {


  const PlayerScreen({super.key});

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  @override
  Widget build(BuildContext context) {
    final currentplayprovider=Provider.of<currentplay>(context);
    final songlistprovider=Provider.of<Songlistprovider>(context);
    return  Material(
      child: Scaffold(
          backgroundColor: currentplayprovider.Theme.background,
          body: Stack(
            children: [
              Center(
                child: Hero(
                  tag: 'player',
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        ValueListenableBuilder<bool>(valueListenable: currentplayprovider.isplaying,
                            builder: (context,playing,child){
                           return    Padding(
                             padding: const EdgeInsets.all(8.0),
                             child: AnimatedContainer(
                               duration: Duration(milliseconds: 400), // Adjust duration for smoother effect
                               curve: Curves.easeInOut, // Smooth transition curve
                               width: playing ? 300 : 250,
                               height: playing ? 300 : 250,
                               child: ClipRRect(
                                 borderRadius: BorderRadius.circular(10),
                                 child: buildSongImage(
                                   base64Image: currentplayprovider.song.Image,
                                   width: double.infinity, // Use full width of AnimatedContainer
                                   height: double.infinity, // Use full height of AnimatedContainer
                                 ),
                               ),
                             ),
                           );
                            }),


                        Column(
                          children: [
                            Text("${currentplayprovider.song.title}",style:TextStyle(color: currentplayprovider.Theme.tab,fontSize: 20),overflow: TextOverflow.ellipsis,maxLines: 2,softWrap: true,),
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Align(
                                alignment: Alignment.bottomCenter,
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Expanded(child: Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: Text("${currentplayprovider.song.artist??"Unknown"}",style:TextStyle(color: currentplayprovider.Theme.text,fontSize: 15),overflow: TextOverflow.ellipsis,maxLines: 2,softWrap: true,),
                                    )),
                                    IconButton(onPressed: ()async{
                                      var box=Hive.box<Song>("likedsongs");
                                          addSongtoplaylist(currentplayprovider.song, box);
                                      showToast("Liked ${currentplayprovider.song.title}");

                                    }, icon: Icon(CupertinoIcons.heart_fill,color: currentplayprovider.Theme.tab,)),


                                  ],
                                ),
                              ),
                            )
                          ],
                        ),

                         ValueListenableBuilder<Duration>(
                             valueListenable: currentplayprovider.positionNotifier,
                             builder: (context,position,child){
                               return Padding(
                                 padding: const EdgeInsets.only(right: 15,left: 15),
                                 child: Material(
                                   color: currentplayprovider.Theme.background,
                                   child: SliderTheme(
                                     data: SliderThemeData(
                                       activeTrackColor: currentplayprovider.Theme.tab,
                                       thumbColor: currentplayprovider.Theme.tab,
                                       overlayColor:currentplayprovider.Theme.tab,
                                       thumbShape: RoundSliderThumbShape(enabledThumbRadius: 0),
                                       trackHeight: 10.0

                                     ),
                                     child: Slider(
                                       min: 0,
                                       max: currentplayprovider.duration?.inSeconds.toDouble()??1,
                                       value: position.inSeconds.toDouble().clamp(0, currentplayprovider.duration?.inSeconds.toDouble()??1), //is ensuring that the Slider value stays within a valid range
                                       onChanged: (value){
                                         //play to this poistion
                                         print("${value.runtimeType}");
                                         print("value :$value");
                                         currentplayprovider.seektoposition(value);
                                       },
                                     ),
                                   ),
                                 ),
                               );
                             }),

                         ValueListenableBuilder<Duration>(
                             valueListenable: currentplayprovider.positionNotifier,
                             builder: (context,position,child){
                               return Padding(
                                 padding: const EdgeInsets.only(right: 40,left: 40),
                                 child: Row(
                                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                   children: [
                                     Text(formatDuration(position),style: TextStyle(color: currentplayprovider.Theme.text),), // Current Time
                                     Text(formatDuration(currentplayprovider.duration ?? Duration.zero),style: TextStyle(color: currentplayprovider.Theme.text),), // Total Time
                                   ],
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
                            IconButton(onPressed: (){}, icon: Icon(Icons.add_to_photos,color: currentplayprovider.Theme.tab,size: 30,)),
                              IconButton(onPressed: (){
                                showModalBottomSheet(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.vertical(top: Radius.circular(20))
                                  ),
                                    backgroundColor: currentplayprovider.Theme.background,
                                    context: context,
                                    builder: (context){
                                     return Padding(
                                       padding: const EdgeInsets.all(16.0),
                                       child: Column(
                                         mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                         crossAxisAlignment: CrossAxisAlignment.start,
                                         children: [
                                           Padding(
                                             padding: const EdgeInsets.only(top: 2.0,bottom: 8.0),
                                             child: Text("Sleep Timer",textAlign:TextAlign.center,style: TextStyle(fontSize: 23,color: currentplayprovider.Theme.tab),),
                                           ),
                                           Padding(
                                             padding: const EdgeInsets.all(8.0),
                                             child: Text("Turn Off",style: TextStyle(fontSize: 18,color: currentplayprovider.Theme.text),),
                                           ),
                                           Padding(
                                             padding: const EdgeInsets.all(8.0),
                                             child: Text("10 Minutes",style: TextStyle(fontSize: 18,color:currentplayprovider.Theme.text),),
                                           ),
                                           Padding(
                                             padding: const EdgeInsets.all(8.0),
                                             child: Text("20 Minutes",style: TextStyle(fontSize: 18,color: currentplayprovider.Theme.text),),
                                           ),
                                           Padding(
                                             padding: const EdgeInsets.all(8.0),
                                             child: Row(
                                               mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                               children: [
                                                 Text("Custom",style: TextStyle(fontSize: 18,color: currentplayprovider.Theme.text),),
                                                 Icon(CupertinoIcons.right_chevron)
                                               ],
                                             ),
                                           ),

                                         ],
                                       ),
                                     );
                                    });
                              }, icon: Icon(CupertinoIcons.clock_solid,color: currentplayprovider.Theme.tab,size: 30,)),
                          ],),
                        )

                      ],
                    ),
                  ),
                ),
              ),
              // Position the arrow at the top
              Positioned(
                top: 40, // Adjust as needed
                left: 10, // Align it to the left
                child: IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: Row(
                    children: [
                      Icon(
                        Icons.arrow_drop_down_rounded,
                        size: 45,
                        color: currentplayprovider.Theme.tab,
                      ),
                      Text("${currentplayprovider.song.title}",style:TextStyle(color: currentplayprovider.Theme.tab,fontSize: 20),overflow: TextOverflow.ellipsis,maxLines: 2,softWrap: true,),
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

  // Check if the song is already in the playlist
  for (Song oldSong in songList) {
    if (oldSong.path == song.path) return;
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