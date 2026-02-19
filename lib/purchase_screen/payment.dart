// usermainpage/payment_page.dart
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

    //  required this.wasteSubId
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
  // Dummy bank data with image paths
  final List<Map<String, String>> banks = [
    {'name': 'card', 'image': 'assets/images/atm-card.png'},
    {'name': 'cash', 'image': 'assets/images/payment.png'},
  ];
  TextEditingController pricecontroller = TextEditingController();
  @override
  void initState() {
    super.initState();
    userId = widget.userId;
    totalAMount = widget.totalPayment;
    paymentChoice = widget.paymentChoice;
    bookingId = widget.bookingId;
    print("bookingId===$bookingId");
      print("paymentChoice paymentChoice===$paymentChoice");
    cartIds = widget.cartIds
        .where((id) => id != null)
        .map((id) => id!)
        .toList();

    selectedBank = banks.first['name'];
    print('Payment ======== $totalAMount');
    print("Payment cartIds...$cartIds");
    print('CartPaymentStatus===$paymentChoice');
  }

  @override
  Widget build(BuildContext context) {
    // Initialize ScreenUtil
    ScreenUtil.init(
      context,
      designSize: const Size(375, 812), // Set this to your design's size
      minTextAdapt: true,
    );

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          "Payment Option",
          style: TextStyle(
            fontSize: 18.sp, // Responsive font size
            color: Colors.black,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: Icon(
            Icons.arrow_back,
            size: 20.sp, // Responsive icon size
            color: Colors.black,
          ),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.w), // Responsive padding
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: pricecontroller,
              textAlign: TextAlign.center,
              keyboardType: TextInputType.number, // Numeric keyboard for amount
              decoration: InputDecoration(
                border: InputBorder.none,
                label: Center(
                  child: Text(
                    '₹$totalAMount',
                    style: TextStyle(fontSize: 70.sp),
                  ),
                ),
                // hintText: '₹0',
              ),
              // Responsive text style
            ),
            SizedBox(height: 20.h),
            const Spacer(),
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(
                  10.r,
                ), // Responsive border radius
              ),
              child: Padding(
                padding: EdgeInsets.all(16.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Choose Your transaction method",
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    ),
                    SizedBox(height: 15.h),
                    DropdownButtonFormField<String>(
                      initialValue:
                          selectedBank, // Set the default selected bank
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 10.w,
                          vertical: 12.h,
                        ),
                      ),
                      items: banks.map((bank) {
                        return DropdownMenuItem<String>(
                          value: bank['name'],
                          child: Row(
                            children: [
                              Image.asset(
                                bank['image']!,
                                width: 30.w,
                                height: 30.h,
                              ),
                              SizedBox(width: 10.w),
                              Text(
                                bank['name']!,
                                style: TextStyle(fontSize: 14.sp),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          selectedBank = newValue;
                          selectedPaymentMethod =
                              null; // Reset payment method on bank change
                        });
                      },
                    ),
                    SizedBox(height: 20.h),
                    if (selectedBank != null) ...[
                      // Add any additional UI elements based on selectedBank if needed
                    ],
                    SizedBox(height: 20.h),
                    SizedBox(
                      width: double.infinity,
                      height: 50.h,
                      child: ElevatedButton(
                        onPressed: () async {
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
                                  // wasteId: wasteId,
                                ),
                              ),
                            );
                            // print(selectedPaymentMethod);
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

                              //  CashPaymentPage(
                              //      // totalPayment: totalAMount,
                              //       // selectedPaymentMethod:
                              //       //     selectedBank ?? "cash",
                              //       // userId: userId,
                              //       // wasteId: wasteId,
                              //     )),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Please select a payment method"),
                              ),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                          backgroundColor: Colors.red,
                        ),
                        child: Text(
                          'Confirm Payment',
                          style: TextStyle(
                            fontSize: 16.sp,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
