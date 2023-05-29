import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class EmergencyAlert {
  final String id;
  final String requesterName;
  final String requesterPic;
  final LatLng position;

  EmergencyAlert({
    required this.id,
    required this.requesterName,
    required this.requesterPic,
    required this.position,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'requesterName': requesterName,
      'requesterPic': requesterPic,
      'position': GeoPoint(position.latitude, position.longitude),
    };
  }

  factory EmergencyAlert.fromMap(Map<String, dynamic> map) {
    return EmergencyAlert(
      id: map['id'],
      requesterName: map['requesterName'],
      requesterPic: map['requesterPic'],
      position: LatLng(map['position'].latitude, map['position'].longitude),
    );
  }
}
