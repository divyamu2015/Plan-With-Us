import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:house_construction_pro/screen/engineer_screen/engineer_home.dart';
import 'package:http/http.dart' as http;

class AdvanceBookingPaymentScreen extends StatefulWidget {
  const AdvanceBookingPaymentScreen({
    super.key,
    required this.userId,
    required this.advanceAmount,
    required this.bookingId,
  });

  final int userId;
  final double advanceAmount;
  final int bookingId;

  @override
  State<AdvanceBookingPaymentScreen> createState() =>
      _AdvanceBookingPaymentScreenState();
}

class _AdvanceBookingPaymentScreenState
    extends State<AdvanceBookingPaymentScreen> {
  int selectedTab = 0;
  bool isLoading = false;

  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _cardController = TextEditingController();
  final _expiryController = TextEditingController();
  final _cvvController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _cardController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Payment")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _amountCard(),
            const SizedBox(height: 20),
            Row(
              children: [
                _tabButton("Card", 0),
                _tabButton("Cash", 1),
              ],
            ),
            const SizedBox(height: 20),
            selectedTab == 0 ? _cardView() : _cashView(),
          ],
        ),
      ),
    );
  }

  /// ================= TAB BUTTON =================
  Widget _tabButton(String title, int index) {
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => selectedTab = index),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: selectedTab == index ? Colors.green : Colors.grey,
                width: 3,
              ),
            ),
          ),
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  /// ================= AMOUNT CARD =================
  Widget _amountCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Amount to pay"),
          const SizedBox(height: 4),
          Text(
            "₹${widget.advanceAmount}",
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  /// ================= CARD VIEW =================
  Widget _cardView() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          _field(
            "Card Holder Name",
            _nameController,
            validator: (value) =>
                value!.isEmpty ? "Enter card holder name" : null,
          ),
          _field(
            "Card Number",
            _cardController,
            type: TextInputType.number,
            validator: (value) =>
                value!.length < 16 ? "Enter valid card number" : null,
          ),
          _field(
            "Expiry Date (MM/YY)",
            _expiryController,
            validator: (value) =>
                value!.isEmpty ? "Enter expiry date" : null,
          ),
          _field(
            "CVV",
            _cvvController,
            type: TextInputType.number,
            obscure: true,
            validator: (value) =>
                value!.length < 3 ? "Enter valid CVV" : null,
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: isLoading ? null : _payByCard,
            style: ElevatedButton.styleFrom(
              minimumSize: const Size.fromHeight(50),
              backgroundColor: Colors.green,
            ),
            child: isLoading
                ? const CircularProgressIndicator(color: Colors.white)
                : const Text("Pay Now"),
          ),
        ],
      ),
    );
  }

  /// ================= CASH VIEW =================
  Widget _cashView() {
    return ElevatedButton(
      onPressed: isLoading ? null : _payByCash,
      style: ElevatedButton.styleFrom(
        minimumSize: const Size.fromHeight(50),
        backgroundColor: Colors.green,
      ),
      child: isLoading
          ? const CircularProgressIndicator(color: Colors.white)
          : const Text("Confirm Cash Payment"),
    );
  }

  /// ================= TEXT FIELD =================
  Widget _field(
    String hint,
    TextEditingController controller, {
    TextInputType type = TextInputType.text,
    bool obscure = false,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        keyboardType: type,
        obscureText: obscure,
        validator: validator,
        decoration: InputDecoration(
          hintText: hint,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }

  /// ================= CARD PAYMENT =================
  Future<void> _payByCard() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    final success = await PaymentService.makePayment(
      bookingId: widget.bookingId,
      userId: widget.userId,
      paymentType: "card",
      totalAmount: widget.advanceAmount,
      cardHolderName: _nameController.text,
      cardNumber: _cardController.text,
      expiryDate: _expiryController.text,
      cvv: _cvvController.text,
    );

    setState(() => isLoading = false);
    _showResult(success);
  }

  /// ================= CASH PAYMENT =================
  Future<void> _payByCash() async {
    setState(() => isLoading = true);

    final success = await PaymentService.makePayment(
      bookingId: widget.bookingId,
      userId: widget.userId,
      paymentType: "cash",
      totalAmount: widget.advanceAmount,
    );

    setState(() => isLoading = false);
    _showResult(success);
  }

 void _showResult(bool success) {
  if (success) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Payment Successful")),
    );

    Future.delayed(const Duration(milliseconds: 800), () {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) =>  DashboardScreen(userId:  widget.userId,)),
        (route) => false,
      );
    });
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Payment Failed")),
    );
  }
}

}

/// ================= PAYMENT SERVICE =================
class PaymentService {
  static const String baseUrl =
      "https://417sptdw-8001.inc1.devtunnels.ms/userapp/advance-booking-payment/";

  static Future<bool> makePayment({
    required int bookingId,
    required int userId,
    required String paymentType,
    required double totalAmount,
    String? cardHolderName,
    String? cardNumber,
    String? expiryDate,
    String? cvv,
  }) async {
    final Map<String, dynamic> body = {
      "booking": bookingId,
      "user": userId,
      "payment_type": paymentType,
      "status": "completed",
      "total_amount": totalAmount,
    };

    if (paymentType == "card") {
      body.addAll({
        "card_holder_name": cardHolderName,
        "card_number": cardNumber,
        "expiry_date": expiryDate,
        "cvv": cvv,
      });
    }

    try {
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      );

      print(response.statusCode);
      print(response.body);

      return response.statusCode == 201;

    } catch (e) {
      print("Payment Error: $e");
      return false;
    }
  }
}
