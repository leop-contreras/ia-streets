import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

enum RoadTypes {none, highway, avenue, street, place, traffic}

class BoxManagerProvider extends ChangeNotifier{
  List<RoadTypes> _boxManagerList = [];
  List<int> _routeBoxIndexes = [];
  int _usedPlaces = 0;
  List<Map<String,dynamic>> _places = [
    {
      "name":'A',
      'index': -1
    },
    {
      "name":'B',
      'index': -1
    },
    {
      "name":'C',
      'index': -1
    },
    {
      "name":'D',
      'index': -1
    },    
    {
      "name":'F',
      'index': -1
    }
  ];
  int _gridSize = 10;
  RoadTypes _selectedBoxType = RoadTypes.avenue;
  final _boxColors = [Colors.grey[300], Colors.red[300], Colors.green[300], Colors.blue[300], Colors.amber];
  List<Map<String,dynamic>> _traffics = [{
        "description": "Chilangos Love",
        "size":10,
        "rate":1,
        "indices": []
    }];
  List<int> _bordersTrafficWeight = [];

  BoxManagerProvider() {
    _initializeBoxManagerList();
  }

  void clearBoxes(){
    for (var i = 0; i < _gridSize * _gridSize; i++){
      _boxManagerList[i] = RoadTypes.none;
    }
    for(var i = 0; i<places.length; i++){
      places[i]['index'] = -1;
    }
    _usedPlaces = 0; // Fixed: Reset to 0 instead of decrementing
    
    // Clear traffic indices
    for(var i = 0; i < _traffics.length; i++){
      _traffics[i]['indices'].clear();
    }
    
    routeBoxIndexes.clear();
    loadTraffic(); // Refresh traffic weights
    notifyListeners();
  }

  // Add this method to handle box placement/removal
  void updateBox(int index, RoadTypes newType) {
    RoadTypes oldType = _boxManagerList[index];
    
    print("UpdateBox: index=$index, oldType=$oldType, newType=$newType");
    print(_usedPlaces);
    
    // Check if this index is currently in traffic (traffic doesn't go in boxManagerList)
    bool wasTraffic = (_traffics[0]['indices'] as List).contains(index);
    
    // Handle removing old type
    if (wasTraffic) {
      // Remove from traffic indices
      indicesToTraffic(0, index, add: false);
    } else if (oldType == RoadTypes.place) {
      // Remove place
      for(var place in _places) {
        if(place['index'] == index) {
          place['index'] = -1;
          _usedPlaces--;
          break;
        }
      }
    }
    
    // Handle adding new type
    if (newType == RoadTypes.traffic) {
      // Traffic doesn't go in boxManagerList, only in traffic indices
      // Keep the old boxManagerList value (or set to none if it was a place)
      if (oldType == RoadTypes.place) {
        _boxManagerList[index] = RoadTypes.none;
      }
      // Add to traffic indices
      indicesToTraffic(0, index, add: true);
    } else {
      // For all other types, update boxManagerList normally
      _boxManagerList[index] = newType;
      
      if (newType == RoadTypes.place) {
        // Add place
        for(var place in _places) {
          if(place['index'] == -1) {
            place['index'] = index;
            _usedPlaces++;
            break;
          }
        }
      }
    }
    
    loadTraffic(); // Refresh traffic weights
    notifyListeners();
  }

  List<int> getCoords(int index){
    var coords = [-1,-1];
    coords[1] = (index/gridSize).truncate();
    coords[0] = index-(coords[1]*gridSize);
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
          "places": [],
          "traffic": []
      },
      "trip": {}
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
        case RoadTypes.place:
          var value = {
                "name": "",
                "size": 1,
                "coords": getCoords(i)
            };
          payload['map']['places'].add(value);
          break;
        default:  
          break;
      }
    }

    List<List<int>> traffic_coords = [];
    for(var i = 0; i < _traffics[0]['indices'].length; i++){
      traffic_coords.add(getCoords(_traffics[0]['indices'][i]));
    }

    payload['trip'] = {
        "name": "Test Trip",
        "coords": []
    };

    // Use actual traffic data instead of hardcoded
    List<dynamic> trafficCoords = [];
    for(int index in _traffics[0]['indices']) {
      trafficCoords.add(getCoords(index));
    }
    
    payload['map']['traffic'] = [{
        "description": _traffics[0]['description'],
        "size": _traffics[0]['size'],
        "rate": _traffics[0]['rate'],
        "coords": trafficCoords
    }];

    if (payload['map']['places'].length >= 0){
      for(var i = 0; i < payload['map']['places'].length; i++){
        payload['trip']['coords'].add(payload['map']['places'][i]['coords']);
      }
    }

    return payload;
  }

  void generatePath() async{
    //await dotenv.load();
    print("Generating path...");

    Map<String,dynamic> payload = generatePayload();
    String payloadString = jsonEncode(payload);
    try{
      final response = await http.post(
        Uri.parse('https://ia-streets.onrender.com/get_path'),
        headers: {
        'Content-Type': 'application/json',
        'Connection': 'keep-alive',
        },
        body:payloadString)
        .timeout(Duration(seconds: 60));
      loadRouteBoxIndexes(jsonDecode(response.body)['coords']);
      print(response.body);
    } on TimeoutException catch (e) {
      print('Requested timeout: $e');
    } catch (e) {
      print('Other error: $e');
    }
  }

  void loadRouteBoxIndexes(var coords) {
    routeBoxIndexes.clear();

    for(var i = 0; i < coords.length; i++){
      routeBoxIndexes.add((coords[i][1]*gridSize)+(coords[i][0]));
    }
    notifyListeners();
  }

  void loadTraffic(){
    _bordersTrafficWeight.clear();
    for (var i = 0; i < gridSize*gridSize; i++){
      _bordersTrafficWeight.add(0);
    }
    for (var i = 0; i < _traffics.length; i++){
      for (var j = 0; j < _traffics[i]['indices'].length; j++){
        int trafficWeight = (_traffics[i]['size'] * _traffics[i]['rate']).round();
        print(trafficWeight);
        try{
          _bordersTrafficWeight[_traffics[i]['indices'][j]] += trafficWeight;
        }catch (e) {
          continue;
        }
      }
    }
    notifyListeners();
  }

  void updateTrafficSize(int trafficIndex, bool add){
    add ? _traffics[trafficIndex]['size'] += 10 : _traffics[trafficIndex]['size'] -= 10;
    _traffics[trafficIndex]['size'] = _traffics[trafficIndex]['size'] < 10 ? 10 : _traffics[trafficIndex]['size'];
    loadTraffic();
  }

  void updateTrafficRate(int trafficIndex, bool add){
    add ? _traffics[trafficIndex]['rate'] ++ : _traffics[trafficIndex]['rate'] --;
    _traffics[trafficIndex]['rate'] = _traffics[trafficIndex]['rate'] < 1 ? 1 : _traffics[trafficIndex]['rate'];
    loadTraffic();
  }

  void indicesToTraffic(int trafficIndex, int boxIndex, {bool add = true}){
    if(add) {
      if(!(_traffics[trafficIndex]['indices'] as List).contains(boxIndex)) {
        (_traffics[trafficIndex]['indices'] as List).add(boxIndex);
      }
    } else {
      (_traffics[trafficIndex]['indices'] as List).remove(boxIndex);
    }
    notifyListeners();
  }

  void _initializeBoxManagerList(){
    boxManagerList.clear();
    for(var i = 0; i<places.length; i++){
      places[i]['index'] = -1;
    }
    _usedPlaces = 0; // Fixed: Set to 0 instead of decrementing
    
    // Clear traffic indices
    for(var i = 0; i < _traffics.length; i++){
      _traffics[i]['indices'].clear();
    }
    
    loadTraffic();
    routeBoxIndexes.clear();
    for(var i = 0; i < gridSize*gridSize; i++){
      boxManagerList.add(RoadTypes.none);
    }
    notifyListeners();
  }

  //GETTERS
  List<RoadTypes> get boxManagerList => _boxManagerList;
  List<int> get routeBoxIndexes => _routeBoxIndexes;
  int get gridSize => _gridSize;
  RoadTypes get selectedBoxType => _selectedBoxType;
  get boxColors => _boxColors;
  int get usedPlaces => _usedPlaces;
  List<Map<String,dynamic>> get places => _places;
  List<Map<String,dynamic>> get traffics => _traffics;
  List<int> get bordersTrafficWeight => _bordersTrafficWeight;

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

  set routeBoxIndexes (List<int> newValue){
    _routeBoxIndexes = newValue;
    notifyListeners();
  }

  set usedPlaces (int newValue){
    _usedPlaces = newValue;
    notifyListeners();
  }

  set places (List<Map<String,dynamic>> newValue){
    _places = newValue;
    notifyListeners();
  }

  set traffics (List<Map<String,dynamic>> newValue){
    _traffics = newValue;
    notifyListeners();
  }

  set bordersTrafficWeight (List<int> newValue){
    _bordersTrafficWeight = newValue;
    notifyListeners();
  }
}