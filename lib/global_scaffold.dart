// ==============================================================================
// File: lib/global_scaffold.dart
// ------------------------------------------------------------------------------
// PURPOSE:
//   A standardized wrapper scaffold used throughout the application to ensure
//   consistent background styling and persistent access to the audio MiniPlayer.
//
// FLOW & ARCHITECTURE:
//   1. Styling:
//      - Listens to `Themeprovider` to dynamically set `Scaffold.backgroundColor`.
//   2. Persistent MiniPlayer:
//      - Houses `MiniPlayer()` in `Scaffold.bottomNavigationBar`.
//      - The `MiniPlayer` widget (defined in `lib/screens/homescreen.dart`) automatically
//        displays track controls (play/pause, next, previous) and track artwork whenever
//        an active song is selected in `currentplay`.
//      - Clicking on the `MiniPlayer` triggers a Hero transition into `PlayerScreen`.
//   3. Usage:
//      - Wraps `HomeScreen`, `searchScreen`, and `playlistsongs` to ensure the music
//        player stays reachable across all major navigation branches.
// ==============================================================================

import 'package:flutter/material.dart';
import 'package:music_app_2/screens/homescreen.dart';
import 'provider_classes.dart';
import 'package:provider/provider.dart';

class GlobalScaffold extends StatelessWidget {

  final Widget child;
  const GlobalScaffold({super.key,required this.child});

  @override
  Widget build(BuildContext context) {
    final colortheme=Provider.of<Themeprovider>(context);
    return Scaffold(
      backgroundColor: colortheme.theme.background,
      body: child,
      bottomNavigationBar: MiniPlayer(),
    );
  }
}
