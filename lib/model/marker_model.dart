import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:excursiona/enums/marker_type.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MarkerModel {
  final String id;
  final String userId;
  final LatLng position;
  final MarkerType markerType;
  final DateTime timestamp;
  final String? title;
  final String? imageUrl;
  final String? ownerName;
  final String? ownerPic;
  final double? altitude;
  final double? speed;
  final double? distance;
  final int? batteryLevel;

  MarkerModel({
    required this.id,
    required this.userId,
    required this.position,
    required this.markerType,
    required this.timestamp,
    this.title,
    this.imageUrl,
    this.ownerName,
    this.ownerPic,
    this.altitude,
    this.speed,
    this.distance,
    this.batteryLevel,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'userId': userId,
      'position': GeoPoint(position.latitude, position.longitude),
      'title': title,
      'imageUrl': imageUrl,
      'markerType': markerType.type,
      'ownerName': ownerName,
      'ownerPic': ownerPic,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'altitude': altitude,
      'speed': speed,
      'distance': distance,
      'batteryLevel': batteryLevel,
    };
  }

  factory MarkerModel.fromMap(Map<String, dynamic> map) {
    return MarkerModel(
      id: map['id'] as String,
      userId: map['userId'],
      ownerName: map['ownerName'] as String?,
      ownerPic: map['ownerPic'] as String?,
      title: map['title'] as String?,
      imageUrl: map['imageUrl'] ?? '',
      position: LatLng(map['position'].latitude, map['position'].longitude),
      altitude: map['altitude'] as double?,
      markerType: MarkerType.fromString(map['markerType']),
      timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp']),
      speed: map['speed'] as double?,
      distance: map['distance'] as double?,
      batteryLevel: map['batteryLevel'] as int?,
    );
  }
}
