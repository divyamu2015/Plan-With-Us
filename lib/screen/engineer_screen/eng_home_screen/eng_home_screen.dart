import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_slider_drawer/flutter_slider_drawer.dart';
import 'package:house_construction_pro/authantication/user_authentication/login_screen/login_view_page.dart';
import 'package:house_construction_pro/screen/engineer_screen/eng_profile_management/eng_profile_manage_view.dart';
import 'package:house_construction_pro/screen/engineer_screen/engineer_pro_bio/engineer_bio.dart';
import 'package:house_construction_pro/screen/engineer_screen/engineer_view_list_works_uploads/engineer_view_work_uploads.dart';
import 'package:house_construction_pro/screen/engineer_screen/view_customer_feedback.dart';
import 'package:house_construction_pro/screen/engineer_screen/view_user_booking_details/view_booking_details.dart';
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

  // Elegant off-white theme
  static const Color kPageBg = Color(0xFFF8F6F1);
  static const Color kSurface = Color(0xFFFFFDFC);
  static const Color kSurface2 = Color(0xFFF2EEE6);
  static const Color kCardBorder = Color(0xFFE7E0D4);
  static const Color kPrimary = Color(0xFF2F6B57);
  static const Color kPrimaryDark = Color(0xFF234E40);
  //static const Color kAccent = Color(0xFF5FAF8D);
  static const Color kText = Color(0xFF1F2937);
  static const Color kSubText = Color(0xFF6B7280);
  static const Color kDanger = Color(0xFFD9534F);
  static const Color kDangerSoft = Color(0xFFFDECEC);
 // static const Color kSuccessSoft = Color(0xFFEAF7F0);
  static const Color kGoldSoft = Color(0xFFB48A3C);

  @override
  void initState() {
    super.initState();
    engineerId = widget.engineerId;

    _sliderKey = GlobalKey<SliderDrawerState>();
    _tabController = TabController(length: 3, vsync: this);
    fetchBookings();
  }

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

  List<dynamic> get pending =>
      bookings.where((b) => b['status'] == 'pending').toList();

  List<dynamic> get accepted =>
      bookings.where((b) => b['status'] == 'accepted').toList();

  List<dynamic> get rejected =>
      bookings.where((b) => b['status'] == 'rejected').toList();

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

    if (!mounted) return;

    updatingIds.remove(bookingId);
    setState(() {});

    _tabController.animateTo(2);
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
      color: kPrimaryDark,
      child: Container(
        padding: const EdgeInsets.only(top: 56, left: 20, right: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.only(left: 10, bottom: 24),
              child: Text(
                "ENGINEER PANEL",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.4,
                ),
              ),
            ),
            ...menuItems.map((item) {
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                decoration: BoxDecoration(
                  // ignore: deprecated_member_use
                  color: Colors.white.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: ListTile(
                  leading: Icon(item['icon'] as IconData, color: Colors.white),
                  title: Text(
                    item['title'].toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                  onTap: () => _onMenuItemClick(item['title'] as String),
                ),
              );
            }),
          ],
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
          builder: (context) => EngineerWorksListScreen(engineerId: engineerId!),
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
        backgroundColor: kSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        title: const Text(
          'Logout',
          style: TextStyle(color: kText, fontWeight: FontWeight.w700),
        ),
        content: const Text(
          'Are you sure you want to logout?',
          style: TextStyle(color: kSubText),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel', style: TextStyle(color: kSubText)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: kPrimary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) {
                    return LoginScreen();
                  },
                ),
              );
            },
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SliderDrawer(
      key: _sliderKey,
      slider: _drawerMenu(),
      appBar: AppBar(toolbarHeight: 0, backgroundColor: kPageBg, elevation: 0),
      child: Scaffold(
        backgroundColor: kPageBg,
        body: SafeArea(
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
    );
  }

  Widget _buildLuxuryTabBar() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 6, 20, 16),
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: kSurface,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: kCardBorder),
        boxShadow: [
          BoxShadow(
            // ignore: deprecated_member_use
            color: Colors.black.withOpacity(0.05),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: TabBar(
        controller: _tabController,
        dividerColor: Colors.transparent,
        indicatorSize: TabBarIndicatorSize.tab,
        labelColor: Colors.white,
        unselectedLabelColor: kPrimary,
        labelStyle: const TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 12,
          letterSpacing: 1,
        ),
        unselectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 12,
          letterSpacing: 1,
        ),
        indicator: BoxDecoration(
          color: kPrimary,
          borderRadius: BorderRadius.circular(26),
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
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              color: kSurface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: kCardBorder),
            ),
            child: IconButton(
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
              icon: const Icon(Icons.menu, color: kPrimary, size: 28),
            ),
          ),
          const Expanded(
            child: Center(
              child: Text(
                "BOOKING DETAILS",
                style: TextStyle(
                  color: kText,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 2,
                  fontSize: 18,
                ),
              ),
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _pendingTab() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator(color: kPrimary));
    }
    if (error != null) {
      return Center(
        child: Text(error!, style: const TextStyle(color: kText)),
      );
    }
    if (pending.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 50,
              child: Icon(Icons.close, color: Colors.red, size: 45),
            ),
            Text(
              "No pending bookings",
              style: TextStyle(color: kSubText, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      itemCount: pending.length,
      itemBuilder: (_, i) => _buildPendingLuxuryCard(pending[i]),
    );
  }

  Widget _buildPendingLuxuryCard(dynamic data) {
    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        color: kSurface,
        border: Border.all(color: kCardBorder),
        boxShadow: [
          BoxShadow(
            // ignore: deprecated_member_use
            color: Colors.black.withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _cardTopSection(
            name: data['user_name']?.toString().toUpperCase() ?? '',
            subtitle: (data['work_type'] ?? "PROJECT REQUEST").toString(),
          ),
          const SizedBox(height: 18),
          Divider(color: kCardBorder, height: 1),
          const SizedBox(height: 18),

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
                  icon: Icons.location_on_outlined,
                  label: "ADDRESS",
                  value: data['address'],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _detailBlock(
                  icon: Icons.calendar_today_outlined,
                  label: "START DATE",
                  value: data['start_date'],
                ),
              ),
              const SizedBox(width: 18),
              Expanded(
                child: _detailBlock(
                  icon: Icons.event_busy_outlined,
                  label: "END DATE",
                  value: data['end_date'],
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          _detailBlock(
            icon: Icons.account_balance_wallet_outlined,
            label: "EXPECTED AMOUNT",
            value: "₹${data['expected_amount'] ?? '0'}",
            isAmount: true,
          ),

          const SizedBox(height: 16),
          _wideLuxuryRow("SQFT", data['sqft']),
          _wideLuxuryRow("CENT", data['cent']),

          if ((data['features'] as List?)?.isNotEmpty ?? false) ...[
            const SizedBox(height: 18),
            const Text(
              "FEATURES",
              style: TextStyle(
                color: kSubText,
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.1,
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: (data['features'] as List)
                  .map(
                    (f) => Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: kSurface2,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: kCardBorder),
                      ),
                      child: Text(
                        f.toString(),
                        style: const TextStyle(
                          color: kText,
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF2F7FF),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFD5E4FF)),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.picture_as_pdf_outlined,
                      color: Colors.blueAccent,
                    ),
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
          Divider(color: kCardBorder, height: 1),
          const SizedBox(height: 18),

          updatingBookingIds.contains(data['id'])
              ? const Center(child: CircularProgressIndicator(color: kPrimary))
              : Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          await updateStatus(data['id'], 'rejected');
                          _tabController.animateTo(2);
                        },
                        icon: const Icon(Icons.close, color: kDanger),
                        label: const Text("REJECT"),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: kDanger,
                          side: const BorderSide(color: kDanger),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                          textStyle: const TextStyle(
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: ElevatedButton.icon(
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
                        },
                        icon: const Icon(Icons.check, color: Colors.white),
                        label: const Text("ACCEPT"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kPrimary,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                          textStyle: const TextStyle(
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1,
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

  Widget _cardTopSection({required String name, required String subtitle}) {
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
                  color: kText,
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
                  color: kPrimary,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.4,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Container(
          width: 62,
          height: 62,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: kSurface2,
            border: Border.all(color: kCardBorder),
          ),
          child: const Icon(Icons.person, color: kGoldSoft, size: 32),
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
            Icon(icon, size: 18, color: kPrimary),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                label,
                style: const TextStyle(
                  color: kSubText,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.1,
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
            color: isAmount ? kPrimary : kText,
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
                color: kSubText,
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.1,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value?.toString() ?? 'N/A',
              textAlign: TextAlign.right,
              style: const TextStyle(
                color: kText,
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
      // ignore: deprecated_member_use
      barrierColor: Colors.black.withOpacity(0.18),
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 24),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              color: kSurface,
              border: Border.all(color: kCardBorder),
              boxShadow: [
                BoxShadow(
                  // ignore: deprecated_member_use
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 26,
                  offset: const Offset(0, 14),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Enter Advance Amount',
                  style: TextStyle(
                    color: kText,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  keyboardType: TextInputType.number,
                  style: const TextStyle(color: kText),
                  decoration: InputDecoration(
                    hintText: 'Enter advance booking amount',
                    hintStyle: const TextStyle(color: kSubText),
                    filled: true,
                    fillColor: kPageBg,
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: kCardBorder),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: kPrimary),
                    ),
                  ),
                  onChanged: (value) {
                    amount = value;
                  },
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, null),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(color: kSubText),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kPrimary,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () => Navigator.pop(context, amount),
                      child: const Text('OK'),
                    ),
                  ],
                ),
              ],
            ),
          ),
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
          backgroundColor: kSurface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          title: const Text(
            'Enter Reason',
            style: TextStyle(color: kText, fontWeight: FontWeight.w700),
          ),
          content: TextField(
            autofocus: true,
            style: const TextStyle(color: kText),
            decoration: InputDecoration(
              hintText: 'Enter reason for rejection',
              hintStyle: const TextStyle(color: kSubText),
              filled: true,
              fillColor: kPageBg,
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: kCardBorder),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: kPrimary),
              ),
            ),
            onChanged: (value) {
              reason = value;
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, null),
              child: const Text('Cancel', style: TextStyle(color: kSubText)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: kPrimary,
                foregroundColor: Colors.white,
              ),
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

  void _openSuggestion(BuildContext context, String path) {
    final fullUrl = 'https://417sptdw-8001.inc1.devtunnels.ms$path';
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Open PDF: $fullUrl'),
        backgroundColor: Colors.blueAccent,
      ),
    );
  }
}

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

  static const Color kPageBg = Color(0xFFF8F6F1);
  static const Color kSurface = Color(0xFFFFFDFC);
  static const Color kCardBorder = Color(0xFFE7E0D4);
  static const Color kPrimary = Color(0xFF2F6B57);
  static const Color kText = Color(0xFF1F2937);
  static const Color kSubText = Color(0xFF6B7280);
  static const Color kSuccess = Color(0xFF3FA66B);
  static const Color kDanger = Color(0xFFD9534F);

  @override
  void initState() {
    super.initState();
    fetchAcceptedBookings();
  }

  // Future<void> _showPaymentDialog(int bookingId) async {
  //   final url =
  //       'https://417sptdw-8001.inc1.devtunnels.ms/userapp/engineer_view_payment_of_booking/$bookingId/';

  //   try {
  //     final response = await http.get(Uri.parse(url));

  //     if (response.statusCode == 200) {
  //       final decoded = jsonDecode(response.body);
  //       final data = decoded['data'];
  //       final payment = data['payment'];

  //       showDialog(
  //         // ignore: use_build_context_synchronously
  //         context: context,
  //         builder: (context) {
  //           return AlertDialog(
  //             backgroundColor: kSurface,
  //             shape: RoundedRectangleBorder(
  //               borderRadius: BorderRadius.circular(22),
  //             ),
  //             title: const Text(
  //               "Payment Details",
  //               style: TextStyle(color: kText, fontWeight: FontWeight.w700),
  //             ),
  //             content: Column(
  //               mainAxisSize: MainAxisSize.min,
  //               crossAxisAlignment: CrossAxisAlignment.start,
  //               children: [
  //                 Text(
  //                   "Customer: ${data['user_name']}",
  //                   style: const TextStyle(color: kText),
  //                 ),
  //                 const SizedBox(height: 8),
  //                 Text(
  //                   "Payment Type: ${payment['payment_type']}",
  //                   style: const TextStyle(color: kText),
  //                 ),
  //                 Text(
  //                   "Payment Status: ${payment['status']}",
  //                   style: TextStyle(
  //                     fontWeight: FontWeight.bold,
  //                     color: payment['status'] == 'completed'
  //                         ? kSuccess
  //                         : kDanger,
  //                   ),
  //                 ),
  //                 Text(
  //                   "Amount: ₹${payment['total_amount']}",
  //                   style: const TextStyle(color: kText),
  //                 ),
  //                 const SizedBox(height: 20),
  //                 ElevatedButton(
  //                   onPressed: () async {
  //                     Navigator.pop(context);
  //                     await _markWorkCompleted(bookingId);
  //                   },
  //                   style: ElevatedButton.styleFrom(
  //                     backgroundColor: kPrimary,
  //                     foregroundColor: Colors.white,
  //                   ),
  //                   child: const Text("Work Completed"),
  //                 ),
  //               ],
  //             ),
  //           );
  //         },
  //       );
  //     }
  //   } catch (e) {
  //     ScaffoldMessenger.of(
  //       // ignore: use_build_context_synchronously
  //       context,
  //     ).showSnackBar(SnackBar(content: Text("Error: $e")));
  //   }
  // }

  Future<void> fetchAcceptedBookings() async {
    final url =
        'https://417sptdw-8001.inc1.devtunnels.ms/userapp/engineer/bookings/accepted/${widget.engineerId}/';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);

        setState(() {
          bookings = decoded['data'];
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
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Work marked as Completed")),
        );

        await fetchAcceptedBookings();
      } else {
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed: ${response.statusCode}")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        // ignore: use_build_context_synchronously
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator(color: kPrimary));
    }

    if (error != null) {
      return Center(
        child: Text(error!, style: const TextStyle(color: kText)),
      );
    }

    if (bookings.isEmpty) {
      return const Center(
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 50,
              child: Icon(Icons.close, color: Colors.red, size: 45),
            ),
            Text(
              "No Accepted bookings",
              style: TextStyle(color: kSubText, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      itemCount: bookings.length,
      itemBuilder: (context, index) {
        final data = bookings[index];
        final paymentStatus = data['payment']?['status'];
        return _acceptedLuxuryCard(context, data, paymentStatus);
      },
    );
  }

  Widget _acceptedLuxuryCard(
    BuildContext context,
    dynamic data,
    dynamic paymentStatus,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        color: kSurface,
        border: Border.all(color: kCardBorder),
        boxShadow: [
          BoxShadow(
            // ignore: deprecated_member_use
            color: Colors.black.withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Align(
            alignment: Alignment.center,
            child: Text(
              (data['user_name'] ?? '').toString().toUpperCase(),
              style: const TextStyle(
                color: kText,
                fontSize: 22,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(height: 18),
          Divider(color: kCardBorder, height: 1),
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
            valueColor: kSuccess,
          ),
          _acceptedRow(
            "PAYMENT STATUS",
            "${paymentStatus ?? "Not Paid"}",
            valueColor: paymentStatus == "completed" ? kSuccess : kDanger,
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
                backgroundColor: kPrimary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
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
                color: kSubText,
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.1,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value?.toString() ?? 'N/A',
              textAlign: TextAlign.right,
              style: TextStyle(
                color: valueColor ?? kText,
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

  static const Color kSurface = Color(0xFFFFFDFC);
  static const Color kCardBorder = Color(0xFFE7E0D4);
  static const Color kText = Color(0xFF1F2937);
  static const Color kSubText = Color(0xFF6B7280);
  static const Color kDanger = Color(0xFFD9534F);
  static const Color kDangerSoft = Color(0xFFFDECEC);
  static const Color kPrimary = Color(0xFF2F6B57);

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
          bookings = decoded['data'];
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
      return const Center(child: CircularProgressIndicator(color: kPrimary));
    }

    if (error != null) {
      return Center(
        child: Text(error!, style: const TextStyle(color: kText)),
      );
    }

    if (bookings.isEmpty) {
      return const Center(
        child: Column(
           mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 50,
              child: Icon(Icons.close, color: Colors.red, size: 45),
            ),
            Text(
              "No Rejected bookings",
              style: TextStyle(color: kSubText, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      itemCount: bookings.length,
      itemBuilder: (context, index) {
        final data = bookings[index];
        return _rejectedLuxuryCard(data);
      },
    );
  }

  Widget _rejectedLuxuryCard(dynamic data) {
    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        color: kSurface,
        border: Border.all(color: kCardBorder),
        boxShadow: [
          BoxShadow(
            // ignore: deprecated_member_use
            color: Colors.black.withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Align(
            alignment: Alignment.center,
            child: Text(
              (data['user_name'] ?? '').toString().toUpperCase(),
              style: const TextStyle(
                color: kText,
                fontSize: 22,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(height: 18),
          Divider(color: kCardBorder, height: 1),
          const SizedBox(height: 18),

          _rejectedRow("PHONE", data['user_phone']),
          _rejectedRow("ADDRESS", data['address']),
          _rejectedRow("START DATE", data['start_date']),
          _rejectedRow("END DATE", data['end_date']),
          _rejectedRow(
            "REJECT REASON",
            data['reject_reason'],
            valueColor: kDanger,
          ),

          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              color: kDangerSoft,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFFF5C9C8)),
            ),
            child: const Center(
              child: Text(
                "REJECTED",
                style: TextStyle(
                  color: kDanger,
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
                color: kSubText,
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.1,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value?.toString() ?? 'N/A',
              textAlign: TextAlign.right,
              style: TextStyle(
                color: valueColor ?? kText,
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
