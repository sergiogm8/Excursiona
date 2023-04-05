class UserModel {
  final String name;
  final String uid;
  final String profilePic;
  final String email;
  final List contactsID;

  UserModel(
      {this.name = '',
      this.uid = '',
      this.profilePic = '',
      this.email = '',
      this.contactsID = const []});

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      name: map['name'] ?? '',
      uid: map['uid'] ?? '',
      profilePic: map['profilePic'] ?? '',
      email: map['email'] ?? '',
      contactsID: map['contacts'] ?? [],
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

  Map<String, dynamic> toMapShort() {
    return {
      'name': name,
      'uid': uid,
      'profilePic': profilePic,
    };
  }
}
