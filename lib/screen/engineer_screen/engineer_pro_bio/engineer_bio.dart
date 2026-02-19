import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:house_construction_pro/constant_page.dart';
import 'package:house_construction_pro/screen/engineer_screen/eng_home_screen/eng_home_screen.dart';
import 'package:house_construction_pro/screen/engineer_screen/engineer_pro_bio/bloc/engineer_bio_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class EngineerBio extends StatefulWidget {
  const EngineerBio({super.key, required this.engineerId});
  final int engineerId;

  @override
  State<EngineerBio> createState() => _EngineerBioState();
}

class _EngineerBioState extends State<EngineerBio> {
  int? engineerId;

  bool _showAmountDetails = false;
  // final List<Feature> _features = [
  //   Feature(name: 'Swimming Pool', icon: Icons.pool),
  //   Feature(name: 'Pooja Room', icon: Icons.temple_hindu),
  //   Feature(name: 'Garden', icon: Icons.yard),
  //   Feature(name: 'Gym', icon: Icons.fitness_center),
  // ];

  final List<House> _houses = [];
  List<Map<String, dynamic>> categoryItems = [];
  final picker = ImagePicker();
  String? selectedCategory;
  File? image;
  XFile? _profileImage;
  List<Map<String, dynamic>> additionalFeature = [];
  final TextEditingController projectNameController = TextEditingController();
  final TextEditingController centController = TextEditingController();
  final TextEditingController sqrftController = TextEditingController();
  final TextEditingController expectedAmountController =
      TextEditingController();
  final TextEditingController additionalAmountController =
      TextEditingController();
  final TextEditingController totalAmountController = TextEditingController();
  final TextEditingController timeDurationController = TextEditingController();
  final GlobalKey<FormState> _formkey = GlobalKey<FormState>();
  bool isLoading = false;
  Future<void> _pickImage(ImageSource source) async {
    try {
      final pickedFile = await picker.pickImage(
        source: source,
        imageQuality: 80,
      );
      if (pickedFile != null) {
        setState(() {
          _profileImage = pickedFile;
        });
      }
    } catch (e) {
      showError("Failed to pick image: $e");
    }
  }

  void showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void _showImageSourceSelection() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Gallery'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Camera'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileImagePicker() {
    double h = MediaQuery.of(context).size.height;
    double w = MediaQuery.of(context).size.width;
    return Center(
      child: GestureDetector(
        onTap: _showImageSourceSelection,
        child: Container(
          width: w * 0.5, // size of container
          height: h * 0.2,
          decoration: BoxDecoration(
            color: Colors.blueGrey[100],
            borderRadius: BorderRadius.circular(15), // Rounded corners
            border: Border.all(
              color: const Color.fromARGB(255, 68, 68, 68),
              width: 1,
            ),
            image: _profileImage != null
                ? DecorationImage(
                    image: FileImage(File(_profileImage!.path)),
                    fit: BoxFit.cover,
                  )
                : null,
          ),
          child: _profileImage == null
              ? const Icon(Icons.camera_alt, size: 40, color: Colors.white70)
              : null,
        ),
      ),
    );
  }

  @override
  void initState() {
    engineerId = widget.engineerId;
    super.initState();
    _getAdditionalFeat();
    fetchCategoryItems();
    centController.addListener(_updateSquareFeet);
    expectedAmountController.addListener(_updateTotalAmount);
    additionalAmountController.addListener(_updateTotalAmount);
  }

  @override
  void dispose() {
    projectNameController.dispose();
    centController.dispose();
    sqrftController.dispose();
    expectedAmountController.dispose();
    additionalAmountController.dispose();
    totalAmountController.dispose();
    timeDurationController.dispose();
    super.dispose();
  }

  void _showAmountBreakdown() {
    setState(() {
      _showAmountDetails = !_showAmountDetails;
    });
  }

  final List<Feature> _features = []; // initially empty

  Future<void> _getAdditionalFeat() async {
    try {
      var response = await http.get(Uri.parse(Urlss.getAdditionalfeturi));

      //print("Response Code: ${response.statusCode}");
      // print("Response Body: ${response.body}");

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);

        if (data is List) {
          setState(() {
            _features.clear(); // remove old data
            for (var item in data) {
              final name = item['name'] ?? '';

              _features.add(
                Feature(
                  name: name, // comes from backend
                  icon: _getIconForFeature(name), // hardcoded icon mapping
                ),
              );
            }
          });
        }
      } else {
        showError('Failed to load features: ${response.statusCode}');
      }
    } catch (e) {
      showError('Network Error: ${e.toString()}');
    }
  }

  // Map backend name to icons
  IconData _getIconForFeature(String name) {
    switch (name.toLowerCase()) {
      case 'swimming pool':
        return Icons.pool;
      case 'prayer room':
      case 'pooja room':
        return Icons.temple_hindu;
      case 'garden':
        return Icons.yard;
      case 'gym':
        return Icons.fitness_center;
      case 'study room':
        return Icons.menu_book;
      case 'dressing room':
        return Icons.checkroom;
      case 'makeup room':
        return Icons.brush;
      case 'home office':
        return Icons.home_work;
      case 'well':
        return Icons.water;
      default:
        return Icons.home; // fallback icon
    }
  }

  Future<void> fetchCategoryItems() async {
    //print(123);
    final response = await http.get(Uri.parse(Urlss.propertyItemCategory));
    if (response.statusCode == 200) {
      //print(response.statusCode);
      final List<dynamic> data = jsonDecode(response.body);
      //  print(response.body);
      //print(data);
      setState(() {
        categoryItems = data.map((value) {
          return value as Map<String, dynamic>;
        }).toList();
      });
    } else {
      throw Exception('Failed to Load Category');
    }
  }

  void submitDetails() {
    FocusScope.of(context).unfocus();
    setState(() {
      isLoading = true;
    });
    final categoryId = int.tryParse(selectedCategory ?? '');
    if (categoryId == null) {
      showError("Select a valid category");
      setState(() {
        isLoading = false;
      });
      return;
    }

    // Gather selected feature IDs
    // You must have a mapping from Feature.name to backend id; here assuming Feature has an 'id'
    final List<int> additionalFeatures = _features
        .asMap()
        .entries
        .where((entry) => entry.value.isSelected)
        .map((entry) => entry.key) // Or however you store the backend id
        .toList();

    // Gather images as Files
    final List<File> images = _houses
        .where((h) => h.fileImagePath != null)
        .map((h) => File(h.fileImagePath!))
        .toList();
    context.read<EngineerBioBloc>().add(
      EngineerBioEvent.uploadEngBio(
        engineerId: widget.engineerId,
        projectName: projectNameController.text,
        categoryId: categoryId,
        profileImage: _profileImage != null ? File(_profileImage!.path) : null,
        cent: double.tryParse(centController.text) ?? 0,
        squareFeet: double.tryParse(sqrftController.text) ?? 0,
        expectedAmount: int.tryParse(expectedAmountController.text) ?? 0,
        additionalAmount: int.tryParse(additionalAmountController.text) ?? 0,
        totalAmount: double.tryParse(totalAmountController.text) ?? 0,
        additionalFeatures: additionalFeatures,
        timeDuration: timeDurationController.text,
        images: images,
      ),
    );
    // print('Cent: ${centController.text}');
    // print('SquareFeet: ${sqrftController.text}');
    // print('TotalAmount: ${totalAmountController.text}');
    // print('AdditionalFeatures: $additionalFeatures');

    // context.read<PropertyInputBloc>().add(
    //   PropertyInputEvent.propertySub(
    //     userId: userId!,
    //     sgft: double.parse(sqrftController.text),
    //     cent: double.parse(centController.text),
    //     amount: double.parse(amountController.text),
    //     category: int.parse(selectedCategory!),
    //   ),
    // );
  }

  void _updateTotalAmount() {
    final expected = double.tryParse(expectedAmountController.text) ?? 0;
    final additional = double.tryParse(additionalAmountController.text) ?? 0;
    final total = expected + additional;
    totalAmountController.text = total.toStringAsFixed(2);
  }

  void _updateSquareFeet() {
    final centText = centController.text;
    final cent = double.tryParse(centText); // use tryParse

    if (cent != null) {
      final sqfeet = cent * 435.56;
      sqrftController.text = sqfeet.toStringAsFixed(2);
    } else {
      sqrftController.text = '';
    }
  }

  @override
  Widget build(BuildContext context) {
    //  double width = MediaQuery.of(context).size.width;
    // double height = MediaQuery.of(context).size.height;
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.blue.shade300,
          title: Text(
            'Project Bio',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: const Color.fromARGB(255, 72, 5, 83),
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
        ),
        body: BlocConsumer<EngineerBioBloc, EngineerBioState>(
          listener: (context, state) {
            state.when(
              initial: () {},
              loading: () {
                setState(() {
                  isLoading = true;
                });
              },
              success: (response) async {
                setState(() {
                  isLoading = false;
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Property details submitted successfully!'),
                    backgroundColor: Colors.green,
                  ),
                );
                //Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) {
                      return ViewEngineerBookingDetails(engineerId: engineerId!,);
                    },
                  ),
                );
              },
              error: (error) {
                setState(() {
                  isLoading = false;
                });
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text('Error: $error')));
              },
            );
          },
          builder: (context, state) => Container(
            width: double.infinity,
            decoration: BoxDecoration(
              // image: DecorationImage(
              //   isAntiAlias: true,
              //   // invertColors: true,
              //   opacity: 0.3,
              //   fit: BoxFit.cover,
              //   image: AssetImage('assets/images/2678894.jpg'),
              // ),
              // gradient: LinearGradient(
              //   colors: [Colors.blue.shade200, Colors.purple.shade100],
              //   begin: Alignment.topLeft,
              //   end: Alignment.bottomRight,
              // ),
            ),
            child: SingleChildScrollView(
              // padding: EdgeInsets.all(16.0),
              child: Form(
                key: _formkey,
                child: Padding(
                  padding: const EdgeInsets.only(
                    left: 9.0,
                    right: 9.0,
                    top: 10.0,
                    bottom: 20.0,
                  ),
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.only(
                        left: 9.0,
                        right: 9.0,
                        top: 15.0,
                        bottom: 10.0,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Center(child: _buildProfileImagePicker()),
                          const SizedBox(height: 30),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Project Name:',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  // color: const Color.fromARGB(255, 72, 5, 83),
                                ),
                              ),
                              const SizedBox(width: 25),
                              Expanded(
                                child: TextFormField(
                                  controller: projectNameController,
                                  validator: (v) => v == null || v.isEmpty
                                      ? "Enter project name"
                                      : null,

                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'House Type:',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  // color: const Color.fromARGB(255, 72, 5, 83),
                                ),
                              ),
                              const SizedBox(width: 40),
                              Expanded(
                                child: DropdownButtonFormField(
                                  validator: (value) {
                                    return value == null || value.isEmpty
                                        ? "Please Select Category"
                                        : null;
                                  },
                                  decoration: const InputDecoration(
                                    border: OutlineInputBorder(),
                                    labelText: 'Select Category',
                                  ),
                                  items: categoryItems
                                      .map(
                                        (items) => DropdownMenuItem(
                                          value: items['id'].toString(),
                                          child: Text(items['name']),
                                        ),
                                      )
                                      .toList(),
                                  onChanged: (value) => setState(() {
                                    selectedCategory = value;
                                  }),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),

                          //  const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Cent:',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  //color: const Color.fromARGB(255, 72, 5, 83),
                                ),
                              ),
                              const SizedBox(width: 97),
                              Expanded(
                                child: TextFormField(
                                  keyboardType: TextInputType.number,
                                  controller: centController,
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Square Feet:',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  // color: const Color.fromARGB(255, 72, 5, 83),
                                ),
                              ),
                              const SizedBox(width: 39),
                              Expanded(
                                child: TextFormField(
                                  readOnly: true,
                                  validator: (value) {
                                    return value == null || value.isEmpty
                                        ? "Please enter Square Feet"
                                        : null;
                                  },
                                  controller: sqrftController,
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          InkWell(
                            onTap: _showAmountBreakdown,
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                //  color: const Color.fromARGB(255, 7, 7, 7),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.black45),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Amount Chart Sheet',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: const Color.fromARGB(
                                        255,
                                        72,
                                        5,
                                        83,
                                      ),
                                    ),
                                  ),
                                  Icon(
                                    _showAmountDetails
                                        ? Icons.keyboard_arrow_up
                                        : Icons.keyboard_arrow_down,
                                    //   color: const Color.fromARGB(255, 8, 8, 8),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          if (_showAmountDetails) ...[
                            const SizedBox(height: 10),

                            // 💡 Pink background container for the expanded details
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: const Color.fromARGB(
                                  255,
                                  245,
                                  204,
                                  219,
                                ), // Light pink background
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.pink.shade100),
                              ),
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Exact Amount:',
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: const Color.fromARGB(
                                            255,
                                            91,
                                            9,
                                            104,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 43),
                                      Expanded(
                                        child: TextFormField(
                                          controller: expectedAmountController,
                                          keyboardType: TextInputType.number,
                                          decoration: InputDecoration(
                                            border: OutlineInputBorder(),
                                          ),
                                        ),
                                      ),
                                      // Text(
                                      //   value,
                                      //   style: TextStyle(
                                      //     fontSize: 16,
                                      //     fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
                                      //     color: Colors.white,
                                      //   ),
                                      // ),
                                    ],
                                  ),
                                  const SizedBox(height: 5),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Additional Amount:',
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: const Color.fromARGB(
                                            255,
                                            91,
                                            9,
                                            104,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: TextFormField(
                                          controller:
                                              additionalAmountController,
                                          keyboardType: TextInputType.number,
                                          decoration: InputDecoration(
                                            border: OutlineInputBorder(),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 5),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Total Amount:',
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: const Color.fromARGB(
                                            255,
                                            91,
                                            9,
                                            104,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 50),
                                      Expanded(
                                        child: TextFormField(
                                          controller: totalAmountController,
                                          readOnly: true,
                                          decoration: InputDecoration(
                                            border: OutlineInputBorder(),
                                          ),
                                        ),
                                      ),
                                      // Text(
                                      //   value,
                                      //   style: TextStyle(
                                      //     fontSize: 16,
                                      //     fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
                                      //     color: Colors.white,
                                      //   ),
                                      // ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],

                          const SizedBox(height: 30),
                          // In your build:
                          Row(
                            children: [
                              Text(
                                'Work Proof:',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: const Color.fromARGB(255, 72, 5, 83),
                                ),
                              ),
                              Spacer(),
                              IconButton(
                                icon: Icon(
                                  Icons.add_a_photo,
                                  color: Colors.deepOrange,
                                ),
                                onPressed: () async {
                                  final pickedFile = await ImagePicker()
                                      .pickImage(source: ImageSource.gallery);
                                  if (pickedFile != null) {
                                    setState(() {
                                      _houses.add(
                                        House(fileImagePath: pickedFile.path),
                                      ); // Append new image
                                    });
                                  }
                                },
                                tooltip: 'Upload Work Proof Image',
                              ),

                              //tooltip: 'Upload Work Proof Image',
                            ],
                          ),
                          if (_houses.isNotEmpty)
                            SizedBox(
                              height: 150,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: _houses.length,
                               itemBuilder: (context, index) =>
    _buildHouseCard(_houses[index], index),

                              ),
                            )
                          else
                            Text(
                              "No Work Proof uploaded yet",
                              style: TextStyle(color: Colors.grey),
                            ),

                          const SizedBox(height: 30),
                          Text(
                            'Additional Features:',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: const Color.fromARGB(255, 72, 5, 83),
                            ),
                          ),
                          const SizedBox(height: 15),
                          SizedBox(
                            height: 150,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: _features.length,
                              itemBuilder: (context, index) {
                                return _buildFeatureCard(_features[index]);
                              },
                            ),
                          ),
                          const SizedBox(height: 30),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Time Duration:',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: const Color.fromARGB(255, 72, 5, 83),
                                ),
                              ),
                              const SizedBox(width: 25),
                              Expanded(
                                child: TextFormField(
                                  controller: timeDurationController,
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 40),
                          Center(
                            child: ElevatedButton.icon(
                              icon: const Icon(
                                Icons.cloud_upload,
                                color: Colors.white,
                              ),
                              label: const Text(
                                'Upload Documents',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.deepOrange,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 30,
                                  vertical: 15,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                              ),
                              onPressed: () {
                                if (_formkey.currentState!.validate()) {
                                  submitDetails();
                                }
                                // ScaffoldMessenger.of(context).showSnackBar(
                                //   const SnackBar(
                                //     content: Text('Registration successful!'),
                                //     backgroundColor: Colors.green,
                                //   ),
                                // );
                                // Navigator.pop(context);
                              },
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
        ),
      ),
    );
  }

  Widget buildAmountDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 16,
              color: const Color.fromARGB(255, 91, 9, 104),
            ),
          ),
          const SizedBox(width: 25),
          Expanded(
            child: TextFormField(
              keyboardType: TextInputType.number,
              decoration: InputDecoration(border: OutlineInputBorder()),
            ),
          ),
          // Text(
          //   value,
          //   style: TextStyle(
          //     fontSize: 16,
          //     fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
          //     color: Colors.white,
          //   ),
          // ),
        ],
      ),
    );
  }

 Widget _buildHouseCard(House house, int index) {
  return Container(
    width: 130,
    margin: const EdgeInsets.only(right: 15),
    decoration: _cardDecoration(),
    child: Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(15),
          child: Image.file(
            File(house.fileImagePath!),
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),
        ),

        /// 🔴 Close Button
        Positioned(
          top: 6,
          right: 6,
          child: GestureDetector(
            onTap: () {
              setState(() {
                _houses.removeAt(index);
              });
            },
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.6),
                shape: BoxShape.circle,
              ),
              padding: const EdgeInsets.all(4),
              child: const Icon(
                Icons.close,
                color: Colors.white,
                size: 18,
              ),
            ),
          ),
        ),
      ],
    ),
  );
}


  Widget _buildFeatureCard(Feature feature) {
    return Container(
      width: 130,
      margin: const EdgeInsets.only(right: 15),
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.white24),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            feature.icon,
            size: 40,
            color: const Color.fromARGB(255, 233, 59, 82),
          ),
          const SizedBox(height: 10),
          Text(
            feature.name,
            style: const TextStyle(color: Color.fromARGB(255, 143, 15, 32)),
          ),
          const SizedBox(height: 10),
          Checkbox(
            value: feature.isSelected,
            onChanged: (value) {
              setState(() {
                feature.isSelected = value!;
              });
            },
            fillColor: WidgetStateProperty.all(Colors.green),
          ),
        ],
      ),
    );
  }
}

BoxDecoration _cardDecoration() {
  return BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(15),
    border: Border.all(color: Colors.white24),
  );
}

TextStyle sectionTitleStyle() {
  return TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: Colors.black,
  );
}

// Models
class Feature {
  String name;
  IconData icon;
  bool isSelected;
  Feature({required this.name, required this.icon, this.isSelected = false});
}

class House {
  final String? image; // asset path
  final String? fileImagePath; // picked image file path

  House({this.image, this.fileImagePath});
}
