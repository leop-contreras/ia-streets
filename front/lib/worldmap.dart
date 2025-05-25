import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/boxManagerProvider.dart';

class WorldMap extends StatelessWidget {
  const WorldMap({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<BoxManagerProvider>(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        final size = MediaQuery.of(context).orientation == Orientation.portrait
            ? constraints.maxWidth
            : constraints.maxHeight;

        return SizedBox(
          width: size,
          height: size,
          child: GestureDetector(
            onPanStart: (details) => _handleDragStart(context, details, provider, size),
            onPanUpdate: (details) => _handleDragUpdate(context, details, provider, size),
            child: GridView.builder(
              padding: EdgeInsets.zero,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: provider.gridSize,
                childAspectRatio: 1.0,
              ),
              itemCount: provider.gridSize * provider.gridSize,
              itemBuilder: (context, index) => BoxWidget(index: index),
            ),
          ),
        );
      },
    );
  }

  void _handleDragStart(BuildContext context, DragStartDetails details, BoxManagerProvider provider, double size) {
    final boxSize = size / provider.gridSize;
    final box = context.findRenderObject() as RenderBox?;
    if (box == null) return;
    final local = box.globalToLocal(details.globalPosition);
    final col = (local.dx / boxSize).floor();
    final row = (local.dy / boxSize).floor();
    if (col >= 0 && row >= 0 && col < provider.gridSize && row < provider.gridSize) {
      final index = row * provider.gridSize + col;
      provider.boxTap(index);
    }
  }

  void _handleDragUpdate(BuildContext context, DragUpdateDetails details, BoxManagerProvider provider, double size) {
    final boxSize = size / provider.gridSize;
    final box = context.findRenderObject() as RenderBox?;
    if (box == null) return;
    final local = box.globalToLocal(details.globalPosition);
    final col = (local.dx / boxSize).floor();
    final row = (local.dy / boxSize).floor();
    if (col >= 0 && row >= 0 && col < provider.gridSize && row < provider.gridSize) {
      final index = row * provider.gridSize + col;
      provider.boxTap(index);
    }
  }
}

class BoxWidget extends StatelessWidget {
  final int index;
  const BoxWidget({super.key, required this.index});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<BoxManagerProvider>(context);
    final isRoute = provider.routeBoxIndexes.contains(index);
    final color = isRoute ? Colors.purple : provider.getColorForBox(index);

    String? label;
    if (isRoute) {
      label = "●";
    } else if (provider.placeTypesByIndex.containsKey(index)) {
      final type = provider.placeTypesByIndex[index];
      if (type == "start") {
        label = "Inicio";
      } else if (type == "end") {
        label = "Fin";
      } else if (type == "stop") {
        final count = provider.placeTypesByIndex.entries
            .where((e) => e.key <= index && e.value == "stop")
            .length;
        label = String.fromCharCode(64 + count); // A, B, C...
      }
    }

    return GestureDetector(
      onTap: () => provider.boxTap(index),
      child: Container(
        decoration: BoxDecoration(
          color: color,
          border: Border.all(color: Colors.black.withOpacity(0.5)),
        ),
        alignment: Alignment.center,
        child: Text(
          label ?? "",
          style: const TextStyle(
            color: Colors.white,
            fontSize: 11,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
