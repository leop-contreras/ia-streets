import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

enum RoadTypes {none, highway, avenue, street, place}

class BoxManagerProvider extends ChangeNotifier{
  List<RoadTypes> _boxManagerList = [];
  int _gridSize = 10;
  RoadTypes _selectedBoxType = RoadTypes.avenue;
  final _boxColors = [Colors.grey[300], Colors.red[300], Colors.green[300], Colors.blue[300], Colors.amber];

  BoxManagerProvider() {
    _initializeBoxManagerList();
  }

  void boxTap(index){
    if (_boxManagerList[index] == _selectedBoxType){
      _boxManagerList[index] = RoadTypes.none;
    }else{
      _boxManagerList[index] = _selectedBoxType;
    }
    notifyListeners();
  }

  void clearBoxes(){
    for (var i = 0; i < _gridSize * _gridSize; i++){
      _boxManagerList[i] = RoadTypes.none;
    }
    notifyListeners();
  }

  List<int> getCoords(int index){
    var coords = [-1,-1];
    coords[1] = (index/10).truncate();
    coords[0] = index-(coords[1]*10);
    return coords;
  }

  Map<String,dynamic> generatePayload(){
    Map<String, dynamic> payload = {
      "map":{
          "dimensions": [_gridSize,_gridSize],
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

    for (var i = 0; i < _boxManagerList.length; i++){
      switch(_boxManagerList[i]){
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

    return payload;
  }

  void generatePath() async{
    await dotenv.load();

    Map<String,dynamic> payload = generatePayload();
    String payloadString = jsonEncode(payload);
    try{
      final response = await http.post(
        Uri.parse('http://${dotenv.env['API_IP']}/get_path'),
        headers: {
        'Content-Type': 'application/json',
        },
        body:payloadString)
        .timeout(Duration(seconds: 30));
      print(response.body);
    } on TimeoutException catch (e) {
      print('Requested timeout: $e');
    } catch (e) {
      print('Other error: $e');
    }
  }

  void _initializeBoxManagerList(){
    boxManagerList.clear();
    for(var i = 0; i < gridSize*gridSize; i++){
      boxManagerList.add(RoadTypes.none);
    }
    notifyListeners();
  }

  //GETTERS
  List<RoadTypes> get boxManagerList => _boxManagerList;
  int get gridSize => _gridSize;
  RoadTypes get selectedBoxType => _selectedBoxType;
  get boxColors => _boxColors;

  //SETTERS
  set selectedBoxType (RoadTypes newValue){
    print("Provider: selectedBoxType changed to: $newValue"); 
    _selectedBoxType = newValue;
    notifyListeners();
  }

  set gridSize (int newValue){
    if(newValue < 3 || newValue > 20){
      _gridSize = _gridSize;
      return;
    }
    _gridSize = newValue;
    _initializeBoxManagerList();
    notifyListeners();
  }

  set boxManagerList (List<RoadTypes> newValue){
    _boxManagerList = newValue;
    notifyListeners();
  }
}