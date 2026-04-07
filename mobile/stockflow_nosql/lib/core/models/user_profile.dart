class UserProfile {
  final String id;
  final String fullName;
  final String email;
  final bool isActive;

  UserProfile({
    required this.id,
    required this.fullName,
    required this.email,
    required this.isActive,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
        id: json['id'] as String,
        fullName: json['fullName'] as String,
        email: json['email'] as String,
        isActive: json['isActive'] as bool,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'fullName': fullName,
        'email': email,
        'isActive': isActive,
      };
}
