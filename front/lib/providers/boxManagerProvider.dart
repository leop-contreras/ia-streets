import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

enum RoadTypes { none, highway, avenue, street, place }

class BoxManagerProvider extends ChangeNotifier {
  int _gridSize = 10;
  RoadTypes _selectedBoxType = RoadTypes.place;
  String _placeMode = "stop";

  final List<RoadTypes> _boxManagerList = [];
  final List<int> _routeBoxIndexes = [];
  final Map<int, String> _placeTypesByIndex = {};
  final List<Map<String, dynamic>> _places = [];

  BoxManagerProvider() {
    _initializeGrid();
  }

  // =================== CORE ===================

  void boxTap(int index) {
    if (_selectedBoxType == RoadTypes.place) {
      _placeTypesByIndex[index] = _placeMode;
      _places.removeWhere((p) => p['coords'].join(',') == getCoords(index).join(','));
      _places.add({
        "name": _placeMode,
        "coords": getCoords(index),
        "size": 1,
      });
    }
    _boxManagerList[index] = _selectedBoxType;
    notifyListeners();
  }

  void clearBoxes() {
    _places.clear();
    _placeTypesByIndex.clear();
    _routeBoxIndexes.clear();
    for (var i = 0; i < _boxManagerList.length; i++) {
      _boxManagerList[i] = RoadTypes.none;
    }
    notifyListeners();
  }

  // =================== PAYLOAD ===================

  List<int> getCoords(int index) {
    int row = index ~/ _gridSize;
    int col = index % _gridSize;
    return [col, row];
  }

  Map<String, dynamic> generatePayload() {
    final map = {
      "dimensions": [_gridSize, _gridSize],
      "roads": {
        "highways": <List<int>>[],
        "avenues": <List<int>>[],
        "streets": <List<int>>[]
      },
      "places": <Map<String, dynamic>>[],
      "traffic": <List<int>>[]
    };

    for (int i = 0; i < _boxManagerList.length; i++) {
      final coords = getCoords(i);
      switch (_boxManagerList[i]) {
        case RoadTypes.highway:
          (map["roads"] as Map<String, dynamic>)["highways"].add(coords);
          break;
        case RoadTypes.avenue:
          (map["roads"] as Map<String, dynamic>)["avenues"].add(coords);
          break;
        case RoadTypes.street:
          (map["roads"] as Map<String, dynamic>)["streets"].add(coords);
          break;
        default:
          break;
      }
    }

    map["places"] = _places;

    final origin = _places.firstWhere((p) => p["name"] == "start", orElse: () => {"coords": [0, 0]});
    final destination = _places.firstWhere((p) => p["name"] == "end", orElse: () => {"coords": [0, 0]});

    return {
      "map": map,
      "trip": {
        "name": "Ruta",
        "origin": origin["coords"],
        "destination": destination["coords"]
      }
    };
  }

  Future<void> generatePath() async {
    try {
      final res = await http
          .post(
            Uri.parse("http://localhost:8000/get_path"), // Corregido el puerto
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(generatePayload()),
          )
          .timeout(const Duration(seconds: 10));
      final data = jsonDecode(res.body);
      loadRouteBoxIndexes(data["coords"]);
    } catch (e) {
      print("Error al generar ruta: $e");
    }
  }

  void loadRouteBoxIndexes(List coords) {
    _routeBoxIndexes.clear();
    for (final c in coords) {
      int index = c[1] * _gridSize + c[0];
      _routeBoxIndexes.add(index);
    }
    notifyListeners();
  }

  // =================== GRID ===================

  void _initializeGrid() {
    _boxManagerList.clear();
    for (var i = 0; i < _gridSize * _gridSize; i++) {
      _boxManagerList.add(RoadTypes.none);
    }
  }

  // =================== GETTERS ===================

  List<RoadTypes> get boxManagerList => _boxManagerList;
  List<int> get routeBoxIndexes => _routeBoxIndexes;
  Map<int, String> get placeTypesByIndex => _placeTypesByIndex;
  RoadTypes get selectedBoxType => _selectedBoxType;
  int get gridSize => _gridSize;

  Color getColorForBox(int index) {
    final type = _placeTypesByIndex[index];
    if (type == "start") return Colors.green;
    if (type == "end") return Colors.red;
    if (type == "stop") return Colors.orange;
    switch (_boxManagerList[index]) {
      case RoadTypes.highway:
        return Colors.red.shade200;
      case RoadTypes.avenue:
        return Colors.green.shade200;
      case RoadTypes.street:
        return Colors.blue.shade200;
      case RoadTypes.place:
        return Colors.amber;
      case RoadTypes.none:
      default:
        return Colors.grey.shade300;
    }
  }

  // =================== SETTERS ===================

  set selectedBoxType(RoadTypes type) {
    _selectedBoxType = type;
    notifyListeners();
  }

  set gridSize(int value) {
    if (value >= 3 && value <= 20) {
      _gridSize = value;
      _initializeGrid();
      notifyListeners();
    }
  }

  void setPlaceMode(String mode) {
    _placeMode = mode;
    notifyListeners();
  }
}
