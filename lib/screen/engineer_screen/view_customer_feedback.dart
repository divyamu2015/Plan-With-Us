import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class CustomerFeedbackPage extends StatefulWidget {
  final int engineerId;
  const CustomerFeedbackPage({super.key, required this.engineerId});

  @override
  State<CustomerFeedbackPage> createState() => _CustomerFeedbackPageState();
}

class _CustomerFeedbackPageState extends State<CustomerFeedbackPage> {
  List<dynamic> feedbacks = [];
  bool isLoading = true;
  String? errorText;
  int? engineerId;

  @override
  void initState() {
    super.initState();
    fetchFeedbacks();
    engineerId = widget.engineerId;
  }

  Future<void> fetchFeedbacks() async {
    setState(() {
      isLoading = true;
      errorText = null;
    });
    final url = Uri.parse(
      'https://417sptdw-8002.inc1.devtunnels.ms/userapp/engineer/view-feedback/${widget.engineerId}/',
    );
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        setState(() {
          feedbacks = jsonDecode(response.body) as List<dynamic>;
          isLoading = false;
        });
      } else {
        setState(() {
          errorText = 'Failed to load feedback';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorText = 'Error: $e';
        isLoading = false;
      });
    }
  }

  // String formatDate(String dateTimeString) {
  //   try {
  //     DateTime dt = DateTime.parse(dateTimeString);
  //     return "${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}";
  //   } catch (_) {
  //     return dateTimeString;
  //   }
  // }
String formatDate(String dateStr) {
    final date = DateTime.parse(dateStr); // "2025-11-01"
    return DateFormat('dd-MM-yyyy').format(date);
  }

  Widget buildRatingStars(int rating) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(
        5,
        (index) => Icon(
          index < rating ? Icons.star : Icons.star_border,
          color: Colors.amber,
          size: 20,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFD),
      appBar: AppBar(
        title: const Text('Feedback'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorText != null
          ? Center(child: Text(errorText!))
          : feedbacks.isEmpty
          ? const Center(child: Text('No feedback found'))
          : ListView.builder(
              itemCount: feedbacks.length,
              itemBuilder: (context, index) {
                final fb = feedbacks[index];
                return Card(
                  color: Colors.white,
                  margin: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          fb['user_name'] ?? 'Unknown User',
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                            color: Color(0xFF18214A),
                          ),
                        ),
                        const SizedBox(height: 6),
                        buildRatingStars(fb['rating'] ?? 0),
                        const SizedBox(height: 10),
                        Text(
                          fb['comments'] ?? '',
                          style: const TextStyle(
                            fontSize: 15,
                            color: Color(0xFF222B45),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          formatDate(fb['created_at'] ?? ''),
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFF8898AD),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
