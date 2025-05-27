import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/boxManagerProvider.dart';
import 'widgets/actionWidget.dart';
import 'widgets/floatingOptions.dart';

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
                    backgroundColor: Colors.grey[200],
                  ),
                  child: Text("Clear"),
                ),
                TextButton(
                  onPressed: () => provider.changeOption(OptionType.highway),
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
                  onPressed: () => provider.changeOption(OptionType.avenue),
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
                  onPressed: () => provider.changeOption(OptionType.street),
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
              ],
            ),
            SingleChildScrollView (
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                spacing: 10,
                children: [
                  Column(
                    children: [
                      TextButton(
                        onPressed:
                            () => provider.changeOption(OptionType.traffic),
                        style: TextButton.styleFrom(
                          backgroundColor:
                              provider.selectedOption == OptionType.traffic
                                  ? Colors.orange[400]
                                  : Colors.orange[100],
                          foregroundColor:
                              provider.selectedOption == OptionType.traffic
                                  ? Colors.white
                                  : null,
                        ),
                        child: Text("Traffic Mode"),
                      ),
                      FloatOptions(provider: provider, designatedFloatOption: OptionType.traffic, optionsWidget: TrafficModeOptions(provider: provider))
                    ],
                  ),
                  Column(
                    children: [
                      TextButton(
                        onPressed:
                            () => provider.changeOption(OptionType.place),
                        style: TextButton.styleFrom(
                          backgroundColor:
                              provider.selectedOption == OptionType.place
                                  ? Colors.amber[400]
                                  : Colors.amber[100],
                          foregroundColor:
                              provider.selectedOption == OptionType.place
                                  ? Colors.white
                                  : null,
                        ),
                        child: Text("Place Mode"),
                      ),
                      FloatOptions(provider: provider, designatedFloatOption: OptionType.place, optionsWidget: PlaceModeOptions(provider: provider))
                    ],
                  ),
                  Column(
                    children: [
                      TextButton(
                        onPressed: //provider.changeOption(OptionType.route)
                            () => provider.generatePath(),
                        style: TextButton.styleFrom(
                          backgroundColor:
                              provider.selectedOption == OptionType.route
                                  ? Colors.blue[400]
                                  : Colors.blue[100],
                          foregroundColor:
                              provider.selectedOption == OptionType.route
                                  ? Colors.white
                                  : null,
                        ),
                        child: Text("Route Mode"),
                      ),
                      FloatOptions(provider: provider, designatedFloatOption: OptionType.route, optionsWidget: RouteModeOptions(provider: provider))
                    ],
                  ),
                ],
              ),
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