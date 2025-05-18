import 'package:flutter/material.dart';

enum RoadTypes {none, highway, avenue, street, place}
final gridSize = 10;

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
    _gridSize = newValue;
    _initializeBoxManagerList();
    notifyListeners();
  }

  set boxManagerList (List<RoadTypes> newValue){
    _boxManagerList = newValue;
    notifyListeners();
  }
}