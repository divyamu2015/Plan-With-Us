import 'package:flutter/material.dart';
import 'package:house_construction_pro/authantication/engineer_auth/eng_reg/eng_registration_page_view.dart';
import 'package:house_construction_pro/authantication/user_authentication/login_screen/login_view_page.dart';

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key, this.userId=0});
  final int userId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black87, // cute pastel background
      body: Center(
        child: Padding(
          padding: const EdgeInsets.only(
            left: 3.0,
            right: 3.0,
            bottom: 300,
            top: 300,
          ),
          child: Card(
            color: Colors.white,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Choose Your Role',
                  style: TextStyle(
                    fontSize: 23,
                    fontWeight: FontWeight.bold,
                    color: const Color.fromARGB(255, 56, 12, 77),
                    fontFamily: 'Montserrat', // or any cute rounded font
                  ),
                ),
                SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // User Button
                    _RoleButton(
                      fontsize: 20,
                      label: 'User',
                      icon: Icons.person,

                      color: const Color.fromARGB(255, 216, 204, 100),

                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) {
                              return LoginScreen();
                            },
                          ),
                        );
                      },
                      cuteDecoration: true,
                    ),
                    SizedBox(width: 10),
                    // Engineer Button
                    _RoleButton(
                      label: 'Engineer',
                      icon: Icons.engineering,
                      color: const Color.fromARGB(255, 89, 114, 194),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) {
                              return EngineeringRegistrationPage();
                            },
                          ),
                        );
                        /* Handle Engineer */
                      },
                      cuteDecoration: false,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RoleButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onPressed;
  final bool cuteDecoration;
  final double fontsize;

  const _RoleButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onPressed,
    this.fontsize = 0,
    this.cuteDecoration = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: AnimatedContainer(
        duration: Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(horizontal: 28, vertical: 18),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(color: Colors.grey, blurRadius: 12, offset: Offset(0, 4)),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white, size: 28),
            SizedBox(width: 14),
            Text(
              label,
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            // if (cuteDecoration)
            //   Padding(
            //     padding: const EdgeInsets.only(left: 10),
            //     child: Icon(
            //       //Icons.star,
            //       color: const Color.fromARGB(255, 247, 247, 234),
            //       size: 18,
            //     ), // cute accent
            //   ),
          ],
        ),
      ),
    );
  }
}
