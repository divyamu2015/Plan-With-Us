import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';


class TermsandCondition extends StatefulWidget {
  const TermsandCondition({super.key});

  @override
  State<TermsandCondition> createState() => _TermsandConditionState();
}

class _TermsandConditionState extends State<TermsandCondition> {
  final _formKey = GlobalKey<FormState>();

  TextEditingController nameCtrl = TextEditingController();
  TextEditingController phoneCtrl = TextEditingController();
  TextEditingController addressCtrl = TextEditingController();
  TextEditingController centCtrl = TextEditingController();
  TextEditingController sqftCtrl = TextEditingController();
  TextEditingController expectedAmountCtrl = TextEditingController();
  TextEditingController featuresCtrl = TextEditingController();

  File? _image;
  DateTime? _startDate;
  DateTime? _endDate;
  bool acceptedTerms = false;

  // Replace with actual engineer name if available
  String engineerName = "Engineer Name";

  Future pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<void> _selectDate(bool isStart) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStart ? (_startDate ?? DateTime.now()) : (_endDate ?? DateTime.now()),
      firstDate: DateTime(2020),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
    }
  }

  void _showTermsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Terms and Conditions'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '''1. The engineer will provide only an initial estimate based on provided details.
2. The final construction cost may vary.
3. All permits and legal clearances are the owner’s responsibility.
4. Payment terms will be discussed and agreed separately.
5. Features requested by the user are subject to site feasibility.
6. The company/engineer is not liable for delays due to unforeseen circumstances (weather, supply chain, etc).
7. By accepting, you agree to share your details with the assigned engineer for further communication.''',
              ),
              SizedBox(height: 20),
              Text(getAgreementContent(
                nameCtrl.text.isEmpty ? "User" : nameCtrl.text,
                engineerName,
              )),
            ],
          ),
        ),
        actions: [
          TextButton(
            child: Text('Accept'),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF8EC5FC), Color(0xFFE0C3FC)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    Text(
                      "Request Form",
                      style: TextStyle(
                        fontSize: 28,
                        color: Colors.deepPurple,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 20),
                    _buildTextField(nameCtrl, "Name"),
                    _buildTextField(phoneCtrl, "Phone", keyboardType: TextInputType.phone),
                    _buildTextField(addressCtrl, "Address"),
                    _buildTextField(centCtrl, "Cent", keyboardType: TextInputType.number),
                    _buildTextField(sqftCtrl, "Square Feet", keyboardType: TextInputType.number),
                    _buildTextField(expectedAmountCtrl, "Expected Amount", keyboardType: TextInputType.number),
                    _buildTextField(featuresCtrl, "Additional Features", maxLines: 2),
                    SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(child: _datePickerField("Start Date", _startDate, () => _selectDate(true))),
                        SizedBox(width: 10),
                        Expanded(child: _datePickerField("End Date", _endDate, () => _selectDate(false))),
                      ],
                    ),
                    SizedBox(height: 12),
                    Row(
                      children: [
                        ElevatedButton.icon(
                          onPressed: pickImage,
                          icon: Icon(Icons.upload_file),
                          label: Text('Upload Suggestion'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.deepPurple,
                          ),
                        ),
                        SizedBox(width: 12),
                        _image != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(6),
                                child: Image.file(_image!, height: 40, width: 40, fit: BoxFit.cover),
                              )
                            : Container(),
                      ],
                    ),
                    SizedBox(height: 24),
                    Row(
                      children: [
                        Checkbox(
                          value: acceptedTerms,
                          onChanged: (val) => setState(() => acceptedTerms = val ?? false),
                        ),
                        Flexible(
                          child: GestureDetector(
                            onTap: _showTermsDialog,
                            child: Text(
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
                    SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        if (!acceptedTerms) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("You must accept the Terms and Conditions!")),
                          );
                          return;
                        }
                        if (_formKey.currentState?.validate() ?? false) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("Request Submitted!")),
                          );
                          // Handle your submission logic here
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                        padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                      ),
                      child: Text(
                        "Request",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
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
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint,
      {TextInputType keyboardType = TextInputType.text, int maxLines = 1}) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        decoration: InputDecoration(
          hintText: hint,
          fillColor: Colors.white,
          filled: true,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
        validator: (val) {
          if (val == null || val.isEmpty) return "Required";
          return null;
        },
      ),
    );
  }

  Widget _datePickerField(String label, DateTime? date, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.deepPurple.shade100),
        ),
        child: Row(
          children: [
            Icon(Icons.calendar_today, size: 20, color: Colors.deepPurple),
            SizedBox(width: 10),
            Text(
              date != null ? "${date.day}/${date.month}/${date.year}" : label,
              style: TextStyle(color: Colors.black87, fontSize: 16, letterSpacing: 0.2),
            ),
          ],
        ),
      ),
    );
  }
}
