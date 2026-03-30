import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:house_construction_pro/screen/engineer_screen/eng_profile_management/bloc/eng_profile_bloc.dart';
import 'package:image_picker/image_picker.dart';

class EngProfileManagementScreen extends StatefulWidget {
  const EngProfileManagementScreen({super.key, required this.emploId});
  final int emploId;

  @override
  State<EngProfileManagementScreen> createState() =>
      _EngProfileManagementScreenState();
}

class _EngProfileManagementScreenState
    extends State<EngProfileManagementScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _statusController = TextEditingController();

  final ImagePicker picker = ImagePicker();

  XFile? _profileImage;
  String? _networkProfileImage;

  int? emploId;
  bool _isEditing = false;
  bool _obscurePassword = true;

  final String baseUrl = "https://417sptdw-8001.inc1.devtunnels.ms";

  // Light theme colors to match screenshot
  static const Color kPageBg = Color(0xFFF4F5F7);
  static const Color kBorder = Color(0xFFDCE2EA);
  static const Color kPrimaryText = Color(0xFF0F172A);
  static const Color kSecondaryText = Color(0xFF64748B);
  static const Color kHintText = Color(0xFF94A3B8);
  static const Color kAccent = Color(0xFF19C37D);
  static const Color kAccentDark = Color(0xFF12A86B);
  static const Color kStatusBg = Color(0xFFE8F8F0);

  @override
  void initState() {
    super.initState();
    emploId = widget.emploId;

    context.read<EngProfileBloc>().add(
      EngProfileEvent.engProfileMan(
        name: '',
        email: '',
        phone: 0,
        address: '',
        password: '',
        profilePic: XFile(''),
        status: '',
        emplId: emploId!,
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _passwordController.dispose();
    _statusController.dispose();
    super.dispose();
  }

  void _saveProfile() {
    if (_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Profile Saved'),
          backgroundColor: kAccentDark,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );

      setState(() {
        _isEditing = false;
      });

      // If you already have an update event in bloc,
      // dispatch it here without changing the UI structure.
      // Example:
      // context.read<EngProfileBloc>().add(
      //   EngProfileEvent.updateProfile(
      //     emplId: emploId!,
      //     name: _nameController.text.trim(),
      //     email: _emailController.text.trim(),
      //     phone: _phoneController.text.trim(),
      //     address: _addressController.text.trim(),
      //     password: _passwordController.text.trim(),
      //     profilePic: _profileImage,
      //   ),
      // );
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final pickedFile = await picker.pickImage(
        source: source,
        imageQuality: 80,
      );
      if (pickedFile != null) {
        setState(() {
          _profileImage = pickedFile;
        });
      }
    } catch (e) {
      showError("Failed to pick image: $e");
    }
  }

  void _showImageSourceSelection() {
    if (!_isEditing) return;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library, color: kAccent),
              title: const Text(
                'Gallery',
                style: TextStyle(color: kPrimaryText),
              ),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt, color: kAccent),
              title: const Text(
                'Camera',
                style: TextStyle(color: kPrimaryText),
              ),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
          ],
        ),
      ),
    );
  }

  void showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  String? _getFullImageUrl(String? imagePath) {
    if (imagePath == null || imagePath.trim().isEmpty) return null;

    if (imagePath.startsWith('http://') || imagePath.startsWith('https://')) {
      return imagePath;
    }

    if (imagePath.startsWith('/')) {
      return "$baseUrl$imagePath";
    }

    return "$baseUrl/$imagePath";
  }

  ImageProvider? _getProfileImageProvider() {
    if (_profileImage != null) {
      return FileImage(File(_profileImage!.path));
    }

    final fullUrl = _getFullImageUrl(_networkProfileImage);
    if (fullUrl != null) {
      return NetworkImage(fullUrl);
    }

    return null;
  }

  Widget _buildProfileImagePicker() {
    final imageProvider = _getProfileImageProvider();

    return Center(
      child: GestureDetector(
        onTap: _showImageSourceSelection,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.black,
                boxShadow: [
                  BoxShadow(
                    // ignore: deprecated_member_use
                    color: Colors.black.withOpacity(0.12),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.black87, width: 3),
                ),
                child: CircleAvatar(
                  radius: 62,
                  backgroundColor: const Color(0xFFF3EFEA),
                  backgroundImage: imageProvider,
                  child: imageProvider == null
                      ? const Icon(
                          Icons.person,
                          size: 56,
                          color: Colors.grey,
                        )
                      : null,
                ),
              ),
            ),
            Positioned(
              right: -2,
              bottom: 10,
              child: Container(
                height: 44,
                width: 44,
                decoration: BoxDecoration(
                  color: kAccent,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 3),
                ),
                child: const Icon(
                  Icons.camera_alt,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 10),
      child: Text(
        text,
        style: const TextStyle(
          color: kPrimaryText,
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String hint,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(
        color: kHintText,
        fontSize: 16,
      ),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 22, vertical: 20),
      suffixIcon: suffixIcon,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(
          color: kBorder,
          width: 1.2,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(
          color: kAccent,
          width: 1.4,
        ),
      ),
      disabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(
          color: kBorder,
          width: 1.2,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: Colors.redAccent),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: Colors.redAccent),
      ),
    );
  }

  Widget _buildStatusChip() {
    final status = _statusController.text.trim().isEmpty
        ? "Unknown"
        : _statusController.text.trim();

    final isApproved = status.toLowerCase() == "approved";

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
      decoration: BoxDecoration(
        color: isApproved ? kStatusBg : Colors.orange.shade50,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: isApproved ? const Color(0xFFA7E5C7) : Colors.orange.shade200,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isApproved ? Icons.check_circle : Icons.info,
            size: 18,
            color: isApproved ? kAccentDark : Colors.orange,
          ),
          const SizedBox(width: 8),
          Text(
            status.toUpperCase(),
            style: TextStyle(
              color: isApproved ? kAccentDark : Colors.orange,
              fontSize: 14,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required String hint,
    TextInputType? keyboardType,
    bool obscureText = false,
    int maxLines = 1,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(label),
        TextFormField(
          controller: controller,
          readOnly: !_isEditing,
          style: const TextStyle(
            color: kPrimaryText,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
          keyboardType: keyboardType,
          obscureText: obscureText,
          maxLines: maxLines,
          decoration: _inputDecoration(
            hint: hint,
            suffixIcon: suffixIcon,
          ),
          validator: validator,
        ),
      ],
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 8),
        children: [
          const SizedBox(height: 8),
          _buildProfileImagePicker(),
          const SizedBox(height: 22),
          Text(
            _nameController.text.isEmpty ? 'Nimmi' : _nameController.text,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: kPrimaryText,
              fontSize: 28,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _emailController.text.isEmpty
                ? 'email@example.com'
                : _emailController.text,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: kSecondaryText,
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 28),

          _buildTextField(
            label: "Full Name",
            controller: _nameController,
            hint: "Enter your name",
            validator: (value) =>
                value == null || value.isEmpty ? 'Name cannot be empty' : null,
          ),
          const SizedBox(height: 20),

          _buildTextField(
            label: "Email Address",
            controller: _emailController,
            hint: "name@example.com",
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Email cannot be empty';
              }
              final emailRegex =
                  RegExp(r'^[\w\-\.]+@([\w\-]+\.)+[\w\-]{2,4}$');
              return emailRegex.hasMatch(value) ? null : 'Enter a valid email';
            },
          ),
          const SizedBox(height: 20),

          _buildTextField(
            label: "Phone Number",
            controller: _phoneController,
            hint: "+1 234 567 890",
            keyboardType: TextInputType.phone,
            validator: (value) => value == null || value.isEmpty
                ? 'Phone number is required'
                : null,
          ),
          const SizedBox(height: 20),

          _buildTextField(
            label: "Address",
            controller: _addressController,
            hint: "Street, City, Zip",
            maxLines: 1,
            validator: (value) => value == null || value.isEmpty
                ? 'Address cannot be empty'
                : null,
          ),
          const SizedBox(height: 20),

          _buildTextField(
            label: "Password",
            controller: _passwordController,
            hint: "Password",
            obscureText: _obscurePassword,
            suffixIcon: IconButton(
              onPressed: () {
                setState(() {
                  _obscurePassword = !_obscurePassword;
                });
              },
              icon: Icon(
                _obscurePassword ? Icons.visibility_off : Icons.visibility,
                color: kHintText,
              ),
            ),
            validator: (value) => value == null || value.length < 6
                ? 'Password must be at least 6 characters'
                : null,
          ),
          const SizedBox(height: 24),

          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Account Status",
                      style: TextStyle(
                        color: kPrimaryText,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      "Current verification state",
                      style: TextStyle(
                        color: kSecondaryText,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              _buildStatusChip(),
            ],
          ),
          const SizedBox(height: 34),

          SizedBox(
            height: 58,
            child: ElevatedButton(
              onPressed: _saveProfile,
              style: ElevatedButton.styleFrom(
                backgroundColor: kAccent,
                foregroundColor: Colors.white,
                elevation: 6,
                // ignore: deprecated_member_use
                shadowColor: kAccent.withOpacity(0.25),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
              child: Text(
                _isEditing ? 'Save Changes' : 'Save Changes',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),

          const SizedBox(height: 30),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kPageBg,
      appBar: AppBar(
        backgroundColor: kPageBg,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: kPrimaryText),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Profile Management',
          style: TextStyle(
            color: kPrimaryText,
            fontWeight: FontWeight.w800,
            fontSize: 20,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: IconButton(
              icon: Icon(
                _isEditing ? Icons.close : Icons.edit,
                color: kAccentDark,
              ),
              onPressed: () {
                setState(() {
                  _isEditing = !_isEditing;
                });
              },
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: BlocConsumer<EngProfileBloc, EngProfileState>(
          listener: (context, state) {
            state.whenOrNull(
              success: (response) {
                _nameController.text = response.name;
                _emailController.text = response.email;
                _phoneController.text = response.phone;
                _addressController.text = response.address;
                _passwordController.text = response.password;
                _statusController.text = response.status;
                _networkProfileImage = response.profileImage;
              },
              error: (error) {
                showError(error);
              },
            );
          },
          builder: (context, state) {
            return state.when(
              initial: () => const Center(
                child: CircularProgressIndicator(color: kAccent),
              ),
              loading: () => const Center(
                child: CircularProgressIndicator(color: kAccent),
              ),
              success: (_) => _buildForm(),
              error: (error) => Center(
                child: Text(
                  "Error: $error",
                  style: const TextStyle(color: kPrimaryText),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}