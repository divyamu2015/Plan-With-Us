import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:house_construction_pro/purchase_screen/view_product_home/view_product_screen.dart';
import 'package:http/http.dart' as http;

class CashPaymentPage extends StatefulWidget {
  const CashPaymentPage({
    super.key,
    required this.selectedPaymentMethod,
    this.userId,
    this.bookingId,
    this.paymentChoice,
    required this.cartIds,
    required this.totalAmount,
  });

  final String selectedPaymentMethod;
  final int? userId;
  final List<int> cartIds;
  final double totalAmount;
  final int? bookingId;
  final String? paymentChoice;

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
    selectPayMethod = widget.selectedPaymentMethod;
    userId = widget.userId;
    cartIds = widget.cartIds;
    totalAmount = widget.totalAmount;
    bookingId = widget.bookingId;
    paymentChoice = widget.paymentChoice;
    super.initState();
  }

  Future<void> _showOrderDialog(BuildContext context) async {
    return showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.65),
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 22.w, vertical: 22.h),
          decoration: BoxDecoration(
            color: kCard2,
            borderRadius: BorderRadius.circular(28.r),
            border: Border.all(color: kGold.withOpacity(0.16)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.45),
                blurRadius: 30,
                offset: const Offset(0, 16),
              ),
              BoxShadow(
                color: kGold.withOpacity(0.05),
                blurRadius: 24,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                height: 58.h,
                width: 58.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: kGold.withOpacity(0.12),
                  border: Border.all(color: kGold.withOpacity(0.22)),
                ),
                child: Icon(
                  Icons.check,
                  color: kGold,
                  size: 30.sp,
                ),
              ),
              SizedBox(height: 16.h),
              Text(
                "Order Status",
                style: TextStyle(
                  color: kText,
                  fontSize: 22.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: 10.h),
              Text(
                "Your order has been successfully confirmed.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: kSubText,
                  fontSize: 14.sp,
                  height: 1.5,
                ),
              ),
              SizedBox(height: 22.h),
              SizedBox(
                width: double.infinity,
                height: 50.h,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kGold,
                    foregroundColor: Colors.black,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18.r),
                    ),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                    Future.delayed(const Duration(milliseconds: 250), () {
                      if (mounted) {
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
                  child: Text(
                    "Continue",
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _saveCashPayment(BuildContext context) async {
    if (userId == null) {
      showError('User ID is missing.');
      return;
    }

    final String paymentOption =
        (selectPayMethod == "cash") ? "cash" : "card_payment";

    final Map<String, dynamic> requestBody = {
      "user_id": userId,
      "cart_ids": cartIds,
      "payment_choice": paymentChoice,
      "payment_type": paymentOption,
      "total_amount": totalAmount.toString(),
    };

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

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);

        if (data.containsKey('status') && data['status'] == "success") {
          showSuccess("Payment Successful! Redirecting...");
          Future.delayed(const Duration(seconds: 1), () {
            if (mounted) {
              _showOrderDialog(context);
            }
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

  Future<void> _saveCashSinglePayment(BuildContext context) async {
    if (userId == null) {
      showError('User ID is missing.');
      return;
    }

    final String paymentOption =
        (selectPayMethod == "cash") ? "cash" : "card_payment";

    final Map<String, dynamic> requestBody = {
      "user_id": userId,
      "booking_id": bookingId,
      "payment_choice": paymentChoice,
      "payment_type": paymentOption,
      "total_amount": totalAmount.toString(),
    };

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

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        if (data.containsKey('status') && data['status'] == "success") {
          showSuccess("Payment Successful! Redirecting...");
          Future.delayed(const Duration(seconds: 1), () {
            if (mounted) {
              _showOrderDialog(context);
            }
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
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void showSuccess(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
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
      body: SafeArea(
        child: Padding(
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
                  color: kGold.withOpacity(0.75),
                ),
              ),

              SizedBox(height: 34.h),

              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
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
                    color: kGold.withOpacity(0.18),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.38),
                      blurRadius: 28,
                      offset: const Offset(0, 16),
                    ),
                    BoxShadow(
                      color: kGold.withOpacity(0.04),
                      blurRadius: 30,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Container(
                      height: 76.h,
                      width: 76.w,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: kGold.withOpacity(0.10),
                        border: Border.all(
                          color: kGold.withOpacity(0.24),
                        ),
                      ),
                      child: Icon(
                        Icons.payments_rounded,
                        color: kGold,
                        size: 38.sp,
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
                        '₹${(totalAmount ?? 0).toStringAsFixed(2)}',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: kGoldSoft,
                          fontSize: 56.sp,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'Serif',
                          height: 1,
                        ),
                      ),
                    ),
                    SizedBox(height: 14.h),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 14.w,
                        vertical: 8.h,
                      ),
                      decoration: BoxDecoration(
                        color: kCard2,
                        borderRadius: BorderRadius.circular(18.r),
                        border: Border.all(color: kBorder),
                      ),
                      child: Text(
                        "Cash Payment",
                        style: TextStyle(
                          color: kText,
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 26.h),

              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 18.h),
                decoration: BoxDecoration(
                  color: kCard,
                  borderRadius: BorderRadius.circular(24.r),
                  border: Border.all(color: kBorder),
                ),
                child: Row(
                  children: [
                    Container(
                      height: 46.h,
                      width: 46.w,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: kGold.withOpacity(0.10),
                        border: Border.all(
                          color: kGold.withOpacity(0.22),
                        ),
                      ),
                      child: Icon(
                        Icons.info_outline,
                        color: kGold,
                        size: 22.sp,
                      ),
                    ),
                    SizedBox(width: 14.w),
                    Expanded(
                      child: Text(
                        "Your order will be confirmed with cash payment selection.",
                        style: TextStyle(
                          color: kSubText,
                          fontSize: 13.sp,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(),

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
                    if (paymentChoice == 'cart_payment') {
                      _saveCashPayment(context);
                    } else if (paymentChoice == 'booking_payment') {
                      _saveCashSinglePayment(context);
                    }
                  },
                  child: Text(
                    "Continue",
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
      ),
    );
  }
}