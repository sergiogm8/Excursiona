import 'package:excursiona/model/user_model.dart';

class ExcursionParticipant extends UserModel {
  final bool isInExcursion;
  final DateTime? joinedAt;
  final DateTime? leftAt;

  ExcursionParticipant({
    required super.uid,
    required super.name,
    required super.profilePic,
    required this.isInExcursion,
    this.joinedAt,
    this.leftAt,
  });

  @override
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
      leftAt: DateTime.fromMillisecondsSinceEpoch(map['leftAt'] ?? 0),
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
