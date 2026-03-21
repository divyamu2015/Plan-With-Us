import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:house_construction_pro/purchase_screen/add_cart/add_cart_view.dart';
import 'package:house_construction_pro/purchase_screen/payment.dart';
import 'package:house_construction_pro/purchase_screen/view_each_pro/view_each_pro_model.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ProductDetailScreen extends StatefulWidget {
  final int productId;
  final int userId;
  const ProductDetailScreen({
    super.key,
    required this.productId,
    required this.userId,
  });

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  ProductDetail? product;
  bool loading = true;
  int quantity = 1;
  int? productId;
  int? userId;
  int? cartId;
  int? bookingId;
  String paymentChoice = 'booking_payment';

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
    fetchProductDetail();
    productId = widget.productId;
    userId = widget.userId;
  }

  double get totalPrice {
    if (product == null) return 0;
    return quantity * (double.tryParse(product!.price) ?? 0.0);
  }

  Future<void> fetchProductDetail() async {
    final url =
        'https://417sptdw-8001.inc1.devtunnels.ms/userapp/product/${widget.productId}/';
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        product = ProductDetail.fromJson(data);
        loading = false;
      });
    } else {
      setState(() {
        loading = false;
      });
    }
  }

  String getImageUrl(String relativeUrl) {
    return "https://417sptdw-8001.inc1.devtunnels.ms$relativeUrl";
  }

  Future<void> addToCart() async {
    final url =
        'https://417sptdw-8001.inc1.devtunnels.ms/userapp/cart/${widget.productId}/';
    final body = {
      "user_id": widget.userId,
      "product_id": widget.productId,
      "quantity": quantity,
      "total_price": totalPrice,
    };

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      final Map<String, dynamic> jsonMap = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        cartId = jsonMap["cart_item"]["id"];

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Item added to cart!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to add item to cart: ${response.reasonPhrase}',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error: Could not add item to cart'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> saveBuyNow(BuildContext context) async {
    final url =
        'https://417sptdw-8001.inc1.devtunnels.ms/userapp/product-bookings/';

    if (userId == null) {
      showError('User ID is missing.');
      return;
    }

    final Map<String, dynamic> requestBody = {
      "user_id": widget.userId,
      "product_id": widget.productId,
      "quantity": quantity,
      "total_price": totalPrice,
    };

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      final Map<String, dynamic> jsonMap = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        bookingId = jsonMap["data"]["id"];

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Processing Successfully'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) {
              return PaymentOpp(
                userId: userId,
                bookingId: bookingId,
                totalPayment: totalPrice,
                paymentChoice: paymentChoice,
              );
            },
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to add item to cart: ${response.reasonPhrase}',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error: Could not add item to cart'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void showError(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message), backgroundColor: Colors.red));
  }

  void showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }

  String _productTag() {
    if (product == null) return "CURATED MATERIAL";
    if (product!.quantity <= 25) return "LIMITED STOCK";
    if (product!.quantity <= 100) return "PREMIUM BUILDING MATERIAL";
    return "ESSENTIAL INFRASTRUCTURE";
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: kBg,
      body: SafeArea(
        child: loading
            ? const Center(
                child: CircularProgressIndicator(color: kGold),
              )
            : product == null
                ? const Center(
                    child: Text(
                      "Product not found",
                      style: TextStyle(color: kText),
                    ),
                  )
                : SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                color: kCard2,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: kBorder),
                              ),
                              child: IconButton(
                                icon: const Icon(
                                  Icons.arrow_back,
                                  color: kText,
                                  size: 26,
                                ),
                                onPressed: () => Navigator.of(context).pop(),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        const Center(
                          child: Text(
                            "ENGINEERED EXCELLENCE",
                            style: TextStyle(
                              color: kGold,
                              fontSize: 9,
                              letterSpacing: 2.4,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),

                        const SizedBox(height: 10),

                        Center(
                          child: Text(
                            product!.name.toUpperCase(),
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: kText,
                              fontSize: 24,
                              height: 1.05,
                              fontWeight: FontWeight.w500,
                              fontFamily: 'Serif',
                            ),
                          ),
                        ),

                        const SizedBox(height: 12),

                        Center(
                          child: Container(
                            width: 70,
                            height: 1.2,
                            color: kGold.withOpacity(0.8),
                          ),
                        ),

                        const SizedBox(height: 28),

                        Center(
                          child: Container(
                            width: width * 0.78,
                            constraints: BoxConstraints(
                              minHeight: height * 0.34,
                              maxHeight: height * 0.48,
                            ),
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(30),
                              gradient: LinearGradient(
                                colors: [
                                  Colors.blueGrey.shade900.withOpacity(0.30),
                                  const Color(0xFF111111),
                                  const Color(0xFF090909),
                                ],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                              ),
                              border: Border.all(
                                color: kGold.withOpacity(0.25),
                                width: 0.9,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.45),
                                  blurRadius: 26,
                                  offset: const Offset(0, 18),
                                ),
                                BoxShadow(
                                  color: kGold.withOpacity(0.06),
                                  blurRadius: 36,
                                  spreadRadius: 1,
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(24),
                              child: AspectRatio(
                                aspectRatio: 0.90,
                                child: Image.network(
                                  getImageUrl(product!.image),
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Container(
                                    color: const Color(0xFF111111),
                                    child: const Center(
                                      child: Icon(
                                        Icons.inventory_2_outlined,
                                        size: 48,
                                        color: Colors.white30,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 24),

                        Text(
                          _productTag(),
                          style: const TextStyle(
                            color: kGold,
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.8,
                          ),
                        ),

                        const SizedBox(height: 12),

                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              "₹${totalPrice.toStringAsFixed(2)}",
                              style: const TextStyle(
                                color: kGoldSoft,
                                fontSize: 34,
                                fontWeight: FontWeight.w700,
                                fontFamily: 'Serif',
                              ),
                            ),
                            const SizedBox(width: 8),
                            Padding(
                              padding: const EdgeInsets.only(bottom: 6),
                              child: Text(
                                "/ ${product!.quantity} available",
                                style: const TextStyle(
                                  color: kSubText,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 18),

                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: kCard2,
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(color: kBorder),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _qtyButton(
                                icon: Icons.remove,
                                onTap: () {
                                  setState(() {
                                    if (quantity > 1) quantity--;
                                  });
                                },
                              ),
                              Container(
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 14),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 18,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: kCard,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Text(
                                  quantity.toString(),
                                  style: const TextStyle(
                                    color: kText,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              _qtyButton(
                                icon: Icons.add,
                                onTap: () {
                                  setState(() {
                                    if (quantity < product!.quantity) {
                                      quantity++;
                                    }
                                  });
                                },
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 22),

                        Text(
                          product!.description,
                          style: TextStyle(
                            color: kSubText.withOpacity(0.95),
                            fontSize: 14,
                            height: 1.7,
                            fontWeight: FontWeight.w400,
                          ),
                        ),

                        const SizedBox(height: 24),

                        ClipRRect(
                          borderRadius: BorderRadius.circular(14),
                          child: LinearProgressIndicator(
                            minHeight: 5,
                            value: (product!.quantity.clamp(0, 200)) / 200.0,
                            backgroundColor: const Color(0xFF1D1A14),
                            valueColor:
                                const AlwaysStoppedAnimation<Color>(kGold),
                          ),
                        ),

                        const SizedBox(height: 10),

                        Text(
                          "Stock strength indicator",
                          style: TextStyle(
                            color: kMuted.withOpacity(0.85),
                            fontSize: 11,
                          ),
                        ),

                        const SizedBox(height: 34),

                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                style: OutlinedButton.styleFrom(
                                  side: BorderSide(
                                    color: kGold.withOpacity(0.95),
                                    width: 1.2,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 17),
                                  foregroundColor: kGold,
                                ),
                                onPressed: () async {
                                  await addToCart();

                                  if (cartId == null) return;

                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) => CartScreen(
                                        userId: userId!,
                                        productId: productId!,
                                        cartId: cartId!,
                                      ),
                                    ),
                                  );
                                },
                                child: const Text(
                                  'Add to Cart',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 17),
                                  backgroundColor: kGold,
                                  foregroundColor: Colors.black,
                                  elevation: 0,
                                ),
                                onPressed: () async {
                                  await saveBuyNow(context);
                                },
                                child: const Text(
                                  'Buy Now',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
      ),
    );
  }

  Widget _qtyButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        height: 40,
        width: 40,
        decoration: BoxDecoration(
          color: kGold.withOpacity(0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: kGold.withOpacity(0.22),
          ),
        ),
        child: Icon(
          icon,
          color: kGold,
          size: 20,
        ),
      ),
    );
  }
}