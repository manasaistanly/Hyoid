import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hyoid_app/theme/app_theme.dart';
import 'package:hyoid_app/screens/login_screen.dart';
import 'package:hyoid_app/screens/register_screen.dart';
import 'package:hyoid_app/models/user_model.dart';
import 'package:hyoid_app/providers/auth_provider.dart';
import 'package:hyoid_app/providers/user_provider.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl_phone_field/intl_phone_field.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isEditing = false;
  final _formKey = GlobalKey<FormState>();

  // Controllers for editing
  late TextEditingController _nameController;
  late TextEditingController _ageController;
  late TextEditingController _phoneController;
  late TextEditingController _dobController;
  late TextEditingController _bloodGroupController;
  late TextEditingController _emergencyContactController;
  late TextEditingController _addressController;
  
  String _completePhoneNumber = '';
  String _completeEmergencyNumber = '';

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _ageController = TextEditingController();
    _phoneController = TextEditingController();
    _dobController = TextEditingController();
    _bloodGroupController = TextEditingController();
    _emergencyContactController = TextEditingController();
    _addressController = TextEditingController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userProvider = context.read<UserProvider>();
      final auth = context.read<AuthProvider>();
      if (auth.isAuthenticated && userProvider.currentUser == null) {
        userProvider.loadProfile();
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _phoneController.dispose();
    _dobController.dispose();
    _bloodGroupController.dispose();
    _emergencyContactController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  void _initControllers(UserModel user) {
    _nameController.text = user.name;
    _ageController.text = user.age?.toString() ?? '';
    _phoneController.text = user.phone ?? '';
    _dobController.text = user.dateOfBirth ?? '';
    _bloodGroupController.text = user.bloodGroup ?? '';
    _emergencyContactController.text = user.emergencyContact ?? '';
    _addressController.text = user.address ?? '';
    
    // Initialize complete numbers with existing data so they aren't lost if not edited
    _completePhoneNumber = user.phone ?? '';
    _completeEmergencyNumber = user.emergencyContact ?? '';
  }

  Future<void> _pickAndUploadImage() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      final success = await context.read<UserProvider>().uploadAvatar(
        File(image.path),
      );
      if (success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Profile photo updated!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                context.read<UserProvider>().errorMessage ?? 'Upload failed',
              ),
            ),
          );
        }
      }
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    final success = await context.read<UserProvider>().updateProfile({
      'name': _nameController.text,
      'age': int.tryParse(_ageController.text),
      'phone': _completePhoneNumber.isNotEmpty ? _completePhoneNumber : '+91${_phoneController.text}',
      'dateOfBirth': _dobController.text,
      'bloodGroup': _bloodGroupController.text,
      'emergencyContact': _completeEmergencyNumber.isNotEmpty ? _completeEmergencyNumber : '+91${_emergencyContactController.text}',
      'address': _addressController.text,
    });

    if (success) {
      setState(() => _isEditing = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              context.read<UserProvider>().errorMessage ?? 'Update failed',
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final userProvider = context.watch<UserProvider>();
    final isGuest = auth.isGuest;

    if (isGuest) {
      return _buildGuestUI();
    }

    if (userProvider.isLoading && userProvider.currentUser == null) {
      return const Center(
        child: CircularProgressIndicator(color: AppTheme.orangeAccent),
      );
    }

    final user = userProvider.currentUser;
    if (user == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Failed to load profile',
              style: TextStyle(color: Colors.white70),
            ),
            TextButton(
              onPressed: () => userProvider.loadProfile(),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    // Initialize controllers once data is available and not editing
    if (!_isEditing) {
      _initControllers(user);
    }

    return SafeArea(
      child: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'My Profile',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                IconButton(
                  icon: Icon(
                    _isEditing ? Icons.close : Icons.edit,
                    color: AppTheme.orangeAccent,
                  ),
                  onPressed: () => setState(() => _isEditing = !_isEditing),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Center(
              child: Column(
                children: [
                  Stack(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: AppTheme.borderCol,
                        backgroundImage:
                            user.profileImage != null &&
                                user.profileImage!.startsWith('http')
                            ? NetworkImage(user.profileImage!)
                            : null,
                        child:
                            user.profileImage == null ||
                                !user.profileImage!.startsWith('http')
                            ? Text(
                                user.name.isNotEmpty
                                    ? user.name[0].toUpperCase()
                                    : 'P',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                ),
                              )
                            : null,
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: _pickAndUploadImage,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: AppTheme.orangeAccent,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.camera_alt,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (userProvider.isUpdating)
                    const Padding(
                      padding: EdgeInsets.only(top: 8),
                      child: SizedBox(
                        height: 2,
                        width: 60,
                        child: LinearProgressIndicator(
                          color: AppTheme.orangeAccent,
                        ),
                      ),
                    ),
                  const SizedBox(height: 16),
                  _isEditing
                      ? _buildEditField(_nameController, 'Name')
                      : Text(
                          user.name.isNotEmpty ? user.name : 'Patient',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                  const SizedBox(height: 6),
                  Text(
                    'Patient ID: ${user.id.substring(user.id.length - 6).toUpperCase()}',
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppTheme.orangeAccent,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            _buildProfileSection(user),
            if (_isEditing) ...[
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: userProvider.isUpdating ? null : _saveProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.orangeAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: userProvider.isUpdating
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'Save Changes',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
            ],
            const SizedBox(height: 40),
            _buildLogoutButton(context),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileSection(UserModel user) {
    return Column(
      children: [
        _buildInfoRow(
          'Email',
          user.email,
          Icons.email,
          AppTheme.orangeAccent,
          isEditable: false,
        ),
        const SizedBox(height: 16),
        _buildInfoRow(
          'Phone',
          user.phone ?? '',
          Icons.phone,
          AppTheme.orangeAccent,
          controller: _phoneController,
          isPhone: true,
          isEmergency: false,
        ),
        const SizedBox(height: 16),
        _buildInfoRow(
          'Age',
          user.age?.toString() ?? '',
          Icons.person_search,
          AppTheme.orangeAccent,
          controller: _ageController,
          isNumber: true,
        ),
        const SizedBox(height: 16),
        _buildInfoRow(
          'Date of Birth',
          user.dateOfBirth ?? '',
          Icons.cake_rounded,
          AppTheme.orangeAccent,
          controller: _dobController,
        ),
        const SizedBox(height: 16),
        _buildInfoRow(
          'Blood Group',
          user.bloodGroup ?? '',
          Icons.bloodtype,
          AppTheme.dangerRed,
          controller: _bloodGroupController,
        ),
        const SizedBox(height: 16),
        _buildInfoRow(
          'Emergency Contact',
          user.emergencyContact ?? '',
          Icons.contact_phone,
          AppTheme.warningOrange,
          controller: _emergencyContactController,
          isPhone: true,
          isEmergency: true,
        ),
        const SizedBox(height: 16),
        _buildInfoRow(
          'Address',
          user.address ?? '',
          Icons.location_on,
          AppTheme.orangeAccent,
          controller: _addressController,
          maxLines: 2,
        ),
      ],
    );
  }

  Widget _buildInfoRow(
    String title,
    String value,
    IconData icon,
    Color iconColor, {
    TextEditingController? controller,
    bool isEditable = true,
    bool isNumber = false,
    bool isPhone = false,
    bool isEmergency = false,
    int maxLines = 1,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.darkSurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.borderCol),
      ),
      child: Row(
        crossAxisAlignment: maxLines > 1
            ? CrossAxisAlignment.start
            : CrossAxisAlignment.center,
        children: [
          Icon(icon, color: iconColor),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(color: Colors.white54, fontSize: 12),
                ),
                _isEditing && isEditable
                    ? (isPhone 
                        ? IntlPhoneField(
                            controller: controller,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                            dropdownTextStyle: const TextStyle(color: Colors.white),
                            dropdownIcon: const Icon(Icons.arrow_drop_down, color: Colors.white),
                            decoration: const InputDecoration(
                              isDense: true,
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.zero,
                            ),
                            initialCountryCode: 'IN',
                            showCountryFlag: false, // Fix for asset loading errors on web
                            flagsButtonPadding: const EdgeInsets.only(left: 8),
                            onChanged: (phone) {
                              if (isEmergency) {
                                _completeEmergencyNumber = phone.completeNumber;
                              } else {
                                _completePhoneNumber = phone.completeNumber;
                              }
                            },
                          )
                        : TextFormField(
                            controller: controller,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                            keyboardType: isNumber
                                ? TextInputType.number
                                : TextInputType.text,
                            maxLines: maxLines,
                            decoration: const InputDecoration(
                              isDense: true,
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.zero,
                            ),
                          ))
                    : Text(
                        value.isNotEmpty ? value : 'Not provided',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEditField(TextEditingController controller, String label) {
    return TextFormField(
      controller: controller,
      textAlign: TextAlign.center,
      style: const TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
      decoration: InputDecoration(
        hintText: label,
        hintStyle: const TextStyle(color: Colors.white24),
        border: InputBorder.none,
      ),
    );
  }

  Widget _buildGuestUI() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.person_outline, size: 80, color: Colors.white54),
            const SizedBox(height: 24),
            const Text(
              'Create an Account',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Sign in to manage your appointments and health journey.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white70, fontSize: 16),
            ),
            const SizedBox(height: 48),
            _buildWideButton(
              'Sign In',
              () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
              ),
              isPrimary: true,
            ),
            const SizedBox(height: 16),
            _buildWideButton(
              'Create Account',
              () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const RegisterScreen()),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWideButton(
    String text,
    VoidCallback onPressed, {
    bool isPrimary = false,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: isPrimary
              ? AppTheme.orangeAccent
              : Colors.transparent,
          side: isPrimary ? null : const BorderSide(color: AppTheme.borderCol),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: OutlinedButton.icon(
        onPressed: () async {
          await context.read<AuthProvider>().logout();
          if (mounted) context.read<UserProvider>().clearUser();
        },
        icon: const Icon(Icons.logout, color: AppTheme.dangerRed),
        label: const Text(
          'Logout',
          style: TextStyle(
            fontSize: 18,
            color: AppTheme.dangerRed,
            fontWeight: FontWeight.bold,
          ),
        ),
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: AppTheme.dangerRed),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }
}
