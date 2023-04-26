class Invitation {
  final String excursionTitle;
  final String excursionId;
  final String ownerName;
  final String ownerPic;

  Invitation({
    required this.excursionTitle,
    required this.excursionId,
    required this.ownerName,
    required this.ownerPic,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'excursionTitle': excursionTitle,
      'excursionId': excursionId,
      'ownerName': ownerName,
      'ownerPic': ownerPic,
    };
  }

  factory Invitation.fromMap(Map<String, dynamic> map) {
    return Invitation(
      excursionTitle: map['excursionTitle'] ?? '',
      excursionId: map['excursionId'] ?? '',
      ownerName: map['ownerName'] ?? '',
      ownerPic: map['ownerPic'] ?? '',
    );
  }
}
