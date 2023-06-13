class UserModel {
  final String name;
  final String uid;
  final String profilePic;
  final String email;
  final int nExcursions;
  final double totalDistance;
  final Duration totalTime;
  final double avgSpeed;
  final int nPhotos;
  final int nMarkers;

  UserModel({
    this.name = '',
    this.uid = '',
    this.profilePic = '',
    this.email = '',
    this.nExcursions = 0,
    this.totalDistance = 0,
    this.totalTime = const Duration(),
    this.avgSpeed = 0,
    this.nPhotos = 0,
    this.nMarkers = 0,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      name: map['name'] ?? '',
      uid: map['uid'] ?? '',
      profilePic: map['profilePic'] ?? '',
      email: map['email'] ?? '',
      nExcursions: map['nExcursions'] ?? 0,
      totalDistance: map['totalDistance'] ?? 0,
      totalTime: Duration(minutes: map['totalTime'] ?? 0),
      avgSpeed: map['avgSpeed'] ?? 0,
      nPhotos: map['nPhotos'] ?? 0,
      nMarkers: map['nMarkers'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'uid': uid,
      'profilePic': profilePic,
      'email': email,
      'nExcursions': nExcursions,
      'totalDistance': totalDistance,
      'totalTime': totalTime.inMinutes,
      'avgSpeed': avgSpeed,
      'nPhotos': nPhotos,
      'nMarkers': nMarkers,
    };
  }

  Map<String, dynamic> toMapShort() {
    return {
      'name': name,
      'uid': uid,
      'profilePic': profilePic,
    };
  }
}
