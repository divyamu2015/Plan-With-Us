import 'package:animated_input_border/animated_input_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:house_construction_pro/authantication/user_authentication/login_screen/bloc/login_bloc.dart';
import 'package:house_construction_pro/authantication/user_authentication/registration_screen/registration_page_view.dart';
import 'package:house_construction_pro/screen/engineer_screen/eng_home_screen/eng_home_screen.dart';
import 'package:house_construction_pro/screen/role_screen.dart';
import 'package:house_construction_pro/screen/user_screen/house_details/property_input_view.dart';
import 'package:house_construction_pro/screen/user_screen/user_home_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passController = TextEditingController();
  late AnimationController _animationController;
  bool isloading = false;
  String _selectedUserType = 'user';
  int? userId;
  int? engineerId;
  final GlobalKey<FormState> _fromKey = GlobalKey<FormState>();
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..forward();
  }

  Widget _buildTextField(
    String label, {
    required TextEditingController controller,
    required String? Function(String?)? validator,
    TextInputType keyboardType = TextInputType.text,
    // String? label,
  }) {
    return Padding(
      padding: EdgeInsets.all(16.0),
      child: TextFormField(
        controller: controller,
        validator: validator,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.black),
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

  Future<void> loginState() async {
    if (!_fromKey.currentState!.validate()) return;

    setState(() => isloading = true);

    context.read<LoginBloc>().add(
      LoginEvent.userLogin(
        role: _selectedUserType,
        email: _emailController.text.trim(),
        password: _passController.text.trim(),
        //  userType: _selectedUserType,
        //email: _emailController.text.trim(),
        // password: _passController.text.trim(),
      ),
    );
  }

  Future<void> storeUserId(int userId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('user_id', userId);
    // print('User ID stored: $userId');
  }

  Future<int?> getUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    userId = prefs.getInt('user_id');
    // print("Retrieved User ID: $userId");
    return userId;
  }

  Future<void> storeEngineerId(int engineerId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('engineer_id', engineerId);
    // print('User ID stored: $engineerId');
  }

  Future<int?> getEngineerId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    engineerId = prefs.getInt('engineer_id');
    // print("Retrieved User ID: $engineerId");
    return engineerId;
  }

  Future<bool> getPropertySubmitted(int userId) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('isPropertySubmitted_$userId') ?? false;
  }

  @override
  Widget build(BuildContext context) {
    double h = MediaQuery.of(context).size.height;
    double w = MediaQuery.of(context).size.width;
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          // leading: Icon(Icons.rotate_left_outlined),
          actions: [
            IconButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) {
                      return RoleSelectionScreen();
                    },
                  ),
                );
              },
              icon: Icon(
                Icons.rotate_left_outlined,
                size: 40,
                color: Color.fromARGB(255, 158, 122, 2),
              ),
            ),
          ],
          // title: Text(
          //   "Login Your Dream Home",
          //   style: TextStyle(
          //     color: const Color.fromARGB(255, 46, 20, 58),
          //     fontSize: 15.0
          //     //  color: Color(colors)
          //   ),
          // ),
          // centerTitle: true,
          backgroundColor: Colors.transparent,
          //backgroundColor: Colors.amberAccent[200],
        ),
        body: BlocConsumer<LoginBloc, LoginState>(
          listener: (context, state) {
            state.when(
              initial: () {},
              loading: () {
                setState(() {
                  isloading = true;
                });
              },
              success: (response) async {
                if (response.role.toLowerCase() == 'user') {
                  await storeUserId(response.userId);
                  userId = await getUserId();
                  // bool submitted = await getPropertySubmitted(userId!);
                  // if (submitted) {
                  //   // Already submitted: Go straight to Home
                  //   Navigator.of(context).pushReplacement(
                  //     MaterialPageRoute(
                  //       builder: (context) => MyHomePage(userId: userId!,
                  //       engineerId: engineerId,),
                  //     ),
                  //   );
                  // } else {
                  // Not submitted: Show property details screen
                  // ignore: use_build_context_synchronously
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (context) {
                        return PropertyInputPage(userId: userId!);
                      },
                    ),
                  );
                  // }
                } else if (response.role.toLowerCase() == 'engineer') {
                  await storeEngineerId(response.engineerId);
                  engineerId = await getEngineerId();
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (context) =>
                          ViewEngineerBookingDetails(engineerId: engineerId!),
                      // ProjectBioPage(employeeId: engineerId!),

                      // EngineerBio(engineerId: engineerId!),
                    ),
                  );
                  //  print("DEBUG: Stored EngineerId $engineerId");
                } else {
                  // print("WARNING: Unknown role '${response.role}'");
                }

                setState(() {
                  isloading = false;
                });

                // ignore: use_build_context_synchronously
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("User login successful"),
                    backgroundColor: Colors.green,
                  ),
                );
                //  WidgetsBinding.instance.addPostFrameCallback((_) async {
                if (response.role.toLowerCase() == 'user' && userId != null) {
                  //  bool submitted = await getPropertySubmitted(userId!);
                  // if (submitted) {
                  //   // Already submitted: Go straight to Home
                  //   Navigator.of(context).pushReplacement(
                  //     MaterialPageRoute(
                  //       builder: (context) => MyHomePage(userId: userId!),
                  //     ),
                  //   );
                  // } else {
                  // Not submitted: Show property details screen
                  // ignore: use_build_context_synchronously
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (context) {
                        return DashboardScreen(
                          uderId: userId!,
                        );
                        //  PropertyInputPage(
                        //   userId: userId!,
                        //   // engineerId: engineerId!,
                        // );
                      },
                    ),
                  );
                } else if (response.role.toLowerCase() == 'engineer' &&
                    engineerId != null)
                // (response.role.toLowerCase() == 'engineer' &&
                //     engineerId != null)
                {
                  // Assuming your engineer response model has engineerId
                  // ignore: use_build_context_synchronously
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (context) =>
                          ViewEngineerBookingDetails(engineerId: engineerId!),
                      // ProjectBioPage(employeeId: engineerId!),

                      // EngineerBio(engineerId: engineerId!),
                    ),
                  );
                }
                //  });
                //});
              },
              error: (error) {
                setState(() {
                  isloading = false;
                });
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
            return SingleChildScrollView(
              child: SizedBox(
                height: h,
                width: w,
                // decoration: BoxDecoration(
                //   image: DecorationImage(
                //     opacity: 0.4,
                //     fit: BoxFit.fill,
                //     image: AssetImage('assets/images/loogo.jpeg'),
                //   ),
                // ),
                child: Padding(
                  padding: const EdgeInsets.only(top: 55.0),
                  child: Column(
                    //mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          // gradient: LinearGradient(
                          //   colors: [
                          //     const Color.fromARGB(255, 14, 65, 1),
                          //     const Color.fromARGB(255, 235, 238, 78),
                          //   ],
                          //   begin: Alignment.topCenter,
                          //   end: Alignment.bottomCenter,
                          // ),
                          color: const Color.fromARGB(255, 145, 117, 17),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 20,
                              offset: Offset(0, 8),
                            ),
                          ],
                          border: Border.all(
                            color: const Color.fromARGB(255, 245, 241, 241),
                            width: 2,
                          ),
                        ),
                        padding: const EdgeInsets.all(8),
                        child:
                            ClipOval(
                              child: Image.asset(
                                "assets/images/logo.JPG",
                                width: h * 0.31,
                                height: h * 0.27,
                                fit: BoxFit.cover,
                              ),
                            ).animate().scale(
                              duration: 3.5.seconds,
                              curve: Curves.easeOutBack,
                            ),
                      ),
                      const SizedBox(height: 20),
                      AnimatedBuilder(
                        animation: _animationController,
                        builder: (context, child) => Form(
                          key: _fromKey,
                          child: Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: DropdownButtonFormField<String>(
                                  items: const [
                                    DropdownMenuItem(
                                      value: 'user',
                                      child: Text('User'),
                                    ),
                                    DropdownMenuItem(
                                      value: 'engineer',
                                      child: Text('Engineer'),
                                    ),
                                  ],
                                  decoration: InputDecoration(
                                    labelText: "Select Role",
                                    border: OutlineInputBorder(),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please select a user type';
                                    }
                                    return null;
                                  },
                                  onChanged: (value) {
                                    setState(() {
                                      _selectedUserType = value!;
                                    });
                                  },
                                ),
                              ),
                              _buildTextField(
                                "Email",
                                keyboardType: TextInputType.emailAddress,
                                controller: _emailController,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return "Enter your Email";
                                  }

                                  return null;
                                },
                              ),
                              _buildTextField(
                                "Password",
                                //  keyboardType: TextInputType.pas,
                                controller: _passController,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return "Enter your Password";
                                  }
                                  return null;
                                },
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),
                      ElevatedButton(
                        style: ButtonStyle(
                          fixedSize: WidgetStatePropertyAll(Size(w * 0.9, 50)),
                          shape: WidgetStatePropertyAll(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                          ),
                          backgroundColor: WidgetStatePropertyAll(
                            const Color.fromARGB(255, 204, 172, 76),
                          ),
                        ),
                        onPressed: isloading ? null : loginState,
                        child: isloading
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                            : const Text(
                                "LOGIN",
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
                                return RegistrationPage();
                              },
                            ),
                          );
                        },
                        child: const Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(text: 'Don\'t have an account?'),
                              TextSpan(
                                text: 'SignUp',
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
            );
          },
        ),
      ),
    );
  }
}
