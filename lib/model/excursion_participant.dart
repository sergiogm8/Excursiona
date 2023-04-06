import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class ExcursionParticipant {
  final String uid;
  final String name;
  final String profilePic;
  final LatLng currentLocation;
  final bool isInExcursion;

  ExcursionParticipant({
    required this.uid,
    required this.name,
    required this.profilePic,
    required this.currentLocation,
    required this.isInExcursion,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'uid': uid,
      'name': name,
      'profilePic': profilePic,
      'currentLocation':
          GeoPoint(currentLocation.latitude, currentLocation.longitude),
      'isInExcursion': isInExcursion,
    };
  }

  factory ExcursionParticipant.fromMap(Map<String, dynamic> map) {
    return ExcursionParticipant(
      uid: map['uid'] as String,
      name: map['name'] as String,
      profilePic: map['profilePic'] as String,
      currentLocation: LatLng(
          map['currentLocation'].latitude, map['currentLocation'].longitude),
      isInExcursion: map['isInExcursion'] as bool,
    );
  }
}
