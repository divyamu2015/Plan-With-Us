import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:house_construction_pro/constant_page.dart';
import 'package:house_construction_pro/screen/user_screen/home_page/home_page_view.dart';
import 'package:house_construction_pro/screen/user_screen/house_details/bloc/property_input_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class PropertyInputPage extends StatefulWidget {
  const PropertyInputPage({
    super.key,
    required this.userId,
    //required this.engineerId
  });
  final int userId;
  //final int engineerId;

  @override
  State<PropertyInputPage> createState() => _PropertyInputPageState();
}

class _PropertyInputPageState extends State<PropertyInputPage> {
  List<Map<String, dynamic>> categoryItems = [];
  String? selectedCategory;
  bool isLoading = false;
  int? userId;
  int? engineerId;
  final GlobalKey<FormState> _formkey = GlobalKey<FormState>();
  final TextEditingController sqrftController = TextEditingController();
  final TextEditingController centController = TextEditingController();
  final TextEditingController amountController = TextEditingController();
  int? cateId;
  int? requestId;
  bool hasSubmitted = false;

  @override
  void initState() {
    super.initState();
    fetchCategoryItems();

    userId = widget.userId;
    centController.addListener(_updateSquareFeet);
  }

  void _updateSquareFeet() {
    final centText = centController.text;
    final cent = double.tryParse(centText);
    if (cent != null) {
      final sqfeet = cent * 435.56;
      sqrftController.text = sqfeet.toStringAsFixed(2);
    } else {
      sqrftController.text = '';
    }
  }

  @override
  void dispose() {
    centController.removeListener(_updateSquareFeet);
    centController.dispose();
    sqrftController.dispose();
    amountController.dispose();
    super.dispose();
  }

  Future<void> fetchCategoryItems() async {
    final response = await http.get(Uri.parse(Urlss.propertyItemCategory));
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      if (!mounted) return;
      setState(() {
        categoryItems = data
            .map((value) => value as Map<String, dynamic>)
            .toList();
      });
    } else {
      throw Exception('Failed to Load Category');
    }
  }

  Future<void> submitDetails() async {
    if (isLoading || hasSubmitted) return; // Check both flags
    if (!mounted) return;
    FocusScope.of(context).unfocus();
    if (_formkey.currentState!.validate() && selectedCategory != null) {
      setState(() {
        isLoading = true;
        hasSubmitted = true;
      });

      context.read<PropertyInputBloc>().add(
        PropertyInputEvent.propertySub(
          userId: userId!,
          sgft: double.parse(sqrftController.text),
          cent: double.parse(centController.text),
          amount: double.parse(amountController.text),
          category: int.parse(selectedCategory!),
        ),
      );
    }
  }

  Future<void> setCategoryId(int catId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('categoryId', catId);
  }

  Future<int?> getCategoryId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getInt('categoryId');
  }

  Future<void> storeRequestId(int requestId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('request_id', requestId);
  }

  Future<int?> getRequestId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    requestId = prefs.getInt('request_id');
    return requestId;
  }

  @override
  Widget build(BuildContext context) {
    final centText = centController.text.isNotEmpty ? centController.text : '0';
    final sqftText = sqrftController.text.isNotEmpty
        ? sqrftController.text
        : '0';
    final amountText = amountController.text.isNotEmpty
        ? amountController.text
        : '0';
    double h = MediaQuery.of(context).size.height;
    double w = MediaQuery.of(context).size.width;

    return SafeArea(
      child: Scaffold(
        // New pastel gradient AppBar colors
        appBar: AppBar(
          leading: IconButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            icon: Icon(Icons.arrow_back,color: Colors.white),
          ),
          title:  Text(
            'Property Details',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22,color: Colors.white),
          ),
          centerTitle: true,
          elevation: 8,
          backgroundColor:  Color(0xFF221F10),
          flexibleSpace: Container(
            // decoration: const BoxDecoration(
            //   gradient: LinearGradient(
            //     colors: [
            //       Color.fromARGB(255, 241, 222, 179),
            //       Color.fromARGB(255, 236, 208, 148),
            //       Color.fromARGB(255, 241, 220, 175),
            //     ],
            //     begin: Alignment.topLeft,
            //     end: Alignment.bottomRight,
            //   ),
            // ),
          ),
          // shadowColor: const Color.fromARGB(
          //   255,
          //   110,
          //   110,
          //   109,
          // ).withOpacity(0.5),
        ),
        body: BlocConsumer<PropertyInputBloc, PropertyInputState>(
          listener: (context, state) {
            state.when(
              initial: () {},
              loading: () => setState(() => isLoading = true),
              success: (response) async {
                if (response.requestId != null) {
                  await storeRequestId(response.requestId!);
                  requestId = await getRequestId();
                }
                if (response.matchedWorks.isNotEmpty) {
                  final work = response.matchedWorks.first;
                }
                setState(() => isLoading = false);

                SharedPreferences prefs = await SharedPreferences.getInstance();
                await prefs.setBool('isPropertySubmitted_$userId', true);
                //  await storeRequestId(response.requestId!);

                // ignore: use_build_context_synchronously
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Property details submitted successfully!'),
                    backgroundColor: Colors.green,
                  ),
                );
                // if (selectedCat.isEmpty) {
                //   // Show error or handle missing category value
                //   return;
                // }

                if (selectedCategory != null) {
                  final selectedCat = int.parse(selectedCategory!);
                  // ignore: use_build_context_synchronously
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (context) => MyHomePage(
                        userId: userId!,
                        requestId: requestId,
                        catId: selectedCat,
                        cent: double.parse(centText),
                        sqft: double.parse(sqftText),
                        expectedAmount: double.parse(amountText),
                        engineerId: engineerId,
                      ),
                    ),
                  );
                  setState(() => isLoading = false);
                }
              },
              error: (error) {
                setState(() => isLoading = false);
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text('Error: $error')));
              },
            );
          },
          builder: (context, state) => Container(
            height: h,
            width: w,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF221F10), // background-dark
                  Color(0xFF221F10),
                  Color(0xFFF8F8F5), // background-light
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: Stack(
              children: [
                SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 30,
                    ),
                    child: Column(
                      children: [
                        Column(
                          children: [
                            Stack(
                              children: [
                                SizedBox(
                                  height: 260,
                                  width: double.infinity,
                                  child: Image.network(
                                    "https://lh3.googleusercontent.com/aida-public/AB6AXuDdeCi0fbPtqJKEIWHraHCzB2GfBlhZ7jzOMnA30SopHwvye0pIzaQ9fxPYyCxvQTOHbBkL2SsWAR1In2YgNS25aNo9T-KYEe16LOkOsgZPt-0XAuUITqJc25SDw3vaLisEvPMWMIJVZ8FJhhVOGppgoDmOC6TBD7ixaCi8lIljAKgSsZTR8yVbMktZcbEKtSm_FI44iMo9ggs1Nxjr8NwWFuf9qmU9-4N9LX0A24JAQiLpsP3Xsum8o2xLH214XlRrJBL02jNm848",
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                Container(
                                  height: 260,
                                  decoration: const BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.bottomCenter,
                                      end: Alignment.topCenter,
                                      colors: [
                                        Colors.black87,
                                        Colors.transparent,
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            // SizedBox(height: 10),
                          ],
                        ),

                        const SizedBox(height: 30),

                        /// FORM CARD
                        Container(
                          padding: const EdgeInsets.all(25),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(25),
                            color: Colors.white,
                            border: Border.all(
                              color: const Color(0xFFF2D00D).withOpacity(0.3),
                              width: 1.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.15),
                                blurRadius: 25,
                                offset: const Offset(0, 12),
                              ),
                            ],
                          ),

                          child: Form(
                            key: _formkey,
                            child: Column(
                              children: [
                                /// CATEGORY
                                DropdownButtonFormField<String>(
                                  validator: (value) =>
                                      (value == null || value.isEmpty)
                                      ? "Please Select Category"
                                      : null,
                                  decoration: InputDecoration(
                                    labelText: "🏠 Select Category",
                                    filled: true,
                                    fillColor: const Color(0xFFF8F8F5),
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 18,
                                      vertical: 16,
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(15),
                                      borderSide: BorderSide.none,
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(15),
                                      borderSide: const BorderSide(
                                        color: Color(0xFFF2D00D),
                                        width: 2,
                                      ),
                                    ),
                                  ),
                                  items: categoryItems
                                      .map(
                                        (item) => DropdownMenuItem<String>(
                                          value: item['id'].toString(),
                                          child: Text(
                                            item['name'],
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      )
                                      .toList(),
                                  onChanged: (value) {
                                    setState(() {
                                      selectedCategory = value;
                                    });
                                  },
                                ),

                                const SizedBox(height: 20),

                                /// CENT
                                TextFormField(
                                  keyboardType: TextInputType.number,
                                  controller: centController,
                                  validator: (value) =>
                                      (value == null || value.isEmpty)
                                      ? "Please enter Cent"
                                      : null,
                                  decoration: InputDecoration(
                                    labelText: "🗺️ Plot Size (Cent)",
                                    // prefixIcon: const Icon(Icons.landscape),
                                    filled: true,
                                    fillColor: const Color(0xFFF8F8F5),
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 18,
                                      vertical: 16,
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(15),
                                      borderSide: BorderSide.none,
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(15),
                                      borderSide: const BorderSide(
                                        color: Color(0xFFF2D00D),
                                        width: 2,
                                      ),
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 20),

                                /// SQFT
                                TextFormField(
                                  readOnly: true,
                                  controller: sqrftController,
                                  validator: (value) =>
                                      (value == null || value.isEmpty)
                                      ? "Please enter Square Feet"
                                      : null,
                                  decoration: InputDecoration(
                                    labelText: "📐 Square Feet",
                                    // prefixIcon: const Icon(Icons.square_foot),
                                    filled: true,
                                    fillColor: const Color(0xFFF8F8F5),
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 18,
                                      vertical: 16,
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(15),
                                      borderSide: BorderSide.none,
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(15),
                                      borderSide: const BorderSide(
                                        color: Color(0xFFF2D00D),
                                        width: 2,
                                      ),
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 20),

                                /// AMOUNT
                                TextFormField(
                                  keyboardType: TextInputType.number,
                                  controller: amountController,
                                  validator: (value) =>
                                      (value == null || value.isEmpty)
                                      ? "Please enter Amount"
                                      : null,
                                  decoration: InputDecoration(
                                    labelText: "💰 Expected Amount",
                                    // prefixIcon: const Icon(
                                    //   Icons.currency_rupee,
                                    // ),
                                    filled: true,
                                    fillColor: const Color(0xFFF8F8F5),
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 18,
                                      vertical: 16,
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(15),
                                      borderSide: BorderSide.none,
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(15),
                                      borderSide: const BorderSide(
                                        color: Color(0xFFF2D00D),
                                        width: 2,
                                      ),
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 30),

                                /// SUBMIT BUTTON
                                SizedBox(
                                  width: double.infinity,
                                  height: 55,
                                  child: ElevatedButton(
                                    onPressed: isLoading
                                        ? null
                                        : () {
                                            if (_formkey.currentState!
                                                .validate()) {
                                              submitDetails();
                                            }
                                          },
                                    style: ElevatedButton.styleFrom(
                                      elevation: 8,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(30),
                                      ),
                                     backgroundColor: const Color.fromARGB(255, 163, 148, 71),
                                    ),
                                    child: isLoading
                                        ? const CircularProgressIndicator(
                                            color: Colors.white,
                                          )
                                        :  Text(
                                            "Submit Property",
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              letterSpacing: 1,
                                              color: Colors.white
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
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
