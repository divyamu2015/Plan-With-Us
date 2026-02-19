import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:house_construction_pro/purchase_screen/view_product_home/view_product_screen.dart';
import 'package:http/http.dart' as http;

class CashPaymentPage extends StatefulWidget {
  const CashPaymentPage({
    super.key,
    // required this.totalPayment,
    required this.selectedPaymentMethod,
    this.userId,
    this.bookingId,
    this.paymentChoice,
    required this.cartIds,
    required this.totalAmount,
  });
  // final double totalPayment;
  final String selectedPaymentMethod;
  final int? userId;
  final List<int> cartIds;
  final double totalAmount;
  final int? bookingId;
  final String? paymentChoice;
  //final List<Map<String, String>> banks;

  @override
  State<CashPaymentPage> createState() => _CashPaymentPageState();
}

class _CashPaymentPageState extends State<CashPaymentPage> {
  double? totalAmount;
  String? selectPayMethod;
  int? userId;
  List<int> cartIds = [];
  int? bookingId;
  String? paymentChoice;
  @override
  void initState() {
    // TODO: implement initState
    //totalAmount = widget.totalPayment;
    selectPayMethod = widget.selectedPaymentMethod;
    print(selectPayMethod);
    userId = widget.userId;
    cartIds = widget.cartIds;
    totalAmount = widget.totalAmount;
    bookingId = widget.bookingId;
    paymentChoice = widget.paymentChoice;
    print('cash payment===$paymentChoice');
    print('Cash Payment===$bookingId');
    super.initState();
    print(selectPayMethod);
  }

  //Futu
  Future<void> _showLogoutDialog(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Order Status"),
        content: const Text("Your order has been successfully confirmed."),
        actions: [
          TextButton(
            onPressed: () {
              Future.delayed(const Duration(seconds: 2), () {
                if (context.mounted) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) {
                        return ShopScreen(userId: userId!);
                      },
                    ),
                  );
                }
              });
            },
            child: const Text("ok", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Future<void> _saveCashPayment(BuildContext context) async {
    if (userId == null) {
      showError('User ID is missing.');
      return;
    }
    print(paymentChoice);
    print(paymentChoice);
    final String paymentOption = (selectPayMethod == "cash")
        ? "cash"
        : "card_payment";
    final Map<String, dynamic> requestBody = {
      "user_id": userId,
      "cart_ids": cartIds,
      "payment_choice": paymentChoice,
      "payment_type": paymentOption,
      "total_amount": totalAmount
          .toString(), // Convert to string if API expects it
    };

    print(' Request Body: $requestBody');

    try {
      final response = await http.post(
        Uri.parse(
          'https://417sptdw-8001.inc1.devtunnels.ms/userapp/cart-payments/',
        ),
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
        body: jsonEncode(requestBody),
      );

      print(' Response Code: ${response.statusCode}');
      print(' Response Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);

        if (data.containsKey('status') && data['status'] == "success") {
          showSuccess("Payment Successful! Redirecting...");
          Future.delayed(const Duration(seconds: 2), () {
            // ignore: use_build_context_synchronously
            _showLogoutDialog(context);
            // Navigator.push(
            //   context,
            //   MaterialPageRoute(
            //     builder: (context) {
            //       return ShopScreen(userId: userId!);
            //     },
            //   ),
            // );
          });
        } else {
          showError('Payment failed: ${data['message']}');
        }
      } else {
        showError('Payment failed: ${response.body}');
        print('Payment failed: ${response.body}');
      }
    } catch (e) {
      showError('Error: $e');
    }
  }

  Future<void> _saveCashSinglePayment(BuildContext context) async {
    if (userId == null) {
      showError('User ID is missing.');
      return;
    }

    print(paymentChoice);
    print(paymentChoice);
    final String paymentOption = (selectPayMethod == "cash")
        ? "cash"
        : "card_payment";
    final Map<String, dynamic> requestBody = {
      "user_id": userId,
      "booking_id": bookingId,
      "payment_choice": paymentChoice,
      "payment_type": paymentOption,
      "total_amount": totalAmount
          .toString(), // Convert to string if API expects it
    };

    print(' Request Body: $requestBody');

    try {
      final response = await http.post(
        Uri.parse(
          'https://417sptdw-8001.inc1.devtunnels.ms/userapp/booking-payment/',
        ),
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
        body: jsonEncode(requestBody),
      );

      print(' Response Code: ${response.statusCode}');
      print(' Response Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        if (data.containsKey('status') && data['status'] == "success") {
          showSuccess("Payment Successful! Redirecting...");
          Future.delayed(const Duration(seconds: 2), () {
            // ignore: use_build_context_synchronously
            _showLogoutDialog(context);
            // Navigator.push(
            //   context,
            //   MaterialPageRoute(
            //     builder: (context) {
            //       return ShopScreen(userId: userId!);
            //     },
            //   ),
            // );
          });
        } else {
          showError('Payment failed: ${data['message']}');
        }
      } else {
        showError('Payment failed: ${response.body}');
      }
    } catch (e) {
      showError('Error: $e');
    }
  }

  void showError(String message) {
    if (!mounted) {
      return; // Prevents calling setState or accessing context if unmounted
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void showSuccess(String message) {
    if (!mounted) return; // Ensures widget is still part of the tree
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green.shade700,
        title: const Text('Pay Invoice', style: TextStyle(color: Colors.white)),
        elevation: 4,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                elevation: 5,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Center(
                    child: Column(
                      children: [
                        Image.asset('assets/images/payment.png', height: 60),
                        const SizedBox(height: 10),
                        const Text(
                          "Payment Amount",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          '₹$totalAmount',
                          style: TextStyle(
                            fontSize: 70.sp,
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const SizedBox(height: 20),
              SizedBox(
                width: width,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade700,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    print(123);
                    print('paymentChoice: $paymentChoice');
                    if (paymentChoice == 'cart_payment') {
                      _saveCashPayment(context);
                    } else if (paymentChoice == 'booking_payment') {
                      _saveCashSinglePayment(context);
                    }
                  },

                  child: const Text(
                    "Continue",
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
