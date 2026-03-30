import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:house_construction_pro/purchase_screen/cart_screen.dart';
import 'package:house_construction_pro/purchase_screen/list_screen.dart';
import 'package:image_picker/image_picker.dart';

class FormPage extends StatefulWidget {
  const FormPage({super.key});

  @override
  State<FormPage> createState() => _FormPageState();
}

class _FormPageState extends State<FormPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _itemController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _offerController = TextEditingController();
  final TextEditingController _stockController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  File? _imageFile;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    final XFile? picked = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (picked != null) {
      setState(() {
        _imageFile = File(picked.path);
      });
    }
  }

  // void _submit() {
  //   if (_formKey.currentState?.validate() ?? false) {
  //     final data = {
  //       'item': _itemController.text.trim(),
  //       'price': double.tryParse(_priceController.text) ?? 0.0,
  //       'offer': double.tryParse(_offerController.text) ?? 0.0,
  //       'stock': int.tryParse(_stockController.text) ?? 0,
  //       'description': _descriptionController.text.trim(),
  //       'imagePath': _imageFile?.path,
  //     };

  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text('Saved: ${data['item']}')),
  //     );

  //     // Navigate to ListDisplay after saving
  //     Navigator.push(
  //       context,
  //       MaterialPageRoute(builder: (context) => const ListDisplay()),
  //     );
  //   }
  // }

  @override
  void dispose() {
    _itemController.dispose();
    _priceController.dispose();
    _offerController.dispose();
    _stockController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
   // final Color primaryColor = const Color(0xFFB3E5FC); // Light Blue
    final Color accentColor = const Color(0xFF81D4FA);
    final Color backgroundColor = const Color(0xFFF5F9FC);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        elevation: 0,
        title: Padding(
          padding: const EdgeInsets.only(left: 20),
          child: Text(
            'Welcome Admin',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ),
        actions: [
          IconButton(
            icon:
                const Icon(Icons.shopping_cart, color: Colors.black87),
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => const CartScreen()));
            },
          )
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Container(
            width: 720,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  // ignore: deprecated_member_use
                  color: Colors.black12.withOpacity(0.08),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  Container(
                    height: 70,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      // ignore: deprecated_member_use
                      color: accentColor.withOpacity(0.6),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(24),
                        topRight: Radius.circular(24),
                      ),
                    ),
                    child: Center(
                      child: Text(
                        "Item info",
                        style: GoogleFonts.poppins(
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),

                  // Item Name
                  _buildTextField(_itemController, "Item Name",
                      validator: (v) =>
                          (v == null || v.isEmpty) ? "Enter item name" : null),
                  const SizedBox(height: 15),

                  // Price and Offer
                  Row(
                    children: [
                      Expanded(
                        child: _buildTextField(
                          _priceController,
                          "Price",
                          keyboardType:
                              const TextInputType.numberWithOptions(decimal: true),
                          validator: (v) {
                            if (v == null || v.isEmpty) return "Enter price";
                            if (double.tryParse(v) == null) return "Invalid number";
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _buildTextField(
                          _offerController,
                          "Offer",
                          keyboardType:
                              const TextInputType.numberWithOptions(decimal: true),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),

                  // Stock
                  _buildTextField(
                    _stockController,
                    "Stock Quantity",
                    keyboardType: TextInputType.number,
                    validator: (v) {
                      if (v == null || v.isEmpty) return "Enter stock count";
                      if (int.tryParse(v) == null) return "Invalid number";
                      return null;
                    },
                  ),
                  const SizedBox(height: 15),

                  // Description
                  _buildTextField(
                    _descriptionController,
                    "Description",
                    maxLines: 4,
                    validator: (v) =>
                        (v == null || v.isEmpty) ? "Enter description" : null,
                  ),
                  const SizedBox(height: 15),

                  // Image Upload Field (styled like textfield)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: GestureDetector(
                      onTap: _pickImage,
                      child: Container(
                        height: 55,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          color: const Color(0xFFF8FAFB),
                          border: Border.all(color: const Color(0xFFB0BEC5)),
                        ),
                        child: Row(
                          children: [
                            SizedBox(width: 17,),
                            Expanded(
                              child: Text(
                                _imageFile != null
                                    ? "Image selected"
                                    : "Upload Image",
                                style: GoogleFonts.poppins(
                                  fontSize: 15,
                                  color: Colors.grey[700],
                                ),
                              ),
                            ),
                            if (_imageFile != null)
                              Padding(
                                padding:
                                    const EdgeInsets.only(right: 12),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.file(
                                    _imageFile!,
                                    width: 40,
                                    height: 40,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  // Save Button
                  Padding(
                    padding: const EdgeInsets.only(bottom: 30),
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 251, 221, 172),
                        foregroundColor: Colors.black87,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 40, vertical: 16),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: (){
                        Navigator.push(context, MaterialPageRoute(builder: (context) => ListDisplay()));
                      },
                      label: Text("Submit",
                          style: GoogleFonts.poppins(fontSize: 16)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Reusable text field
  Widget _buildTextField(
    TextEditingController controller,
    String label, {
    TextInputType? keyboardType,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: GoogleFonts.poppins(color: Colors.grey[800]),
          filled: true,
          fillColor: const Color(0xFFF8FAFB),
          border: OutlineInputBorder(
            gapPadding: 5,
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFFB0BEC5)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFF81D4FA), width: 2),
          ),
        ),
        validator: validator,
      ),
    );
  }
}
