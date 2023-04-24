class Excursion {
  final String ownerName;
  final String ownerPic;
  final String title;
  final String id;
  final String description;
  final String difficulty;
  final int nParticipants;
  final double duration;
  final double distance;
  final DateTime date;

  Excursion({
    required this.ownerName,
    required this.ownerPic,
    required this.id,
    required this.nParticipants,
    this.duration = 0,
    this.distance = 0,
    required this.title,
    required this.date,
    required this.description,
    required this.difficulty,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'ownerName': ownerName,
      'ownerPic': ownerPic,
      'title': title,
      'id': id,
      'nParticipants': nParticipants,
      'duration': duration,
      'distance': distance,
      'date': date.millisecondsSinceEpoch,
      'description': description,
      'difficulty': difficulty,
    };
  }

  Map<String, dynamic> toMapForInvitation() {
    return <String, dynamic>{
      'title': title,
      'id': id,
      'ownerName': ownerName,
      'ownerPic': ownerPic,
    };
  }

  factory Excursion.fromMap(Map<String, dynamic> map) {
    return Excursion(
      ownerName: map['ownerName'] ?? '',
      ownerPic: map['ownerPic'] ?? '',
      title: map['title'] ?? '',
      id: map['id'] ?? '',
      nParticipants: map['nParticipants'] ?? 1,
      duration: map['duration'] ?? 0.0,
      distance: map['distance'] ?? 0.0,
      date: DateTime.fromMillisecondsSinceEpoch(map['date']),
      description: map['description'] ?? '',
      difficulty: map['difficulty'] ?? '',
    );
  }
}
