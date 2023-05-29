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
