// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:http/http.dart' as http;

// //import 'view_details_page.dart';

// // ignore: must_be_immutable
// class HistoryPage extends StatefulWidget {
//   HistoryPage({super.key, required this.userid});
//   int? userid;

//   @override
//   State<HistoryPage> createState() => _HistoryPageState();
// }

// class _HistoryPageState extends State<HistoryPage> {
//   List<Map<String, dynamic>> paymentHistory = [];
//   int? userId;
//   bool? isCompleted;
//   bool? isNotCompleted;
//   String? status;
//   //  bool isCompleted = payment['status'] == 'Completed';
//   // bool isNotCompleted=payment['status'] == 'pending';

//   @override
//   void initState() {
//     super.initState();
//     userId = widget.userid;
//     getDetails();
//   }

//   Future<void> getDetails() async {
//     try {
//       if (userId == null) return;

//       final String apiUrl =
//           'https://417sptdw-8001.inc1.devtunnels.ms/userapp/user/bookings/$userId/';
//       final response = await http.get(Uri.parse(apiUrl));

//       if (response.statusCode == 200) {
//         List<dynamic> jsonData = jsonDecode(response.body);
//         setState(() {
//           paymentHistory = jsonData
//               .map((data) => {
//                     'id': data["id"],
//                     'date': data['date'],
//                     'time': data['time'],
//                     'total_price': data['total_price'],
//                     'waste': data['waste'].join(', '),
//                     //'kilogram': data['kilogram'].join(', '),
//                     'status': data['status'],
//                     'payment_status': data['payment_status'],
//                   })
//               .toList();
//         });
//       } else {
//         print("Failed to load data. Status code: ${response.statusCode}");
//       }
//     } catch (e) {
//       print("Error: $e");
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: const Color.fromARGB(255, 11, 53, 12),
//         title: Text(
//           "My Booking History",
//           style: TextStyle(fontSize: 20.sp, color: Colors.white),
//         ),
//         centerTitle: true,
//         leading: IconButton(
//           onPressed: () async {
//             await getDetails(); // Ensure data is fetched before proceeding

//             if (paymentHistory.isNotEmpty) {
//               bool hasCompleted = paymentHistory
//                   .any((payment) => payment['status'] == 'Completed');
//               bool hasNotCompleted = paymentHistory
//                   .any((payment) => payment['status'] == 'pending');

//               String latestStatus =
//                   paymentHistory.first['status']; // Get latest status

//               Navigator.pushReplacement(
//                 context,
//                 MaterialPageRoute(
//                   builder: (context) => HomePage(
//                     isCompleted: hasCompleted,
//                     isNotCompleted: hasNotCompleted,
//                     status: latestStatus, // Pass the current status
//                     userId: userId,
//                   ),
//                 ),
//               );
//             }
//           },
//           icon: Icon(Icons.arrow_back, size: 20.sp, color: Colors.white),
//         ),
//       ),
//       body: Padding(
//         padding: EdgeInsets.all(16.w),
//         child: ListView.builder(
//           itemCount: paymentHistory.length,
//           itemBuilder: (context, index) {
//             final payment = paymentHistory[index];
//             return Card(
//               elevation: 8,
//               margin: EdgeInsets.only(bottom: 16.h),
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(16.r),
//               ),
//               child: Padding(
//                 padding: EdgeInsets.all(20.w),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         Text(
//                           "Date: ${payment['date']}",
//                           style: TextStyle(
//                               fontSize: 16.sp, fontWeight: FontWeight.bold),
//                         ),
//                         Text(
//                           "Time: ${payment['time']}",
//                           style: TextStyle(
//                               fontSize: 16.sp,
//                               color: Colors.black,
//                               fontWeight: FontWeight.bold),
//                         ),
//                       ],
//                     ),
//                     SizedBox(height: 10.h),
//                     Text(
//                       "Waste: ${payment['waste']}",
//                       style: TextStyle(fontSize: 16.sp, color: Colors.black),
//                     ),
//                     SizedBox(height: 10.h),
//                     // Text(
//                     //   "Kilogram: ${payment['kilogram']}",
//                     //   style: TextStyle(fontSize: 16.sp, color: Colors.black),
//                     // ),
//                     // SizedBox(height: 10.h),
//                     Text(
//                       "Total Amount: \$${payment['total_price']}",
//                       style: TextStyle(
//                         fontSize: 16.sp,
//                         color: payment['payment_status'] == 'cash'
//                             ? Colors.red
//                             : Colors.green,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                     SizedBox(height: 10.h),
//                     Text(
//                       "Status: ${payment['status']}",
//                       style: TextStyle(
//                         fontSize: 16.sp,
//                         color: payment['status'] == 'Completed'
//                             ? Colors.green
//                             : Colors.orange,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                     SizedBox(height: 10.h),
//                     Text(
//                       "Payment: ${payment['payment_status']}",
//                       style: TextStyle(
//                         fontSize: 16.sp,
//                         color: payment['payment_status'] == 'Not Paid'
//                             ? Colors.red
//                             : Colors.green,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                     SizedBox(height: 25.h),
//                     Center(
//                       child: ElevatedButton.icon(
//                         onPressed: () async {
//                           final result =
//                               await Navigator.push(context, MaterialPageRoute(
//                             builder: (context) {
//                               return ReschedulePage(
//                                 wasteId: payment['id'],
//                                 userId: userId!,
//                                 wasteName: payment['waste'],
//                                 amount: double.parse(
//                                     payment['total_price'].toString()),
//                               );
//                             },
//                           ));
//                           if (result == true) {
//                             setState(() {});
//                           }
//                         },
//                         label: const Text('Reschedule'),
//                         icon: const Icon(Icons.replay_outlined),
//                       ),
//                     )
//                     // SizedBox(height: 12.h),
//                     // SizedBox(
//                     //   width: double.infinity,
//                     //   height: 40.h,
//                     //   child: ElevatedButton(
//                     //     onPressed: () {
//                     //       Navigator.push(context, MaterialPageRoute(
//                     //         builder: (context) {
//                     //           return const ViewdetailsHistory();
//                     //         },
//                     //       ));
//                     //     },
//                     //     style: ElevatedButton.styleFrom(
//                     //       shape: RoundedRectangleBorder(
//                     //         borderRadius: BorderRadius.circular(8.r),
//                     //       ),
//                     //       backgroundColor: Colors.blue,
//                     //     ),
//                     //     child: Text(
//                     //       'View Details',
//                     //       style:
//                     //           TextStyle(fontSize: 14.sp, color: Colors.white),
//                     //     ),
//                     //   ),
//                     // ),
//                   ],
//                 ),
//               ),
//             );
//           },
//         ),
//       ),
//     );
//   }
// }
