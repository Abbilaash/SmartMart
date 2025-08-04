class User {
  final String id;
  final String name;
  final String email;
  final String phoneNumber;
  final String? profileImageUrl;
  final DateTime createdAt;
  final bool isActive;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.phoneNumber,
    this.profileImageUrl,
    required this.createdAt,
    required this.isActive,
  });

  // Create User from JSON
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      phoneNumber: json['phoneNumber'],
      profileImageUrl: json['profileImageUrl'],
      createdAt: DateTime.parse(json['createdAt']),
      isActive: json['isActive'],
    );
  }

  // Convert User to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phoneNumber': phoneNumber,
      'profileImageUrl': profileImageUrl,
      'createdAt': createdAt.toIso8601String(),
      'isActive': isActive,
    };
  }

  // Copy with method for creating modified copies
  User copyWith({
    String? id,
    String? name,
    String? email,
    String? phoneNumber,
    String? profileImageUrl,
    DateTime? createdAt,
    bool? isActive,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      createdAt: createdAt ?? this.createdAt,
      isActive: isActive ?? this.isActive,
    );
  }
} 