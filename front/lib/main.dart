import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/boxManagerProvider.dart';
import 'worldmap.dart';

//List<RoadTypes> boxManagerList = [];
//RoadTypes selectedBoxType = RoadTypes.avenue;
void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => BoxManagerProvider(),
      child: MainApp()
  ));
}

class MainApp extends StatefulWidget {
  MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {

  List<int> getCoords(int index){
    var coords = [-1,-1];
    coords[1] = (index/10).truncate();
    coords[0] = index-(coords[1]*10);
    return coords;
  }

  void generatePayload(){
    Map<String, dynamic> payload = {
      "map":{
          "dimensions": [Provider.of<BoxManagerProvider>(context, listen: false).gridSize,Provider.of<BoxManagerProvider>(context, listen: false).gridSize],
          "roads":{
              "highways":[],
              "avenues":[],
              "streets":[]
          },
          "places":[
              {
                  "name":"NULL",
                  "size":1,
                  "coords":[5,5]
              }
          ],
          "traffic":[
              {
                  "description":"NULL",
                  "size":10,
                  "rate":1,
                  "origin":[0,0],
                  "destination":[5,5]
              }
          ]
      },
      "trip":{
          "name":"NULL",
          "origin":[0,0],
          "destination":[5,5]
      }
    };

    for (var i = 0; i < Provider.of<BoxManagerProvider>(context, listen: false).boxManagerList.length; i++){
      switch(Provider.of<BoxManagerProvider>(context, listen: false).boxManagerList[i]){
        case RoadTypes.highway:
          payload['map']['roads']['highways'].add(getCoords(i));
          break;
        case RoadTypes.avenue:
          payload['map']['roads']['avenues'].add(getCoords(i));
          break;
        case RoadTypes.street:
          payload['map']['roads']['streets'].add(getCoords(i));
          break;
        default:  
          break;
      }
    }

    print(payload);
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<BoxManagerProvider>(context, listen: false);

    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            spacing: 20,
            children: [
              Container(
                child: Center(
                  child: Column(
                    spacing: 10,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        spacing: 10,
                        children: [
                          TextButton(
                            onPressed: () => provider.clearBoxes(), 
                            style: TextButton.styleFrom(
                              backgroundColor: Colors.amber[100]
                            ),
                            child: Text("Clear")
                          ),
                          TextButton(
                            onPressed: () => generatePayload(), 
                            style: TextButton.styleFrom(
                              backgroundColor: Colors.green[100]
                            ),
                            child: Text("Get Payload")
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
                              backgroundColor: Colors.grey[100]
                            ),
                            child: Text("Highway")
                          ),
                          TextButton(
                            onPressed: () => provider.selectedBoxType = RoadTypes.avenue, 
                            style: TextButton.styleFrom(
                              backgroundColor: Colors.grey[100]
                            ),
                            child: Text("Avenue")
                          ),
                          TextButton(
                            onPressed: () => provider.selectedBoxType = RoadTypes.street, 
                            style: TextButton.styleFrom(
                              backgroundColor: Colors.grey[100]
                            ),
                            child: Text("Street")
                          ),
                          TextButton(
                            onPressed: () => provider.selectedBoxType = RoadTypes.place, 
                            style: TextButton.styleFrom(
                              backgroundColor: Colors.grey[100]
                            ),
                            child: Text("Place")
                          ),
                        ],
                      ),
                    
                    ],
                  ),
                  )
              ),
              Container(
                margin: EdgeInsets.all(20),
                color: Colors.red[100],
                child: WorldMap()
              ),
            ],
          ),
        ),
      ),
    );
  }
}
