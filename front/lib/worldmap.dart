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
      if (provider.selectedBoxType == RoadTypes.place) return;
      if (provider.selectedBoxType == RoadTypes.traffic) return;

      final RenderBox? box =
          _key.currentContext?.findRenderObject() as RenderBox?;
      if (box == null) return;

      final localPosition = box.globalToLocal(details.globalPosition);

      final col = (localPosition.dx / boxSize).floor();
      final row = (localPosition.dy / boxSize).floor();

      if (col >= 0 &&
          col < provider.gridSize &&
          row >= 0 &&
          row < provider.gridSize) {
        final dragIndex = row * provider.gridSize + col;

        if(provider.boxManagerList[dragIndex] == RoadTypes.place) return;
        
        _isDeleteMode ? provider.updateBox(dragIndex, RoadTypes.none) : provider.updateBox(dragIndex, provider.selectedBoxType);
        provider.notifyListeners();
      }
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final maxSize = constraints.biggest;
        final squareSize =
            orientation == Orientation.portrait
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
                if (provider.selectedBoxType == RoadTypes.place) return;
                setState(() {
                  _isDragging = true;
                });

                final RenderBox? box =
                    _key.currentContext?.findRenderObject() as RenderBox?;
                if (box == null) return;

                final localPosition = box.globalToLocal(details.globalPosition);

                final col = (localPosition.dx / cellSize).floor();
                final row = (localPosition.dy / cellSize).floor();

                if (col >= 0 &&
                    col < provider.gridSize &&
                    row >= 0 &&
                    row < provider.gridSize) {
                  final initialIndex = row * provider.gridSize + col;
                  if(provider.boxManagerList[initialIndex] == RoadTypes.place) return;
                  _isDeleteMode =
                      provider.boxManagerList[initialIndex] ==
                      provider.selectedBoxType;
                  if (provider.selectedBoxType == RoadTypes.traffic) return;
                  _isDeleteMode ? provider.updateBox(initialIndex, RoadTypes.none) : provider.updateBox(initialIndex, provider.selectedBoxType);
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
                color: Colors.transparent,
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
  final defaultBorder = Border.all(color: Colors.black.withValues(alpha: 0.5));

  BoxWidget({Key? key, required this.index}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<BoxManagerProvider>(context);
    final color = provider.boxColors[provider.boxManagerList[index].index];
    Border paintTrafficBorder(int index){
      int weight = provider.bordersTrafficWeight[index];
      if(weight >= 100){
        return Border.all(color: Colors.red.withValues(alpha: 0.75), width: 10.0);
      }else if(weight >= 10){
        return Border.all(color: Colors.deepOrange.withValues(alpha: 0.75), width: weight/10);
      }else if(weight > 0){
        return Border.all(color: Colors.orange.withValues(alpha: 0.75), width: 1.0);
      }
      return defaultBorder;
    }

    return GestureDetector(
      onTap: () {
        if (provider.selectedBoxType == RoadTypes.traffic){
            (provider.traffics[0]['indices'] as List).contains(index)
              ? provider.updateBox(index, RoadTypes.none)
              : provider.updateBox(index, RoadTypes.traffic);
            provider.loadTraffic();
            return;
        }
        if(provider.selectedBoxType == RoadTypes.place){
          if(provider.usedPlaces < provider.places.length && provider.boxManagerList[index] != provider.selectedBoxType){
            for(var i = 0; i<provider.places.length; i++){
              if(provider.places[i]['index'] <= 0){
                provider.places[i]['index'] = index;
                provider.usedPlaces += 1;
                provider.updateBox(index, RoadTypes.place);
                provider.notifyListeners();
                break;
              }
            }
          }else{
            for(var i = 0; i<provider.places.length; i++){
              if(provider.places[i]['index'] == index){
                provider.places[i]['index'] = -1;
                provider.usedPlaces -= 1;
                provider.updateBox(index, RoadTypes.none);
                provider.notifyListeners();
                break;
              }
            }
          }
        }else if(provider.boxManagerList[index] != RoadTypes.place){
          provider.boxManagerList[index] == provider.selectedBoxType ? provider.updateBox(index, RoadTypes.none) : provider.updateBox(index, provider.selectedBoxType);
          provider.notifyListeners();
        }
      },
      child: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: color,
          border: paintTrafficBorder(index),
        ),
        child:
            provider.routeBoxIndexes.contains(index)
                ? Text("●", style: TextStyle(color: Colors.red, fontSize: 15))
                : null,
      ),
    );
  }
}
