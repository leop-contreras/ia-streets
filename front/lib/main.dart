import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/boxManagerProvider.dart';
import 'worldmap.dart';
import 'actions.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => BoxManagerProvider(),
      child: MainApp(),
    ),
  );
}

class MainApp extends StatefulWidget {
  MainApp({super.key});
  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: SafeArea(
          child: OrientationBuilder(
            builder: (context, orientation) {
              final isPortrait = orientation == Orientation.portrait;
              
              return isPortrait 
                ? _buildPortraitLayout()
                : _buildLandscapeLayout();
            },
          ),
        ),
      ),
    );
  }
  
  Widget _buildPortraitLayout() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.all(10),
          child: ActionsBar(),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: WorldMap(),
          ),
        ),
      ],
    );
  }
  
  Widget _buildLandscapeLayout() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.all(10),
          child: ActionsBar(),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: WorldMap(),
          ),
        ),
      ],
    );
  }
}