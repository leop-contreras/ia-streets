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

    bool checkInGrid(int col, int row, double cellSize){
      if(col >= 0 && col < provider.gridSize && row >= 0 && row < provider.gridSize){
        return true;
      }
      return false;
    }

    void _handleDragUpdate(
      DragUpdateDetails details,
      BoxManagerProvider provider,
      double cellSize,
    ) {
      if (!_isDragging) return;
      if (provider.selectedOption == OptionType.place) return;
      if (provider.selectedOption == OptionType.traffic) return;

      final RenderBox? box =
          _key.currentContext?.findRenderObject() as RenderBox?;
      if (box == null) return;

      final localPosition = box.globalToLocal(details.globalPosition);

      final col = (localPosition.dx / cellSize).floor();
      final row = (localPosition.dy / cellSize).floor();

      if (checkInGrid(col, row, cellSize)) {
        final dragIndex = row * provider.gridSize + col;

        if(provider.boxManagerList[dragIndex] == RoadTypes.place) return;
        
        !_isDeleteMode ? provider.handleRoad(dragIndex, dragMode: 1) : provider.handleRoad(dragIndex, dragMode: -1);
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
                if (provider.selectedOption == OptionType.traffic) return;
                if (provider.selectedOption == OptionType.place) return;

                setState(() {
                  _isDragging = true;
                });

                final RenderBox? box =
                    _key.currentContext?.findRenderObject() as RenderBox?;
                if (box == null) return;

                final localPosition = box.globalToLocal(details.globalPosition);

                final col = (localPosition.dx / cellSize).floor();
                final row = (localPosition.dy / cellSize).floor();

                if (checkInGrid(col, row, cellSize)) {
                  final initialIndex = row * provider.gridSize + col;
                  _isDeleteMode = provider.boxManagerList[initialIndex] == provider.selectedBoxType;
                  provider.handleRoad(initialIndex);
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
  List<Color> routeColors = [Colors.red,Colors.blue,Colors.green,Colors.orange,Colors.purple];

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

    Text textBoxHandler(int index){
      for(var place in provider.places){
        if(place['index'] == index){
          return Text(place['name'], style: TextStyle(color: Colors.black, fontSize: 15));
        }
      }
      
      Text finalDot = Text("");
      for(var i = 0; i < provider.routesBoxIndexes.length; i++){
        if(provider.routesBoxIndexes[i].contains(index)){
          finalDot = Text("●", style: TextStyle(color: routeColors[i], fontSize: 15));
        }
      }
      return finalDot;
    }

    return GestureDetector(
      onTap: () {
        print(provider.selectedOption);
        if (provider.selectedOption == OptionType.traffic){
          provider.handleTraffic(provider.selectedTrafficIndex, index); // TODO multiple traffics
          return;
        }else if(provider.selectedOption == OptionType.place){
          print("About to handle place");
          provider.handlePlace(index);
          return;
        }else{
          provider.handleRoad(index);
        }
      },
      child: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: color,
          border: paintTrafficBorder(index),
        ),
        child: textBoxHandler(index)
      ),
    );
  }
}
