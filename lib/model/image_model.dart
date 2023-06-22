class ImageModel {
  final String ownerId;
  final String ownerName;
  final String ownerPic;
  final String imageUrl;
  final DateTime timestamp;

  ImageModel({
    required this.ownerId,
    required this.ownerName,
    required this.ownerPic,
    required this.imageUrl,
    required this.timestamp,
  });

  factory ImageModel.fromMap(Map<String, dynamic> map) {
    return ImageModel(
      ownerId: map['ownerId'] as String,
      ownerName: map['ownerName'] as String,
      ownerPic: map['ownerPic'] as String,
      imageUrl: map['imageUrl'] as String,
      timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp'] as int),
    );
  }

  factory ImageModel.fromMapForGallery(Map<String, dynamic> map) {
    return ImageModel(
      ownerId: map['userId'] as String,
      ownerName: '',
      ownerPic: '',
      imageUrl: map['imageUrl'] as String,
      timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp'] as int),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'ownerId': ownerId,
      'ownerName': ownerName,
      'ownerPic': ownerPic,
      'imageUrl': imageUrl,
      'timestamp': timestamp.millisecondsSinceEpoch,
    };
  }

  Map<String, dynamic> toMapForGallery() {
    return {
      'userId': ownerId,
      'imageUrl': imageUrl,
      'timestamp': timestamp.millisecondsSinceEpoch,
    };
  }
}
