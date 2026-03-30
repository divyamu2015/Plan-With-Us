// ignore_for_file: avoid_print

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:house_construction_pro/authantication/engineer_auth/eng_reg/bloc/eng_reg_bloc.dart';
import 'package:house_construction_pro/authantication/user_authentication/login_screen/login_view_page.dart';
import 'package:image_picker/image_picker.dart';
import 'package:animated_input_border/animated_input_border.dart';

class EngineeringRegistrationPage extends StatefulWidget {
  const EngineeringRegistrationPage({super.key});

  @override
  State<EngineeringRegistrationPage> createState() =>
      _EngineeringRegistrationPageState();
}

class _EngineeringRegistrationPageState
    extends State<EngineeringRegistrationPage>
    with SingleTickerProviderStateMixin {
  final picker = ImagePicker();
  late AnimationController _animationController;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
 
  final TextEditingController ageController =
      TextEditingController(); // New controller for Age
  final TextEditingController addressController = TextEditingController();
  // We will no longer use a simple TextEditingController for phone.
  // We'll use the InternationalPhoneNumberInput's internal controller and callbacks.
  final TextEditingController placeController = TextEditingController();
  final TextEditingController phoneController =
      TextEditingController(); // New controller for Place
  final TextEditingController specializationController =
      TextEditingController();
  final TextEditingController experienceController = TextEditingController();
  String? _selectedGender;
  double? latitude;
  double? longitude;
bool isPasswordVisible = false;
bool isConfirmPasswordVisible = false;
  final ImagePicker _picker = ImagePicker();

  File? _aadhaarImage;
  File? image;
  XFile? _profileImage;

  // Variables to store phone number details from InternationalPhoneNumberInput
  // String? _phoneNumber;
  // String? _phoneCountryCode;
  // String? _phoneDialCode;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool isloading = false;

  get loadFromJson => null;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
     confirmPasswordController.dispose();
    addressController.dispose();
    phoneController.dispose(); // No longer needed for direct use
    super.dispose();
  }

  void showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
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

  Future<void> saveForm() async {
    print(123);
    FocusScope.of(context).unfocus();
    setState(() {
      isloading = true;
    });
    final form = _formKey.currentState;
    if (form == null || !form.validate()) {
      return;
    }
    setState(() {
      isloading = true;
    });
    print('after validation');

    print('Validation successful. Dispatching RegisterBlocEvent.');
    context.read<EngRegBloc>().add(
      EngRegEvent.engineerRegister(
        name: nameController.text,
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
        address: addressController.text,
        phone: phoneController.text,
        workCertificate: XFile(_aadhaarImage!.path),
        profilePic: _profileImage!,
      ),
    );
  }

 Widget _buildTextField(
    String label, {
    required TextEditingController controller,
    required String? Function(String?)? validator,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1, // ✅ default 1
    bool obscureText = false,
    Widget? suffixIcon,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        maxLines: obscureText ? 1 : maxLines, // ✅ fix
        controller: controller,
        validator: validator,
        keyboardType: keyboardType,
        obscureText: obscureText,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.black),
          suffixIcon: suffixIcon,
          border: AnimatedInputBorder(
            animationValue: _animationController.value,
          ),
          focusedBorder: AnimatedInputBorder(
            animationValue: _animationController.value,
            borderRadius: BorderRadius.circular(16.0),
            borderSide: const BorderSide(width: 2.0, color: Color(0xFF163A57)),
          ),
        ),
      ),
    );
  }


  Widget buildGenderSelector() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Gender",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          Row(
            children: [
              Radio<String>(
                value: "Male",
                // ignore: deprecated_member_use
                groupValue: _selectedGender,
                // ignore: deprecated_member_use
                onChanged: (value) {
                  setState(() {
                    _selectedGender = value;
                  });
                },
              ),
              const Text("Male"),
              Radio<String>(
                value: "Female",
                // ignore: deprecated_member_use
                groupValue: _selectedGender,
                // ignore: deprecated_member_use
                onChanged: (value) {
                  setState(() {
                    _selectedGender = value;
                  });
                },
              ),
              const Text("Female"),
            ],
          ),
          if (_selectedGender == null && !isloading)
            const Padding(
              padding: EdgeInsets.only(left: 8.0),
              child: Text(
                "Please select gender",
                style: TextStyle(color: Colors.red, fontSize: 12),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildProfileImagePicker() {
    return Center(
      child: GestureDetector(
        onTap: _showImageSourceSelection,
        child: CircleAvatar(
          radius: 60,
          backgroundColor: Colors.blueGrey[200],
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

  Future<void> _pickAadhaarImage() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
    ); // or ImageSource.camera
    if (image != null) {
      setState(() {
        _aadhaarImage = File(image.path);
      });
    }
  }

  void showMessage(BuildContext context, String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        backgroundColor: color,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double h = MediaQuery.of(context).size.height;
    double w = MediaQuery.of(context).size.width;
    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color.fromARGB(255, 206, 233, 247),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          title: const Text(
            'Register Your Account',
            style: TextStyle(
              color: Color.fromARGB(221, 57, 17, 73),
              fontSize: 20,
              fontWeight: FontWeight.bold,
              //fontStyle: FontStyle.italic,
            ),
          ),
          centerTitle: true,
        ),
        body: BlocConsumer<EngRegBloc, EngRegState>(
          listener: (context, state) {
            state.when(
              initial: () {},
              loading: () {
                setState(() => isloading = true);
              },
              success: (response) {
                setState(() => isloading = false);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Registration Successful"),
                    backgroundColor: Colors.green,
                  ),
                );
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) {
                      return const LoginScreen();
                    },
                  ),
                );
              },
              error: (error) {
                setState(() => isloading = false);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("Error: $error"),
                    backgroundColor: Colors.red,
                  ),
                );
              },
            );
          },
          builder: (context, state) {
            return Container(
              height: h,
              width: w,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  isAntiAlias: true,
                  // invertColors: true,
                  opacity: 0.3,
                  fit: BoxFit.cover,
                  image: AssetImage('assets/images/reg1.jpg'),
                ),
              ),
              child: SingleChildScrollView(
                child: Center(
                  child: Column(
                    children: [
                      Center(
                        child:
                            _buildProfileImagePicker(), // Just the profile image, no card here
                      ),
                      const SizedBox(height: 20),
                      Card(
                        elevation: 6,
                        // semanticContainer: true,
                        borderOnForeground: true,
                        shadowColor: Colors.black,
                        margin: const EdgeInsets.all(16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.only(
                            top: 20,
                            left: 20,
                            right: 20,
                            bottom: 35,
                          ),
                          child: AnimatedBuilder(
                            animation: _animationController,
                            builder: (context, child) => Form(
                              key: _formKey,
                              child: SingleChildScrollView(
                                child: Padding(
                                  padding: const EdgeInsets.only(top: 10.0),
                                  child: Column(
                                    children: [
                                      _buildTextField(
                                        "Name",
                                        controller: nameController,
                                        validator: (value) => value!.isEmpty
                                            ? "Please enter name"
                                            : null,
                                      ),

                                      const SizedBox(
                                        height: 10,
                                      ), // Reduced spacing
                                      _buildTextField(
                                        "Email",
                                        controller: emailController,
                                        keyboardType:
                                            TextInputType.emailAddress,
                                        validator: (value) {
                                          if (value!.isEmpty) {
                                            return "Please enter email";
                                          }
                                          final emailRegex = RegExp(
                                            r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                                          );
                                          if (!emailRegex.hasMatch(value)) {
                                            return "Invalid email";
                                          }
                                          return null;
                                        },
                                      ),
                                      const SizedBox(
                                        height: 10,
                                      ), // Reduced spacing
                                     _buildTextField(
  "Password",
  controller: passwordController,
  keyboardType: TextInputType.visiblePassword,
  obscureText: !isPasswordVisible,
  suffixIcon: IconButton(
    icon: Icon(
      isPasswordVisible ? Icons.visibility : Icons.visibility_off,
    ),
    onPressed: () {
      setState(() {
        isPasswordVisible = !isPasswordVisible;
      });
    },
  ),
  validator: (value) {
    if (value!.isEmpty) {
      return "Please enter password";
    }
    if (value.length < 6) {
      return "Min 6 characters";
    }
    return null;
  },
),
                                  _buildTextField(
  "Confirmation Password",
  controller: confirmPasswordController,
  keyboardType: TextInputType.visiblePassword,
  obscureText: !isConfirmPasswordVisible,
  suffixIcon: IconButton(
    icon: Icon(
      isConfirmPasswordVisible ? Icons.visibility : Icons.visibility_off,
    ),
    onPressed: () {
      setState(() {
        isConfirmPasswordVisible = !isConfirmPasswordVisible;
      });
    },
  ),
  validator: (value) {
    if (value!.isEmpty) {
      return "Please enter confirmation password";
    }
    if (value != passwordController.text) {
      return "Password does not match";
    }
    return null;
  },
),
                                      const SizedBox(height: 10),
                                      _buildTextField(
                                        "Phone Number",
                                        controller: phoneController,
                                        keyboardType: TextInputType
                                            .phone, // Age should be a number
                                        validator: (value) {
                                          if (value!.isEmpty) {
                                            return "Please enter your Phone Number";
                                          }
                                          if (int.tryParse(value) == null ||
                                              int.parse(value) <= 0) {
                                            return "Please enter a valid age";
                                          }
                                          return null;
                                        },
                                      ),

                                      const SizedBox(
                                        height: 10,
                                      ), // Reduced spacing
                                      _buildTextField(
                                        "Address",
                                        maxLines: 3,
                                        controller: addressController,
                                        keyboardType:
                                            TextInputType.streetAddress,
                                        validator: (value) => value!.isEmpty
                                            ? "Please enter address"
                                            : null,
                                      ),

                                      const SizedBox(
                                        height: 10,
                                      ), // Reduced spacing
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          // ignore: unnecessary_null_comparison
                                          _aadhaarImage != null
                                              ? Image.file(
                                                  _aadhaarImage!,
                                                  height: 150,
                                                )
                                              : const Text(
                                                  "",
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                  ),
                                                ),
                                          const SizedBox(height: 10),
                                          ElevatedButton.icon(
                                            style: const ButtonStyle(
                                              backgroundColor:
                                                  WidgetStatePropertyAll(
                                                    Color.fromARGB(
                                                      255,
                                                      255,
                                                      255,
                                                      255,
                                                    ),
                                                  ),
                                            ),
                                            onPressed: _pickAadhaarImage,
                                            icon: const Icon(
                                              Icons.upload,
                                              color: Color.fromARGB(
                                                255,
                                                44,
                                                108,
                                                161,
                                              ),
                                            ),
                                            label: const Text(
                                              "Upload Work Certificate",
                                              style: TextStyle(
                                                fontSize: 15,
                                                color: Color.fromARGB(
                                                  255,
                                                  44,
                                                  108,
                                                  161,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 15),

                                      ElevatedButton(
                                        style: ButtonStyle(
                                          fixedSize: WidgetStatePropertyAll(
                                            Size(w * 0.9, 50),
                                          ),
                                          shape: WidgetStatePropertyAll(
                                            RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8.0),
                                            ),
                                          ),
                                          backgroundColor:
                                              const WidgetStatePropertyAll(
                                                Colors.blueGrey,
                                              ),
                                        ),
                                        onPressed: saveForm,
                                        child: isloading
                                            ? const CircularProgressIndicator(
                                                color: Colors.white,
                                              )
                                            : const Text(
                                                "REGISTER",
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 15,
                                                  color: Colors.white,
                                                ),
                                              ),
                                      ),
                                      SizedBox(height: h * 0.02),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          const Text(
                                            "Already have an account?",
                                            style: TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          TextButton(
                                            onPressed: () {
                                              Navigator.of(
                                                context,
                                              ).pushReplacement(
                                                MaterialPageRoute(
                                                  builder: (ctx) =>
                                                      const LoginScreen(),
                                                ),
                                              );
                                            },
                                            child: const Text(
                                              "Login",
                                              style: TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.blueGrey,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // );
              // },
              // ),
            );
          },
        ),
      ),
    );
  }
}
