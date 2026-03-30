import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:house_construction_pro/constant_page.dart';
import 'package:house_construction_pro/screen/engineer_screen/engineer_crud_view.dart';
import 'package:house_construction_pro/screen/engineer_screen/engineer_view_list_works_uploads/view_engineer_details.dart';
import 'package:http/http.dart' as http;

class EngineerWorksListScreen extends StatefulWidget {
  final int engineerId;

  const EngineerWorksListScreen({
    super.key,
    required this.engineerId,
  });

  @override
  State<EngineerWorksListScreen> createState() =>
      _EngineerWorksListScreenState();
}

class _EngineerWorksListScreenState extends State<EngineerWorksListScreen> {
  bool isLoading = true;
  String? error;
  List<dynamic> works = [];

  static const Color kPageBg = Color(0xFFF8F6F1);
  static const Color kSurface = Color(0xFFFFFDFC);
  static const Color kSurface2 = Color(0xFFF2EEE6);
  static const Color kCardBorder = Color(0xFFE7E0D4);
  static const Color kPrimary = Color(0xFF2F6B57);
  static const Color kPrimaryDark = Color(0xFF234E40);
  static const Color kText = Color(0xFF1F2937);
  static const Color kSubText = Color(0xFF6B7280);
  static const Color kDanger = Color(0xFFD9534F);
  static const Color kGoldSoft = Color(0xFFB48A3C);

  @override
  void initState() {
    super.initState();
    fetchEngineerWorks();
  }

  Future<void> fetchEngineerWorks() async {
    final url = "$baseUri/userapp/engineer/works/${widget.engineerId}/";

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final decodedData = jsonDecode(response.body);

        setState(() {
          works = decodedData['data'] ?? [];
          isLoading = false;
          error = null;
        });
      } else {
        setState(() {
          isLoading = false;
          error = "Failed to load works: ${response.statusCode}";
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        error = e.toString();
      });
    }
  }

  Future<void> deleteWork(int workId) async {
    final url = "$baseUri/userapp/engineer/work/delete/$workId/";

    try {
      final response = await http.delete(Uri.parse(url));

      if (!mounted) return;

      if (response.statusCode == 200 || response.statusCode == 204) {
        setState(() {
          works.removeWhere((work) => work['id'] == workId);
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Work deleted successfully")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Delete failed: ${response.statusCode}")),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  Future<void> confirmDelete(int workId) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Work"),
        content: const Text("Are you sure you want to delete this work?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              "Delete",
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (shouldDelete == true) {
      await deleteWork(workId);
    }
  }

  String getFullImageUrl(String? path) {
    if (path == null || path.isEmpty) return "";
    if (path.startsWith("http")) return path;
    return "$imageUrl$path";
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 14, 12, 16),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(
              Icons.arrow_back_ios_new,
              color: kPrimary,
              size: 24,
            ),
          ),
          Expanded(
            child: Center(
              child: Column(
                children: [
                  const Text(
                    "YOUR WORKS",
                    style: TextStyle(
                      color: kText,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 2,
                      fontSize: 18,
                    ),
                  ),
                  Text(
                    "${works.length} works",
                    style: const TextStyle(
                      color: kSubText,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildWorkCard(dynamic work) {
    final propertyImageUrl = getFullImageUrl(work['property_image']);
    final engineer = (work['engineer'] ?? '').toString();
    final projectName = (work['project_name'] ?? '').toString();
    final category = (work['category'] ?? '').toString();
    final cent = (work['cent'] ?? '').toString();
    final timeDuration = (work['time_duration'] ?? '').toString();

    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        color: kSurface,
        border: Border.all(color: kCardBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(26)),
            child: Stack(
              children: [
                SizedBox(
                  height: 220,
                  width: double.infinity,
                  child: propertyImageUrl.isNotEmpty
                      ? Image.network(
                          propertyImageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            color: Colors.grey[200],
                            child: const Center(
                              child: Icon(
                                Icons.image_not_supported,
                                size: 40,
                                color: kDanger,
                              ),
                            ),
                          ),
                        )
                      : Container(
                          color: Colors.grey[200],
                          child: const Center(
                            child: Icon(
                              Icons.image_not_supported,
                              size: 40,
                              color: kDanger,
                            ),
                          ),
                        ),
                ),

                Positioned(
                  top: 12,
                  right: 12,
                  child: Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.edit, color: kPrimary),
                          onPressed: () async {
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ProjectDetailsPage(
                                  workId: work['id'],
                                ),
                              ),
                            );

                            if (result == true) {
                              fetchEngineerWorks();
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.delete, color: kDanger),
                          onPressed: () {
                            confirmDelete(work['id']);
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  projectName,
                  style: const TextStyle(
                    color: kPrimary,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    height: 1.15,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Engineer: $engineer",
                  style: const TextStyle(
                    color: kSubText,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _infoBox(
                        title: "Category",
                        value: category,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _infoBox(
                        title: "Cent",
                        value: cent,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                _infoBox(
                  title: "Time Duration",
                  value: timeDuration,
                  fullWidth: true,
                ),
                const SizedBox(height: 18),
                Align(
                  alignment: Alignment.centerRight,
                  child: SizedBox(
                    width: 150,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ViewProjectDetailsPage(
                              workId: work['id'],
                            ),
                          ),
                        );

                        if (result == true) {
                          fetchEngineerWorks();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kPrimary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text(
                        "View Details",
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoBox({
    required String title,
    required String value,
    bool fullWidth = false,
  }) {
    return Container(
      width: fullWidth ? double.infinity : null,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: kSurface2,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: kCardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title.toUpperCase(),
            style: const TextStyle(
              color: kSubText,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.1,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              color: kText,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: kPrimary),
      );
    }

    if (error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            error!,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: kPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      );
    }

    if (works.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 50,
              child: Icon(Icons.close, color: Colors.red, size: 45),
            ),
            SizedBox(height: 12),
            Text(
              "No works uploaded yet",
              style: TextStyle(
                color: kSubText,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(18, 0, 18, 24),
      itemCount: works.length,
      itemBuilder: (context, index) {
        return _buildWorkCard(works[index]);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kPageBg,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(child: _buildBody()),
          ],
        ),
      ),
    );
  }
}