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
