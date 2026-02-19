import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class EngineerRequestDetailsPage extends StatefulWidget {
  final int bookingId;

  const EngineerRequestDetailsPage({super.key, required this.bookingId});

  @override
  State<EngineerRequestDetailsPage> createState() =>
      _EngineerRequestDetailsPageState();
}

class _EngineerRequestDetailsPageState
    extends State<EngineerRequestDetailsPage> {
  Map<String, dynamic>? bookingData;
  bool isLoading = true;
  bool isUpdating = false;

  final String baseUrl = "https://417sptdw-8001.inc1.devtunnels.ms"; // Android emulator

  @override
  void initState() {
    super.initState();
    fetchBookingDetails();
  }

  // ================= FETCH BOOKING =================

  Future<void> fetchBookingDetails() async {
    final response = await http.get(
      Uri.parse(
          "$baseUrl/userapp/engineer_view_payment_of_booking/${widget.bookingId}/"),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        bookingData = data["data"];
        isLoading = false;
      });
    }
  }

  // ================= UPDATE STATUS =================

  Future<void> updateWorkStatus() async {
    setState(() => isUpdating = true);

    final response = await http.patch(
      Uri.parse(
          "$baseUrl/userapp/engineer_update_status/${widget.bookingId}/"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"status": "completed"}),
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Work marked as completed")),
      );
      fetchBookingDetails();
    }

    setState(() => isUpdating = false);
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F8F8),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF006C75)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Update Work Status",
          style: TextStyle(
            color: Color(0xFF006C75),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildStatusCard(),
            const SizedBox(height: 16),
            _buildProjectInfoCard(),
            const SizedBox(height: 16),
            _buildFinancialCard(),
            const SizedBox(height: 16),
           // _buildSuggestionCard(),
          ],
        ),
      ),

      // ================= WORK COMPLETE BUTTON =================

    bottomNavigationBar: bookingData?["status"] == "completed"
    ? null
    : Padding(
        padding: const EdgeInsets.all(16),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onPressed: isUpdating
              ? null
              : () {
                  final paymentStatus =
                      bookingData?["payment"]?["status"];

                  if (paymentStatus == "completed") {
                    updateWorkStatus();
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content:
                            Text("Payment not completed yet"),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
          child: isUpdating
              ? const CircularProgressIndicator(
                  color: Colors.white)
              : const Text(
                  "Work Completed",
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold),
                ),
        ),
      ),

    );
  }

  // ================= STATUS CARD =================

  Widget _buildStatusCard() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Request Status",
                  style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                      fontWeight: FontWeight.w600),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: bookingData?["status"] == "completed"
                        ? Colors.green.shade100
                        : Colors.orange.shade100,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    bookingData?["status"].toString().toUpperCase() ?? "",
                    style: TextStyle(
                        color: bookingData?["status"] == "completed"
                            ? Colors.green
                            : Colors.orange,
                        fontSize: 12,
                        fontWeight: FontWeight.bold),
                  ),
                )
              ],
            ),
            const Divider(height: 30),

            // Client
            _buildContactRow(
              title: "Client",
              name: bookingData?["user_name"] ?? "",
              phone: bookingData?["user_phone"] ?? "",
            ),

            const Divider(height: 30),

            // Engineer
            _buildContactRow(
              title: "Engineer",
              name: bookingData?["engineer_name"] ?? "",
              phone: bookingData?["engineer_phone"] ?? "",
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactRow({
  required String title,
  required String name,
  required String phone,
}) {
  return Row(
    children: [
      // Left Side (Title + Name)
      Expanded(
        child: Row(
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(  // Prevent overflow
              child: Text(
                name,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),

      // Right Side (Phone)
      Text(
        phone,
        style: const TextStyle(
          fontSize: 13,
          color: Colors.grey,
        ),
      ),
    ],
  );
}


  // ================= PROJECT INFO =================

  Widget _buildProjectInfoCard() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Project Information",
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: (bookingData?["features"] as List? ?? [])
    .map((feature) => Chip(label: Text(feature.toString())))
    .toList(),

            ),
            const SizedBox(height: 16),
            Text(
              "${bookingData?["cent"]} Cent (${bookingData?["sqft"]} Sq.Ft)",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
                "${bookingData?["start_date"]} to ${bookingData?["end_date"]}"),
            const SizedBox(height: 8),
            Text(
              "Site Address: ${bookingData?["address"]}",
              style: const TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  // ================= FINANCIAL CARD =================

 Widget _buildFinancialCard() {
  final payment = bookingData?["payment"];
  final paymentStatus = payment?["status"];

  return Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: const Color(0xFF006C75),
      borderRadius: BorderRadius.circular(16),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Expected Budget: ₹${bookingData?["expected_amount"] ?? "0"}",
          style: const TextStyle(color: Colors.white),
        ),
        const SizedBox(height: 10),
        Text(
          "Advance Booking: ₹${bookingData?["advance_booking"] ?? "0"}",
          style: const TextStyle(color: Colors.white),
        ),
        const SizedBox(height: 16),
        Text(
          "Payment Status: ${paymentStatus ?? "Not Paid"}",
          style: TextStyle(
            color: paymentStatus == "completed"
                ? Colors.greenAccent
                : Colors.redAccent,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    ),
  );
}

  // ================= SUGGESTION =================

  Widget _buildSuggestionCard() {
    final suggestion = bookingData?["suggestion"];

  if (suggestion == null || suggestion.toString().isEmpty) {
    return const SizedBox(); // hide card if no suggestion
  }

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: [
          ClipRRect(
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(16)),
            child: Image.network(
              "$baseUrl${bookingData?["suggestion"]}",
              height: 180,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          const Padding(
            padding: EdgeInsets.all(12),
            child: Text(
              "Engineer Suggestion",
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          )
        ],
      ),
    );
  }
}
      