import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:excursiona/enums/marker_type.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MarkerModel {
  final String id;
  final String? title;
  final String? imageUrl;
  final String? ownerName;
  final String? ownerPic;
  final String userId;
  final LatLng position;
  final MarkerType markerType;
  final DateTime timestamp;

  MarkerModel({
    required this.id,
    required this.position,
    required this.markerType,
    required this.userId,
    this.title,
    this.imageUrl,
    this.ownerName,
    this.ownerPic,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'title': title,
      'imageUrl': imageUrl,
      'position': GeoPoint(position.latitude, position.longitude),
      'markerType': markerType.type,
      'ownerName': ownerName,
      'ownerPic': ownerPic,
      'userId': userId,
      'timestamp': timestamp.millisecondsSinceEpoch
    };
  }

  factory MarkerModel.fromMap(Map<String, dynamic> map) {
    return MarkerModel(
        id: map['id'] as String,
        userId: map['userId'],
        ownerName: map['ownerName'] as String?,
        ownerPic: map['ownerPic'] as String?,
        title: map['title'] as String?,
        imageUrl: map['imageUrl'] as String?,
        position: LatLng(map['position'].latitude, map['position'].longitude),
        markerType: MarkerType.fromString(map['markerType']),
        timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp']));
  }
}
