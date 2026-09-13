class UserModel {
  final String uid;
  final String name;
  final String email;
  final String? photoUrl;
  final String language;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    this.photoUrl,
    required this.language,
    this.createdAt,
    this.updatedAt,
  });
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'photoUrl': photoUrl,
      'language': language,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
  factory UserModel.fromMap(
      String uid,
      Map<String, dynamic> map,
      ) {
    return UserModel(
      uid: uid,
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      photoUrl: map['photoUrl'],
      language: map['language'] ?? 'en',
      createdAt: map['createdAt']?.toDate(),
      updatedAt: map['updatedAt']?.toDate(),
    );
  }
}