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
  List<int> cartIds = [];
  String? paymentChoice;
  int? bookingId;

  static const Color kBg = Color(0xFF050505);
  static const Color kCard = Color(0xFF0D0D0D);
  static const Color kCard2 = Color(0xFF151515);
  static const Color kGold = Color(0xFFD4AF37);
  static const Color kGoldSoft = Color(0xFFE7C65A);
  static const Color kText = Color(0xFFF5F1E8);
  static const Color kSubText = Color(0xFFA4A099);
  static const Color kMuted = Color(0xFF6E675D);
  static const Color kBorder = Color(0xFF2A2316);

  @override
  void initState() {
    super.initState();
    totalAmount = widget.totalPayment;
    selectPayMethod = widget.selectedPaymentMethod;
    userid = widget.userId;
    cartIds = widget.cartIds;
    paymentChoice = widget.paymentChoice;
    bookingId = widget.bookingId;
  }

  @override
  void dispose() {
    cardNumberController.dispose();
    nameController.dispose();
    expiryDateController.dispose();
    cvvController.dispose();
    super.dispose();
  }

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

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
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

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);

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

  InputDecoration _inputDecoration({
    required String label,
    Widget? prefixIcon,
  }) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(
        color: kSubText,
        fontSize: 14.sp,
      ),
      prefixIcon: prefixIcon,
      prefixIconColor: kGold,
      filled: true,
      fillColor: kCard2,
      contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 18.h),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18.r),
        borderSide: BorderSide(color: kBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18.r),
        // ignore: deprecated_member_use
        borderSide: BorderSide(color: kGold.withOpacity(0.9), width: 1.2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18.r),
        borderSide: const BorderSide(color: Colors.red),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18.r),
        borderSide: const BorderSide(color: Colors.red),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label, {
    bool obscureText = false,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    Widget? prefixIcon,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      style: TextStyle(
        color: kText,
        fontSize: 15.sp,
        fontWeight: FontWeight.w500,
      ),
      decoration: _inputDecoration(
        label: label,
        prefixIcon: prefixIcon,
      ),
      validator: validator,
    );
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(
      context,
      designSize: const Size(375, 812),
      minTextAdapt: true,
    );

    return Scaffold(
      backgroundColor: kBg,
      appBar: AppBar(
        backgroundColor: kBg,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: Icon(
            Icons.arrow_back,
            color: kText,
            size: 22.sp,
          ),
        ),
        title: Text(
          'Pay Invoice',
          style: TextStyle(
            color: kText,
            fontSize: 20.sp,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(18.w, 8.h, 18.w, 22.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 4.h),

            // Center(
            //   child: Text(
            //     "ENGINEERED EXCELLENCE",
            //     style: TextStyle(
            //       color: kGold,
            //       fontSize: 9.sp,
            //       fontWeight: FontWeight.w700,
            //       letterSpacing: 2.4,
            //     ),
            //   ),
            // ),

            // SizedBox(height: 10.h),

            // Center(
            //   child: Text(
            //     "THE CURATED\nCOLLECTION",
            //     textAlign: TextAlign.center,
            //     style: TextStyle(
            //       color: kText,
            //       fontSize: 28.sp,
            //       fontWeight: FontWeight.w500,
            //       height: 0.95,
            //       fontFamily: 'Serif',
            //     ),
            //   ),
            // ),

            // SizedBox(height: 12.h),

            Center(
              child: Container(
                width: 70.w,
                height: 1.2,
                // ignore: deprecated_member_use
                color: kGold.withOpacity(0.75),
              ),
            ),

            SizedBox(height: 28.h),

            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 22.h),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(28.r),
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF101010),
                    Color(0xFF080808),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                border: Border.all(
                  // ignore: deprecated_member_use
                  color: kGold.withOpacity(0.18),
                ),
                boxShadow: [
                  BoxShadow(
                    // ignore: deprecated_member_use
                    color: Colors.black.withOpacity(0.38),
                    blurRadius: 28,
                    offset: const Offset(0, 16),
                  ),
                  BoxShadow(
                    // ignore: deprecated_member_use
                    color: kGold.withOpacity(0.04),
                    blurRadius: 30,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    height: 72.h,
                    width: 72.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      // ignore: deprecated_member_use
                      color: kGold.withOpacity(0.10),
                      border: Border.all(
                        // ignore: deprecated_member_use
                        color: kGold.withOpacity(0.25),
                      ),
                    ),
                    child: Icon(
                      Icons.credit_card_rounded,
                      color: kGold,
                      size: 34.sp,
                    ),
                  ),
                  SizedBox(height: 18.h),
                  Text(
                    "Payment Amount",
                    style: TextStyle(
                      color: kSubText,
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 10.h),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      '₹${totalAmount.toStringAsFixed(2)}',
                      style: TextStyle(
                        color: kGoldSoft,
                        fontSize: 54.sp,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'Serif',
                        height: 1,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 28.h),

            Text(
              "Card Details",
              style: TextStyle(
                fontSize: 22.sp,
                fontWeight: FontWeight.w700,
                color: kText,
              ),
            ),

            SizedBox(height: 14.h),

            Form(
              key: _formKey,
              child: Column(
                children: [
                  _buildTextField(
                    nameController,
                    "Name on Card",
                    prefixIcon: Icon(Icons.person_outline, size: 20.sp),
                    validator: (value) =>
                        (value == null || value.isEmpty) ? 'Fill the field' : null,
                  ),
                  SizedBox(height: 14.h),
                  _buildTextField(
                    cardNumberController,
                    "Card Number",
                    keyboardType: TextInputType.number,
                    prefixIcon: Icon(Icons.credit_card, size: 20.sp),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Enter card number';
                      }
                      if (value.length != 16 ||
                          !RegExp(r'^\d{16}$').hasMatch(value)) {
                        return 'Enter a valid 16-digit card number';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 14.h),
                  Row(
                    children: [
                      Expanded(
                        child: _buildTextField(
                          expiryDateController,
                          "Expiry Date",
                          keyboardType: TextInputType.datetime,
                          prefixIcon: Icon(Icons.calendar_month, size: 20.sp),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Enter expiry date";
                            }

                            final regex = RegExp(r'^(0[1-9]|1[0-2])\/\d{2}$');
                            if (!regex.hasMatch(value)) {
                              return "Enter valid format MM/YY";
                            }

                            final parts = value.split('/');
                            final int month = int.parse(parts[0]);
                            final int year = int.parse("20${parts[1]}");

                            final now = DateTime.now();
                            final expiryDate = DateTime(year, month + 1, 0);

                            if (expiryDate.isBefore(now)) {
                              return "Card has expired";
                            }

                            if (year > now.year + 20) {
                              return "Enter valid expiry year";
                            }

                            return null;
                          },
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: _buildTextField(
                          cvvController,
                          "CVV",
                          obscureText: true,
                          keyboardType: TextInputType.number,
                          prefixIcon: Icon(Icons.lock_outline, size: 20.sp),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Enter CVV number';
                            }
                            if (value.length != 3 ||
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

            SizedBox(height: 26.h),

            SizedBox(
              width: double.infinity,
              height: 56.h,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: kGold,
                  foregroundColor: Colors.black,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(22.r),
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
                child: Text(
                  "Pay Securely",
                  style: TextStyle(
                    fontSize: 17.sp,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}