class StatisticRecap {
  final DateTime startTime;
  final DateTime endTime;
  final int nParticipants;
  final int nPhotos;
  final int nMarkers;
  double? distance;
  double? avgSpeed;
  double? avgAltitude;

  StatisticRecap(
      {required this.startTime,
      required this.endTime,
      required this.nParticipants,
      required this.nPhotos,
      required this.nMarkers,
      this.distance,
      this.avgSpeed,
      this.avgAltitude});

  setAvgSpeed(double speed) => avgSpeed = speed;
  setAvgAltitude(double altitude) => avgAltitude = altitude;
  setDistance(double distance) => distance = distance;

  Duration get duration => endTime.difference(startTime);
}

class ExcursionRecap {
  final String id;
  final String title;
  final String description;
  final String difficulty;
  final DateTime date;
  final Duration duration;
  final double distance;
  final double avgSpeed;
  final int nParticipants;
  final String userId;
  final String userPic;
  final String userName;
  String? mapSnapshotUrl;

  ExcursionRecap({
    required this.id,
    required this.title,
    required this.description,
    required this.difficulty,
    required this.date,
    required this.duration,
    required this.distance,
    required this.avgSpeed,
    required this.nParticipants,
    required this.userId,
    required this.userPic,
    required this.userName,
    this.mapSnapshotUrl,
  });

  factory ExcursionRecap.fromMap(Map<String, dynamic> map) {
    return ExcursionRecap(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      difficulty: map['difficulty'] ?? '',
      date: DateTime.fromMillisecondsSinceEpoch(map['date'] ?? 0),
      duration: Duration(minutes: map['duration'] ?? 0),
      distance: map['distance'] ?? 0.0,
      avgSpeed: map['avgSpeed'] ?? 0.0,
      nParticipants: map['nParticipants'] ?? 0,
      userId: map['userId'] ?? '',
      userPic: map['userPic'] ?? '',
      userName: map['userName'] ?? '',
      mapSnapshotUrl: map['mapSnapshotUrl'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'title': title,
      'description': description,
      'difficulty': difficulty,
      'date': date.millisecondsSinceEpoch,
      'duration': duration.inMinutes,
      'distance': distance,
      'avgSpeed': avgSpeed,
      'nParticipants': nParticipants,
      'userId': userId,
      'userPic': userPic,
      'userName': userName,
      'mapSnapshotUrl': mapSnapshotUrl,
    };
  }
}
