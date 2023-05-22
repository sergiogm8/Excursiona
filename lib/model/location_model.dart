import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class LocationModel {
  final LatLng position;
  final DateTime timestamp;

  LocationModel({required this.position, required this.timestamp});

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'position': GeoPoint(position.latitude, position.longitude),
      'timestamp': timestamp.millisecondsSinceEpoch,
    };
  }

  factory LocationModel.fromMap(Map<String, dynamic> map) {
    return LocationModel(
      position: LatLng(map['position'].latitude, map['position'].longitude),
      timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp']),
    );
  }
}
