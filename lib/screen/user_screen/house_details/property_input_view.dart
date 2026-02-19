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
            icon: Icon(Icons.arrow_back),
          ),
          title: const Text(
            'Property Details',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
          ),
          centerTitle: true,
          elevation: 8,
          backgroundColor: Colors.red[100],
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
          builder: (context, state) => SingleChildScrollView(
            child: Container(
              height: h,
              width: w,
              decoration: BoxDecoration(
                // gradient: LinearGradient(colors: [Colors.grey,
                // Colors.grey]),
                // //color: Colors.grey
                image: DecorationImage(
                  opacity: 0.3,
                  fit: BoxFit.cover,
                  image: AssetImage('assets/images/bck.JPG'),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.only(
                  left: 20,
                  right: 20,
                  top: 40,
                  bottom: 30,
                ),
                child: Form(
                  key: _formkey,
                  child: Column(
                    // mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      DropdownButtonFormField<String>(
                        validator: (value) => (value == null || value.isEmpty)
                            ? "Please Select Category"
                            : null,
                        decoration: InputDecoration(
                          labelText: 'Select Category',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),

                          // filled: true,
                          // fillColor: Color.fromARGB(255, 245, 230, 195),
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 16,
                            horizontal: 16,
                          ),
                        ),
                        items: categoryItems
                            .map(
                              (item) => DropdownMenuItem<String>(
                                value: item['id'].toString(),
                                child: Text(
                                  item['name'],
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    color: Color.fromARGB(255, 2, 2, 65),
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
                      const SizedBox(height: 25),
                      TextFormField(
                        keyboardType: TextInputType.number,
                        controller: centController,
                        validator: (value) => (value == null || value.isEmpty)
                            ? "Please enter Cent"
                            : null,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white70,
                          label: Text("Plot Size(cent)"),
                          // filled: true,
                          // fillColor: Color.fromARGB(255, 245, 230, 195),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: const BorderSide(
                              color: Color.fromARGB(255, 2, 2, 65),
                            ),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 16,
                          ),
                        ),
                        style: const TextStyle(
                          color: Color(0xFF4A148C),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 22),
                      TextFormField(
                        readOnly: true,
                        controller: sqrftController,
                        validator: (value) => (value == null || value.isEmpty)
                            ? "Please enter Square Feet"
                            : null,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white70,
                          label: Text("Square Feet"),

                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: const BorderSide(
                              color: Color.fromARGB(255, 2, 2, 65),
                            ),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 16,
                          ),
                        ),
                        style: const TextStyle(
                          color: Color(0xFF4A148C),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 22),
                      TextFormField(
                        keyboardType: TextInputType.number,
                        controller: amountController,
                        validator: (value) => (value == null || value.isEmpty)
                            ? "Please enter Amount"
                            : null,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white70,
                          label: Text("Expected Amount"),

                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: const BorderSide(
                              color: Color.fromARGB(255, 2, 2, 65),
                            ),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 16,
                          ),
                        ),
                        style: const TextStyle(
                          color: Color(0xFF4A148C),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 40),
                      SizedBox(
                        width: double.infinity,
                        height: 54,
                        child: ElevatedButton(
                          onPressed: isLoading
                              ? null
                              : () {
                                  if (_formkey.currentState!.validate()) {
                                    submitDetails();
                                  }
                                },
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24),
                            ),
                            elevation: 8,
                            backgroundColor: Colors.red[200],

                            shadowColor: const Color.fromARGB(
                              255,
                              206,
                              191,
                              247,
                            ),
                            textStyle: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.2,
                            ),
                          ),
                          child: isLoading
                              ? const CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 3,
                                )
                              : Text(
                                  'Submit',
                                  style: TextStyle(
                                    color: const Color.fromARGB(
                                      255,
                                      36,
                                      26,
                                      53,
                                    ),
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
