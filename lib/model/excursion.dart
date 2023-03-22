class Excursion {
  final String id;
  final int nParticipants;
  final double duration;
  final double distance;
  final DateTime date;

  Excursion({
    required this.id,
    required this.nParticipants,
    required this.duration,
    required this.distance,
    required this.date,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'nParticipants': nParticipants,
      'duration': duration,
      'distance': distance,
      'date': date.millisecondsSinceEpoch,
    };
  }

  factory Excursion.fromMap(Map<String, dynamic> map) {
    return Excursion(
      id: map['id'] ?? '',
      nParticipants: map['nParticipants'] ?? 1,
      duration: map['duration'] ?? 0.0,
      distance: map['distance'] ?? 0.0,
      date: DateTime.fromMillisecondsSinceEpoch(map['date']),
    );
  }
}
