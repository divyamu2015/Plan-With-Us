import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class BookingStatusTabScreen extends StatelessWidget {
  final int engineerId;
  final int initialIndex;

  const BookingStatusTabScreen({
    super.key,
    required this.engineerId,
    required this.initialIndex,
  });

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      initialIndex: initialIndex,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Booking Status'),
          centerTitle: true,
          bottom: const TabBar(
            indicatorColor: Colors.white,
            tabs: [
              Tab(text: 'Pending'),
              Tab(text: 'Accepted'),
              Tab(text: 'Rejected'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            AcceptedBookingScreen(engineerId: engineerId),
            RejectedBookingScreen(engineerId: engineerId),
          ],
        ),
      ),
    );
  }
}

class AcceptedBookingScreen extends StatefulWidget {
  final int engineerId;

  const AcceptedBookingScreen({
    super.key,
    required this.engineerId,
  });

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

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (error != null) {
      return Center(child: Text(error!));
    }

    if (bookings.isEmpty) {
      return const Center(child: Text('No accepted bookings'));
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
                const SizedBox(height: 6),
                const Chip(
                  label: Text('ACCEPTED'),
                  backgroundColor: Colors.green,
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

class RejectedBookingScreen extends StatefulWidget {
  final int engineerId;

  const RejectedBookingScreen({
    super.key,
    required this.engineerId,
  });

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
      return const Center(child: Text('No rejected bookings'));
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


