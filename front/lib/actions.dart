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
                    backgroundColor:
                        provider.selectedBoxType == RoadTypes.highway
                            ? Colors.red[200]
                            : Colors.red[50],
                    foregroundColor:
                        provider.selectedBoxType == RoadTypes.highway
                            ? Colors.white
                            : null,
                  ),
                  child: Text("Highway"),
                ),
                TextButton(
                  onPressed: () => provider.selectedBoxType = RoadTypes.avenue,
                  style: TextButton.styleFrom(
                    backgroundColor:
                        provider.selectedBoxType == RoadTypes.avenue
                            ? Colors.green[200]
                            : Colors.green[50],
                    foregroundColor:
                        provider.selectedBoxType == RoadTypes.avenue
                            ? Colors.white
                            : null,
                  ),
                  child: Text("Avenue"),
                ),
                TextButton(
                  onPressed: () => provider.selectedBoxType = RoadTypes.street,
                  style: TextButton.styleFrom(
                    backgroundColor:
                        provider.selectedBoxType == RoadTypes.street
                            ? Colors.blue[200]
                            : Colors.blue[50],
                    foregroundColor:
                        provider.selectedBoxType == RoadTypes.street
                            ? Colors.white
                            : null,
                  ),
                  child: Text("Street"),
                ),
                TextButton(
                  onPressed: () => provider.selectedBoxType = RoadTypes.place,
                  style: TextButton.styleFrom(
                    backgroundColor:
                        provider.selectedBoxType == RoadTypes.place
                            ? Colors.amber[200]
                            : Colors.amber[50],
                    foregroundColor:
                        provider.selectedBoxType == RoadTypes.place
                            ? Colors.white
                            : null,
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
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              spacing: 10,
              children: [
                TextButton(
                  onPressed:
                      () =>
                          provider.selectedBoxType =
                              provider.selectedBoxType == RoadTypes.traffic
                                  ? RoadTypes.none
                                  : RoadTypes.traffic,
                  style: TextButton.styleFrom(
                    backgroundColor:
                        provider.selectedBoxType == RoadTypes.traffic
                            ? Colors.orange[400]
                            : Colors.orange[100],
                    foregroundColor:
                        provider.selectedBoxType == RoadTypes.traffic
                            ? Colors.white
                            : null,
                  ),
                  child: Text("Traffic Mode"),
                ),
                FloatOptions(provider: provider),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class FloatOptions extends StatelessWidget {
  const FloatOptions({
    super.key,
    required this.provider,
  });

  final BoxManagerProvider provider;

  @override
  Widget build(BuildContext context) {
    return AnimatedSize(
      duration: Duration(milliseconds: 300),
      curve: Curves.easeInOutCubic,
      child: AnimatedSwitcher(
        duration: Duration(milliseconds: 200),
        switchInCurve: Curves.easeOutCubic,
        switchOutCurve: Curves.easeInCubic,
        transitionBuilder: (
          Widget child,
          Animation<double> animation,
        ) {
          return FadeTransition(
            opacity: animation,
            child: ScaleTransition(
              scale: Tween<double>(begin: 0.8, end: 1.0).animate(
                CurvedAnimation(
                  parent: animation,
                  curve: Curves.elasticOut,
                ),
              ),
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: Offset(
                    -0.5,
                    0.0,
                  ), // Slide from button direction
                  end: Offset.zero,
                ).animate(
                  CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeOutBack,
                  ),
                ),
                child: child,
              ),
            ),
          );
        },
        child:
            provider.selectedBoxType == RoadTypes.traffic
                ? Padding(
                  padding: EdgeInsets.only(left: 8.0),
                  child: Column(
                    key: ValueKey('traffic_controls'),
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 0,
                        ),
                        child: Row(
                          spacing: 4,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizerButton(
                              provider: provider,
                              isSize: true,
                              isAdd: false,
                            ),
                            Text(
                              "Size ${provider.traffics[0]['size']}",
                              style: TextStyle(fontSize: 16),
                            ),
                            SizerButton(
                              provider: provider,
                              isSize: true,
                              isAdd: true,
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 0,
                        ),
                        child: Row(
                          spacing: 4,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizerButton(
                              provider: provider,
                              isSize: false,
                              isAdd: false,
                            ),
                            Text(
                              "Rate ${provider.traffics[0]['rate']}",
                              style: TextStyle(fontSize: 16),
                            ),
                            SizerButton(
                              provider: provider,
                              isSize: false,
                              isAdd: true,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                )
                : SizedBox.shrink(key: ValueKey('empty')),
      ),
    );
  }
}

class SizerButton extends StatelessWidget {
  final bool isSize;
  final bool isAdd;

  const SizerButton({
    super.key,
    required this.provider,
    required this.isSize,
    required this.isAdd,
  });

  final BoxManagerProvider provider;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent, // Keep transparent or set a background color
      child: InkWell(
        borderRadius: BorderRadius.circular(100), // Optional rounded corners
        onTap: () {
          isSize
              ? provider.updateTrafficSize(0, isAdd)
              : provider.updateTrafficRate(0, isAdd);
        },
        child: Padding(
          padding: EdgeInsets.all(9),
          child: Icon(isAdd ? Icons.add : Icons.remove, size: 20),
        ),
      ),
    );
  }
}
