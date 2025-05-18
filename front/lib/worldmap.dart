import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/boxManagerProvider.dart';

class WorldMap extends StatelessWidget {
  const WorldMap({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<BoxManagerProvider>(context);
    final boxSize = MediaQuery.of(context).size.width / provider.gridSize;

    return GridView.count(
      padding: EdgeInsets.zero,
      physics: NeverScrollableScrollPhysics(),
      crossAxisCount: gridSize,
      childAspectRatio: 1.0,
      shrinkWrap: true,
      children: List.generate(gridSize * gridSize, (index) {
        return Center(
          child: GestureDetector(
            onTap: () => provider.boxTap(index),
            child: Container(
              constraints: BoxConstraints(
                minHeight: boxSize,
                minWidth: boxSize,
              ),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black),
                color: provider.boxColors[provider.boxManagerList[index].index],
              ),
              child: Text(
                "$index",
                textScaler: MediaQuery.textScalerOf(context),
              ),
            ),
          ),
        );
      }),
    );
  }
}
