import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class LocationModel {
  final LatLng position;
  final DateTime timestamp;
  final double speed;
  final double altitude;

  LocationModel(
      {required this.position,
      required this.timestamp,
      required this.speed,
      required this.altitude});

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'position': GeoPoint(position.latitude, position.longitude),
      'timestamp': timestamp.millisecondsSinceEpoch,
      'speed': speed,
      'altitude': altitude,
    };
  }

  factory LocationModel.fromMap(Map<String, dynamic> map) {
    return LocationModel(
      position: LatLng(map['position'].latitude, map['position'].longitude),
      timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp']),
      speed: map['speed'],
      altitude: map['altitude'],
    );
  }
}

class RouteModel {
  List<LocationModel>? route;
  double? distance;

  RouteModel({this.route, this.distance}) {
    route ??= [];
    distance ??= 0;
  }

  LatLng get startPoint => route!.first.position;
  LatLng get endPoint => route!.last.position;
  double get avgSpeed =>
      route!.map((location) => location.speed).reduce((a, b) => a + b) /
      route!.length;
  double get avgAltitude =>
      route!.map((location) => location.altitude).reduce((a, b) => a + b) /
      route!.length;

  void addLocation(double latitude, double longitude, double speed,
      double altitude, double distance) {
    route!.add(LocationModel(
        position: LatLng(latitude, longitude),
        timestamp: DateTime.now(),
        speed: speed,
        altitude: altitude));
    this.distance = distance;
  }

  LocationModel getMidPoint() {
    var midPoint = route!.length ~/ 2;
    return route![midPoint];
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'route': route!.map((location) => location.toMap()).toList(),
      'distance': distance,
    };
  }

  factory RouteModel.fromMap(Map<String, dynamic> map) {
    return RouteModel(
      route: map['route']
          .map<LocationModel>((location) => LocationModel.fromMap(location))
          .toList(),
      distance: map['distance'],
    );
  }
}
