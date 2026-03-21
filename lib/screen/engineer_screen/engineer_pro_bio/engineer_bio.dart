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

  // White elegant UI colors
  static const Color kPageBg = Color(0xFFF8FAFC);
  static const Color kCard = Colors.white;
  static const Color kCardSoft = Color(0xFFFDFDFD);
  static const Color kField = Colors.white;
  static const Color kBorder = Color(0xFFE2E8F0);
  static const Color kAccent = Color(0xFF19C37D);
  static const Color kAccentDark = Color(0xFF159A64);
  static const Color kText = Color(0xFF0F172A);
  static const Color kSubText = Color(0xFF475569);
  static const Color kHint = Color(0xFF94A3B8);
  static const Color kDanger = Color(0xFFE96A6A);

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
      SnackBar(
        content: Text(message),
        backgroundColor: kDanger,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showImageSourceSelection() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library, color: kAccent),
              title: const Text('Gallery', style: TextStyle(color: kText)),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt, color: kAccent),
              title: const Text('Camera', style: TextStyle(color: kText)),
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
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: w * 0.38,
              height: h * 0.17,
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: kAccent.withOpacity(0.35),
                  width: 1.3,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
                image: _profileImage != null
                    ? DecorationImage(
                        image: FileImage(File(_profileImage!.path)),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: _profileImage == null
                  ? const Icon(Icons.camera_alt, size: 42, color: kSubText)
                  : null,
            ),
            Positioned(
              right: -8,
              bottom: -8,
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: kAccent,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 3),
                  boxShadow: [
                    BoxShadow(
                      color: kAccent.withOpacity(0.25),
                      blurRadius: 12,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.edit,
                  color: Colors.white,
                  size: 18,
                ),
              ),
            ),
          ],
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

  final List<Feature> _features = [];

  Future<void> _getAdditionalFeat() async {
    try {
      var response = await http.get(Uri.parse(Urlss.getAdditionalfeturi));

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);

        if (data is List) {
          setState(() {
            _features.clear();
            for (var item in data) {
              final name = item['name'] ?? '';

              _features.add(
                Feature(
                  name: name,
                  icon: _getIconForFeature(name),
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
        return Icons.home;
    }
  }

  Future<void> fetchCategoryItems() async {
    final response = await http.get(Uri.parse(Urlss.propertyItemCategory));
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
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

    final List<int> additionalFeatures = _features
        .asMap()
        .entries
        .where((entry) => entry.value.isSelected)
        .map((entry) => entry.key)
        .toList();

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
  }

  void _updateTotalAmount() {
    final expected = double.tryParse(expectedAmountController.text) ?? 0;
    final additional = double.tryParse(additionalAmountController.text) ?? 0;
    final total = expected + additional;
    totalAmountController.text = total.toStringAsFixed(2);
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

  InputDecoration _inputDecoration({String? hint, String? label}) {
    return InputDecoration(
      hintText: hint,
      labelText: label,
      labelStyle: const TextStyle(color: kSubText),
      hintStyle: const TextStyle(color: kHint),
      filled: true,
      fillColor: kField,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(
          color: kBorder,
          width: 1.1,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(
          color: kAccent,
          width: 1.4,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: kDanger),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: kDanger),
      ),
    );
  }

  Widget _buildLabeledField({
    required String label,
    required Widget child,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: kSubText,
            ),
          ),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, {IconData? icon}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, color: kAccent, size: 20),
            const SizedBox(width: 8),
          ],
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: kText,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAmountField({
    required String label,
    required TextEditingController controller,
    bool readOnly = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        readOnly: readOnly,
        keyboardType: TextInputType.number,
        style: const TextStyle(color: kText),
        decoration: _inputDecoration(label: label),
      ),
    );
  }

  Widget _buildInfoCard({required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: kCard,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: kBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kPageBg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Project Bio',
          style: TextStyle(
            color: kText,
            fontWeight: FontWeight.w800,
          ),
        ),
        iconTheme: const IconThemeData(color: kText),
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
                const SnackBar(
                  content: Text('Property details submitted successfully!'),
                  backgroundColor: kAccentDark,
                ),
              );
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) {
                    return ViewEngineerBookingDetails(
                      engineerId: engineerId!,
                    );
                  },
                ),
              );
            },
            error: (error) {
              setState(() {
                isLoading = false;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Error: $error')),
              );
            },
          );
        },
        builder: (context, state) => Stack(
          children: [
            SingleChildScrollView(
              child: Form(
                key: _formkey,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: _buildInfoCard(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 20, 16, 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Center(child: _buildProfileImagePicker()),
                          const SizedBox(height: 24),

                          _buildSectionTitle(
                            "Project Details",
                            icon: Icons.home_work_outlined,
                          ),

                          _buildLabeledField(
                            label: "Project Name",
                            child: TextFormField(
                              controller: projectNameController,
                              style: const TextStyle(color: kText),
                              validator: (v) => v == null || v.isEmpty
                                  ? "Enter project name"
                                  : null,
                              decoration: _inputDecoration(
                                hint: "Enter project name",
                              ),
                            ),
                          ),

                          _buildLabeledField(
                            label: "House Type",
                            child: DropdownButtonFormField<String>(
                              initialValue: selectedCategory,
                              dropdownColor: Colors.white,
                              style: const TextStyle(color: kText),
                              validator: (value) {
                                return value == null || value.isEmpty
                                    ? "Please Select Category"
                                    : null;
                              },
                              decoration: _inputDecoration(
                                label: 'Select Category',
                              ),
                              items: categoryItems
                                  .map(
                                    (items) => DropdownMenuItem<String>(
                                      value: items['id'].toString(),
                                      child: Text(
                                        items['name'],
                                        style: const TextStyle(color: kText),
                                      ),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (value) => setState(() {
                                selectedCategory = value;
                              }),
                            ),
                          ),

                          Row(
                            children: [
                              Expanded(
                                child: _buildLabeledField(
                                  label: "Cent",
                                  child: TextFormField(
                                    keyboardType: TextInputType.number,
                                    controller: centController,
                                    style: const TextStyle(color: kText),
                                    decoration: _inputDecoration(
                                      hint: "Enter cent",
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: _buildLabeledField(
                                  label: "Square Feet",
                                  child: TextFormField(
                                    readOnly: true,
                                    controller: sqrftController,
                                    style: const TextStyle(color: kText),
                                    validator: (value) {
                                      return value == null || value.isEmpty
                                          ? "Please enter Square Feet"
                                          : null;
                                    },
                                    decoration: _inputDecoration(
                                      hint: "Auto calculated",
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 8),

                          InkWell(
                            onTap: _showAmountBreakdown,
                            borderRadius: BorderRadius.circular(16),
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF8FAFC),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: kBorder),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'Amount Chart Sheet',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: kText,
                                    ),
                                  ),
                                  Icon(
                                    _showAmountDetails
                                        ? Icons.keyboard_arrow_up
                                        : Icons.keyboard_arrow_down,
                                    color: kAccent,
                                  ),
                                ],
                              ),
                            ),
                          ),

                          if (_showAmountDetails) ...[
                            const SizedBox(height: 14),
                            Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF8FAFC),
                                borderRadius: BorderRadius.circular(18),
                                border: Border.all(color: kBorder),
                              ),
                              child: Column(
                                children: [
                                  _buildAmountField(
                                    label: 'Exact Amount',
                                    controller: expectedAmountController,
                                  ),
                                  _buildAmountField(
                                    label: 'Additional Amount',
                                    controller: additionalAmountController,
                                  ),
                                  _buildAmountField(
                                    label: 'Total Amount',
                                    controller: totalAmountController,
                                    readOnly: true,
                                  ),
                                ],
                              ),
                            ),
                          ],

                          const SizedBox(height: 26),

                          Row(
                            children: [
                              _buildSectionTitle(
                                'Work Proof',
                                icon: Icons.photo_library_outlined,
                              ),
                              const Spacer(),
                              IconButton(
                                icon: const Icon(
                                  Icons.add_a_photo,
                                  color: kAccent,
                                ),
                                onPressed: () async {
                                  final pickedFile = await ImagePicker()
                                      .pickImage(source: ImageSource.gallery);
                                  if (pickedFile != null) {
                                    setState(() {
                                      _houses.add(
                                        House(
                                          fileImagePath: pickedFile.path,
                                        ),
                                      );
                                    });
                                  }
                                },
                                tooltip: 'Upload Work Proof Image',
                              ),
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
                            const Padding(
                              padding: EdgeInsets.only(bottom: 10),
                              child: Text(
                                "No Work Proof uploaded yet",
                                style: TextStyle(color: kSubText),
                              ),
                            ),

                          const SizedBox(height: 26),

                          _buildSectionTitle(
                            'Additional Features',
                            icon: Icons.widgets_outlined,
                          ),

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

                          const SizedBox(height: 26),

                          _buildLabeledField(
                            label: "Time Duration",
                            child: TextFormField(
                              controller: timeDurationController,
                              style: const TextStyle(color: kText),
                              decoration: _inputDecoration(
                                hint: "Eg. 6 months",
                              ),
                            ),
                          ),

                          const SizedBox(height: 24),

                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              icon: const Icon(
                                Icons.cloud_upload,
                                color: Colors.white,
                              ),
                              label: const Text(
                                'Upload Documents',
                                style: TextStyle(
                                  fontSize: 17,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: kAccent,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 30,
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(18),
                                ),
                                elevation: 4,
                              ),
                              onPressed: () {
                                if (_formkey.currentState!.validate()) {
                                  submitDetails();
                                }
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
            if (isLoading)
              Container(
                color: Colors.black.withOpacity(0.12),
                child: const Center(
                  child: CircularProgressIndicator(color: kAccent),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget buildAmountDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                color: kSubText,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: TextFormField(
              keyboardType: TextInputType.number,
              style: const TextStyle(color: kText),
              decoration: _inputDecoration(),
            ),
          ),
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
                  color: Colors.black.withOpacity(0.45),
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: feature.isSelected ? kAccent : kBorder,
        ),
        boxShadow: [
          BoxShadow(
            color: feature.isSelected
                ? kAccent.withOpacity(0.12)
                : Colors.black.withOpacity(0.04),
            blurRadius: 14,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            feature.icon,
            size: 36,
            color: feature.isSelected ? kAccent : kSubText,
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              feature.name,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: feature.isSelected ? kText : kSubText,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Checkbox(
            value: feature.isSelected,
            onChanged: (value) {
              setState(() {
                feature.isSelected = value!;
              });
            },
            activeColor: kAccent,
            checkColor: Colors.white,
            side: const BorderSide(color: kAccent),
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
    border: Border.all(color: const Color(0xFFE2E8F0)),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.05),
        blurRadius: 16,
        offset: const Offset(0, 8),
      ),
    ],
  );
}

TextStyle sectionTitleStyle() {
  return const TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: Color(0xFF0F172A),
  );
}

class Feature {
  String name;
  IconData icon;
  bool isSelected;
  Feature({required this.name, required this.icon, this.isSelected = false});
}

class House {
  final String? image;
  final String? fileImagePath;

  House({this.image, this.fileImagePath});
}