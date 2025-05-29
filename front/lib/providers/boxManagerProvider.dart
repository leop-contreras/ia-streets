import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

enum RoadTypes {none, highway, avenue, street, place}
enum OptionType {none, highway, avenue, street, place, traffic, route}

class BoxManagerProvider extends ChangeNotifier{
  OptionType _selectedOption = OptionType.none;
  List<RoadTypes> _boxManagerList = [];
  List<List<int>> _routesBoxIndexes = [];
  int _usedPlaces = 0;
  int _selectedPlaceIndex = 0;
  int _selectedTrafficIndex = 0;
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
      "name":'E',
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
  List<Map<String,dynamic>> _traffics = [
    {
        "name": "X",
        "size":10,
        "rate":1,
        "indices": []
    },
    {
        "name": "Y",
        "size":10,
        "rate":1,
        "indices": []
    },
    {
        "name": "Z",
        "size":10,
        "rate":1,
        "indices": []
    }
    ];
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
    
    routesBoxIndexes.clear();
    loadTraffic(); // Refresh traffic weights
    notifyListeners();
  }

  void handleRoad(int index, {int dragMode = 0}) {
    RoadTypes oldType = _boxManagerList[index];

    if(selectedBoxType == RoadTypes.place) return;
    if(_boxManagerList[index] == RoadTypes.place) return;

    print("handleRoad: index=$index, oldType=$oldType, newType=$selectedBoxType");

    if(dragMode == 1){
      _boxManagerList[index] = selectedBoxType;
      notifyListeners();
      return;
    }else if(dragMode == -1){
      _boxManagerList[index] = RoadTypes.none;
      notifyListeners();
      return;
    }

    _boxManagerList[index] = oldType != selectedBoxType ? selectedBoxType : RoadTypes.none;
    
    notifyListeners();
  }

  void handlePlace(int index){
    print("Handle place at $index");

    // Check if a place is there, if -1 or index remove, if other index exchange
    // If no place there, if index already placed exchange, if not place check for limit and place
    if(selectedPlaceIndex == -1){
      for(var place in _places){
        if(place['index'] == index){
          place['index'] = -1;
          _usedPlaces--;
          _boxManagerList[index] = RoadTypes.none;
          notifyListeners();
          return;
        }
      }
    }

    if (selectedPlaceIndex == -1) return;

    if(boxManagerList[index] == RoadTypes.place){
      if(selectedPlaceIndex == -1 || places[selectedPlaceIndex]['index'] == index){
        places[selectedPlaceIndex]['index'] = -1;
        _usedPlaces--;
        _boxManagerList[index] = RoadTypes.none;
      }else{
        for(var place in _places){
          if(place['index'] == index){
            place['index'] = -1;
            places[selectedPlaceIndex]['index'] = index;
            break;
          }
        }
      }
    }else{
      if(places[selectedPlaceIndex]['index'] != -1){
        places[selectedPlaceIndex]['index'] = index;
        _boxManagerList[index] = RoadTypes.place;
      }else if(_usedPlaces < _places.length){
        places[selectedPlaceIndex]['index'] = index;
        _usedPlaces++;
        _boxManagerList[index] = RoadTypes.place;
      }
    }

    // Unselect place
    selectedPlaceIndex = -1;
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
          "traffics": []
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
    
    for(var i = 0; i < _traffics.length; i++){
      if(traffics[i]['indices'].length > 0){
        List<List<int>> trafficCoords = [];
        for(var j = 0; j < _traffics[i]['indices'].length; j++){
          trafficCoords.add(getCoords(_traffics[i]['indices'][j]));
        }
        Map<String,dynamic> traffic = {
          "name": _traffics[i]['name'],
          "size": _traffics[i]['size'],
          "rate": _traffics[i]['rate'],
          "coords": trafficCoords
        };
        payload['map']['traffics'].add(traffic);
      }
    }

    for(var i = 0; i < places.length; i++){
        if(places[i]['index'] != -1){
          Map<String,dynamic> place = {
            "name": places[i]['name'],
            "coords": getCoords(places[i]['index'])
          };
          payload['map']['places'].add(place);
        }
    }

    print(payload);
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
      var trips = jsonDecode(response.body)['trips'];
      routesBoxIndexes.clear();
      for(var i = 0; i < trips.length; i++){
        loadRouteBoxIndexes(i,trips[i]['coords']);
      }
      print(response.body);
    } on TimeoutException catch (e) {
      print('Requested timeout: $e');
    } catch (e) {
      print('Other error: $e');
    }
  }

  void loadRouteBoxIndexes(int tripIndex, var coords) {
     routesBoxIndexes.add([]);
    for(var i = 0; i < coords.length; i++){
      routesBoxIndexes[tripIndex].add((coords[i][1]*gridSize)+(coords[i][0]));
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

  void handleTraffic(int trafficIndex, int boxIndex){
    if(!(_traffics[trafficIndex]['indices'] as List).contains(boxIndex)) {
      (_traffics[trafficIndex]['indices'] as List).add(boxIndex);
    }else{
      (_traffics[trafficIndex]['indices'] as List).remove(boxIndex);
    }
    loadTraffic();
    notifyListeners();
  }

  void changeOption(OptionType selectedOptionType){
    final bool isToggleOn = selectedOptionType != selectedOption ? true : false;
    selectedOption = isToggleOn ? selectedOptionType : OptionType.none;
    switch(selectedOptionType){
      case OptionType.avenue: selectedBoxType = isToggleOn ? RoadTypes.avenue : RoadTypes.none; break;
      case OptionType.highway: selectedBoxType = isToggleOn ? RoadTypes.highway : RoadTypes.none; break;
      case OptionType.street: selectedBoxType = isToggleOn ? RoadTypes.street : RoadTypes.none; break;
      case OptionType.place: selectedBoxType = isToggleOn ? RoadTypes.place : RoadTypes.none; break;
      case OptionType.traffic: selectedBoxType = RoadTypes.none; break;
      case OptionType.route: selectedBoxType = RoadTypes.none; break;
      default: break;
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
    routesBoxIndexes.clear();
    for(var i = 0; i < gridSize*gridSize; i++){
      boxManagerList.add(RoadTypes.none);
    }
    notifyListeners();
  }

  //GETTERS
  List<RoadTypes> get boxManagerList => _boxManagerList;
  List<List<int>> get routesBoxIndexes => _routesBoxIndexes;
  int get gridSize => _gridSize;
  RoadTypes get selectedBoxType => _selectedBoxType;
  get boxColors => _boxColors;
  int get usedPlaces => _usedPlaces;
  List<Map<String,dynamic>> get places => _places;
  List<Map<String,dynamic>> get traffics => _traffics;
  List<int> get bordersTrafficWeight => _bordersTrafficWeight;
  OptionType get selectedOption => _selectedOption;
  int get selectedPlaceIndex => _selectedPlaceIndex;
  int get selectedTrafficIndex => _selectedTrafficIndex;

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

  set routesBoxIndexes (List<List<int>> newValue){
    _routesBoxIndexes = newValue;
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

  set selectedOption (OptionType newValue){
    _selectedOption = newValue;
    notifyListeners();
  }

  set selectedPlaceIndex (int newValue){
    _selectedPlaceIndex = newValue;
    notifyListeners();
  }

  set selectedTrafficIndex (int newValue){
    _selectedTrafficIndex = newValue;
    notifyListeners();
  }
}