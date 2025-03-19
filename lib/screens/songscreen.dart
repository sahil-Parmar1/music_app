import 'dart:convert';
import 'dart:ffi';
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
                      Expanded(child: Text("${songProvider.Songlist[index].title}",style: TextStyle(color: currentplayprovider.Theme.background),overflow: TextOverflow.ellipsis,maxLines: 2,softWrap: true,))
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
      }):Center(child: Text("No Songs are Found!",style: TextStyle(color: colortheme.theme.tab),),),
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
    return  Material(
      child: Scaffold(
          backgroundColor: currentplayprovider.Theme.background,
          body: Center(
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
                           width: playing ? 250 : 220,
                           height: playing ? 250 : 220,
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
                                IconButton(onPressed: (){}, icon: Icon(CupertinoIcons.heart_fill,color: currentplayprovider.Theme.tab,)),
                                IconButton(onPressed: (){}, icon: Icon(CupertinoIcons.ellipsis_vertical,color: currentplayprovider.Theme.tab,)),
      
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
                               child: Slider(
                                 min: 0,
                                 max: currentplayprovider.duration?.inSeconds.toDouble()??1,
                                 value: position.inSeconds.toDouble().clamp(0, currentplayprovider.duration?.inSeconds.toDouble()??1),
                                 onChanged: (value){
                                   //play to this poistion
                                   print("${value.runtimeType}");
                                   print("value :$value");
                                   currentplayprovider.seektoposition(value);
                                 },
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
      
                  ],
                ),
              ),
            ),
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