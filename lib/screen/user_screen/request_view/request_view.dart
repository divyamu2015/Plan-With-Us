import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_swipe_button/flutter_swipe_button.dart';
import 'package:house_construction_pro/constant_page.dart';
import 'package:house_construction_pro/screen/feedback_page.dart';
import 'package:house_construction_pro/screen/user_screen/request_view/bloc/request_bloc.dart';
import 'package:house_construction_pro/screen/user_screen/request_view/getinput_model.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:file_picker/file_picker.dart';

class RequestViewBooking extends StatefulWidget {
  const RequestViewBooking({
    super.key,
    required this.engineerId,
    required this.userId,
    required this.requestId,
  });
  final int engineerId;
  final int? userId;
  final int? requestId;

  @override
  State<RequestViewBooking> createState() => _RequestViewBookingState();
}

class _RequestViewBookingState extends State<RequestViewBooking> {
  final TextEditingController nameCtrl = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _centController = TextEditingController();
  final TextEditingController _squareController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _suggestionController = TextEditingController();
  final TextEditingController _startDateController = TextEditingController();
  final TextEditingController _endDateController = TextEditingController();
  final TextEditingController _featuresController = TextEditingController();
  File? _suggestionFile;
  final _formKey = GlobalKey<FormState>();
  final List<Feature> _features = [];

  DateTime selectedDate = DateTime.now();
  TimeOfDay? startTime = TimeOfDay(hour: 9, minute: 0);
  TimeOfDay? endTime = TimeOfDay(hour: 17, minute: 0);
  bool acceptedTerms = false;
  File? _image;
  File? _pdfFile;
  int? userId;
  int? engineerId;
  bool isLoading = true;
  String? errorMessage;
  int? requestId;

  @override
  void initState() {
    super.initState();
    _getAdditionalFeat();
    requestId = widget.requestId;
    print("book your estimate-------------vgh $requestId");
    if (widget.userId != null) {
      userId = widget.userId!;
      engineerId = widget.engineerId;
      getInputDetails();
      context.read<RequestBloc>().add(
        RequestEvent.getUserDetails(userId: userId!, requestId: 0),
      );
    }
  }

  Future pickImage() async {
    final pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<void> selectStartDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 60)),
    );
    if (picked != null) {
      setState(() {
        _startDateController.text = DateFormat(
          'yyyy-MM-dd',
        ).format(picked); // "2025-11-05"
      });
    }
  }

  Future<void> selectEndDate(BuildContext context) async {
  if (_startDateController.text.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Please select start date first")),
    );
    return;
  }

  final startDate = DateTime.parse(_startDateController.text);

  final DateTime? picked = await showDatePicker(
    context: context,
    initialDate: startDate.add(const Duration(days: 1)),
    firstDate: startDate, // ❗ end date cannot be before start
    lastDate: startDate.add(const Duration(days: 365 * 2)), // 2 years from start
  );
 
  if (picked != null) {
    setState(() {
      _endDateController.text = DateFormat('yyyy-MM-dd').format(picked);
    });
  }
}


  Future<GetPropertyInputModel> getInputDetails() async {
    if (userId == null) {
      setState(() {
        isLoading = false;
        errorMessage = "User ID is missing";
      });
      throw Exception("User ID is null");
    }

    final url = Uri.parse(
      'https://417sptdw-8001.inc1.devtunnels.ms/userapp/requests/$userId/${widget.requestId}/',
    );
    print(url);
    try {
      final res = await http.get(url);
      print('Request view ${res.body}');
      if (res.statusCode == 200) {
        print(res.statusCode);
        final data = jsonDecode(res.body);
        print(data);
        final propertyDetails = GetPropertyInputModel.fromJson(data);
        print(propertyDetails);
        setState(() {
          _centController.text = propertyDetails.cent.toString();
          _squareController.text = propertyDetails.sqft.toString();
          _amountController.text = propertyDetails.expectedAmount.toString();
          isLoading = false;
          errorMessage = null;
        });
        return propertyDetails;
      } else {
        setState(() {
          isLoading = false;
          errorMessage = 'Failed to load details. Status: ${res.statusCode}';
        });
        throw Exception(
          'Failed to load profile. Status code: ${res.statusCode}',
        );
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = 'Error: ${e.toString()}';
      });
      rethrow;
    }
  }

  String formatTimeOfDay(TimeOfDay tod) {
    final hour = tod.hourOfPeriod == 0 ? 12 : tod.hourOfPeriod;
    final minute = tod.minute.toString().padLeft(2, '0');
    final period = tod.period == DayPeriod.am ? "AM" : "PM";
    return "$hour:$minute $period";
  }

  Future<void> storeId(int requestId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('id', requestId);
  }

  Future<int?> getStoredId() async {
    final prefs = await SharedPreferences.getInstance();
    requestId = prefs.getInt('id');
    return requestId;
  }

  void pickPdfFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
    );
    if (result != null) {
      setState(() {
        _suggestionFile = File(result.files.single.path!);
      });
    }
  }

  Future<void> postEngineerBooking() async {
    var url = Uri.parse(
      'https://417sptdw-8001.inc1.devtunnels.ms/userapp/book_engineer/',
    );
    var request = http.MultipartRequest('POST', url);

    Map<String, dynamic> bookingData = {
      "user": widget.userId,
      "engineer": widget.engineerId,
      "cent": _centController.text.isEmpty ? null : _centController.text,
      "sqft": _squareController.text.isEmpty ? null : _squareController.text,
      "expected_amount": _amountController.text.isEmpty
          ? null
          : _amountController.text,
      "features": _features
          .where((f) => f.isSelected)
          .map((f) => f.id)
          .toList(),
      "address": _addressController.text.isEmpty
          ? null
          : _addressController.text,
      "start_date": _startDateController.text.isEmpty
          ? null
          : _startDateController.text,
      "end_date": _endDateController.text.isEmpty
          ? null
          : _endDateController.text,
      "suggestion": null,
      "status": "pending",
      "created_at": DateTime.now().toIso8601String(),
      "user_request": widget.requestId,
    };

    bookingData.forEach((key, value) {
      if (value != null) {
        if (value is List) {
          request.fields[key] = jsonEncode(value);
        } else {
          request.fields[key] = value.toString();
        }
      }
    });

    if (_suggestionFile != null) {
      String fileExt = _suggestionFile!.path.split('.').last.toLowerCase();
      MediaType mediaType;
      if (fileExt == 'pdf') {
        mediaType = MediaType('application', 'pdf');
      } else if (fileExt == 'jpg' || fileExt == 'jpeg') {
        mediaType = MediaType('image', 'jpeg');
      } else if (fileExt == 'png') {
        mediaType = MediaType('image', 'png');
      } else {
        mediaType = MediaType('application', 'octet-stream');
      }

      request.files.add(
        await http.MultipartFile.fromPath(
          'suggestion',
          _suggestionFile!.path,
          contentType: mediaType,
        ),
      );
    }

    var streamedResponse = await request.send();
    var response = await http.Response.fromStream(streamedResponse);

    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode == 200 || response.statusCode == 201) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Success: ${response.body}")));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed: ${response.statusCode} - ${response.body}"),
        ),
      );
    }
  }

  void _showTermsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Terms and Conditions'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '''1. The engineer will provide only an initial estimate based on provided details.
2. The final construction cost may vary.
3. All permits and legal clearances are the owner’s responsibility.
4. Payment terms will be discussed and agreed separately.
5. Features requested by the user are subject to site feasibility.
6. The company/engineer is not liable for delays due to unforeseen circumstances (weather, supply chain, etc).
7. By accepting, you agree to share your details with the assigned engineer for further communication.''',
              ),
              const SizedBox(height: 20),
              Text(
                getAgreementContent(
                  nameCtrl.text.isEmpty ? "User" : nameCtrl.text,
                  "engineerName",
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            child: const Text('Accept'),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  static String getAgreementContent(String userName, String engineerName) {
    return '''
This agreement is made between $userName and $engineerName.
As the appointed engineer, I commit to completing the construction project on time. However, the following terms and conditions apply:
1. Natural Disasters:
   In events such as rain, flood, or any natural disaster, if project timelines are affected, neither I (the engineer) nor my company shall be held responsible for these delays.
2. Procurement of Additional Materials:
   For specific items such as windows, doors, or other special materials, it is the responsibility of $userName to purchase and provide them if required. Any delay in the arrival of these materials at the construction site that leads to project postponement is not the responsibility of $engineerName or our company.
3. Risk Disclaimer:
   Any delays, damages, or risks arising due to reasons beyond our (engineer/company) control are acknowledged and accepted by $userName. We shall not be liable for losses arising from such circumstances.
''';
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
              final id = item['id'] ?? 0;
              _features.add(
                Feature(id: id, name: name, icon: _getIconForFeature(name)),
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

  void showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<RequestBloc, RequestState>(
        listener: (context, state) {
          state.when(
            initial: () {
              return const Center(child: Text("Please wait..."));
            },
            loading: () {
              return const Center(child: CircularProgressIndicator());
            },
            success: (response) {
              nameCtrl.text = response.name;
              _phoneController.text = response.phone;
              _addressController.text = response.address;
            },
            error: (error) => Center(child: Text('Error: $error')),
          );
        },
        builder: (context, state) {
          return SingleChildScrollView(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFD9BFFB), Color(0xFFEFEAFE)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: SafeArea(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            IconButton(
                              icon: Icon(Icons.arrow_back),
                              onPressed: () => Navigator.pop(context),
                            ),
                            Expanded(
                              child: Center(
                                child: Text(
                                  "Book Your Estimate",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 22,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),
                        _buildTextField(
                          controller: nameCtrl,
                          label: "Name",
                          readOnly: true,
                          icon: Icons.person,
                        ),
                        _buildTextField(
                          controller: _phoneController,
                          label: "Phone",
                          readOnly: true,
                          icon: Icons.call,
                          inputType: TextInputType.phone,
                        ),
                        _buildTextField(
                          controller: _addressController,
                          label: "Address",
                          readOnly: true,
                          icon: Icons.home,
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: _buildDateField(
                                text: Text(
                                  _startDateController.text.isEmpty
                                      ? ''
                                      : _startDateController.text,
                                  style: TextStyle(fontSize: 16),
                                ),
                                label: "Start Date",
                                icon: Icons.calendar_today,
                                onTap: () => selectStartDate(context),
                              ),
                            ),
                            SizedBox(width: 16),
                            Expanded(
                              child: _buildDateField(
                                text: Text(
                                  _endDateController.text.isEmpty
                                      ? ''
                                      : _endDateController.text,
                                  style: TextStyle(fontSize: 16),
                                ),
                                label: "End Date",
                                icon: Icons.calendar_today,
                                onTap: () => selectEndDate(context),
                              ),
                            ),
                          ],
                        ),

                        Row(
                          children: [
                            Expanded(
                              child: _buildTextField(
                                controller: _centController,
                                label: "Cent",
                                readOnly: true,
                                icon: Icons.grass,
                              ),
                            ),
                            SizedBox(width: 16),
                            Expanded(
                              child: _buildTextField(
                                controller: _squareController,
                                label: "Square",
                                readOnly: true,
                                icon: Icons.square_foot,
                              ),
                            ),
                          ],
                        ),
                        _buildTextField(
                          controller: _amountController,
                          label: "Expected Amount",
                          readOnly: true,
                          icon: Icons.attach_money,
                          inputType: TextInputType.number,
                        ),
                        SizedBox(height: 18),
                        if (_pdfFile != null)
                          Stack(
                            children: [
                              Container(
                                padding: EdgeInsets.all(10),
                                color: Colors.grey.shade300,
                                width: 200,
                                height: 60,
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.picture_as_pdf,
                                      color: Colors.red,
                                      size: 32,
                                    ),
                                    SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        _pdfFile!.path.split('/').last,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Positioned(
                                top: 0,
                                right: 0,
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _pdfFile = null;
                                    });
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.red,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      Icons.close,
                                      size: 18,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: pickPdfFile,
                          icon: Icon(Icons.upload_file),
                          label: Text('Upload Suggestion'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.deepPurple,
                          ),
                        ),
                        SizedBox(height: 10),
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
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Checkbox(
                              value: acceptedTerms,
                              onChanged: (val) =>
                                  setState(() => acceptedTerms = val ?? false),
                            ),
                            Flexible(
                              child: GestureDetector(
                                onTap: _showTermsDialog,
                                child: const Text(
                                  "I agree to the Terms and Conditions",
                                  style: TextStyle(
                                    decoration: TextDecoration.underline,
                                    color: Colors.deepPurple,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 32),
                        SwipeButton.expand(
                          thumb: const Icon(
                            Icons.double_arrow,
                            color: Colors.white,
                          ),
                          activeThumbColor: Colors.deepPurple,
                          activeTrackColor: Colors.deepPurple.shade100,
                          onSwipe: () async {
                            if (!acceptedTerms) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'You must accept the Terms and Conditions!',
                                  ),
                                ),
                              );
                              return;
                            }
                            if (_formKey.currentState?.validate() ?? false) {
                              await postEngineerBooking(); // <-- This posts to the API
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => FeedbackPage(
                                    userid: userId,
                                    engineerid: engineerId,
                                  ),
                                ),
                              );
                            }
                          },
                          child: const Text(
                            "BOOK NOW",
                            style: TextStyle(
                              color: Colors.deepPurple,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool readOnly = false,
    TextInputType inputType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 12),
        Text(label, style: TextStyle(fontWeight: FontWeight.w500)),
        SizedBox(height: 4),
        TextFormField(
          controller: controller,
          keyboardType: inputType,
          readOnly: readOnly,
          decoration: InputDecoration(
            prefixIcon: Icon(icon, size: 22),
            filled: true,
            fillColor: Colors.white,
            contentPadding: EdgeInsets.symmetric(vertical: 18, horizontal: 16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDateField({
    required String label,
    required IconData icon,
    required VoidCallback onTap,
    required Text text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontWeight: FontWeight.w500)),
        SizedBox(height: 4),
        InkWell(
          onTap: onTap,
          child: InputDecorator(
            decoration: InputDecoration(
              prefixIcon: Icon(icon),
              filled: true,
              fillColor: Colors.white,
              contentPadding: EdgeInsets.symmetric(
                vertical: 18,
                horizontal: 16,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: BorderSide.none,
              ),
            ),
            child: text,
          ),
        ),
      ],
    );
  }

  Future<void> selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 60)),
    );
    if (picked != null) {
      setState(() => selectedDate = picked);
    }
  }
}

class Feature {
  int id;
  String name;
  IconData icon;
  bool isSelected;
  Feature({
    required this.id,
    required this.name,
    required this.icon,
    this.isSelected = false,
  });
}
  