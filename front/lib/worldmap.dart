import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/boxManagerProvider.dart';

class WorldMap extends StatefulWidget {
  const WorldMap({super.key});

  @override
  State<WorldMap> createState() => _WorldMapState();
}

class _WorldMapState extends State<WorldMap> {
  bool _isDragging = false;
  bool _isDeleteMode = false;
  final GlobalKey _key = GlobalKey();

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<BoxManagerProvider>(context);
    final orientation = MediaQuery.of(context).orientation;

    void _handleDragUpdate(
      DragUpdateDetails details,
      BoxManagerProvider provider,
      double boxSize,
    ) {
      if (!_isDragging) return;

      final RenderBox? box =
          _key.currentContext?.findRenderObject() as RenderBox?;
      if (box == null) return;

      final localPosition = box.globalToLocal(details.globalPosition);

      final col = (localPosition.dx / boxSize).floor();
      final row = (localPosition.dy / boxSize).floor();

      if (col >= 0 && col < provider.gridSize && row >= 0 && row < provider.gridSize) {
        final dragIndex = row * provider.gridSize + col;
        
        provider.boxManagerList[dragIndex] =
            _isDeleteMode ? RoadTypes.none : provider.selectedBoxType;
        provider.notifyListeners();
      }
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final maxSize = constraints.biggest;
        final squareSize = orientation == Orientation.portrait
            ? maxSize.width
            : maxSize.height;
        
        final cellSize = squareSize / provider.gridSize;
        
        return Center(
          child: SizedBox(
            width: squareSize,
            height: squareSize,
            child: GestureDetector(
              key: _key,
              onPanStart: (details) {
                setState(() {
                  _isDragging = true;
                });
                
                final RenderBox? box =
                    _key.currentContext?.findRenderObject() as RenderBox?;
                if (box == null) return;
                
                final localPosition = box.globalToLocal(details.globalPosition);
                
                final col = (localPosition.dx / cellSize).floor();
                final row = (localPosition.dy / cellSize).floor();
                
                if (col >= 0 && col < provider.gridSize && row >= 0 && row < provider.gridSize) {
                  final initialIndex = row * provider.gridSize + col;
                  _isDeleteMode = provider.boxManagerList[initialIndex] == provider.selectedBoxType;
                  provider.boxManagerList[initialIndex] = 
                      _isDeleteMode ? RoadTypes.none : provider.selectedBoxType;
                  provider.notifyListeners();
                }
              },
              onPanUpdate: (details) {
                _handleDragUpdate(details, provider, cellSize);
              },
              onPanEnd: (_) {
                setState(() {
                  _isDragging = false;
                });
              },
              child: Container(
                color: Colors.redAccent,
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
            ),
          ),
        );
      },
    );
  }
}

class BoxWidget extends StatelessWidget {
  final int index;

  const BoxWidget({Key? key, required this.index}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<BoxManagerProvider>(context);
    final color = provider.boxColors[provider.boxManagerList[index].index];

    return GestureDetector(
      onTap: () {
        provider.boxManagerList[index] =
            provider.boxManagerList[index] == provider.selectedBoxType
                ? RoadTypes.none
                : provider.selectedBoxType;
        provider.notifyListeners();
      },
      child: Container(
        decoration: BoxDecoration(
          color: color,
          border: Border.all(color: Colors.black.withValues(alpha:0.5)),
        ),
      ),
    );
  }
}