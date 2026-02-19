import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:house_construction_pro/screen/engineer_screen/eng_profile_management/bloc/eng_profile_bloc.dart';
import 'package:image_picker/image_picker.dart';

class EngProfileManagementScreen extends StatefulWidget {
  const EngProfileManagementScreen({super.key, required this.emploId});
  final int emploId;

  @override
  // ignore: library_private_types_in_public_api
  _EngProfileManagementScreenState createState() =>
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
  int? emploId;

  bool _isEditing = false; // 🔹 Controls whether form fields are editable

  @override
  void initState() {
    super.initState();
    emploId = widget.emploId;

    // Trigger load profile
    context.read<EngProfileBloc>().add(
      EngProfileEvent.engProfileMan(
        name: '',
        email: '',
        phone: 0,
        address: '',
        password: '',
        profilePic: XFile(''), // dummy for GET
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
      // For now, just show a message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile Saved (Future Implementation)')),
      );

      setState(() {
        _isEditing = false; // Exit edit mode after saving
      });
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
    if (!_isEditing) return; // Only allow picking image if editing
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Gallery'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Camera'),
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

  Widget _buildProfileImagePicker() {
    return Center(
      child: GestureDetector(
        onTap: _showImageSourceSelection,
        child: CircleAvatar(
          radius: 60,
          backgroundColor: Colors.grey[300],
          backgroundImage: _profileImage != null
              ? FileImage(File(_profileImage!.path))
              : null,
          child: _profileImage == null
              ? const Icon(Icons.camera_alt, size: 50, color: Colors.white70)
              : null,
        ),
      ),
    );
  }

  void showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  Widget _buildForm() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: ListView(
          children: [
            _buildProfileImagePicker(),
            const SizedBox(height: 15),

            // Name
            TextFormField(
              controller: _nameController,
              readOnly: !_isEditing,
              decoration: const InputDecoration(
                labelText: 'Name',
                border: OutlineInputBorder(),
              ),
              validator: (value) => value == null || value.isEmpty
                  ? 'Name cannot be empty'
                  : null,
            ),
            const SizedBox(height: 15),

            // Email
            TextFormField(
              controller: _emailController,
              readOnly: !_isEditing,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Email cannot be empty';
                }
                final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                return emailRegex.hasMatch(value)
                    ? null
                    : 'Enter a valid email';
              },
            ),
            const SizedBox(height: 15),

            // Phone
            TextFormField(
              controller: _phoneController,
              readOnly: !_isEditing,
              decoration: const InputDecoration(
                labelText: 'Phone',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.phone,
              validator: (value) => value == null || value.isEmpty
                  ? 'Phone number is required'
                  : null,
            ),
            const SizedBox(height: 15),

            // Address
            TextFormField(
              controller: _addressController,
              readOnly: !_isEditing,
              decoration: const InputDecoration(
                labelText: 'Address',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
              validator: (value) => value == null || value.isEmpty
                  ? 'Address cannot be empty'
                  : null,
            ),
            const SizedBox(height: 15),

            // Password
            TextFormField(
              controller: _passwordController,
              readOnly: !_isEditing,
              decoration: const InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
              validator: (value) => value == null || value.length < 6
                  ? 'Password must be at least 6 characters'
                  : null,
            ),
            const SizedBox(height: 15),

            // Status
            TextFormField(
              controller: _statusController,
              readOnly: true, // Always readonly
              decoration: const InputDecoration(
                labelText: 'Status',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 25),

            if (_isEditing)
              ElevatedButton(
                onPressed: _saveProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Save',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile Management'),
        backgroundColor: const Color.fromARGB(255, 193, 162, 247),
        actions: [
          IconButton(
            icon: Icon(_isEditing ? Icons.close : Icons.edit),
            onPressed: () {
              setState(() {
                _isEditing = !_isEditing;
              });
            },
          ),
        ],
      ),
      body: BlocConsumer<EngProfileBloc, EngProfileState>(
        listener: (context, state) {
          state.whenOrNull(
            success: (response) {
              _nameController.text = response.name;
              _emailController.text = response.email;
              _phoneController.text = response.phone;
              _addressController.text = response.address;
              _passwordController.text = response.password;
              _statusController.text = response.status;
            },
            error: (error) {
              showError(error);
            },
          );
        },
        builder: (context, state) {
          return state.when(
            initial: () => const Center(child: Text("Loading profile...")),
            loading: () => const Center(child: CircularProgressIndicator()),
            success: (_) => _buildForm(),
            error: (error) => Center(child: Text("Error: $error")),
          );
        },
      ),
    );
  }
}
