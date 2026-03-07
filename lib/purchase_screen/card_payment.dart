import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:house_construction_pro/purchase_screen/view_cart/view_cart_screen.dart';
import 'package:house_construction_pro/purchase_screen/view_product_home/view_product_screen.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CardPaymentPage extends StatefulWidget {
  const CardPaymentPage({
    super.key,
    required this.totalPayment,
    required this.selectedPaymentMethod,
    this.userId,
    required this.cartIds,
    required this.paymentChoice,
    this.bookingId,
  });

  final double totalPayment;
  final String selectedPaymentMethod;
  final int? userId;
  final List<int> cartIds;
  final String? paymentChoice;
  final int? bookingId;

  @override
  State<CardPaymentPage> createState() => _CardPaymentPageState();
}

class _CardPaymentPageState extends State<CardPaymentPage> {
  final TextEditingController cardNumberController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController expiryDateController = TextEditingController();
  final TextEditingController cvvController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  double totalAmount = 0.00;
  String? selectPayMethod;
  int? userid;
  int? wastesubid; // Corrected variable to store retrieved waste submission ID
  List<int> cartIds = [];
  String? paymentChoice;
  int? bookingId;
  @override
  void initState() {
    super.initState();
    totalAmount = widget.totalPayment;
    selectPayMethod = widget.selectedPaymentMethod;
    userid = widget.userId;
    cartIds = widget.cartIds;
    paymentChoice = widget.paymentChoice;
    bookingId = widget.bookingId;
    print('CardPaymentPage =$bookingId');
  }

  /// ✅ Save card payment
  Future<void> saveCardPayment(BuildContext context) async {
    final url = Uri.parse(
      'https://417sptdw-8001.inc1.devtunnels.ms/userapp/cart-payments/',
    );

    if (userid == null) {
      showError('User ID is missing.');
      return;
    }

    final String paymentOption = (selectPayMethod == "card") ? "card" : "cash";

    final Map<String, dynamic> requestBody = {
      "user_id": userid,
      "cart_ids": cartIds,
      "total_amount": totalAmount,
      "payment_type": paymentOption,
      "card_holder_name": nameController.text.trim(),
      "card_number": cardNumberController.text.trim(),
      "expiry_date": expiryDateController.text.trim(),
      "cvv": cvvController.text.trim(),
    };

    print("Request Body: $requestBody");

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        print("Response: $data");

        // if (data.containsKey('message') &&
        //     data['message'] == 'Payment successful') {
        showSuccess('Payment Successful! Redirecting...');
        Future.delayed(const Duration(seconds: 2), () {
          if (context.mounted) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) {
                  return ViewCartItem(userId: userid!);
                },
              ),
            );
          }
        });
        // ViewCartItem
        // Navigator.push(
        //   context,
        //   MaterialPageRoute(
        //     builder: (context) {
        //       return ShopScreen(userId: userid!);
        //     },
        //   ),
        // );

        //  }
      } else {
        showError('Payment failed: ${response.body}');
      }
    } catch (e) {
      showError('Error: $e');
    }
  }

  Future<void> saveCardPaymentBuyNow(BuildContext context) async {
    final url = Uri.parse(
      'https://417sptdw-8001.inc1.devtunnels.ms/userapp/booking-payment/',
    );

    if (userid == null) {
      showError('User ID is missing.');
      return;
    }

    final String paymentOption = (selectPayMethod == "card") ? "card" : "cash";

    final Map<String, dynamic> requestBody = {
      "user_id": userid,
      "booking_id": bookingId,
      "total_amount": totalAmount,
      "payment_type": paymentOption,
      "card_holder_name": nameController.text.trim(),
      "card_number": cardNumberController.text.trim(),
      "expiry_date": expiryDateController.text.trim(),
      "cvv": cvvController.text.trim(),
    };

    print("Request Body: $requestBody");

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        print("Response: $data");

        if (data.containsKey('message') &&
            data['message'] == 'CARD payment created successfully') {
          showSuccess('Payment Successful! Redirecting...');

          Future.delayed(const Duration(seconds: 2), () {
            if (context.mounted) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) {
                    return ShopScreen(userId: userid!);
                  },
                ),
              );
            }
          });
        }
      } else {
        showError('Payment failed: ${response.body}');
      }
    } catch (e) {
      showError('Error: $e');
    }
  }

  void showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void showSuccess(String message) {
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
                        Image.asset('assets/images/atm-card.png', height: 60),
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
              const Text(
                "Card Details",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    _buildTextField(
                      nameController,
                      "Name on Card",
                      validator: (value) => (value == null || value.isEmpty)
                          ? 'Fill the field'
                          : null,
                    ),
                    const SizedBox(height: 15),
                    _buildTextField(
                      cardNumberController,
                      "Card Number",
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Enter card number';
                        }
                        if (value.length != 16 &&
                            !RegExp(r'^\d{16}$').hasMatch(value)) {
                          return 'Enter a valid 16-digit card number';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 15),
                    Row(
                      children: [
                        Expanded(
                          child: _buildTextField(
                            expiryDateController,
                            "Expiry Date",
                            keyboardType: TextInputType.datetime,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Enter expiry date";
                              }

                              // Must match MM/YY format
                              final regex = RegExp(r'^(0[1-9]|1[0-2])\/\d{2}$');
                              if (!regex.hasMatch(value)) {
                                return "Enter valid format MM/YY";
                              }

                              final parts = value.split('/');
                              final int month = int.parse(parts[0]);
                              final int year = int.parse("20${parts[1]}");

                              final now = DateTime.now();

                              // Create expiry date (last day of that month)
                              final expiryDate = DateTime(year, month + 1, 0);

                              if (expiryDate.isBefore(now)) {
                                return "Card has expired";
                              }

                              // Optional: prevent unrealistic future dates (like 2099)
                              if (year > now.year + 20) {
                                return "Enter valid expiry year";
                              }

                              return null;
                            },
                            // (value == null || value.isEmpty)
                            // ? 'Fill the field'
                            // : null,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _buildTextField(
                            cvvController,
                            "CVV",
                            obscureText: true,
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Enter CVV number';
                              }
                              if (value.length != 3 &&
                                  !RegExp(r'^\d{3}$').hasMatch(value)) {
                                return 'Enter a valid 3-digit CVV number';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
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
                    if (_formKey.currentState!.validate()) {
                      if (paymentChoice == 'cart_payment') {
                        saveCardPayment(context);
                      }
                      if (paymentChoice == 'booking_payment') {
                        saveCardPaymentBuyNow(context);
                      }
                    }
                  },
                  child: const Text(
                    "Pay",
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

  Widget _buildTextField(
    TextEditingController controller,
    String label, {
    bool obscureText = false,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
      validator: validator,
      // validator: (value) =>
      //     (value == null || value.isEmpty) ? 'Fill the field' : null,
    );
  }
}
