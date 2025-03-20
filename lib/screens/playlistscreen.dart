import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:music_app_2/provider_classes.dart';

class Playlistscreen extends StatefulWidget {
  const Playlistscreen({super.key});

  @override
  State<Playlistscreen> createState() => _PlaylistscreenState();
}

class _PlaylistscreenState extends State<Playlistscreen> {
  @override
  Widget build(BuildContext context) {
    final colortheme=Provider.of<Themeprovider>(context);
    return SingleChildScrollView(
      child: Column(
        children: [
          Padding(
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
                  Text("add song",style: TextStyle(color: colortheme.theme.text),),
                ],
                          ),
              )),),
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
                    child: Image.asset("assets/music.png",width: 80,
                    height: 80,
                      fit: BoxFit.cover,
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
        ],
      ),
    );
  }
}
