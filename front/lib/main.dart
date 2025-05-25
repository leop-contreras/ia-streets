import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/boxManagerProvider.dart';
import 'worldmap.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => BoxManagerProvider(),
      child: MaterialApp(
        title: 'IA Streets',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: const MyHomePage(),
      ),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('IA Streets'),
      ),
      body: Column(
        children: [
          const Expanded(
            child: WorldMap(),
          ),
          Container(
            padding: const EdgeInsets.all(8.0),
            child: const ActionsBar(),
          ),
        ],
      ),
    );
  }
}

class ActionsBar extends StatelessWidget {
  const ActionsBar({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<BoxManagerProvider>(context, listen: false);

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextButton(onPressed: () => provider.setPlaceMode("start"), child: const Text("Inicio")),
            TextButton(onPressed: () => provider.setPlaceMode("stop"), child: const Text("Parada")),
            TextButton(onPressed: () => provider.setPlaceMode("end"), child: const Text("Fin")),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextButton(
              onPressed: provider.clearBoxes,
              style: TextButton.styleFrom(backgroundColor: Colors.amber[100]),
              child: const Text("Clear"),
            ),
            TextButton(
              onPressed: provider.generatePath,
              style: TextButton.styleFrom(backgroundColor: Colors.blue[100]),
              child: const Text("Trace Route"),
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextButton(onPressed: () => provider.selectedBoxType = RoadTypes.highway, child: const Text("Highway")),
            TextButton(onPressed: () => provider.selectedBoxType = RoadTypes.avenue, child: const Text("Avenue")),
            TextButton(onPressed: () => provider.selectedBoxType = RoadTypes.street, child: const Text("Street")),
            TextButton(onPressed: () => provider.selectedBoxType = RoadTypes.place, child: const Text("Place")),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(onPressed: () => provider.gridSize++, icon: const Icon(Icons.add)),
            Consumer<BoxManagerProvider>(
              builder: (context, p, _) => Text("Grid ${p.gridSize}", style: const TextStyle(fontSize: 20)),
            ),
            IconButton(onPressed: () => provider.gridSize--, icon: const Icon(Icons.remove)),
          ],
        ),
      ],
    );
  }
}
