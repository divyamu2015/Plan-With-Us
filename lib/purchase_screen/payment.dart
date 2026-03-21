import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:house_construction_pro/purchase_screen/card_payment.dart';
import 'package:house_construction_pro/purchase_screen/cash_payment.dart';

class PaymentOpp extends StatefulWidget {
  const PaymentOpp({
    super.key,
    required this.totalPayment,
    this.userId,
    this.cartIds = const [],
    this.productId,
    this.bookingId,
    required this.paymentChoice,
  });

  final double totalPayment;
  final int? userId;
  final List<int?> cartIds;
  final int? productId;
  final int? bookingId;
  final String paymentChoice;

  @override
  State<PaymentOpp> createState() => _PaymentOppState();
}

class _PaymentOppState extends State<PaymentOpp> {
  String? selectedBank;
  String? selectedPaymentMethod;
  TextEditingController donationcontroller = TextEditingController();
  double totalAMount = 0.00;
  int? userId;
  int? wasteId;
  int? bookingId;
  List<int> cartIds = [];
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

  final List<Map<String, dynamic>> banks = [
    {
      'name': 'card',
      'label': 'Card Payment',
      'icon': Icons.credit_card_rounded,
      'desc': 'Visa, MasterCard, RuPay',
    },
    {
      'name': 'cash',
      'label': 'Cash Payment',
      'icon': Icons.payments_rounded,
      'desc': 'Pay directly on confirmation',
    },
  ];

  TextEditingController pricecontroller = TextEditingController();

  @override
  void initState() {
    super.initState();
    userId = widget.userId;
    totalAMount = widget.totalPayment;
    paymentChoice = widget.paymentChoice;
    bookingId = widget.bookingId;

    cartIds = widget.cartIds
        .where((id) => id != null)
        .map((id) => id!)
        .toList();

    selectedBank = banks.first['name'];
  }

  @override
  void dispose() {
    donationcontroller.dispose();
    pricecontroller.dispose();
    super.dispose();
  }

  void _continuePayment() {
    if (selectedBank == "card") {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CardPaymentPage(
            totalPayment: totalAMount,
            selectedPaymentMethod: selectedBank ?? "card",
            userId: userId,
            cartIds: cartIds,
            paymentChoice: paymentChoice,
            bookingId: bookingId,
          ),
        ),
      );
    } else if (selectedBank == "cash") {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CashPaymentPage(
            selectedPaymentMethod: selectedBank ?? "cash",
            userId: userId,
            cartIds: cartIds,
            totalAmount: totalAMount,
            bookingId: bookingId,
            paymentChoice: paymentChoice,
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please select a payment method"),
        ),
      );
    }
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
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: Icon(
            Icons.arrow_back,
            size: 22.sp,
            color: kText,
          ),
        ),
        title: Text(
          "Payment Option",
          style: TextStyle(
            fontSize: 20.sp,
            color: kText,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 8.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // SizedBox(height: 6.h),

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

              Center(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 14.h),
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
                      Text(
                        "Amount Payable",
                        style: TextStyle(
                          color: kSubText,
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 10.h),
                      Text(
                        "₹${totalAMount.toStringAsFixed(2)}",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: kGoldSoft,
                          fontSize: 52.sp,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'Serif',
                          height: 1,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 34.h),
               SizedBox(height: 34.h),

              Text(
                "Choose your transaction method",
                style: TextStyle(
                  color: kSubText,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),

              SizedBox(height: 14.h),

              ...banks.map((bank) {
                final bool isSelected = selectedBank == bank['name'];

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedBank = bank['name'];
                      selectedPaymentMethod = null;
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    margin: EdgeInsets.only(bottom: 14.h),
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 14.h,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected ? kCard2 : kCard,
                      borderRadius: BorderRadius.circular(22.r),
                      border: Border.all(
                        color: isSelected
                            ? kGold.withOpacity(0.75)
                            : kBorder,
                        width: isSelected ? 1.2 : 1,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: kGold.withOpacity(0.08),
                                blurRadius: 18,
                                spreadRadius: 1,
                              ),
                            ]
                          : null,
                    ),
                    child: Row(
                      children: [
                        Container(
                          height: 46.h,
                          width: 46.w,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? kGold.withOpacity(0.12)
                                : Colors.white.withOpacity(0.04),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isSelected
                                  ? kGold.withOpacity(0.4)
                                  : kBorder,
                            ),
                          ),
                          child: Icon(
                            bank['icon'] as IconData,
                            color: isSelected ? kGold : kSubText,
                            size: 22.sp,
                          ),
                        ),
                        SizedBox(width: 14.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                bank['label'] as String,
                                style: TextStyle(
                                  color: kText,
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              SizedBox(height: 4.h),
                              Text(
                                bank['desc'] as String,
                                style: TextStyle(
                                  color: kSubText,
                                  fontSize: 12.sp,
                                ),
                              ),
                            ],
                          ),
                        ),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 220),
                          height: 24.h,
                          width: 24.w,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isSelected ? kGold : kMuted,
                              width: 1.5,
                            ),
                            color: isSelected ? kGold : Colors.transparent,
                          ),
                          child: isSelected
                              ? Icon(
                                  Icons.check,
                                  color: Colors.black,
                                  size: 15.sp,
                                )
                              : null,
                        ),
                      ],
                    ),
                  ),
                );
              }),

              const Spacer(),

              SizedBox(
                width: double.infinity,
                height: 56.h,
                child: ElevatedButton(
                  onPressed: _continuePayment,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kGold,
                    foregroundColor: Colors.black,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(22.r),
                    ),
                  ),
                  child: Text(
                    'Confirm Payment',
                    style: TextStyle(
                      fontSize: 17.sp,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),

              SizedBox(height: 10.h),
            ],
          ),
        ),
      ),
    );
  }
}