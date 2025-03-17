import 'dart:convert';
import 'dart:ffi';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:music_app_2/provider_classes.dart';


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
  @override
  Widget build(BuildContext context) {
    final songProvider = Provider.of<Songlistprovider>(context);
    final colortheme=Provider.of<Themeprovider>(context);
    return ListView.builder(
        itemCount: songProvider.Songlist.length,
        itemBuilder: (context,index){
          return ListTile(
            title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
         crossAxisAlignment: CrossAxisAlignment.center,
         children: [
         ClipRRect(
             borderRadius: BorderRadius.circular(10),
             child: buildSongImage(songProvider.Songlist[index].Image)),
            SizedBox(width: 10,),
             Expanded(child: Text("${songProvider.Songlist[index].title}",style: TextStyle(color: colortheme.theme.text),overflow: TextOverflow.ellipsis,maxLines: 2,softWrap: true,))
         ],
       ),);
    });
  }
}

//widget to build song profile image
Widget buildSongImage(String? base64Image) {
  if (base64Image == null || base64Image.isEmpty) {
    return Image.asset('assets/default-music.png', fit: BoxFit.cover,width: 65,height: 65,); // Default image
  }

  try {
    Uint8List imageBytes = base64Decode(base64Image); // Decode only if not null
    return Image.memory(imageBytes, fit: BoxFit.cover,width: 65,height: 65,);
  } catch (e) {
    print("Error decoding base64 image: $e");
    return Image.asset('assets/default-music.png', fit: BoxFit.cover,width: 65,height: 65,); // Fallback in case of error
  }
}