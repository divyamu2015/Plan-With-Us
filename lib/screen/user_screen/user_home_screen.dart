import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:house_construction_pro/purchase_screen/view_product_home/view_product_screen.dart';
import 'package:house_construction_pro/screen/role_screen.dart';
import 'package:house_construction_pro/screen/user_screen/advance_booking_payment_screen/advance_booking_view.dart';
import 'package:house_construction_pro/screen/user_screen/house_details/property_input_view.dart';
import 'package:http/http.dart' as http show get;

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key, required this.uderId});
  final int uderId;

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool showMenu = false;
  int? userId;
  int notificationCount = 0; // For badge
  List<dynamic> bookings = [];
  bool bookingsLoading = false;
  String? bookingsError;
  bool showNotifications = true;
  bool showBookingsFromNotification = false;
  @override
  void initState() {
    super.initState();
    userId = widget.uderId;
     bookingsLoading = false; 
    Future.delayed(Duration(seconds: 5), () {
      addNotification();
    });
    fetchUserBookings(userId!);
  }

  void addNotification() {
    setState(() {
      notificationCount++;
    });
  }

  Future<void> fetchUserBookings(int uid) async {
    setState(() {
      bookingsLoading = true;
      bookingsError = null;
    });
    try {
      final url = Uri.parse(
        'https://417sptdw-8001.inc1.devtunnels.ms/userapp/user/$uid/bookings/',
      );
      final response = await http.get(url);
      if (response.statusCode == 200) {
        setState(() {
          bookings = List.from(jsonDecode(response.body));
          bookingsLoading = false;
        });
      } else {
        setState(() {
          bookingsError = 'Failed to load bookings.';
          bookingsLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        bookingsError = 'Error: $e';
        bookingsLoading = false;
      });
    }
  }

  // Widget _buildNotificationMessage() {
  //   return Container(
  //     margin: EdgeInsets.symmetric(horizontal: 18, vertical: 12),
  //     padding: EdgeInsets.all(18),
  //     decoration: BoxDecoration(
  //       color: Colors.teal[50],
  //       borderRadius: BorderRadius.circular(16),
  //       border: Border.all(color: Colors.red, width: 2),
  //     ),
  //     child: Row(
  //       children: [
  //         Icon(Icons.info, color: Colors.red, size: 28),
  //         SizedBox(width: 12),
  //         Expanded(
  //           child: Text(
  //             "You have a new booking notification!",
  //             style: TextStyle(
  //               fontSize: 17,
  //               fontWeight: FontWeight.w600,
  //               color: Colors.black87,
  //             ),
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  Future<Map<String, dynamic>?> fetchPaymentHistory(int bookingId) async {
    try {
      final url = Uri.parse(
        "https://417sptdw-8001.inc1.devtunnels.ms/userapp/user_view_payment_of_booking/$bookingId/",
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        return decoded['data']['payment'];
      } else {
        return null;
      }
    } catch (e) {
      print("History Error: $e");
      return null;
    }
  }

  Future<void> showPaymentHistoryDialog(int bookingId) async {
    final payment = await fetchPaymentHistory(bookingId);

    if (payment == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to fetch payment history")),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            "Payment History",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _historyRow("Payment Type", payment['payment_type']),
              _historyRow("Status", payment['status']),
              _historyRow("Total Amount", "₹${payment['total_amount']}"),

              if (payment['payment_type'] == "card") ...[
                _historyRow("Card Holder", payment['card_holder_name'] ?? "-"),
                _historyRow("Card Number", payment['card_number'] ?? "-"),
                _historyRow("Expiry Date", payment['expiry_date'] ?? "-"),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) {
                    return DashboardScreen(uderId: widget.uderId);
                  },
                ),
              ),
              child: const Text("Close"),
            ),
          ],
        );
      },
    );
  }
Widget _buildElegantLogoutButton() {
  return GestureDetector(
    onTap: () {
      _showLogoutConfirmation();
    },
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFFFF5F6D),
            Color(0xFFFF2E63),
          ],
        ),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.red.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Icon(Icons.logout_rounded, color: Colors.white, size: 22),
          SizedBox(width: 10),
          Text(
            "Logout",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
        ],
      ),
    ),
  );
}
void _showLogoutConfirmation() {
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text(
          "Confirm Logout",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: const Text(
          "Are you sure you want to logout?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (_) => RoleSelectionScreen(),
                ),
                (route) => false,
              );
            },
            child: const Text("Logout"),
          ),
        ],
      );
    },
  );
}
  Widget _historyRow(String title, dynamic value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Text("$title: ", style: const TextStyle(fontWeight: FontWeight.bold)),
          Expanded(child: Text(value?.toString() ?? "-")),
        ],
      ),
    );
  }
void showBookingsDialog() {
  showDialog(
    context: context,
    builder: (context) {
      return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Container(
          padding: const EdgeInsets.all(16),
          constraints: const BoxConstraints(
            maxHeight: 500, // limit height
          ),
          child: Column(
            children: [
              const Text(
                "Your Bookings",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 15),

              Expanded(
                child: SingleChildScrollView(
                  child: _buildBookingCards(),
                ),
              ),

              const SizedBox(height: 10),

              Align(
                alignment: Alignment.bottomRight,
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Close"),
                ),
              )
            ],
          ),
        ),
      );
    },
  );
}
  Widget _buildBookingCards() {
    if (bookingsLoading) {
      return Center(child: CircularProgressIndicator());
    }
    if (bookingsError != null) {
      return Center(
        child: Text(bookingsError!, style: TextStyle(color: Colors.red)),
      );
    }
    if (bookings.isEmpty) {
      return Center(child: Text("No bookings found."));
    }

    return Column(
      children: bookings.map<Widget>((booking) {
        final paymentStatus = booking['payment_status'] ?? 'Pending';
        return Card(
          margin: EdgeInsets.only(bottom: 16),
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          child: Padding(
            padding: const EdgeInsets.all(18.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  booking['engineer_name'] ?? 'Unknown Engineer',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Colors.teal[800],
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  "Status: ${booking['status'] ?? 'N/A'}",
                  style: TextStyle(fontSize: 16),
                ),
                SizedBox(height: 6),
                if ((booking['status']?.toLowerCase() ?? "") == "accepted") ...[
                  SizedBox(height: 6),
                  Text(
                    "Requested: ${booking['user_name'] ?? 'N/A'} (${booking['user_phone'] ?? ''})",
                    style: TextStyle(fontSize: 15, color: Colors.grey[700]),
                  ),
                  SizedBox(height: 6),
                  Text(
                    "Start: ${booking['start_date'] ?? '-'}  |  End: ${booking['end_date'] ?? '-'}",
                    style: TextStyle(fontSize: 15),
                  ),
                  SizedBox(height: 10),
                  Text(
                    "Advance Booking: ${booking['advance_booking'] ?? 'N/A'}",
                    style: TextStyle(
                      fontSize: 16,
                      color: const Color.fromARGB(255, 27, 146, 33),
                    ),
                  ),
                  SizedBox(height: 10),

                  Text(
                    "payment Status: ${booking['payment_status'] ?? 'Pending'}",
                    style: TextStyle(
                      fontSize: 16,
                      color:
                          paymentStatus.toString().toLowerCase() == "completed"
                          ? Colors.green
                          : Colors.red,
                    ),
                  ),
                  SizedBox(height: 10),
                  Align(
                    alignment: Alignment.bottomRight,
                    child:
                        (paymentStatus.toString().toLowerCase() == "completed")
                        ? ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color.fromARGB(
                                255,
                                141,
                                178,
                                197,
                              ),
                            ),
                            onPressed: () {
                              showPaymentHistoryDialog(
                                int.parse(booking['id'].toString()),
                              );
                            },

                            child: Text(
                              "HISTORY",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          )
                        : ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                            ),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      AdvanceBookingPaymentScreen(
                                        userId: userId!,
                                        advanceAmount: double.parse(
                                          booking['advance_booking'].toString(),
                                        ),
                                        bookingId: int.parse(
                                          booking['id'].toString(),
                                        ),
                                      ),
                                ),
                              );
                            },
                            child: const Text(
                              "PAY",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                  ),
                ]
                // ...add more booking details if needed
                else ...[
                  SizedBox(height: 10),
                  Text(
                    "Reason: ${booking['reject_reason'] ?? 'No reason provided'}",
                    style: TextStyle(fontSize: 15, color: Colors.red[700]),
                  ),
                ],
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildDashboard() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildBookingCards(), // Show booking cards at top!
            SizedBox(height: 18),
            // Text(
            //   "Your Progress Today",
            //   style: Theme.of(context).textTheme.titleLarge,
            // ),
            // Add other widgets as needed
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Plan with US'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        actions: [
          Stack(
            alignment: Alignment.topRight,
            children: [
              IconButton(
                icon: Icon(
                  Icons.notifications,
                  color: notificationCount > 0 ? Colors.red : Colors.grey[600],
                ),
               onPressed: () {
  setState(() {
    notificationCount = 0; // clear badge
  });

  showBookingsDialog(); // open popup
},
              ),

              if (notificationCount > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    constraints: BoxConstraints(minWidth: 18, minHeight: 18),
                    child: Center(
                      child: Text(
                        '$notificationCount',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
          // Other actions
        ],
      ),

      body: Stack(
        children: [
           showBookingsFromNotification
    ? Padding(
        padding: const EdgeInsets.all(16),
        child: _buildBookingCards(),
      )
    : 
          ListView(
            padding: const EdgeInsets.all(16),
            children: [
              /// ==========================
              /// 🔥 HERO IMAGE BANNER
              /// ==========================
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Stack(
                  children: [
                    Image.network(
                      "https://images.unsplash.com/photo-1503387762-592deb58ef4e",
                      height: 300,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),

                    Container(
                      height: 200,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: Colors.black.withOpacity(0.4),
                      ),
                    ),

                    const Positioned(
                      left: 20,
                      bottom: 20,
                      child: Text(
                        "Build Your Dream\nWith Confidence",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              /// ==========================
              /// 👋 WELCOME TEXT
              /// ==========================
              Text(
                "Welcome Back 👋",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.teal[800],
                ),
              ),

              const SizedBox(height: 20),

              const Text(
                "Manage your construction projects and bookings easily and ensuring a stress-free experience.",
                style: TextStyle(color: Colors.grey),
              ),

              const SizedBox(height: 25),

              /// ==========================
              /// 🚀 QUICK ACTION CARDS
              /// ==========================
              Row(
                children: [
                  Expanded(
                    child: _quickActionCard(
                      icon: Icons.home_work,
                      title: "Property",
                      color: Colors.orange,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                PropertyInputPage(userId: userId!),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: _quickActionCard(
                      icon: Icons.shopping_cart,
                      title: "Materials",
                      color: Colors.green,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ShopScreen(userId: userId!),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 30),

              // Text(
              //   "Plan With US",
              //   style: TextStyle(
              //     fontSize: 20,
              //     fontWeight: FontWeight.bold,
              //     color: Colors.teal[800],
              //   ),
              // ),

          //    const SizedBox(height: 15),

             // _buildBookingCards(),
            ],
          ),
          // Floating vertical menu (Conditional)
          if (showMenu)
            Positioned(
              right: 20,
              bottom: 40,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // _FloatingMenuButton(
                  //   label: "Property Details",
                  //   icon: Icons.details,
                  //   onTap: () {
                  //     Navigator.of(context).push(
                  //       MaterialPageRoute(
                  //         builder: (context) {
                  //           return PropertyInputPage(
                  //             userId: userId!,
                  //             // engineerId: engineerId!,
                  //           );
                  //         },
                  //       ),
                  //     );
                  //     // Navigate or show your view logic
                  //   },
                  // ),
                  // const SizedBox(height: 20),
                  // _FloatingMenuButton(
                  //   label: "Buy Product",
                  //   icon: Icons.home,
                  //   onTap: () {
                  //     Navigator.of(context).push(
                  //       MaterialPageRoute(
                  //         builder: (context) {
                  //           return ShopScreen(userId: userId!);
                  //         },
                  //       ),
                  //     );
                  //     // Navigate to home screen
                  //   },
                  // ),
                  const SizedBox(height: 20),
                  _FloatingMenuButton(
                    label: "Logout",
                    icon: Icons.exit_to_app,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) {
                            return RoleSelectionScreen();
                          },
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 18),
                  // Close Button
                  FloatingActionButton(
                    backgroundColor: Colors.teal[800],
                    onPressed: () => setState(() => showMenu = false),
                    child: const Icon(Icons.close),
                  ),
                ],
              ),
            ),
        ],
      ),
      floatingActionButton: !showMenu
          ? FloatingActionButton(
              backgroundColor: Colors.teal[800],
              onPressed: () => setState(() => showMenu = true),
              child: const Icon(Icons.menu),
            )
          : null,
    );
  }

  // Widget _buildDashboard() {
  //   return Card(
  //     elevation: 4,
  //     child: Padding(
  //       padding: const EdgeInsets.all(16),
  //       child: Column(
  //         children: [
  //           Text(
  //             "Your Progress Today",
  //             style: Theme.of(context).textTheme.titleLarge,
  //           ),
  //           // Add other widgets as needed
  //         ],
  //       ),
  //     ),
  //   );
  // }
}

Widget _quickActionCard({
  required IconData icon,
  required String title,
  required Color color,
  required VoidCallback onTap,
}) {
  return InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(18),
    child: Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          Icon(icon, size: 35, color: color),
          const SizedBox(height: 10),
          Text(
            title,
            style: TextStyle(fontWeight: FontWeight.bold, color: color),
          ),
        ],
      ),
    ),
  );
}

// Individual Floating Menu Option
class _FloatingMenuButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _FloatingMenuButton({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Label bubble
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.grey[700],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ),
        const SizedBox(width: 8),
        // Icon button
        Material(
          color: Colors.teal[600],
          shape: const CircleBorder(),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Icon(icon, color: Colors.white, size: 26),
            ),
          ),
        ),
      ],
    );
  }
}

  