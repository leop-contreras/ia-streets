import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/boxManagerProvider.dart';

class ActionsBar extends StatefulWidget {
  const ActionsBar({super.key});

  @override
  State<ActionsBar> createState() => _ActionsBarState();
}

class _ActionsBarState extends State<ActionsBar> {
  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<BoxManagerProvider>(context, listen: false);

    return Container(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          spacing: 10,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              spacing: 10,
              children: [
                TextButton(
                  onPressed: () => provider.clearBoxes(),
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.amber[100],
                  ),
                  child: Text("Clear"),
                ),
                TextButton(
                  onPressed: () => provider.generatePath(),
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.blue[100],
                  ),
                  child: Text("Trace Route"),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              spacing: 10,
              children: [
                TextButton(
                  onPressed: () => provider.selectedBoxType = RoadTypes.highway,
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.grey[100],
                  ),
                  child: Text("Highway"),
                ),
                TextButton(
                  onPressed: () => provider.selectedBoxType = RoadTypes.avenue,
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.grey[100],
                  ),
                  child: Text("Avenue"),
                ),
                TextButton(
                  onPressed: () => provider.selectedBoxType = RoadTypes.street,
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.grey[100],
                  ),
                  child: Text("Street"),
                ),
                TextButton(
                  onPressed: () => provider.selectedBoxType = RoadTypes.place,
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.grey[100],
                  ),
                  child: Text("Place"),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              spacing: 5,
              children: [
                IconButton(
                  onPressed: () => {provider.gridSize++},
                  icon: Icon(Icons.add),
                ),
                Text(
                  "Grid ${Provider.of<BoxManagerProvider>(context).gridSize}",
                  style: TextStyle(fontSize: 20),
                ),
                IconButton(
                  onPressed: () => {provider.gridSize--},
                  icon: Icon(Icons.remove),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
}
