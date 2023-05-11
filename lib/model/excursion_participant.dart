import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:excursiona/model/user_model.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class ExcursionParticipant {
  final String uid;
  final String name;
  final String profilePic;
  final bool isInExcursion;
  final DateTime? joinedAt;
  final DateTime? leftAt;

  ExcursionParticipant({
    required this.uid,
    required this.name,
    required this.profilePic,
    required this.isInExcursion,
    this.joinedAt,
    this.leftAt,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'uid': uid,
      'name': name,
      'profilePic': profilePic,
      'isInExcursion': isInExcursion,
      'joinedAt': joinedAt?.millisecondsSinceEpoch,
      'leftAt': leftAt?.millisecondsSinceEpoch,
    };
  }

  factory ExcursionParticipant.fromMap(Map<String, dynamic> map) {
    return ExcursionParticipant(
      uid: map['uid'] as String,
      name: map['name'] as String,
      profilePic: map['profilePic'] as String,
      isInExcursion: map['isInExcursion'] as bool,
      joinedAt: DateTime.fromMillisecondsSinceEpoch(map['joinedAt']),
      leftAt: DateTime.fromMillisecondsSinceEpoch(map['leftAt']),
    );
  }

  factory ExcursionParticipant.fromUserModel(UserModel user) {
    return ExcursionParticipant(
      uid: user.uid,
      name: user.name,
      profilePic: user.profilePic,
      isInExcursion: true,
      joinedAt: DateTime.now(),
    );
  }
}
