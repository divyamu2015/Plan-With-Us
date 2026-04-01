import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:house_construction_pro/constant_page.dart';
import 'package:http/http.dart' as http;

class ProjectDetailsPage extends StatefulWidget {
  final int workId;
  const ProjectDetailsPage({super.key, required this.workId});

  @override
  State<ProjectDetailsPage> createState() => _ProjectDetailsPageState();
}

class _ProjectDetailsPageState extends State<ProjectDetailsPage> {
  Map<String, dynamic>? work;
  bool isLoading = true;
  bool isEditing = false;
  bool isUpdating = false;

  int currentImage = 0;
  final PageController pageController = PageController();

  final TextEditingController projectNameController = TextEditingController();
  final TextEditingController categoryController = TextEditingController();
  final TextEditingController centController = TextEditingController();
  final TextEditingController squarefeetController = TextEditingController();
  final TextEditingController timeDurationController = TextEditingController();
  final TextEditingController expectedAmountController = TextEditingController();
  final TextEditingController additionalAmountController =
      TextEditingController();
  final TextEditingController totalAmountController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchWork();
  }

  @override
  void dispose() {
    pageController.dispose();
    projectNameController.dispose();
    categoryController.dispose();
    centController.dispose();
    squarefeetController.dispose();
    timeDurationController.dispose();
    expectedAmountController.dispose();
    additionalAmountController.dispose();
    totalAmountController.dispose();
    super.dispose();
  }

  Future<void> fetchWork() async {
    try {
      final response = await http.get(
        Uri.parse("$baseUri/userapp/engineer/works/${widget.workId}/"),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final fetchedWork = data["data"][0];

        setState(() {
          work = fetchedWork;

          projectNameController.text =
              fetchedWork["project_name"]?.toString() ?? "";
          categoryController.text = fetchedWork["category"]?.toString() ?? "";
          centController.text = fetchedWork["cent"]?.toString() ?? "";
          squarefeetController.text =
              fetchedWork["squarefeet"]?.toString() ?? "";
          timeDurationController.text =
              fetchedWork["time_duration"]?.toString() ?? "";
          expectedAmountController.text =
              fetchedWork["expected_amount"]?.toString() ?? "";
          additionalAmountController.text =
              fetchedWork["additional_amount"]?.toString() ?? "";
          totalAmountController.text =
              fetchedWork["total_amount"]?.toString() ?? "";

          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
      }
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  Future<void> updateWork() async {
    if (work == null) return;

    setState(() => isUpdating = true);

    try {
      final request = http.MultipartRequest(
        "PATCH",
        Uri.parse("$baseUri/userapp/engineer/work/update/${widget.workId}/"),
      );

      void addIfChanged(String key, TextEditingController controller) {
        final newValue = controller.text.trim();
        final oldValue = work?[key]?.toString() ?? "";
        if (newValue != oldValue) {
          request.fields[key] = newValue;
        }
      }

      addIfChanged("project_name", projectNameController);
      addIfChanged("category", categoryController);
      addIfChanged("cent", centController);
      addIfChanged("squarefeet", squarefeetController);
      addIfChanged("time_duration", timeDurationController);
      addIfChanged("expected_amount", expectedAmountController);
      addIfChanged("additional_amount", additionalAmountController);
      addIfChanged("total_amount", totalAmountController);

      if (request.fields.isEmpty) {
        setState(() => isUpdating = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("No changes made")),
        );
        return;
      }

      final response = await request.send();
      final body = await response.stream.bytesToString();

      setState(() => isUpdating = false);

      if (!mounted) return;

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Updated Successfully")),
        );
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Update failed: ${response.statusCode} $body"),
          ),
        );
      }
    } catch (e) {
      setState(() => isUpdating = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  Widget _editableField({
    required String label,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Positioned(
      top: 40,
      left: 16,
      right: 16,
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.arrow_back, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPropertyImage(String? propertyImage) {
    return SizedBox(
      height: 300,
      width: double.infinity,
      child: propertyImage != null
          ? Image.network(
              "$imageUrl$propertyImage",
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                color: Colors.grey.shade300,
                child: const Center(child: Text("No Property Image")),
              ),
            )
          : Container(
              color: Colors.grey.shade300,
              child: const Center(child: Text("No Property Image")),
            ),
    );
  }

  Widget _buildTitleSection() {
    final engineerName = work?["engineer"]?.toString() ?? "";

    if (isEditing) {
      return Column(
        children: [
          _editableField(
            label: "Project Name",
            controller: projectNameController,
          ),
          _editableField(
            label: "Category",
            controller: categoryController,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Align(
              alignment: Alignment.centerRight,
              child: Text(
                engineerName,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
          ),
        ],
      );
    }

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                projectNameController.text,
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                categoryController.text,
                style: const TextStyle(
                  color: Color(0xFFEEBD2B),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          Text(
            engineerName,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStatsOrFields() {
    if (isEditing) {
      return Column(
        children: [
          _editableField(
            label: "Area (Cent)",
            controller: centController,
            keyboardType: TextInputType.number,
          ),
          _editableField(
            label: "Total Sqft",
            controller: squarefeetController,
            keyboardType: TextInputType.number,
          ),
          _editableField(
            label: "Duration",
            controller: timeDurationController,
          ),
        ],
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          _statCard("Area", "${centController.text} Cent"),
          _statCard("Total Sqft", squarefeetController.text),
          _statCard("Duration", timeDurationController.text),
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
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 6),
              Text(
                value,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFinancialSection() {
    if (isEditing) {
      return Column(
        children: [
          _editableField(
            label: "Expected Amount",
            controller: expectedAmountController,
            keyboardType: TextInputType.number,
          ),
          _editableField(
            label: "Additional Amount",
            controller: additionalAmountController,
            keyboardType: TextInputType.number,
          ),
          _editableField(
            label: "Total Budget",
            controller: totalAmountController,
            keyboardType: TextInputType.number,
          ),
        ],
      );
    }

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
            _financeRow("Expected Amount", expectedAmountController.text),
            _financeRow("Additional Amount", additionalAmountController.text),
            const Divider(height: 30),
            _financeRow("Total Budget", totalAmountController.text, isTotal: true),
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
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
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

  Widget _buildImageSlider(List images) {
    return SizedBox(
      height: 300,
      child: PageView.builder(
        controller: pageController,
        itemCount: images.length,
        onPageChanged: (index) {
          setState(() => currentImage = index);
        },
        itemBuilder: (context, index) {
          return Image.network(
            "$imageUrl${images[index]}",
            fit: BoxFit.cover,
            width: double.infinity,
            errorBuilder: (_, __, ___) => Container(
              color: Colors.grey.shade300,
              child: const Center(child: Icon(Icons.broken_image, size: 40)),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBottomButton() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(color: Colors.white),
      child: Center(
        child: SizedBox(
          width: 220,
          height: 52,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  isEditing ? const Color(0xFF2F6B57) : Colors.white,
              foregroundColor:
                  isEditing ? Colors.white : const Color(0xFF6C5B9A),
              side: isEditing
                  ? BorderSide.none
                  : const BorderSide(color: Color(0xFF6C5B9A)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            onPressed: isUpdating
                ? null
                : () {
                    if (isEditing) {
                      updateWork();
                    } else {
                      setState(() {
                        isEditing = true;
                      });
                    }
                  },
            child: isUpdating
                ? const SizedBox(
                    height: 22,
                    width: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : Text(
                    isEditing ? "Update" : "Edit",
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final images = work?["images"] as List? ?? [];
    final propertyImage = work?["property_image"];

    return Scaffold(
      backgroundColor: const Color(0xFFF8F7F6),
      body: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 120),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildPropertyImage(propertyImage),
                  _buildTitleSection(),
                  _buildQuickStatsOrFields(),
                  _buildFinancialSection(),
                  _buildFeatures(),
                  const SizedBox(height: 15),
                  const Text(
                    'WORK PROOF',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 17.0,
                    ),
                  ),
                  const SizedBox(height: 10),
                  _buildImageSlider(images),
                ],
              ),
            ),
            _buildTopBar(),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomButton(),
    );
  }
}