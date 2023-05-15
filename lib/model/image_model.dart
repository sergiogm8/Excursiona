class ImageModel {
  final String ownerName;
  final String ownerPic;
  final String imageUrl;
  final DateTime timestamp;

  ImageModel({
    required this.ownerName,
    required this.ownerPic,
    required this.imageUrl,
    required this.timestamp,
  });

  factory ImageModel.fromMap(Map<String, dynamic> map) {
    return ImageModel(
      ownerName: map['ownerName'] as String,
      ownerPic: map['ownerPic'] as String,
      imageUrl: map['imageUrl'] as String,
      timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp'] as int),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'ownerName': ownerName,
      'ownerPic': ownerPic,
      'imageUrl': imageUrl,
      'timestamp': timestamp.millisecondsSinceEpoch,
    };
  }
}
