import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:house_construction_pro/authantication/user_authentication/login_screen/login_view_page.dart';
import 'package:house_construction_pro/purchase_screen/view_cart/view_cart_screen.dart';
import 'package:house_construction_pro/purchase_screen/view_each_pro/view_each_pro_screen.dart';
import 'package:house_construction_pro/purchase_screen/view_product_home/view_product_model.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ShopScreen extends StatefulWidget {
  const ShopScreen({super.key, required this.userId});
  final int userId;

  @override
  State<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen> {
  List<Product> products = [];
  bool loading = true;
  int? userId;
  int? productId;

  static const Color kBg = Color(0xFF050505);
  static const Color kCard = Color(0xFF0D0D0D);
  static const Color kCard2 = Color(0xFF121212);
  static const Color kGold = Color(0xFFD4AF37);
  static const Color kGoldSoft = Color(0xFFE7C65A);
  static const Color kText = Color(0xFFF5F1E8);
  static const Color kSubText = Color(0xFFA4A099);
  static const Color kMuted = Color(0xFF6E675D);
  static const Color kBorder = Color(0xFF2A2316);

  @override
  void initState() {
    super.initState();
    fetchProducts();
    userId = widget.userId;
  }

  Future<void> storeUserId(int productId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('id', productId);
  }

  Future<int?> getUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    productId = prefs.getInt('id');
    return productId;
  }

  Future<void> _showLogoutDialog(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: kCard2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
          side: const BorderSide(color: kBorder),
        ),
        title: const Text(
          "Logout Alert",
          style: TextStyle(color: kText, fontWeight: FontWeight.w700),
        ),
        content: const Text(
          "Are you sure you want to logout?",
          style: TextStyle(color: kSubText),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text(
              "No",
              style: TextStyle(color: kSubText),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: kGold,
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => LoginScreen()),
              );
            },
            child: const Text(
              "Yes, Logout",
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> fetchProducts() async {
    final url = 'https://417sptdw-8001.inc1.devtunnels.ms/userapp/products/';
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      setState(() {
        products = data.map((e) => Product.fromJson(e)).toList();
        loading = false;
      });
    } else {
      setState(() {
        loading = false;
      });
    }
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
        title: Column(
          children: const [
            SizedBox(height: 4),
            Text(
              'ENGINEERED EXCELLENCE',
              style: TextStyle(
                color: kGold,
                fontSize: 9,
                letterSpacing: 2.2,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'THE CURATED\nCOLLECTION',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: kText,
                height: 0.95,
                fontSize: 18,
                fontWeight: FontWeight.w500,
                fontFamily: 'Serif',
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
          : Column(
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 4, bottom: 18),
                  width: 72,
                  height: 1.2,
                  color: kGold.withOpacity(0.7),
                ),
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(10, 0, 10, 110),
                    itemCount: products.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 18),
                    itemBuilder: (context, index) {
                      final p = products[index];
                      return LuxuryProductCard(product: p, userId: userId!);
                    },
                  ),
                ),
              ],
            ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: kBg,
          border: Border(
            top: BorderSide(color: kBorder, width: 1),
          ),
        ),
        child: BottomNavigationBar(
          onTap: (index) {
            if (index == 0) {
              return;
            } else if (index == 1) {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => ViewCartItem(
                    userId: userId!,
                  ),
                ),
              );
            } else if (index == 2) {
              _showLogoutDialog(context);
            }
          },
          currentIndex: 0,
          backgroundColor: kBg,
          selectedItemColor: kGold,
          unselectedItemColor: kMuted,
          type: BottomNavigationBarType.fixed,
          elevation: 0,
          selectedLabelStyle: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.8,
          ),
          unselectedLabelStyle: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w500,
          ),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.auto_awesome_mosaic_outlined),
              activeIcon: Icon(Icons.auto_awesome_mosaic),
              label: "COLLECTION",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.shopping_bag_outlined),
              activeIcon: Icon(Icons.shopping_bag),
              label: "CART",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.logout_outlined),
              activeIcon: Icon(Icons.logout),
              label: "LOGOUT",
            ),
          ],
        ),
      ),
    );
  }
}

class LuxuryProductCard extends StatelessWidget {
  final Product product;
  final int userId;

  const LuxuryProductCard({
    required this.product,
    super.key,
    required this.userId,
  });

  static const Color kBg = Color(0xFF050505);
  static const Color kCard = Color(0xFF0D0D0D);
  static const Color kGold = Color(0xFFD4AF37);
  static const Color kGoldSoft = Color(0xFFE7C65A);
  static const Color kText = Color(0xFFF5F1E8);
  static const Color kSubText = Color(0xFFA4A099);
  static const Color kBorder = Color(0xFF2A2316);

  String getImageUrl(String relativeUrl) {
    return "https://417sptdw-8001.inc1.devtunnels.ms$relativeUrl";
  }

  String getSubtitle(Product product) {
    if ((product.quantity) <= 25) return "LIMITED STOCK | PREMIUM GRADE";
    if ((product.quantity) <= 100) return "TRIPLE WASHED | FINE QUALITY";
    return "ESSENTIAL INFRASTRUCTURE";
  }

  @override
  Widget build(BuildContext context) {
    final qty = (product.quantity).toDouble().clamp(0, 200);
    final progress = qty / 200.0;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 2),
      padding: const EdgeInsets.fromLTRB(10, 10, 10, 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: LinearGradient(
          colors: [
            const Color(0xFF101010),
            const Color(0xFF080808),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(
          color: kGold.withOpacity(0.28),
          width: 0.8,
        ),
        boxShadow: [
          BoxShadow(
            color: kGold.withOpacity(0.05),
            blurRadius: 30,
            spreadRadius: 1,
          ),
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
          _buildImage(),
          const SizedBox(height: 14),
          Text(
            getSubtitle(product),
            style: const TextStyle(
              color: kGold,
              fontSize: 8,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            product.name,
            style: const TextStyle(
              color: kText,
              fontSize: 17,
              height: 1.0,
              fontWeight: FontWeight.w500,
              fontFamily: 'Serif',
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Premium construction material with dependable quality and refined finish for modern builds.",
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: kSubText.withOpacity(0.88),
              fontSize: 11,
              height: 1.45,
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                "₹${product.price}",
                style: const TextStyle(
                  color: kGoldSoft,
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'Serif',
                ),
              ),
              const SizedBox(width: 6),
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  "/ qty ${product.quantity}",
                  style: const TextStyle(
                    color: kSubText,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: LinearProgressIndicator(
              minHeight: 4,
              value: progress,
              backgroundColor: const Color(0xFF1E1A14),
              valueColor: const AlwaysStoppedAnimation<Color>(kGold),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: kGold.withOpacity(0.9)),
                    foregroundColor: kGold,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  onPressed: () async {
                    final prefs = await SharedPreferences.getInstance();
                    await prefs.setInt('id', product.id);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        backgroundColor: Colors.black87,
                        content: Text(
                          'Your Product View more details!',
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    );
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) {
                          return ProductDetailScreen(
                            productId: product.id,
                            userId: userId,
                          );
                        },
                      ),
                    );
                  },
                  child: const Text(
                    "View Details  →",
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
              // const SizedBox(width: 12),
              // Container(
              //   decoration: BoxDecoration(
              //     color: kGold,
              //     borderRadius: BorderRadius.circular(24),
              //   ),
              //   child: InkWell(
              //     borderRadius: BorderRadius.circular(24),
              //     onTap: () async {
              //       final prefs = await SharedPreferences.getInstance();
              //       await prefs.setInt('id', product.id);
              //       ScaffoldMessenger.of(context).showSnackBar(
              //         SnackBar(
              //           backgroundColor: Colors.black87,
              //           content: Text(
              //             'Product ID ${product.id} saved!',
              //             style: const TextStyle(color: Colors.white),
              //           ),
              //         ),
              //       );
              //       Navigator.of(context).push(
              //         MaterialPageRoute(
              //           builder: (context) {
              //             return ProductDetailScreen(
              //               productId: product.id,
              //               userId: userId,
              //             );
              //           },
              //         ),
              //       );
              //     },
              //     child: const Padding(
              //       padding: EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              //       child: Text(
              //         "Reserve Batch",
              //         style: TextStyle(
              //           color: Colors.black,
              //           fontWeight: FontWeight.w700,
              //           fontSize: 12,
              //         ),
              //       ),
              //     ),
              //   ),
              // ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildImage() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: Container(
        height: 210,
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.blueGrey.shade900.withOpacity(0.25),
              Colors.black,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Image.network(
          getImageUrl(product.image),
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Container(
            color: const Color(0xFF111111),
            child: const Center(
              child: Icon(
                Icons.inventory_2_outlined,
                size: 46,
                color: Colors.white30,
              ),
            ),
          ),
          loadingBuilder: (context, child, progress) {
            if (progress == null) return child;
            return const Center(
              child: CircularProgressIndicator(
                color: kGold,
                strokeWidth: 2,
              ),
            );
          },
        ),
      ),
    );
  }
}