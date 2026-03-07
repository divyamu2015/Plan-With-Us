import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_slider_drawer/flutter_slider_drawer.dart';
import 'package:house_construction_pro/screen/engineer_screen/eng_profile_management/eng_profile_manage_view.dart';
import 'package:house_construction_pro/screen/engineer_screen/engineer_crud_view.dart';
import 'package:house_construction_pro/screen/engineer_screen/engineer_pro_bio/engineer_bio.dart';
import 'package:house_construction_pro/screen/engineer_screen/view_customer_feedback.dart';
import 'package:house_construction_pro/screen/engineer_screen/view_user_booking_details/view_booking_details.dart';
import 'package:house_construction_pro/screen/role_screen.dart';
import 'package:http/http.dart' as http;

class ViewEngineerBookingDetails extends StatefulWidget {
  final int engineerId;
  const ViewEngineerBookingDetails({super.key, required this.engineerId});

  @override
  State<ViewEngineerBookingDetails> createState() =>
      _ViewEngineerBookingDetailsState();
}

class _ViewEngineerBookingDetailsState extends State<ViewEngineerBookingDetails>
    with SingleTickerProviderStateMixin {
  late GlobalKey<SliderDrawerState> _sliderKey;
  late TabController _tabController;
  late GlobalKey<SliderDrawerState> _sliderController;
  Set<int> updatingBookingIds = {};
  bool isLoading = true;
  String? error;

  List<dynamic> bookings = [];
  Set<int> updatingIds = {};
  int? engineerId;
  int? bookingId;
  @override
  void initState() {
    super.initState();
    engineerId = widget.engineerId;

    _sliderKey = GlobalKey<SliderDrawerState>();
    _tabController = TabController(length: 3, vsync: this);
    fetchBookings();
  }

  // ---------------- FETCH BOOKINGS ----------------
 Future<void> fetchBookings() async {
  if (!mounted) return;

  setState(() => isLoading = true);

  final url =
      'https://417sptdw-8001.inc1.devtunnels.ms/userapp/engineer/bookings/${widget.engineerId}/';

  try {
    final res = await http.get(Uri.parse(url));

    if (!mounted) return;

    final decoded = jsonDecode(res.body);

    setState(() {
      bookings = (decoded['data'] as List?) ?? [];
      isLoading = false;
      error = null;
    });
  } catch (e) {
    if (!mounted) return;

    setState(() {
      error = e.toString();
      isLoading = false;
    });
  }
}


  // ---------------- STATUS HELPERS ----------------
  List<dynamic> get pending =>
      bookings.where((b) => b['status'] == 'pending').toList();

  List<dynamic> get accepted =>
      bookings.where((b) => b['status'] == 'accepted').toList();

  List<dynamic> get rejected =>
      bookings.where((b) => b['status'] == 'rejected').toList();

  // ---------------- UPDATE STATUS ----------------
Future<void> updateAccept(int bookingId, String amount) async {
  updatingIds.add(bookingId);
  if (mounted) setState(() {});

  await http.post(
    Uri.parse(
      'https://417sptdw-8001.inc1.devtunnels.ms/userapp/engineer/booking/accept/$bookingId/',
    ),
    body: {'advance_amount': amount},
  );

  await fetchBookings();

  if (!mounted) return; 

  updatingIds.remove(bookingId);
  setState(() {});

  _tabController.animateTo(1);
}

  Future<void> updateReject(int bookingId, String reason) async {
  updatingIds.add(bookingId);
  if (mounted) setState(() {});

  await http.post(
    Uri.parse(
      'https://417sptdw-8001.inc1.devtunnels.ms/booking/reject/$bookingId/',
    ),
    body: {'reason': reason},
  );

  await fetchBookings();

  if (!mounted) return; // 🔥 IMPORTANT

  updatingIds.remove(bookingId);
  setState(() {});

  _tabController.animateTo(2);
}


  // ---------------- DIALOGS ----------------
  Future<String?> _amountDialog() async {
    final controller = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Advance Amount"),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(hintText: "Enter amount"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: const Text("Submit"),
          ),
        ],
      ),
    );
  }

  Widget _drawerMenu() {
    final menuItems = [
      {'icon': Icons.person, 'title': 'View Profile'},
      {'icon': Icons.work, 'title': 'Add Engineer Work'},
        {'icon': Icons.view_agenda_outlined, 'title': 'View Engineer Work'},
      {'icon': Icons.feedback_outlined, 'title': 'View Engineer Feedback'},
     
      {'icon': Icons.logout, 'title': 'Logout'},
    ];

    return Material(
      color: Colors.deepPurple,
      child: Container(
        padding: const EdgeInsets.only(top: 50, left: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: menuItems.map((item) {
            return ListTile(
              leading: Icon(item['icon'] as IconData, color: Colors.white),
              title: Text(
                item['title'] as String,
                style: const TextStyle(color: Colors.white, fontSize: 18),
              ),
              onTap: () => _onMenuItemClick(item['title'] as String),
            );
          }).toList(),
        ),
      ),
    );
  }

  void _onMenuItemClick(String title) {
    _sliderKey.currentState?.closeSlider();
    if (title == 'View Profile') {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) =>
              EngProfileManagementScreen(emploId: engineerId!),
        ),
      );
    } else if (title == 'Add Engineer Work') {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => EngineerBio(engineerId: engineerId!),
        ),
      );
    } else if (title == 'View Engineer Work') {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => ProjectDetailsPage(workId: engineerId!),
        ),
      );
    }  
    else if (title == 'View Engineer Feedback') {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => CustomerFeedbackPage(engineerId: engineerId!),
        ),
      );
    } else if (title == 'Logout') {
      _showLogoutDialog(context);
    }
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) {
                    return RoleSelectionScreen();
                  },
                ),
              );
              // Add your logout logic here
            },
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  Future<String?> _reasonDialog() async {
    final controller = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Reject Reason"),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: "Reason"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: const Text("Submit"),
          ),
        ],
      ),
    );
  }

  // ---------------- UI ----------------
  @override
  Widget build(BuildContext context) {
    return SliderDrawer(
      appBar: AppBar(
        title: const Text(
          'Booking Details',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.w600,
            fontSize: 22,
          ),
        ),
      ),
      key: _sliderKey,
      slider: _drawerMenu(),
      child: Scaffold(
        backgroundColor: const Color(0xFFF6FAFF),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 2,
          iconTheme: const IconThemeData(color: Colors.black87),
          leading: IconButton(
            icon: const Icon(Icons.menu, color: Colors.black),
            onPressed: () {
              _sliderKey.currentState?.toggle();
              final sliderState = _sliderKey.currentState;
              if (sliderState != null) {
                if (sliderState.isDrawerOpen) {
                  sliderState.closeSlider();
                } else {
                  sliderState.openSlider();
                }
              }
            },
          ),
          title: const Text(
            "Booking Details",
            style: TextStyle(color: Colors.black),
          ),
          centerTitle: true,
          bottom: TabBar(
            controller: _tabController,
            labelColor: Colors.deepPurple,
            indicatorColor: Colors.deepPurple,
            tabs: const [
              Tab(text: "Pending"),
              Tab(text: "Accepted"),
              Tab(text: "Rejected"),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            _pendingTab(),
            AcceptedBookingScreen(engineerId: engineerId!),
            RejectedBookingScreen(engineerId: engineerId!),
          ],
        ),
      ),
    );
  }

  // ---------------- TABS ----------------
  Widget _pendingTab() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (error != null) {
      return Center(child: Text(error!));
    }
    if (pending.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              backgroundColor: Colors.green[100],
              radius: 50,
              child: Icon(Icons.close, color: Colors.red, size: 40),
            ),
            const SizedBox(height: 20),
            Text(
              "No pending bookings",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: pending.length,
      itemBuilder: (_, i) => _buildBookingCard(pending[i]),
    );
  }

  Future<String?> _showAdvanceAmountDialog(BuildContext context) async {
    String? amount;

    return await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Enter Advance Amount'),
          content: TextField(
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              hintText: 'Enter advance booking amount',
            ),
            onChanged: (value) {
              amount = value;
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, null),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, amount),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  Future<void> fetchBookingDetails() async {
    final url =
        'https://417sptdw-8001.inc1.devtunnels.ms/userapp/engineer/bookings/$engineerId/';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        setState(() {
          bookings = json.decode(response.body);
          isLoading = false;
          error = null;
        });
      } else {
        setState(() {
          error = "Failed to load: ${response.statusCode}";
          isLoading = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        error = e.toString();
        isLoading = false;
      });
    }
  }

  Future<String?> _showReasonDialog(BuildContext context) async {
    String? reason;
    return await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Enter Reason'),
          content: TextField(
            autofocus: true,
            decoration: const InputDecoration(
              hintText: 'Enter reason for rejection',
            ),
            onChanged: (value) {
              reason = value;
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, null),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, reason),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  Future<void> updateStatus(int bookingId, String status) async {
    String? reason;
    if (status == 'rejected') {
      reason = await _showReasonDialog(context);
      if (reason == null || reason.isEmpty) {
        // If user cancels or enters no reason, do nothing
        return;
      }
    }

    final url =
        'https://417sptdw-8001.inc1.devtunnels.ms/userapp/engineer/booking/reject/$bookingId/';
    setState(() {
      updatingBookingIds.add(bookingId);
    });
    try {
      final response = await http.patch(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'status': status,
          if (reason != null) 'reason': reason,
        }),
      );
      if (!mounted) return;
      if (response.statusCode == 200 || response.statusCode == 201) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Status updated to $status')));
        await fetchBookingDetails();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update status: ${response.statusCode}'),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
    setState(() {
      updatingBookingIds.remove(bookingId);
    });
  }

  Future<void> updateAcceptStatus(
    int bookingId,
    String status,
    String advanceBooking,
  ) async {
    final url =
        'https://417sptdw-8001.inc1.devtunnels.ms/userapp/engineer_update_status/$bookingId/';
    setState(() {
      updatingBookingIds.add(bookingId);
    });
    try {
      final response = await http.patch(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'status': status, 'advance_booking': advanceBooking}),
      );

      if (!mounted) return;
      if (response.statusCode == 200 || response.statusCode == 201) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Status updated to $status')));
        await fetchBookingDetails();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update status: ${response.statusCode}'),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
    setState(() {
      updatingBookingIds.remove(bookingId);
    });
  }

  // ---------------- CARDS ----------------
  Widget _buildBookingCard(dynamic data) {
    final features = (data['features'] as List?)?.cast<String>() ?? [];

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      margin: const EdgeInsets.only(bottom: 20),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoRow(Icons.person, "Customer Name", data['user_name']),
            _buildInfoRow(Icons.phone, "Phone", data['user_phone']),
            _buildInfoRow(Icons.location_on, "Address", data['address']),
            _buildInfoRow(
              Icons.calendar_today,
              "Start Date",
              data['start_date'],
            ),
            _buildInfoRow(Icons.event, "End Date", data['end_date']),
            _buildInfoRow(Icons.landscape, "Cent", data['cent']),
            _buildInfoRow(Icons.square_foot, "Sqft", data['sqft']),
            _buildInfoRow(
              Icons.monetization_on,
              "Expected Amount",
              "₹ ${data['expected_amount']}",
            ),
            const SizedBox(height: 16),
            const Text(
              "Features",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: features.isNotEmpty
                  ? features
                        .map(
                          (f) => Chip(
                            label: Text(f),
                            backgroundColor: const Color(0xFFEAF2FF),
                            labelStyle: const TextStyle(color: Colors.black87),
                          ),
                        )
                        .toList()
                  : [
                      const Text(
                        "No features listed",
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
            ),
            const SizedBox(height: 20),
            if (data['suggestion'] != null &&
                data['suggestion'].toString().isNotEmpty)
              GestureDetector(
                onTap: () {
                  _openSuggestion(context, data['suggestion']);
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.picture_as_pdf, color: Colors.blueAccent),
                      SizedBox(width: 8),
                      Text(
                        "View Suggestion File",
                        style: TextStyle(
                          color: Colors.blueAccent,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 20),
            updatingBookingIds.contains(data['id'])
                ? const Center(child: CircularProgressIndicator())
                : Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        onPressed: () async {
                          final amount = await _showAdvanceAmountDialog(
                            context,
                          );
                          if (amount == null || amount.isEmpty) return;

                          await updateAcceptStatus(
                            data['id'],
                            'accepted',
                            amount,
                          );
                          _tabController.animateTo(1);
                          // Navigator.pushReplacement(
                          //   context,
                          //   MaterialPageRoute(
                          //     builder: (_) => BookingStatusTabScreen(
                          //       engineerId: engineerId!,
                          //       initialIndex: 1,
                          //     ),
                          //   ),
                          // );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromARGB(
                            255,
                            96,
                            224,
                            101,
                          ),
                        ),
                        child: const Text('Accept'),
                      ),

                      ElevatedButton(
                        onPressed: () async {
                          await updateStatus(data['id'], 'rejected');
                          _tabController.animateTo(2);
                          // Navigator.pushReplacement(
                          //   // ignore: use_build_context_synchronously
                          //   context,
                          //   MaterialPageRoute(
                          //     builder: (_) => BookingStatusTabScreen(
                          //       engineerId: engineerId!,
                          //       initialIndex: 2, // Rejected tab
                          //     ),
                          //   ),
                          // );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color.fromARGB(255, 248, 93, 82),
                        ),
                        child: const Text('Reject'),
                      ),
                    ],
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String title, dynamic value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.blueGrey, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: RichText(
              text: TextSpan(
                text: "$title: ",
                style: const TextStyle(
                  color: Colors.black87,
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
                children: [
                  TextSpan(
                    text: value?.toString() ?? 'N/A',
                    style: const TextStyle(
                      color: Colors.black54,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // const SizedBox(height: 20),
          // if (isUpdatingStatus) const Center(child: CircularProgressIndicator())
          // else
          //   Row(
          //     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          //     children: [
          //       ElevatedButton(
          //         onPressed: () async {
          //           if (bookingId != null) {
          //             await updateStatus(bookingId!, 'accepted');
          //           }
          //         },
          //         style:
          //             ElevatedButton.styleFrom(backgroundColor: Colors.green),
          //         child: const Text('Accept'),
          //       ),
          //       ElevatedButton(
          //         onPressed: () async {
          //           if (bookingId != null) {
          //             await updateStatus(bookingId!, 'rejected');
          //           }
          //         },
          //         style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          //         child: const Text('Reject'),
          //       ),
          //     ],
          //   ),
        ],
      ),
    );
  }

  void _openSuggestion(BuildContext context, String path) {
    final fullUrl = 'https://417sptdw-8001.inc1.devtunnels.ms$path';
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Open PDF: $fullUrl'),
        backgroundColor: Colors.blueAccent,
      ),
    );
    // You can integrate url_launcher here later:
    // launchUrl(Uri.parse(fullUrl));
  }
}

// ---------------- DRAWER ----------------

class AcceptedBookingScreen extends StatefulWidget {
  final int engineerId;

  const AcceptedBookingScreen({super.key, required this.engineerId});

  @override
  State<AcceptedBookingScreen> createState() => _AcceptedBookingScreenState();
}

class _AcceptedBookingScreenState extends State<AcceptedBookingScreen> {
  bool isLoading = true;
  String? error;
  List<dynamic> bookings = [];

  @override
  void initState() {
    super.initState();
    fetchAcceptedBookings();
  }

  Future<void> _showPaymentDialog(int bookingId) async {
    final url =
        'https://417sptdw-8001.inc1.devtunnels.ms/userapp/engineer_view_payment_of_booking/$bookingId/';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        final data = decoded['data'];
        final payment = data['payment'];

        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text("Payment Details"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Customer: ${data['user_name']}"),
                  const SizedBox(height: 8),
                  Text("Payment Type: ${payment['payment_type']}"),
                  Text(
                    "Payment Status: ${payment['status']}",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: payment['status'] == 'completed'
                          ? Colors.green
                          : Colors.red,
                    ),
                  ),
                  Text("Amount: ₹${payment['total_amount']}"),
                  const SizedBox(height: 20),

                  ElevatedButton(
                    onPressed: () async {
                      Navigator.pop(context);
                      await _markWorkCompleted(bookingId);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                    ),
                    child: const Text("Work Completed"),
                  ),
                ],
              ),
            );
          },
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  Future<void> fetchAcceptedBookings() async {
    final url =
        'https://417sptdw-8001.inc1.devtunnels.ms/userapp/engineer/bookings/accepted/${widget.engineerId}/';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);

        setState(() {
          bookings = decoded['data']; // 🔥 IMPORTANT
          isLoading = false;
        });
      } else {
        setState(() {
          error = 'Failed: ${response.statusCode}';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        error = e.toString();
        isLoading = false;
      });
    }
  }

  Future<void> _markWorkCompleted(int bookingId) async {
    final url =
        'https://417sptdw-8001.inc1.devtunnels.ms/userapp/engineer_update_status/$bookingId/';

    try {
      final response = await http.patch(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({"status": "completed"}),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Work marked as Completed")),
        );

        await fetchAcceptedBookings(); // refresh list
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed: ${response.statusCode}")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (error != null) {
      return Center(child: Text(error!));
    }

    if (bookings.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              backgroundColor: Colors.green[100],
              radius: 50,
              child: Icon(Icons.close, size: 40, color: Colors.red),
            ),
            const SizedBox(height: 20),
            Text(
              "No Accepted bookings",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: bookings.length,
      itemBuilder: (context, index) {
        final data = bookings[index];
        final paymentStatus = data['payment']?['status'];
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data['user_name'],
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text('Phone: ${data['user_phone']}'),
                Text('Address: ${data['address']}'),
                Text('Start: ${data['start_date']}'),
                Text('End: ${data['end_date']}'),
                Text('Sqft: ${data['sqft']}'),
                Text('Expected: ₹${data['expected_amount']}'),
                const SizedBox(height: 8),
                Text(
                  'Advance Paid: ₹${data['advance_booking']}',
                  style: const TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),

                Text(
                  "Payment Status: ${paymentStatus ?? "Not Paid"}",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: paymentStatus == "completed"
                        ? Colors.green
                        : Colors.red,
                  ),
                ),

                const SizedBox(height: 10),

                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            EngineerRequestDetailsPage(bookingId: data['id']),
                      ),
                    );
                  },
                  child: const Text("Update Work Result"),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class RejectedBookingScreen extends StatefulWidget {
  final int engineerId;

  const RejectedBookingScreen({super.key, required this.engineerId});

  @override
  State<RejectedBookingScreen> createState() => _RejectedBookingScreenState();
}

class _RejectedBookingScreenState extends State<RejectedBookingScreen> {
  bool isLoading = true;
  String? error;
  List<dynamic> bookings = [];

  @override
  void initState() {
    super.initState();
    fetchRejectedBookings();
  }

  Future<void> fetchRejectedBookings() async {
    final url =
        'https://417sptdw-8001.inc1.devtunnels.ms/userapp/engineer/bookings/rejected/${widget.engineerId}/';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);

        setState(() {
          bookings = decoded['data']; // 🔥 IMPORTANT
          isLoading = false;
        });
      } else {
        setState(() {
          error = 'Failed: ${response.statusCode}';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        error = e.toString();
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (error != null) {
      return Center(child: Text(error!));
    }

    if (bookings.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              backgroundColor: Colors.green[100],
              radius: 50,
              child: Icon(Icons.close, color: Colors.red, size: 40),
            ),
            const SizedBox(height: 20),
            Text(
              "No Rejected bookings",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: bookings.length,
      itemBuilder: (context, index) {
        final data = bookings[index];

        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data['user_name'],
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text('Phone: ${data['user_phone']}'),
                Text('Address: ${data['address']}'),
                Text('Start: ${data['start_date']}'),
                Text('End: ${data['end_date']}'),
                const SizedBox(height: 8),
                Text(
                  'Reject Reason: ${data['reject_reason']}',
                  style: const TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                const Chip(
                  label: Text('REJECTED'),
                  backgroundColor: Colors.red,
                  labelStyle: TextStyle(color: Colors.white),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
   