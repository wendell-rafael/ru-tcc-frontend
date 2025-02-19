class UserNormal {
  final String id;
  final String name;
  final String email;
  final String? photoUrl;
  final String role;

  UserNormal({
    required this.id,
    required this.name,
    required this.email,
    this.photoUrl,
    required this.role,
  });

  factory UserNormal.fromJson(Map<String, dynamic> json) {
    return UserNormal(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      photoUrl: json['photoUrl'],
      role: json['role'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'photoUrl': photoUrl,
      'role': role,
    };
  }
}
