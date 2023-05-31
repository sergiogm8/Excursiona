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
    this.mapSnapshotUrl,
  });

  factory ExcursionRecap.fromMap(Map<String, dynamic> map) {
    return ExcursionRecap(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      difficulty: map['difficulty'] ?? '',
      date: DateTime.fromMillisecondsSinceEpoch(map['date'] ?? 0),
      duration: Duration(seconds: map['duration'] ?? 0),
      distance: map['distance'] ?? 0.0,
      avgSpeed: map['avgSpeed'] ?? 0.0,
      nParticipants: map['nParticipants'] ?? 0,
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
      'duration': duration.inSeconds,
      'distance': distance,
      'avgSpeed': avgSpeed,
      'nParticipants': nParticipants,
      'mapSnapshotUrl': mapSnapshotUrl,
    };
  }
}
