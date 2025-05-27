import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/boxManagerProvider.dart';
import 'actionWidget.dart';

class TrafficModeOptions extends StatelessWidget {
  const TrafficModeOptions({
    super.key,
    required this.provider,
  });

  final BoxManagerProvider provider;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 8.0, right: 8.0),
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
    );
  }
}

class PlaceModeOptions extends StatefulWidget {

  const PlaceModeOptions({
    super.key,
    required this.provider,
  });

  final BoxManagerProvider provider;

  @override
  State<PlaceModeOptions> createState() => _PlaceModeOptionsState();
}

class _PlaceModeOptionsState extends State<PlaceModeOptions> {

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<BoxManagerProvider>(context, listen: false);
    
    return Padding(
      padding: EdgeInsets.only(left: 8.0, right: 8.0),
      child: Column(
        key: ValueKey('place_controls'),
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: 6,
              vertical: 0,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  height: 100,
                  width: 100,
                  child: GridView.count(
                    crossAxisCount: 3,
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    children: List.generate(widget.provider.places.length, (index) {
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            provider.selectedPlaceIndex = index;
                          });
                          },
                        child: Container(
                          decoration: BoxDecoration(
                            color: widget.provider.places[index]['index'] == -1 ? Colors.amber[300] : Colors.amber[100],
                            border: Border.all(color: Colors.black.withValues(alpha: 0.5))
                          ),
                          child: Center(
                            child: Text(
                              '${widget.provider.places[index]['name']}',
                              style: TextStyle(
                                color: provider.selectedPlaceIndex == index ? Colors.red : (widget.provider.places[index]['index'] == -1 ?Colors.white : Colors.grey), 
                                fontSize: 12),
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ),
              ],
            )
          ),
        ],
      ),
    );
  }
}

class RouteModeOptions extends StatelessWidget {
  const RouteModeOptions({
    super.key,
    required this.provider,
  });

  final BoxManagerProvider provider;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 8.0, right: 8.0),
      child: Column(
        key: ValueKey('place_controls'),
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
                  "Strength ${provider.traffics[0]['size']}",
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
    );
  }
}
