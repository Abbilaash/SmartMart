import 'package:flutter/material.dart';
import '../data/mock_user.dart';
import '../models/user.dart';
import '../utils/constants.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late User _user;
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;

  @override
  void initState() {
    super.initState();
    _user = MockUser.getCurrentUser();
    _nameController = TextEditingController(text: _user.name);
    _emailController = TextEditingController(text: _user.email);
    _phoneController = TextEditingController(text: _user.phoneNumber);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () {
              _showLogoutDialog(context);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(AppSizes.paddingMedium),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Profile Header
              _buildProfileHeader(),
              SizedBox(height: AppSizes.paddingLarge),

              // Profile Form
              _buildProfileForm(),
              SizedBox(height: AppSizes.paddingLarge),

              // Action Buttons
              _buildActionButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Column(
      children: [
        // Profile Image
        CircleAvatar(
          radius: 50,
          backgroundImage: NetworkImage(_user.profileImageUrl ?? ''),
          onBackgroundImageError: (exception, stackTrace) {
            // Handle image error
          },
          child: _user.profileImageUrl == null
              ? Icon(Icons.person, size: 50, color: Colors.white)
              : null,
        ),
        SizedBox(height: AppSizes.paddingMedium),
        Text(
          _user.name,
          style: AppTextStyles.heading2,
        ),
        Text(
          'Member since ${_user.createdAt.year}',
          style: AppTextStyles.caption,
        ),
      ],
    );
  }

  Widget _buildProfileForm() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(AppSizes.paddingMedium),
        child: Column(
          children: [
            // Name Field
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Full Name',
                prefixIcon: Icon(Icons.person),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your name';
                }
                return null;
              },
            ),
            SizedBox(height: AppSizes.paddingMedium),

            // Email Field
            TextFormField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'Email',
                prefixIcon: Icon(Icons.email),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your email';
                }
                if (!value.contains('@')) {
                  return 'Please enter a valid email';
                }
                return null;
              },
            ),
            SizedBox(height: AppSizes.paddingMedium),

            // Phone Field
            TextFormField(
              controller: _phoneController,
              decoration: InputDecoration(
                labelText: 'Phone Number',
                prefixIcon: Icon(Icons.phone),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your phone number';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        // Update Profile Button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _updateProfile,
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: AppSizes.paddingMedium),
            ),
            child: Text(
              'Update Profile',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        SizedBox(height: AppSizes.paddingMedium),

        // Settings Options
        Card(
          child: Column(
            children: [
              ListTile(
                leading: Icon(Icons.notifications, color: AppColors.primaryPurple),
                title: Text('Notifications'),
                subtitle: Text('Manage your notification preferences'),
                trailing: Icon(Icons.chevron_right),
                onTap: () {
                  // TODO: Navigate to notifications settings
                },
              ),
              Divider(height: 1),
              ListTile(
                leading: Icon(Icons.security, color: AppColors.primaryPurple),
                title: Text('Privacy & Security'),
                subtitle: Text('Manage your privacy settings'),
                trailing: Icon(Icons.chevron_right),
                onTap: () {
                  // TODO: Navigate to privacy settings
                },
              ),
              Divider(height: 1),
              ListTile(
                leading: Icon(Icons.help, color: AppColors.primaryPurple),
                title: Text('Help & Support'),
                subtitle: Text('Get help and contact support'),
                trailing: Icon(Icons.chevron_right),
                onTap: () {
                  // TODO: Navigate to help screen
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _updateProfile() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _user = _user.copyWith(
          name: _nameController.text,
          email: _emailController.text,
          phoneNumber: _phoneController.text,
        );
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Profile updated successfully!'),
          backgroundColor: AppColors.successGreen,
        ),
      );
    }
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Logout'),
        content: Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              // TODO: Implement logout functionality
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Logout functionality coming soon!')),
              );
            },
            child: Text('Logout', style: TextStyle(color: AppColors.errorRed)),
          ),
        ],
      ),
    );
  }
} 