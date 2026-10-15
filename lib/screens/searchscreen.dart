// ==============================================================================
// File: lib/screens/searchscreen.dart
// ------------------------------------------------------------------------------
// PURPOSE:
//   Provides real-time search capabilities across the local music library,
//   filtering songs by title as the user types.
//
// FLOW & ARCHITECTURE:
//   1. Navigation & Setup:
//      - Navigated to from the search icon in the `HomeScreen` header.
//      - The navigation route injects a scoped `searchProvider` instance.
//      - Wrapped in `GlobalScaffold` to maintain background theming and keep the
//        `MiniPlayer` accessible while searching.
//
//   2. Search Interaction:
//      - A rounded `TextFormField` in the `SliverAppBar` captures the user query.
//      - `onChanged` triggers `search.searchlistfunction(query)` in `searchProvider`
//        (`lib/provider_classes.dart`), performing case-insensitive matching against
//        all songs in the master Hive 'songs' box.
//
//   3. Results Display & Playback:
//      - Matching results are rendered in a `SliverList`.
//      - The currently playing song is highlighted using `currentplay.Theme.tab`.
//      - Tapping any search result switches the active playback box to 'songs'
//        and starts playback via `currentplay.changesong(song)`.
// ==============================================================================

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:music_app_2/global_scaffold.dart';
import 'package:music_app_2/screens/songscreen.dart';
import 'package:music_app_2/store/songs.dart';
import 'homescreen.dart';
import 'package:provider/provider.dart';
import 'package:music_app_2/provider_classes.dart';
import 'package:hive_flutter/hive_flutter.dart';

class searchScreen extends StatefulWidget {
  const searchScreen({super.key});

  @override
  State<searchScreen> createState() => _searchScreenState();
}

class _searchScreenState extends State<searchScreen> {
  @override
  Widget build(BuildContext context) {
    final colortheme=Provider.of<Themeprovider>(context);
    final search=Provider.of<searchProvider>(context);
    final currentplayprovider=Provider.of<currentplay>(context);
    return GlobalScaffold(
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              backgroundColor: colortheme.theme.background,
              pinned: true,
              automaticallyImplyLeading: false,
              elevation: 0,
              scrolledUnderElevation: 0,
              toolbarHeight: 68,
              titleSpacing: 8,
              title: Row(
                children: [
                  IconButton(
                    onPressed: () {
                      if (Navigator.of(context).canPop()) {
                        Navigator.of(context).pop();
                      }
                    },
                    icon: Icon(CupertinoIcons.back, color: colortheme.theme.text, size: 24),
                  ),
                  Expanded(
                    child: Container(
                      height: 46,
                      decoration: BoxDecoration(
                        color: colortheme.theme.tab.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: colortheme.theme.tab.withValues(alpha: 0.25),
                          width: 1,
                        ),
                      ),
                      child: TextField(
                        autofocus: true,
                        onChanged: (value) async {
                          search.searchlistfunction(value);
                        },
                        style: TextStyle(color: colortheme.theme.text, fontSize: 15),
                        textAlignVertical: TextAlignVertical.center,
                        decoration: InputDecoration(
                          isDense: true,
                          hintText: "Search songs...",
                          hintStyle: TextStyle(
                            color: colortheme.theme.text.withValues(alpha: 0.5),
                            fontSize: 14,
                          ),
                          prefixIcon: Icon(
                            CupertinoIcons.search,
                            color: colortheme.theme.tab,
                            size: 20,
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
              ),
            ),

            SliverList(
                delegate: SliverChildBuilderDelegate(
                        (context,index){
                      if(currentplayprovider.song.path == search.searchlist[index].path)
                        return GestureDetector(
                          onTap: ()async{
                            Box<Song> box=Hive.box<Song>("songs");
                            currentplayprovider.changebox(box);
                            currentplayprovider.changesong(search.searchlist[index]);

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
                                        child: buildSongImage(base64Image:search.searchlist[index].Image,width: 50,height: 50)),
                                  ),
                                ),
                                SizedBox(width: 10,),
                                Expanded(child: Text("${search.searchlist[index].title}",style: TextStyle(color: currentplayprovider.Theme.tab),overflow: TextOverflow.ellipsis,maxLines: 2,softWrap: true,))
                              ],
                            ),),
                        );
                      else
                        return GestureDetector(
                          onTap: ()async{
                            Box<Song> box=Hive.box<Song>("songs");
                            currentplayprovider.changebox(box);
                            currentplayprovider.changesong(search.searchlist[index]);
                          },
                          child: ListTile(
                            title: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: buildSongImage(base64Image:search.searchlist[index].Image)),
                                SizedBox(width: 10,),
                                Expanded(child: Text("${search.searchlist[index].title}",style: TextStyle(color: colortheme.theme.text),overflow: TextOverflow.ellipsis,maxLines: 2,softWrap: true,))
                              ],
                            ),),
                        );
                    },
                childCount:search.searchlist.length
                )),
          ],
        ),
     );
  }
}
