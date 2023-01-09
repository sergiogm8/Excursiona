class UserModel {
  final String name;
  final String uid;
  final String profilePic;
  final String email;
  final List<String> contactsID;

  UserModel(
      {required this.name,
      required this.uid,
      required this.profilePic,
      required this.email,
      required this.contactsID});

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      name: map['name'] ?? '',
      uid: map['uid'] ?? '',
      profilePic: map['profilePic'] ?? '',
      email: map['email'] ?? '',
      contactsID: List<String>.from(map['contactsID']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'uid': uid,
      'profilePic': profilePic,
      'email': email,
      'contactsID': contactsID,
    };
  }
}
