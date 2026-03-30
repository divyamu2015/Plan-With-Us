import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:house_construction_pro/screen/engineer_screen/eng_profile_management/eng_profile_manage_view.dart';
import 'package:house_construction_pro/screen/engineer_screen/engineer_pro_bio/engineer_bio.dart';
import 'package:house_construction_pro/screen/engineer_screen/engineer_status_screen.dart/engineer_status_view.dart';
import 'package:house_construction_pro/screen/engineer_screen/view_customer_feedback.dart';
import 'package:house_construction_pro/screen/role_screen.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_slider_drawer/flutter_slider_drawer.dart';

class ViewEngineerBookingDetail extends StatefulWidget {
  final int engineerId;
  const ViewEngineerBookingDetail({super.key, required this.engineerId});

  @override
  State<ViewEngineerBookingDetail> createState() =>
      _ViewEngineerBookingDetailState();
}

Future<void> saveBookingId(int id) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setInt('id', id);
}

Future<int?> getBookingId() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getInt('id'); // returns null if not found
}

class _ViewEngineerBookingDetailState
    extends State<ViewEngineerBookingDetail> {
  bool isLoading = true;
  String? error;
  List<dynamic> bookings = [];
  int? engineerId;
  int? bookingId;
  Set<int> updatingBookingIds = {};

  late GlobalKey<SliderDrawerState> _sliderController;

  @override
  void initState() {
    super.initState();
    engineerId = widget.engineerId;
    _sliderController = GlobalKey<SliderDrawerState>();
   // print(engineerId);
    _loadBookingIdAndFetch();

    fetchBookingDetails();
  }

  Future<void> _loadBookingIdAndFetch() async {
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getInt('id');
    if (id == null) {
      setState(() {
        error = 'Booking ID not found in SharedPreferences';
        isLoading = false;
      });
      return;
    }
    setState(() {
      bookingId = id;
    });
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

  Future<void> updateAcceptStatus(int bookingId, String status) async {
    // String? reason;
    // if (status == 'accepted') {
    //   // reason = await _showReasonDialog(context);
    //   // if (reason == null || reason.isEmpty) {
    //   //   // If user cancels or enters no reason, do nothing
    //   //   return;
    //   // }
    // }

    final url =
        'https://417sptdw-8001.inc1.devtunnels.ms/userapp/engineer_update_status/$bookingId/';
    setState(() {
      updatingBookingIds.add(bookingId);
    });
    try {
      final response = await http.patch(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'status': status}),
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

  void _onMenuItemClick(String title) {
    _sliderController.currentState?.closeSlider();
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
    } else if (title == 'View Engineer Feedback') {
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
      key: _sliderController,
      slider: _menu(),
      child: Scaffold(
        backgroundColor: const Color(0xFFF6FAFF),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 2,
          iconTheme: const IconThemeData(color: Colors.black87),
          leading: IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () {
              final sliderState = _sliderController.currentState;
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
            'Booking Details',
            style: TextStyle(
              color: Colors.black87,
              fontWeight: FontWeight.w600,
              fontSize: 22,
            ),
          ),
          centerTitle: true,
        ),
        body: isLoading
            ? const Center(child: CircularProgressIndicator())
            : error != null
            ? Center(child: Text(error!))
            : bookings.isEmpty
            ? const Center(child: Text("No bookings found"))
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: bookings.length,
                itemBuilder: (context, index) {
                  final item = bookings[index];
                  return _buildBookingCard(item);
                },
              ),
      ),
    );
  }

  Widget _menu() {
    final menuItems = [
      {'icon': Icons.person, 'title': 'View Profile'},
      {'icon': Icons.work, 'title': 'Add Engineer Work'},
      {'icon': Icons.feedback_outlined, 'title': 'View Engineer Feedback'},
      {'icon': Icons.logout, 'title': 'Logout'},
    ];
    return Material(
      // This ensures the drawer has Material context
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
                          await updateAcceptStatus(data['id'], 'accepted');
                          Navigator.pushReplacement(
                            // ignore: use_build_context_synchronously
                            context,
                            MaterialPageRoute(
                              builder: (_) => BookingStatusTabScreen(
                                engineerId: engineerId!,
                                initialIndex: 0, // Accepted tab
                              ),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color.fromARGB(255, 96, 224, 101),
                        ),
                        child: const Text('Accept'),
                      ),
                      ElevatedButton(
                        onPressed: () async {
                          await updateStatus(data['id'], 'rejected');
                          Navigator.pushReplacement(
                            // ignore: use_build_context_synchronously
                            context,
                            MaterialPageRoute(
                              builder: (_) => BookingStatusTabScreen(
                                engineerId: engineerId!,
                                initialIndex: 1, // Rejected tab
                              ),
                            ),
                          );
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

// Placeholder pages for navigation targets from menu
class ViewProfilePage extends StatelessWidget {
  const ViewProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('View Profile')),
      body: const Center(child: Text('Profile Details here')),
    );
  }
}

class AddEngineerWorkPage extends StatelessWidget {
  const AddEngineerWorkPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Engineer Work')),
      body: const Center(child: Text('Add engineer work form here')),
    );
  }
}

class ViewEngineerfeedback extends StatelessWidget {
  const ViewEngineerfeedback({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('View Feedback')),
      body: const Center(child: Text('View engineer Feedback form here')),
    );
  }
}
