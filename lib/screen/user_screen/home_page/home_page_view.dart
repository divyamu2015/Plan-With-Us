import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:house_construction_pro/authantication/user_authentication/login_screen/login_view_page.dart';
import 'package:house_construction_pro/constant_page.dart';
import 'package:house_construction_pro/screen/user_screen/home_page/home_page_model.dart';
import 'package:house_construction_pro/screen/user_screen/home_page/home_page_service.dart';
import 'package:house_construction_pro/screen/user_screen/suggestion.dart';
import 'package:house_construction_pro/screen/user_screen/view_engineers/view_engineers.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class MyHomePage extends StatefulWidget {
  final int? userId;
  final int? catId;
  final double? cent;
  final double? sqft;
  final double? expectedAmount;
  final int? engineerId;
  final int? requestId;

  const MyHomePage({
    super.key,
    this.userId,
    this.catId,
    this.cent,
    this.sqft,
    this.expectedAmount,
    this.engineerId,
    this.requestId,
  });

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late Future<HouseSearchModel> houseSearchFuture;
  bool isPredicting = false;
  final int _bottomNavIndex = 0; // Default index of the first screen
  int? engineerId;
  int? requestId;
  int? userId;
  int? workId;
  Future<void> predictHouse(workId) async {
    setState(() => isPredicting = true);

    try {
      // print("predictHousesss: $requestId");
      final response = await http.post(
        Uri.parse(Urlss.getSuggestion),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "sqft": widget.sqft,
          "cent": widget.cent,
          "budget": widget.expectedAmount,
          "category_id": widget.catId,
        }),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        // ignore: use_build_context_synchronously
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) {
              return MaterialBudgetSuggestionPage(
                prediction: data,
                requestId: requestId!,
              );
            },
          ),
        );
      } else {
        ScaffoldMessenger.of(
          // ignore: use_build_context_synchronously
          context,
        ).showSnackBar(SnackBar(content: Text("Error: ${response.body}")));
      }
    } catch (e) {
      ScaffoldMessenger.of(
        // ignore: use_build_context_synchronously
        context,
      ).showSnackBar(SnackBar(content: Text("Failed: $e")));
    } finally {
      setState(() => isPredicting = false);
    }
  }

  @override
  void initState() {
    super.initState();
    engineerId = widget.engineerId;
    userId = widget.userId;
    requestId = widget.requestId;
    print("userId in home page: $requestId");
    houseSearchFuture = fetchHouseSearch(
      userId: widget.userId!,
      category: widget.catId!,
      cent: widget.cent!,
      sqft: widget.sqft!,
      expectedAmount: widget.expectedAmount!,
    );
  }

  Future<void> _showLogoutDialog(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Logout Alert"),
        content: const Text("Are you sure you want to logout?"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close dialog (No)
            },
            child: const Text("No"),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close dialog first
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => LoginScreen()),
              ); // Navigate to login (Yes)
            },
            child: const Text(
              "Yes, Logout",
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> storeUserId(int workId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('id', workId);
    print('User ID stored: $workId');
  }

  Future<int?> getUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    workId = prefs.getInt('id');
    print("Retrieved User ID: $workId");
    return workId;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: Container(
        color: const Color(0xFF1a0f0a),
        // decoration: BoxDecoration(
        //   gradient: LinearGradient(
        //     colors: [
        //       // Colors.white,
        //       Colors.red[50]!,
        //       Colors.red[100]!,
        //       Colors.red[50]!, // Color.fromARGB(255, 241, 181, 196),
        //     ],
        //     begin: Alignment.topLeft,
        //     end: Alignment.bottomRight,
        //   ),
        // ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.arrow_back_ios,
                        color: Color(0xFFF5F0E6),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                    const Expanded(
                      child: Center(
                        child: Text(
                          "MATCHED ESTATES",
                          style: TextStyle(
                            color: Color(0xFFF5F0E6),
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                    // const Icon(Icons.search, color: Color(0xFFF5F0E6))
                  ],
                ),
              ),
              Expanded(
                child: FutureBuilder<HouseSearchModel>(
                  future: houseSearchFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(
                        child: Text(
                          "Error: ${snapshot.error}",
                          style: const TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      );
                    } else if (!snapshot.hasData ||
                        snapshot.data!.matchedWorks.isEmpty) {
                      return Center(
                        child: Text(
                          "No matching houses found",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      );
                    }
                    final works = snapshot.data!.matchedWorks;
                    return ListView.builder(
                      padding: const EdgeInsets.all(22),
                      itemCount: works.length,
                      itemBuilder: (context, index) {
                        final work = works[index];

                        return Container(
                          margin: const EdgeInsets.only(bottom: 20),
                          decoration: BoxDecoration(
                            color: const Color(0xFF2d1b12),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.white10),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(.4),
                                blurRadius: 10,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),

                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              /// IMAGE (UPDATED)
                              AspectRatio(
                                aspectRatio: 1.40,
                                child: ClipRRect(
                                  borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(16),
                                  ),
                                  child: Stack(
                                    fit: StackFit.expand,
                                    children: [
                                      GestureDetector(
                                        onTap: () async {
                                          await storeUserId(work.id);
                                          predictHouse(work.id);
                                        },
                                        child: Hero(
                                          tag:
                                              "house_image_${work.propertyImage}_$index",
                                          child: FadeInImage.assetNetwork(
                                            placeholder:
                                                "assets/images/assimage.jpeg",
                                            image:
                                                "$imageUrl${work.propertyImage}",
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),

                                      /// TAP LABEL
                                      Positioned(
                                        bottom: 10,
                                        right: 10,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 10,
                                            vertical: 6,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.black.withOpacity(
                                              0.6,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                          child: const Row(
                                            children: [
                                              Icon(
                                                Icons.auto_awesome,
                                                color: Colors.amber,
                                                size: 16,
                                              ),
                                              SizedBox(width: 5),
                                              Text(
                                                "Tap for AI Suggestion",
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                              /// DETAILS
                              Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    /// MATCH LABEL
                                    // Row(
                                    //   mainAxisAlignment:
                                    //       MainAxisAlignment.spaceBetween,
                                    //   children: [
                                    //     const Text(
                                    //       "98% MATCH",
                                    //       style: TextStyle(
                                    //         color: Color(0xFFD4AF37),
                                    //         fontWeight: FontWeight.bold,
                                    //         letterSpacing: 1,
                                    //       ),
                                    //     ),
                                    //     const Icon(
                                    //       Icons.favorite_border,
                                    //       color: Colors.white70,
                                    //     ),
                                    //   ],
                                    // ),
                                    const SizedBox(height: 6),

                                    /// PROJECT NAME
                                    Text(
                                      "Project Name: ${work.projectName}",
                                      style: const TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFFF5F0E6),
                                      ),
                                    ),

                                    const SizedBox(height: 4),

                                    /// ENGINEER
                                    Text(
                                      "Engineer Name: ${work.engineer}",
                                      style: const TextStyle(
                                        color: Colors.white70,
                                      ),
                                    ),

                                    const SizedBox(height: 10),
                                    Text(
                                      "Total Amount: ${work.totalAmount}",
                                      style: const TextStyle(
                                        color: Colors.white70,
                                      ),
                                    ),

                                    /// TAGS
                                    const SizedBox(height: 10),
                                    Text(
                                      "Time Duration: ${work.timeDuration}",
                                      style: const TextStyle(
                                        color: Colors.white70,
                                      ),
                                    ),

                                    const SizedBox(height: 16),

                                    /// DETAILS BUTTON
                                    Align(
                                      alignment: Alignment.centerRight,
                                      child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color(
                                            0xFFD4AF37,
                                          ),
                                          foregroundColor: const Color(
                                            0xFF1a0f0a,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                        ),
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  ViewEngineersProfile(
                                                    engineerId: work.engineerId,
                                                    cent: work.cent,
                                                    workId: work.id,
                                                    userId: userId!,
                                                    requestId: requestId!,
                                                  ),
                                            ),
                                          );
                                        },
                                        child: const Text("View Details"),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
              // Padding(
              //   padding: const EdgeInsets.all(16.0),
              //   child: SizedBox(
              //     width: double.infinity,
              //     height: 50,
              //     child: ElevatedButton(
              //       onPressed: isPredicting ? null : predictHouse,
              //       style: ElevatedButton.styleFrom(
              //         backgroundColor: Colors.deepPurpleAccent,
              //         shape: RoundedRectangleBorder(
              //           borderRadius: BorderRadius.circular(16),
              //         ),
              //       ),
              //       child: isPredicting
              //           ? const CircularProgressIndicator(
              //               color: Colors.white,
              //               strokeWidth: 2,
              //             )
              //           : const Text(
              //               "View Suggestions",
              //               style: TextStyle(
              //                 fontSize: 18,
              //                 fontWeight: FontWeight.bold,
              //               ),
              //             ),
              //     ),
              //   ),
              // ),
            ],
          ),
        ),
      ),
    );
  }

  Widget infoChip(String label, Color bgColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: textColor,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
