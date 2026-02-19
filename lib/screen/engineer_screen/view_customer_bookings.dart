import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class BookingDetailsScreen extends StatefulWidget {
  const BookingDetailsScreen({super.key});

  @override
  State<BookingDetailsScreen> createState() => _BookingDetailsScreenState();
}

class _BookingDetailsScreenState extends State<BookingDetailsScreen> {
  Map<String, dynamic>? details;
  bool loading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    getBookingDetails();
  }

  Future<void> getBookingDetails() async {
    const url = 'https://your-api-domain.com/userapp/engineer/bookings/1/';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        List data = json.decode(response.body);
        setState(() {
          details = data.isNotEmpty ? data[0] : null;
          loading = false;
        });
      } else {
        setState(() {
          error = 'Failed to load data (${response.statusCode})';
          loading = false;
        });
      }
    } catch (e) {
      setState(() {
        error = 'Error: $e';
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Booking Details')),
        body: Center(child: Text(error!)),
      );
    }
    if (details == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Booking Details')),
        body: const Center(child: Text('No data found')),
      );
    }

    final features = (details!['features'] as List?)?.cast<String>() ?? [];
    final start = details!['start_date'] ?? '';
    final end = details!['end_date'] ?? '';
    final suggestionFile = details!['suggestion']?.toString();
    final hasPdf = suggestionFile != null && suggestionFile.endsWith('.pdf');

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(),
        title: const Text('Booking Details'),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _SectionCard(
              title: 'Customer Details',
              children: [
                _InfoRow(
                  icon: Icons.person,
                  label: 'Customer Name',
                  value: (details!['user_name'] ?? '').toString(),
                ),
                const Divider(),
                _InfoRow(
                  icon: Icons.phone,
                  label: 'Phone Number',
                  value: (details!['user_phone'] ?? '').toString(),
                ),
                const Divider(),
                _InfoRow(
                  icon: Icons.location_pin,
                  label: 'Address',
                  value: (details!['address'] ?? '').toString(),
                  multiLine: true,
                ),
              ],
            ),
            const SizedBox(height: 16),
            _SectionCard(
              title: 'Project Details',
              children: [
                _InfoRow(
                  icon: Icons.calendar_today,
                  label: 'Start Date',
                  value: '$start - $end',
                ),
                const SizedBox(height: 16),
                 _InfoRow(
                  icon: Icons.calendar_today,
                  label: 'End Date',
                  value: '$end',
                ),
                const Divider(),
                Row(
                  children: [
                    Icon(hasPdf ? Icons.picture_as_pdf : Icons.photo,
                        color: Colors.blue, size: 28),
                    const SizedBox(width: 12),
                    Text(
                        hasPdf ? 'Engineer Suggestion PDF' : 'Photo/PDF',
                        style: const TextStyle(fontWeight: FontWeight.w500)
                    ),
                  ],
                ),
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 12),
                  height: 90,
                  color: Colors.grey.shade200,
                  child: Center(
                    child: hasPdf
                        ? Icon(Icons.picture_as_pdf, size: 35, color: Colors.red)
                        : Icon(Icons.image, size: 35, color: Colors.grey),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _DetailTile(
                      icon: Icons.square_foot,
                      label: 'Cent',
                      value: (details!['cent'] ?? '').toString(),
                    ),
                    _DetailTile(
                      icon: Icons.straighten,
                      label: 'Sqft',
                      value: (details!['sqft'] ?? '').toString(),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                _InfoRow(
                  icon: Icons.attach_money,
                  label: 'Expected Amount',
                  value: (details!['expected_amount'] ?? '').toString(),
                  highlight: true,
                ),
              ],
            ),
            const SizedBox(height: 16),
            _SectionCard(
              title: 'Additional Info',
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Text('Features',
                        style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade700)),
                  ),
                ),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: features.map((f) => _FeatureChip(f)).toList(),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(Icons.lightbulb_outline,
                        color: Colors.blue, size: 24),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Suggestion',
                              style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey.shade700)),
                          Text(
                            hasPdf
                                ? 'Engineer Suggestion PDF available'
                                : 'No suggestion attached',
                            style: TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)
                  ),
                ),
                child: const Text('Edit Booking', style: TextStyle(fontSize: 18)),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final List<Widget> children;
  const _SectionCard({required this.title, required this.children});
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool multiLine;
  final bool highlight;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.multiLine = false,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment:
          multiLine ? CrossAxisAlignment.start : CrossAxisAlignment.center,
      children: [
        Icon(icon, color: Colors.blue, size: 28),
        const SizedBox(width: 12),
        Text(
          label,
          style: TextStyle(
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade700,
              fontSize: 15),
        ),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: TextStyle(
              fontWeight: highlight ? FontWeight.bold : FontWeight.w500,
              color: highlight ? Colors.black : Colors.grey.shade900,
              fontSize: 15,
            ),
            maxLines: multiLine ? 2 : 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

class _DetailTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _DetailTile({required this.icon, required this.label, required this.value});
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: Colors.blue.shade300, size: 22),
        const SizedBox(width: 6),
        Text('$label ',
            style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade700)),
        Text(value,
            style: TextStyle(
                fontWeight: FontWeight.w600, color: Colors.grey.shade900)),
      ],
    );
  }
}

class _FeatureChip extends StatelessWidget {
  final String label;
  const _FeatureChip(this.label);
  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
      backgroundColor: Colors.blue.shade50,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }
}
