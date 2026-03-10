//import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:house_construction_pro/authantication/user_authentication/login_screen/login_view_page.dart';
import 'package:house_construction_pro/authantication/user_authentication/registration_screen/bloc/register_bloc_bloc.dart';
import 'package:image_picker/image_picker.dart';
//import 'package:draggable_home/draggable_home.dart';
import 'package:animated_input_border/animated_input_border.dart';

class RegistrationPage extends StatefulWidget {
  const RegistrationPage({super.key});

  @override
  State<RegistrationPage> createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage>
    with SingleTickerProviderStateMixin {
  // File? _imageFile;
  final picker = ImagePicker();
  late AnimationController _animationController;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool isloading = false;
  bool isPasswordVisible = false;
  bool isConfirmPasswordVisible = false;
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
    phoneController.dispose();
    super.dispose();
  }

  // Future<void> _pickImage() async {
  //   final pickedFile = await showModalBottomSheet<XFile?>(
  //     context: context,
  //     builder: (context) => Wrap(
  //       children: [
  //         ListTile(
  //           leading: const Icon(Icons.camera_alt),
  //           title: const Text('Take Photo'),
  //           onTap: () async {
  //             final picked = await picker.pickImage(source: ImageSource.camera);
  //             Navigator.pop(context, picked);
  //           },
  //         ),
  //         ListTile(
  //           leading: const Icon(Icons.photo),
  //           title: const Text('Choose from Gallery'),
  //           onTap: () async {
  //             final picked = await picker.pickImage(
  //               source: ImageSource.gallery,
  //             );
  //             Navigator.pop(context, picked);
  //           },
  //         ),
  //       ],
  //     ),
  //   );

  //   if (pickedFile != null) {
  //     setState(() {
  //       _imageFile = File(pickedFile.path);
  //     });
  //   }
  // }

  void showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  Future<void> saveForm() async {
    // print(123);
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
    //  print('after validation');
    context.read<RegisterBlocBloc>().add(
      RegisterBlocEvent.userRegister(
        name: nameController.text,
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
        address: addressController.text,
        phone: phoneController.text,
        // id: "123", // or generate ID if needed
        // role: "user", // adjust based on your app logic
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

  @override
  Widget build(BuildContext context) {
    double h = MediaQuery.of(context).size.height;
    double w = MediaQuery.of(context).size.width;
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: const Text(
            'Register Your Dream House',
            style: TextStyle(
              color: Color.fromARGB(221, 65, 64, 64),
              fontSize: 20,
              fontWeight: FontWeight.bold,
              // fontStyle: FontStyle.italic,
            ),
          ),
          centerTitle: true,
          actions: [],
        ),
        body: BlocConsumer<RegisterBlocBloc, RegisterBlocState>(
          listener: (context, state) {
            state.when(
              initial: () {},
              //  start: () {},
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
                      return LoginScreen();
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
            return
            //  DraggableHome(
            // title: const Text(
            //   "Create an Account",
            //   style: TextStyle(color: Colors.black),
            // ),
            // headerWidget: Column(
            //   children: [
            //     GestureDetector(
            //       onTap: _pickImage,
            //       child: CircleAvatar(
            //         radius: 60,
            //         backgroundColor: Colors.grey.shade200,
            //         backgroundImage: _imageFile != null
            //             ? FileImage(_imageFile!)
            //             : null,
            //         child: _imageFile == null
            //             ? const Icon(
            //                 Icons.add_a_photo,
            //                 size: 32,
            //                 color: Colors.grey,
            //               )
            //             : null,
            //       ),
            //     ),
            //     const SizedBox(height: 10),
            //     const Text(
            //       "Tap to upload profile image",
            //       style: TextStyle(color: Colors.black54),
            //     ),
            //   ],
            // ),
            // appBarColor: Colors.white,
            // body: [
            SingleChildScrollView(
              child: Container(
                height: h,
                width: w,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    opacity: 0.3,
                    fit: BoxFit.fitHeight,
                    image: AssetImage(
                      'assets/images/3d-cartoon-scene-depicting-variety-people-multitasking.jpg',
                    ),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: AnimatedBuilder(
                    animation: _animationController,
                    builder: (context, child) => Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          _buildTextField(
                            "Name",
                            controller: nameController,
                            validator: (value) =>
                                value!.isEmpty ? "Please enter name" : null,
                          ),
                          _buildTextField(
                            "Email",
                            controller: emailController,
                            keyboardType: TextInputType.emailAddress,
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
                          _buildTextField(
                            "Password",
                            controller: passwordController,
                            keyboardType: TextInputType.visiblePassword,
                            obscureText: !isPasswordVisible,
                            suffixIcon: IconButton(
                              icon: Icon(
                                isPasswordVisible
                                    ? Icons.visibility
                                    : Icons.visibility_off,
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
                                isConfirmPasswordVisible
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                              ),
                              onPressed: () {
                                setState(() {
                                  isConfirmPasswordVisible =
                                      !isConfirmPasswordVisible;
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
                          _buildTextField(
                            "Address",
                            maxLines: 3,
                            controller: addressController,
                            keyboardType: TextInputType.streetAddress,
                            validator: (value) =>
                                value!.isEmpty ? "Please enter address" : null,
                          ),
                          _buildTextField(
                            "Contact Number",
                            controller: phoneController,
                            keyboardType: TextInputType.phone,
                            validator: (value) {
                              if (value!.isEmpty) {
                                return "Enter contact number";
                              }
                              if (!RegExp(r'^\d{10}$').hasMatch(value)) {
                                return "Must be 10 digits";
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton(
                            style: ButtonStyle(
                              fixedSize: WidgetStatePropertyAll(
                                Size(w * 0.9, 50),
                              ),
                              shape: WidgetStatePropertyAll(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                              ),
                              backgroundColor: WidgetStatePropertyAll(
                                const Color.fromARGB(255, 204, 172, 76),
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
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) {
                                    return LoginScreen();
                                  },
                                ),
                              );
                            },
                            child: const Text.rich(
                              TextSpan(
                                children: [
                                  TextSpan(text: 'Already have an account?'),
                                  TextSpan(
                                    text: 'Login',
                                    style: TextStyle(
                                      color: Color.fromARGB(255, 158, 122, 2),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
            // ],
            //  ),
          },
        ),
      ),
    );
  }
}
