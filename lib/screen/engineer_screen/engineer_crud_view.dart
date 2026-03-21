import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class ProjectDetailsPage extends StatefulWidget {
  final int workId;
  const ProjectDetailsPage({super.key, required this.workId});

  @override
  State<ProjectDetailsPage> createState() => _ProjectDetailsPageState();
}

class _ProjectDetailsPageState extends State<ProjectDetailsPage> {
  final String baseUrl = "https://417sptdw-8001.inc1.devtunnels.ms";

  Map<String, dynamic>? work;
  bool isLoading = true;
  int currentImage = 0;
  PageController pageController = PageController();
File? selectedPropertyImage;
File? selectedWorkProofImage;
final ImagePicker picker = ImagePicker();
 
  bool isEditing = false;

  final TextEditingController projectNameController = TextEditingController();
  final TextEditingController categoryController = TextEditingController();
  final TextEditingController additionalAmountController =
      TextEditingController();
  final TextEditingController totalAmountController =
      TextEditingController();
  @override
  void initState() {
    super.initState();
    fetchWork();
  }

  Future<void> fetchWork() async {
    final response = await http.get(
      Uri.parse("$baseUrl/userapp/engineer/works/${widget.workId}/"),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        work = data["data"][0];
        isLoading = false;
      });
    }
  }

  Future<void> updateWork() async {
    var request = http.MultipartRequest(
      "PATCH",
      Uri.parse(
          "$baseUrl/userapp/engineer/work/update/${widget.workId}/"),
    );

    request.fields["project_name"] = projectNameController.text;
    request.fields["category"] = categoryController.text;
    request.fields["additional_amount"] =
        additionalAmountController.text;
    request.fields["total_amount"] = totalAmountController.text;

    var response = await request.send();

    if (!mounted) return;

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Updated Successfully")),
      );
      setState(() => isEditing = false);
      fetchWork();
    }
  }

  Future<void> deleteWork() async {
    final response = await http.delete(
      Uri.parse("$baseUrl/userapp/engineer/works/${widget.workId}/"),
    );

    if (response.statusCode == 204 && mounted) {
      Navigator.pop(context);
    }
  }
 

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final images = work?["images"] as List? ?? [];
final propertyImage=work?["property_image"];
    return Scaffold(
      backgroundColor: const Color(0xFFF8F7F6),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 120),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildPropertyImage(propertyImage),
                _buildTitleSection(),
                _buildQuickStats(),
                _buildFinancialCard(),
                _buildFeatures(),
                const SizedBox(height: 15),
                Text('WORK PROOF',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 17.0),),
                  const SizedBox(height: 10),
                _buildImageSlider(images),
              ],
            ),
          ),
          _buildTopBar(),
        ],
      ),
   //   bottomNavigationBar: _buildActionButtons(),
    );
  }

  Widget _buildTopBar() {
    return Positioned(
      top: 40,
      left: 16,
      right: 16,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _circleIcon(Icons.arrow_back, () => Navigator.pop(context)),
          //  _circleIcon(Icons.share, () {}),
        ],
      ),
    );
  }

  Widget _circleIcon(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.black87),
      ),
    );
  }
Widget _buildImageSlider(List images) {
  return SizedBox(
    height: 300,
    child: Stack(
      children: [
        PageView.builder(
          controller: pageController,
          itemCount: images.length,
          onPageChanged: (index) {
            setState(() => currentImage = index);
          },
          itemBuilder: (context, index) {
            return Stack(
              children: [
                Image.network(
                  "$baseUrl${images[index]}",
                  fit: BoxFit.cover,
                  width: double.infinity,
                ),

                /// ❌ Delete image button
                // Positioned(
                //   top: 16,
                //   right: 16,
                //   child: _circleActionIcon(Icons.close, () {
                // //    _deleteWorkProofImage(index);
                //   }),
                // ),
              ],
            );
          },
        ),

        // /// ➕ Add Image Button
        // Positioned(
        //   bottom: 16,
        //   right: 16,
        //   child: FloatingActionButton(
        //     mini: true,
        //     backgroundColor: const Color(0xFFEEBD2B),
        //     onPressed: _pickWorkProofImage,
        //     child: const Icon(Icons.add),
        //   ),
        // ),
      ],
    ),
  );
}
Future<void> _pickWorkProofImage() async {
  final XFile? image =
      await picker.pickImage(source: ImageSource.gallery);

  if (image != null) {
    File file = File(image.path);

    await updateWorkWithImage(
      imageFile: file,
    );
  }
}

Future<void> updateWorkWithImage({
  String? additionalAmount,
  String? totalAmount,
  File? imageFile,
}) async {
  var request = http.MultipartRequest(
    "PATCH",
    Uri.parse(
        "$baseUrl/userapp/engineer/work/update/${widget.workId}/"),
  );

  // Add text fields
  if (additionalAmount != null) {
    request.fields["additional_amount"] = additionalAmount;
  }

  if (totalAmount != null) {
    request.fields["total_amount"] = totalAmount;
  }

  // Add image file
  if (imageFile != null) {
    request.files.add(
      await http.MultipartFile.fromPath(
        "images", // must match Django field name
        imageFile.path,
      ),
    );
  }

  var response = await request.send();

  if (response.statusCode == 200) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Work updated successfully")),
    );
    fetchWork(); // refresh page
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Update failed")),
    );
  }
}

 Widget _buildPropertyImage(String? propertyImage) {
  return SizedBox(
    height: 300,
    child: Stack(
      children: [
        propertyImage != null
            ? Image.network(
                "$baseUrl$propertyImage",
                width: double.infinity,
                fit: BoxFit.cover,
              )
            : Container(
                color: Colors.grey.shade300,
                child: const Center(child: Text("No Property Image")),
              ),

        /// 🔙 Back button already handled in top bar

        /// ✏ Edit Button
        // Positioned(
        //   top: 50,
        //   right: 60,
        //   child: _circleActionIcon(Icons.edit, () {
        //     _pickPropertyImage();
        //   }),
        // ),

        /// ❌ Delete Button
        // Positioned(
        //   top: 50,
        //   right: 16,
        //   child: _circleActionIcon(Icons.close, () {
        //   //  _deletePropertyImage();
        //   }),
        // ),
      ],
    ),
  );
}
Future<void> _pickPropertyImage() async {
  final XFile? image =
      await picker.pickImage(source: ImageSource.gallery);

  if (image != null) {
    File file = File(image.path);

    await updateWorkWithImage(
      imageFile: file,
    );
  }
}

Widget _circleActionIcon(IconData icon, VoidCallback onTap) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.all(8),
      decoration: const BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
      ),
      child: Icon(icon, size: 20, color: Colors.black87),
    ),
  );
}

  Widget _buildTitleSection() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                work?["project_name"] ?? "",
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                work?["category"] ?? "",
                style: const TextStyle(
                  color: Color(0xFFEEBD2B),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          Column(
            children: [
             // const CircleAvatar(radius: 22),
              const SizedBox(height: 6),
              Text(
                work?["engineer"] ?? "",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStats() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          _statCard("Area", "${work?["cent"]} Cent"),
          _statCard("Total Sqft", work?["squarefeet"] ?? ""),
          _statCard("Duration", work?["time_duration"] ?? ""),
        ],
      ),
    );
  }

  Widget _statCard(String title, String value) {
    return Expanded(
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 6),
              Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFinancialCard() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          children: [
            _financeRow("Expected Amount", work?["expected_amount"]),
            _financeRow("Additional Amount", work?["additional_amount"]),
            const Divider(height: 30),
            _financeRow("Total Budget", work?["total_amount"], isTotal: true),
          ],
        ),
      ),
    );
  }

  Widget _financeRow(String label, String? value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            "₹ ${value ?? "0"}",
            style: TextStyle(
              fontSize: isTotal ? 18 : 14,
              fontWeight: FontWeight.bold,
              color: isTotal ? const Color(0xFFEEBD2B) : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatures() {
    final features = work?["additional_features"] as List? ?? [];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Wrap(
        spacing: 10,
        runSpacing: 10,
        children: features
            .map(
              (f) => Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFEEBD2B).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  f.toString(),
                  style: const TextStyle(
                    color: Color(0xFFEEBD2B),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(color: Colors.white),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () {
                // Navigate to edit page
              },
              child: const Text("Edit"),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: deleteWork,
              child: const Text("Delete"),
            ),
          ),
        ],
      ),
    );
  }
}
