import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class WishlistScreenAdd extends StatefulWidget {
  final int userId;

  const WishlistScreenAdd({super.key, required this.userId});

  @override
  State<WishlistScreenAdd> createState() => _WishlistScreenAddState();
}

class _WishlistScreenAddState extends State<WishlistScreenAdd> {
  List wishlist = [];
  bool loading = true;

  static const Color kBg = Color(0xFF050505);
  static const Color kGold = Color(0xFFD4AF37);
  static const Color kGoldSoft = Color(0xFFE7C65A);
  static const Color kText = Color(0xFFF5F1E8);
  static const Color kSubText = Color(0xFFA4A099);
  static const Color kBorder = Color(0xFF2A2316);

  final String baseUrl = "https://417sptdw-8001.inc1.devtunnels.ms";

  @override
  void initState() {
    super.initState();
    fetchWishlist();
  }

  Future<void> fetchWishlist() async {
    final url = Uri.parse("$baseUrl/userapp/wishlist/${widget.userId}/");

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        setState(() {
          wishlist = jsonDecode(response.body);
          loading = false;
        });
      } else {
        setState(() => loading = false);
      }
    } catch (e) {
      setState(() => loading = false);
    }
  }

  String getImageUrl(String image) {
    return "$baseUrl$image";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      appBar: AppBar(
        backgroundColor: kBg,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: kText),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: const Column(
          children: [
            Text(
              "MY SAVED ITEMS",
              style: TextStyle(
                color: kGold,
                fontSize: 9,
                letterSpacing: 2.2,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: 8),
            Text(
              "WISHLIST\nCOLLECTION",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: kText,
                height: 0.95,
                fontSize: 18,
                fontWeight: FontWeight.w500,
                fontFamily: "Serif",
              ),
            ),
          ],
        ),
        toolbarHeight: 100,
      ),
      body: loading
          ? const Center(
              child: CircularProgressIndicator(color: kGold),
            )
          : wishlist.isEmpty
              ? const Center(
                  child: Text(
                    "No wishlist products",
                    style: TextStyle(color: kSubText),
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(18, 20, 18, 100),
                  itemCount: wishlist.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 22),
                  itemBuilder: (context, index) {
                    final item = wishlist[index];
                    final product = item["product"];

                    return Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0D0D0D),
                        borderRadius: BorderRadius.circular(28),
                        border: Border.all(
                          color: kGold.withOpacity(0.28),
                          width: 0.8,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.45),
                            blurRadius: 20,
                            offset: const Offset(0, 14),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(22),
                            child: Image.network(
                              getImageUrl(product["image"]),
                              height: 210,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                height: 210,
                                color: const Color(0xFF111111),
                                child: const Icon(
                                  Icons.image_not_supported,
                                  color: Colors.white30,
                                  size: 45,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 16),

                          const Text(
                            "WISHLISTED PRODUCT",
                            style: TextStyle(
                              color: kGold,
                              fontSize: 8,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.2,
                            ),
                          ),

                          const SizedBox(height: 10),

                          Text(
                            product["name"] ?? "",
                            style: const TextStyle(
                              color: kText,
                              fontSize: 20,
                              height: 1.0,
                              fontWeight: FontWeight.w500,
                              fontFamily: "Serif",
                            ),
                          ),

                          const SizedBox(height: 10),

                          Text(
                            "Saved construction material from your curated collection.",
                            style: TextStyle(
                              color: kSubText.withOpacity(0.88),
                              fontSize: 12,
                              height: 1.45,
                            ),
                          ),

                          const SizedBox(height: 16),

                          Row(
                            children: [
                              Text(
                                "₹${product["price"]}",
                                style: const TextStyle(
                                  color: kGoldSoft,
                                  fontSize: 30,
                                  fontWeight: FontWeight.w700,
                                  fontFamily: "Serif",
                                ),
                              ),
                              const Spacer(),
                              const Icon(
                                Icons.favorite,
                                color: Colors.red,
                                size: 28,
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
    );
  }
}