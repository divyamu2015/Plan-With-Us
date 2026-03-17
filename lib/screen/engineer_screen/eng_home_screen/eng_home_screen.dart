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
        bookings = decoded is List ? decoded : decoded['data'] ?? [];
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
    key: _sliderKey,
    slider: _drawerMenu(),
    appBar: AppBar(
      toolbarHeight: 0,
      backgroundColor: const Color(0xFF081C15),
      elevation: 0,
    ),
    child: Scaffold(
      backgroundColor: const Color(0xFF081C15),
      body: SafeArea(
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFF061A14),
                Color(0xFF08241C),
                Color(0xFF0A2D22),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            children: [
              _buildHeader(),
              _buildLuxuryTabBar(),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _pendingTab(),
                    AcceptedBookingScreen(engineerId: engineerId!),
                    RejectedBookingScreen(engineerId: engineerId!),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

Widget _buildLuxuryTabBar() {
  return Container(
    margin: const EdgeInsets.fromLTRB(22, 8, 22, 18),
    padding: const EdgeInsets.all(6),
    decoration: BoxDecoration(
      color: const Color(0xFF103526).withOpacity(0.9),
      borderRadius: BorderRadius.circular(32),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.18),
          blurRadius: 20,
          offset: const Offset(0, 10),
        ),
      ],
    ),
    child: TabBar(
      controller: _tabController,
      dividerColor: Colors.transparent,
      indicatorSize: TabBarIndicatorSize.tab,
      labelColor: Colors.black,
      unselectedLabelColor: const Color(0xFF25F49D).withOpacity(0.72),
      labelStyle: const TextStyle(
        fontWeight: FontWeight.w700,
        fontSize: 12,
        letterSpacing: 1.2,
      ),
      unselectedLabelStyle: const TextStyle(
        fontWeight: FontWeight.w700,
        fontSize: 12,
        letterSpacing: 1.2,
      ),
      indicator: BoxDecoration(
        color: const Color(0xFF2CF0A0),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2CF0A0).withOpacity(0.45),
            blurRadius: 22,
            spreadRadius: 1,
          ),
        ],
      ),
      tabs: const [
        Tab(text: "PENDING"),
        Tab(text: "ACCEPTED"),
        Tab(text: "REJECTED"),
      ],
    ),
  );
}

 Widget _buildHeader() {
  return Padding(
    padding: const EdgeInsets.fromLTRB(20, 18, 20, 12),
    child: Row(
      children: [
        IconButton(
          onPressed: () {
            final sliderState = _sliderKey.currentState;
            if (sliderState != null) {
              if (sliderState.isDrawerOpen) {
                sliderState.closeSlider();
              } else {
                sliderState.openSlider();
              }
            }
          },
          icon: const Icon(
            Icons.menu,
            color: Color(0xFF25F49D),
            size: 30,
          ),
        ),
        const Expanded(
          child: Center(
            child: Text(
              "BOOKING DETAILS",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                letterSpacing: 4,
                fontSize: 16,
              ),
            ),
          ),
        ),
        const SizedBox(width: 48),
      ],
    ),
  );
}
  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFF0F3D2E),
        borderRadius: BorderRadius.circular(30),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: const Color(0xFF25F49D),
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Color(0xFF25F49D).withOpacity(0.6),
              blurRadius: 15,
            ),
          ],
        ),
        labelColor: Colors.black,
        unselectedLabelColor: const Color(0xFF25F49D).withOpacity(0.6),
        tabs: const [
          Tab(text: "PENDING"),
          Tab(text: "ACCEPTED"),
          Tab(text: "REJECTED"),
        ],
      ),
    );
  }

  Widget _buildTabViews() {
  return TabBarView(
    controller: _tabController,
    children: [
      _pendingTab(),

      // ✅ ACCEPTED TAB
      AcceptedBookingScreen(engineerId: engineerId!),

      // ✅ REJECTED TAB
      RejectedBookingScreen(engineerId: engineerId!),
    ],
  );
}

  // ---------------- TABS ----------------
  Widget _pendingTab() {
  if (isLoading) {
    return const Center(child: CircularProgressIndicator(color: Color(0xFF25F49D)));
  }
  if (error != null) {
    return Center(
      child: Text(
        error!,
        style: const TextStyle(color: Colors.white),
      ),
    );
  }
  if (pending.isEmpty) {
    return const Center(
      child: Text(
        "No pending bookings",
        style: TextStyle(
          color: Colors.white70,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  return ListView.builder(
    padding: const EdgeInsets.fromLTRB(22, 0, 22, 24),
    itemCount: pending.length,
    itemBuilder: (_, i) => _buildPendingLuxuryCard(pending[i]),
  );
}

Widget _buildPendingLuxuryCard(dynamic data) {
  return Container(
    margin: const EdgeInsets.only(bottom: 22),
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(28),
      gradient: LinearGradient(
        colors: [
          const Color(0xFF0D2C21).withOpacity(0.97),
          const Color(0xFF0A241B).withOpacity(0.98),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      border: Border.all(
        color: Colors.white.withOpacity(0.10),
        width: 1.2,
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.28),
          blurRadius: 28,
          offset: const Offset(0, 14),
        ),
        BoxShadow(
          color: const Color(0xFF25F49D).withOpacity(0.06),
          blurRadius: 40,
          spreadRadius: 2,
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _cardTopSection(
          name: data['user_name']?.toString() ?? '',
          subtitle: (data['work_type'] ?? "PROJECT REQUEST").toString(),
        ),
        const SizedBox(height: 18),
        Container(
          height: 1,
          color: const Color(0xFF25F49D).withOpacity(0.18),
        ),
        const SizedBox(height: 20),

        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _detailBlock(
                icon: Icons.call_outlined,
                label: "PHONE",
                value: data['user_phone'],
              ),
            ),
            const SizedBox(width: 18),
            Expanded(
              child: _detailBlock(
                icon: Icons.calendar_today_outlined,
                label: "START DATE",
                value: data['start_date'],
              ),
            ),
          ],
        ),
        const SizedBox(height: 22),

        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _detailBlock(
                icon: Icons.event_busy_outlined,
                label: "END DATE",
                value: data['end_date'],
              ),
            ),
            const SizedBox(width: 18),
            Expanded(
              child: _detailBlock(
                icon: Icons.square_foot_outlined,
                label: "SQFT",
                value: data['sqft'],
              ),
            ),
          ],
        ),

        const SizedBox(height: 22),

        _detailBlock(
          icon: Icons.account_balance_wallet_outlined,
          label: "EXPECTED AMOUNT",
          value: "₹${data['expected_amount'] ?? '0'}",
          isAmount: true,
        ),

        const SizedBox(height: 18),
        _wideLuxuryRow("ADDRESS", data['address']),
        _wideLuxuryRow("CENT", data['cent']),

        if ((data['features'] as List?)?.isNotEmpty ?? false) ...[
          const SizedBox(height: 18),
          const Text(
            "FEATURES",
            style: TextStyle(
              color: Colors.white54,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: (data['features'] as List)
                .map(
                  (f) => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.06),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white.withOpacity(0.08)),
                    ),
                    child: Text(
                      f.toString(),
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        ],

        if (data['suggestion'] != null &&
            data['suggestion'].toString().isNotEmpty) ...[
          const SizedBox(height: 18),
          InkWell(
            onTap: () => _openSuggestion(context, data['suggestion']),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withOpacity(0.08)),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.picture_as_pdf_outlined, color: Colors.blueAccent),
                  SizedBox(width: 8),
                  Text(
                    "View Suggestion File",
                    style: TextStyle(
                      color: Colors.blueAccent,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],

        const SizedBox(height: 18),
        Container(
          height: 1,
          color: const Color(0xFF25F49D).withOpacity(0.18),
        ),
        const SizedBox(height: 18),

        updatingBookingIds.contains(data['id'])
            ? const Center(
                child: CircularProgressIndicator(color: Color(0xFF25F49D)),
              )
            : Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        await updateStatus(data['id'], 'rejected');
                        _tabController.animateTo(2);
                      },
                      icon: const Icon(Icons.close, color: Color(0xFFFF5A5A)),
                      label: const Text("REJECT"),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFFFF5A5A),
                        side: BorderSide(
                          color: const Color(0xFFFF5A5A).withOpacity(0.35),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(22),
                        ),
                        textStyle: const TextStyle(
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.1,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        final amount = await _showAdvanceAmountDialog(context);
                        if (amount == null || amount.isEmpty) return;

                        await updateAcceptStatus(data['id'], 'accepted', amount);
                        _tabController.animateTo(1);
                      },
                      icon: const Icon(Icons.check, color: Colors.black),
                      label: const Text("ACCEPT"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2CF0A0),
                        foregroundColor: Colors.black,
                        elevation: 0,
                        shadowColor: const Color(0xFF2CF0A0),
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(22),
                        ),
                        textStyle: const TextStyle(
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.1,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
      ],
    ),
  );
}

Widget _cardTopSection({
  required String name,
  required String subtitle,
}) {
  return Row(
    children: [
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w800,
                height: 1.15,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle.toUpperCase(),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Color(0xFF2CF0A0),
                fontSize: 12,
                fontWeight: FontWeight.w700,
                letterSpacing: 2,
              ),
            ),
          ],
        ),
      ),
      const SizedBox(width: 12),
      Container(
        width: 66,
        height: 66,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: const Color(0xFF1A4C3A),
          border: Border.all(color: const Color(0xFF2CF0A0).withOpacity(0.35)),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF2CF0A0).withOpacity(0.10),
              blurRadius: 18,
              spreadRadius: 1,
            ),
          ],
        ),
        child: const Icon(
          Icons.person,
          color: Color(0xFFE6E6E6),
          size: 34,
        ),
      ),
    ],
  );
}

Widget _detailBlock({
  required IconData icon,
  required String label,
  required dynamic value,
  bool isAmount = false,
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        children: [
          Icon(icon, size: 20, color: const Color(0xFF9FB0A8)),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              label,
              style: const TextStyle(
                color: Color(0xFF8FA19A),
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.2,
              ),
            ),
          ),
        ],
      ),
      const SizedBox(height: 8),
      Text(
        value?.toString() ?? 'N/A',
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: isAmount ? const Color(0xFF2CF0A0) : Colors.white,
          fontSize: isAmount ? 18 : 15,
          fontWeight: FontWeight.w800,
          height: 1.2,
        ),
      ),
    ],
  );
}

Widget _wideLuxuryRow(String label, dynamic value) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 92,
          child: Text(
            label,
            style: const TextStyle(
              color: Color(0xFF8FA19A),
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value?.toString() ?? 'N/A',
            textAlign: TextAlign.right,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    ),
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
                    gradient: LinearGradient(
                      colors: [Color(0xFF0F3D2E), Color(0xFF0B2E23)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white.withOpacity(0.1)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.6),
                        blurRadius: 20,
                        offset: Offset(0, 10),
                      ),
                    ],
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
                          backgroundColor: Color(0xFF25F49D),
                          foregroundColor: Colors.black,
                          elevation: 10,
                          shadowColor: Color(0xFF25F49D),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
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
                      style: OutlinedButton.styleFrom(
  side: BorderSide(color: Colors.red.withOpacity(0.5)),
  foregroundColor: Colors.red,
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(30),
  ),
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
    return const Center(
      child: CircularProgressIndicator(color: Color(0xFF25F49D)),
    );
  }

  if (error != null) {
    return Center(
      child: Text(
        error!,
        style: const TextStyle(color: Colors.white),
      ),
    );
  }

  if (bookings.isEmpty) {
    return const Center(
      child: Text(
        "No Accepted bookings",
        style: TextStyle(
          color: Colors.white70,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  return ListView.builder(
    padding: const EdgeInsets.fromLTRB(22, 0, 22, 24),
    itemCount: bookings.length,
    itemBuilder: (context, index) {
      final data = bookings[index];
      final paymentStatus = data['payment']?['status'];
      return _acceptedLuxuryCard(context, data, paymentStatus);
    },
  );
}
Widget _acceptedLuxuryCard(BuildContext context, dynamic data, dynamic paymentStatus) {
  return Container(
    margin: const EdgeInsets.only(bottom: 22),
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(28),
      gradient: LinearGradient(
        colors: [
          const Color(0xFF0D2C21).withOpacity(0.97),
          const Color(0xFF0A241B).withOpacity(0.98),
        ],
      ),
      border: Border.all(color: Colors.white.withOpacity(0.10), width: 1.2),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.28),
          blurRadius: 28,
          offset: const Offset(0, 14),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                (data['user_name'] ?? '').toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF1A4C3A),
                border: Border.all(
                  color: const Color(0xFF2CF0A0).withOpacity(0.35),
                ),
              ),
              child: const Icon(Icons.person, color: Colors.white70),
            ),
          ],
        ),
        const SizedBox(height: 18),
        Container(height: 1, color: const Color(0xFF25F49D).withOpacity(0.18)),
        const SizedBox(height: 18),

        _acceptedRow("PHONE", data['user_phone']),
        _acceptedRow("ADDRESS", data['address']),
        _acceptedRow("START DATE", data['start_date']),
        _acceptedRow("END DATE", data['end_date']),
        _acceptedRow("CENT", data['cent']),
        _acceptedRow("SQFT", data['sqft']),
        _acceptedRow("EXPECTED AMOUNT", "₹${data['expected_amount']}"),
        _acceptedRow(
          "ADVANCE PAID",
          "₹${data['advance_booking']}",
          valueColor: const Color(0xFF59D36B),
        ),
        _acceptedRow(
          "PAYMENT STATUS",
          "${paymentStatus ?? "Not Paid"}",
          valueColor: paymentStatus == "completed"
              ? const Color(0xFF59D36B)
              : const Color(0xFFFF6B6B),
        ),

        const SizedBox(height: 18),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      EngineerRequestDetailsPage(bookingId: data['id']),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2CF0A0),
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(vertical: 17),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              textStyle: const TextStyle(
                fontWeight: FontWeight.w800,
                letterSpacing: 1,
              ),
            ),
            child: const Text("UPDATE WORK RESULT"),
          ),
        ),
      ],
    ),
  );
}

Widget _acceptedRow(String label, dynamic value, {Color? valueColor}) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Row(
      children: [
        SizedBox(
          width: 130,
          child: Text(
            label,
            style: const TextStyle(
              color: Color(0xFF8FA19A),
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value?.toString() ?? 'N/A',
            textAlign: TextAlign.right,
            style: TextStyle(
              color: valueColor ?? Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    ),
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
    return const Center(
      child: CircularProgressIndicator(color: Color(0xFF25F49D)),
    );
  }

  if (error != null) {
    return Center(
      child: Text(
        error!,
        style: const TextStyle(color: Colors.white),
      ),
    );
  }

  if (bookings.isEmpty) {
    return const Center(
      child: Text(
        "No Rejected bookings",
        style: TextStyle(
          color: Colors.white70,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  return ListView.builder(
    padding: const EdgeInsets.fromLTRB(22, 0, 22, 24),
    itemCount: bookings.length,
    itemBuilder: (context, index) {
      final data = bookings[index];
      return _rejectedLuxuryCard(data);
    },
  );
}
Widget _rejectedLuxuryCard(dynamic data) {
  return Container(
    margin: const EdgeInsets.only(bottom: 22),
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(28),
      gradient: LinearGradient(
        colors: [
          const Color(0xFF0D2C21).withOpacity(0.97),
          const Color(0xFF0A241B).withOpacity(0.98),
        ],
      ),
      border: Border.all(color: Colors.white.withOpacity(0.10), width: 1.2),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.28),
          blurRadius: 28,
          offset: const Offset(0, 14),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          (data['user_name'] ?? '').toString(),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 18),
        Container(height: 1, color: const Color(0xFF25F49D).withOpacity(0.18)),
        const SizedBox(height: 18),

        _rejectedRow("PHONE", data['user_phone']),
        _rejectedRow("ADDRESS", data['address']),
        _rejectedRow("START DATE", data['start_date']),
        _rejectedRow("END DATE", data['end_date']),
        _rejectedRow(
          "REJECT REASON",
          data['reject_reason'],
          valueColor: const Color(0xFFFF6B6B),
        ),

        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: const Color(0xFFFF5A5A).withOpacity(0.14),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: const Color(0xFFFF5A5A).withOpacity(0.30),
            ),
          ),
          child: const Center(
            child: Text(
              "REJECTED",
              style: TextStyle(
                color: Color(0xFFFF6B6B),
                fontWeight: FontWeight.w800,
                letterSpacing: 1.2,
              ),
            ),
          ),
        ),
      ],
    ),
  );
}

Widget _rejectedRow(String label, dynamic value, {Color? valueColor}) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Row(
      children: [
        SizedBox(
          width: 120,
          child: Text( 
            label,
            style: const TextStyle(
              color: Color(0xFF8FA19A),
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value?.toString() ?? 'N/A',
            textAlign: TextAlign.right,
            style: TextStyle(
              color: valueColor ?? Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    ),
  );
}
}
