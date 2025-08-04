import '../models/user.dart';

class MockUser {
  static User getCurrentUser() {
    return User(
      id: 'user_001',
      name: 'John Doe',
      email: 'john.doe@example.com',
      phoneNumber: '+1 (555) 123-4567',
      profileImageUrl: 'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=400',
      createdAt: DateTime(2024, 1, 15),
      isActive: true,
    );
  }
} 