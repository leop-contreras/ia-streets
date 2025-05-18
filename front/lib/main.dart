import 'package:flutter/material.dart';

enum RoadTypes {none, highway, avenue, street, place}
final boxColors = [Colors.grey[300], Colors.red[300], Colors.green[300], Colors.blue[300], Colors.amber];

final gridSize = 10;
List<RoadTypes> boxManagerList = [];
RoadTypes selectedBoxType = RoadTypes.avenue;

Map<String,dynamic> payload = {};

void main() {
  for (var i = 0; i < gridSize * gridSize; i++){
    boxManagerList.add(RoadTypes.none);
  }
  runApp(MainApp());
}

class MainApp extends StatefulWidget {
  MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  void boxTap(index){
    setState(() {
      if (boxManagerList[index] == selectedBoxType){
        boxManagerList[index] = RoadTypes.none;
      }else{
        boxManagerList[index] = selectedBoxType;
      }
    });
  }

  void clearBoxes(){
    setState(() {
      for (var i = 0; i < gridSize * gridSize; i++){
        boxManagerList[i] = RoadTypes.none;
      }
    });
  }

  List<int> getCoords(int index){
    var coords = [-1,-1];
    coords[1] = (index/10).truncate();
    coords[0] = index-(coords[1]*10);
    return coords;
  }

  void generatePayload(){
    Map<String, dynamic> payload = {
      "map":{
          "dimensions": [gridSize,gridSize],
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

    for (var i = 0; i < boxManagerList.length; i++){
      switch(boxManagerList[i]){
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
    final boxSize = MediaQuery.sizeOf(context).width/gridSize;
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
                            onPressed: () => clearBoxes(), 
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
                            onPressed: () => setState(() {selectedBoxType = RoadTypes.highway;}), 
                            style: TextButton.styleFrom(
                              backgroundColor: Colors.grey[100]
                            ),
                            child: Text("Highway")
                          ),
                          TextButton(
                            onPressed: () => setState(() {selectedBoxType = RoadTypes.avenue;}), 
                            style: TextButton.styleFrom(
                              backgroundColor: Colors.grey[100]
                            ),
                            child: Text("Avenue")
                          ),
                          TextButton(
                            onPressed: () => setState(() {selectedBoxType = RoadTypes.street;}), 
                            style: TextButton.styleFrom(
                              backgroundColor: Colors.grey[100]
                            ),
                            child: Text("Street")
                          ),
                          TextButton(
                            onPressed: () => setState(() {selectedBoxType = RoadTypes.place;}), 
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
                child: GridView.count(
                  padding: EdgeInsets.all(0),
                  physics: NeverScrollableScrollPhysics(),
                  crossAxisCount: gridSize,
                  childAspectRatio: 1.0,
                  shrinkWrap: true,
                  children: List.generate(gridSize*gridSize, (index){
                    return Center(
                      child: GestureDetector(
                        onTap: () => boxTap(index),
                        child: Container(
                          constraints: BoxConstraints(
                            minHeight: boxSize,
                            minWidth: boxSize,
                          ),
                          child: Text("$index", textScaler: MediaQuery.textScalerOf(context) ,),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Colors.black
                            ),
                            color: boxColors[boxManagerList[index].index]
                          ),
                        ),
                      ),
                    );
                  }),
                  )
              ),
            ],
          ),
        ),
      ),
    );
  }
}
