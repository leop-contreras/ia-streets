import 'package:flutter/material.dart';
import 'providers/boxManagerProvider.dart';

class ActionsBar extends StatelessWidget {
  const ActionsBar({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<BoxManagerProvider>(context, listen: false);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Tipo de lugar
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextButton(onPressed: () => provider.setPlaceMode("start"), child: const Text("Inicio")),
            TextButton(onPressed: () => provider.setPlaceMode("stop"), child: const Text("Parada")),
            TextButton(onPressed: () => provider.setPlaceMode("end"), child: const Text("Fin")),
          ],
        ),
        // Acciones
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
        // Tipos de calle
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextButton(
              onPressed: () => provider.selectedBoxType = RoadTypes.highway,
              style: TextButton.styleFrom(backgroundColor: Colors.grey[100]),
              child: const Text("Highway"),
            ),
            TextButton(
              onPressed: () => provider.selectedBoxType = RoadTypes.avenue,
              style: TextButton.styleFrom(backgroundColor: Colors.grey[100]),
              child: const Text("Avenue"),
            ),
            TextButton(
              onPressed: () => provider.selectedBoxType = RoadTypes.street,
              style: TextButton.styleFrom(backgroundColor: Colors.grey[100]),
              child: const Text("Street"),
            ),
            TextButton(
              onPressed: () => provider.selectedBoxType = RoadTypes.place,
              style: TextButton.styleFrom(backgroundColor: Colors.grey[100]),
              child: const Text("Place"),
            ),
          ],
        ),
        // Tamaño del grid
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
