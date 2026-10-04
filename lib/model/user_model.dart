class UserModel {
  final String uid;
  final String name;
  final String email;
  final String? photoUrl;
  final String language;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final int currentStreak;
  final int longestStreak;
  final DateTime? lastCompletedDate;
  final int? birthdayMonth;
  final int? birthdayDay;
  final String voiceGender;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.language,
    this.photoUrl,
    this.createdAt,
    this.updatedAt,
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.lastCompletedDate,
    this.birthdayMonth,
    this.birthdayDay,
    this.voiceGender = 'female',
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'photoUrl': photoUrl,
      'language': language,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'currentStreak': currentStreak,
      'longestStreak': longestStreak,
      'lastCompletedDate': lastCompletedDate,
      'birthdayMonth': birthdayMonth,
      'birthdayDay': birthdayDay,
      'voiceGender': voiceGender,
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
      currentStreak: map['currentStreak'] ?? 0,
      longestStreak: map['longestStreak'] ?? 0,
      lastCompletedDate: map['lastCompletedDate']?.toDate(),
      birthdayMonth: map['birthdayMonth'],
      birthdayDay: map['birthdayDay'],
      voiceGender: map['voiceGender'] ?? 'female',
    );
  }
}