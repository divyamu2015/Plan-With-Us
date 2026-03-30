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

  final String baseUrl = "https://417sptdw-8001.inc1.devtunnels.ms";

  @override
  void initState() {
    super.initState();
    fetchBookingDetails();
  }

  Future<void> fetchBookingDetails() async {
    final response = await http.get(
      Uri.parse(
        "$baseUrl/userapp/engineer_view_payment_of_booking/${widget.bookingId}/",
      ),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        bookingData = data["data"];
        isLoading = false;
      });
    }
  }

  Future<void> updateWorkStatus() async {
    setState(() => isUpdating = true);

    final response = await http.patch(
      Uri.parse(
        "$baseUrl/userapp/engineer_update_status/${widget.bookingId}/",
      ),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"status": "completed"}),
    );

    if (response.statusCode == 200) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Work marked as completed")),
      );
      fetchBookingDetails();
    }

    setState(() => isUpdating = false);
  }
//   const Color(0xFF0D2C21).withOpacity(0.97),
     //   const Color(0xFF0A241B).withOpacity(0.98),
    
 BoxDecoration _cardDecoration() {
  return BoxDecoration(
    borderRadius: BorderRadius.circular(28),
    gradient: LinearGradient(
      colors: [
       // ignore: deprecated_member_use
       const Color.fromARGB(255, 16, 75, 54).withOpacity(0.98),
     // ignore: deprecated_member_use
     const Color.fromARGB(255, 16, 75, 54).withOpacity(0.98),
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    border: Border.all(
      // ignore: deprecated_member_use
      color: Colors.white.withOpacity(0.10),
      width: 1.2,
    ),
    boxShadow: [
      BoxShadow(
        // ignore: deprecated_member_use
        color: Colors.black.withOpacity(0.28),
        blurRadius: 28,
        offset: const Offset(0, 14),
      ),
    ],
  );
}

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFF081C15),
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFF2CF0A0)),
        ),
      );
    }

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
             Color.fromARGB(255, 1, 100, 72),
           
             Color.fromARGB(255, 1, 100, 72),
            Color.fromARGB(255, 1, 100, 72),
           
            Color.fromARGB(255, 13, 58, 44),
            Color.fromARGB(255, 1, 100, 72),
            Color(0xFF0A2D22),
           //  Color(0xFF0A2D22),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Color(0xFF2CF0A0)),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text(
            "UPDATE WORK STATUS",
               style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                letterSpacing: 4,
                fontSize: 16,
              ),
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
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
        ),
        bottomNavigationBar: bookingData?["status"] == "completed"
            ? null
            : Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: ElevatedButton(
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
                  onPressed: isUpdating
                      ? null
                      : () {
                          final paymentStatus = bookingData?["payment"]?["status"];

                          if (paymentStatus == "completed") {
                            updateWorkStatus();
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Payment not completed yet"),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        },
                  child: isUpdating
                      ? const SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: Colors.black,
                          ),
                        )
                      : const Text(
                          "WORK COMPLETED",
                          style: TextStyle(fontSize: 16),
                        ),
                ),
              ),
      ),
    );
  }

  Widget _buildStatusCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "REQUEST STATUS",
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white70,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1,
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: bookingData?["status"] == "completed"
                      ? Colors.green.shade100
                      : Colors.orange.shade100,
                      //
             
             
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  bookingData?["status"].toString().toUpperCase() ?? "",
                  style: TextStyle(
                    color: bookingData?["status"] == "completed"
                        ? const Color.fromARGB(255, 30, 148, 34)
                        : const Color.fromARGB(255, 163, 102, 10),
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1
                  ),
                ),
              )
            ],
          ),
          const Divider(height: 30, color: Colors.white24),
          _buildContactRow(
            title: "Client",
            name: bookingData?["user_name"] ?? "",
            phone: bookingData?["user_phone"] ?? "",
          ),
          const Divider(height: 30, color: Colors.white24),
          _buildContactRow(
            title: "Engineer",
            name: bookingData?["engineer_name"] ?? "",
            phone: bookingData?["engineer_phone"] ?? "",
          ),
        ],
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
        Expanded(
          child: Row(
            children: [
              Text(
                "${title.toUpperCase()}:",
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.white30,
                  fontWeight: FontWeight.w600,
                   letterSpacing: 1,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  name.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 1,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        Text(
          phone,
          style: const TextStyle(
            fontSize: 13,
            color: Colors.white70,
          ),
        ),
      ],
    );
  }

  Widget _buildProjectInfoCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "PROJECT INFORMATION",
            style: TextStyle(
              fontWeight: FontWeight.bold,
               color: Colors.white70,
              letterSpacing: 1
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: (bookingData?["features"] as List? ?? [])
                .map(
                  (feature) => Chip(
                    backgroundColor: const Color(0xFF2CF0A0),
                    label: Text(
                      feature.toString(),
                      style: const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 16),
          Text(
            "${bookingData?["cent"]} Cent (${bookingData?["sqft"]} Sq.Ft)",
            style: const TextStyle(
              fontWeight: FontWeight.bold,
               color: Colors.white70,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "${bookingData?["start_date"]} to ${bookingData?["end_date"]}",
            style: const TextStyle(color: Colors.white70),
          ),
          const SizedBox(height: 8),
          Text(
            "Site Address: ${bookingData?["address"]}",
            style: const TextStyle(color: Colors.white70),
          ),
        ],
      ),
    );
  }

  Widget _buildFinancialCard() {
    final payment = bookingData?["payment"];
    final paymentStatus = payment?["status"];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: _cardDecoration(),
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

  // Widget _buildSuggestionCard() {
  //   final suggestion = bookingData?["suggestion"];

  //   if (suggestion == null || suggestion.toString().isEmpty) {
  //     return const SizedBox();
  //   }

  //   return Container(
  //     width: double.infinity,
  //     decoration: _cardDecoration(),
  //     child: Column(
  //       children: [
  //         ClipRRect(
  //           borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
  //           child: Image.network(
  //             "$baseUrl${bookingData?["suggestion"]}",
  //             height: 180,
  //             width: double.infinity,
  //             fit: BoxFit.cover,
  //           ),
  //         ),
  //         const Padding(
  //           padding: EdgeInsets.all(12),
  //           child: Text(
  //             "Engineer Suggestion",
  //             style: TextStyle(
  //               fontWeight: FontWeight.w600,
  //               color: Colors.white,
  //             ),
  //           ),
  //         )
  //       ],
  //     ),
  //   );
  // }
}