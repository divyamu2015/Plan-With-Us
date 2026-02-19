import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:house_construction_pro/purchase_screen/add_cart/add_cart_view.dart';
import 'package:house_construction_pro/purchase_screen/payment.dart';
import 'package:house_construction_pro/purchase_screen/view_each_pro/view_each_pro_model.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

// Make sure to use your ProductDetail model from above

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
  int quantity = 1; // User selected quantity
  int? productId;
  int? userId;
  int? cartId;
  int? bookingId;
  String paymentChoice = 'booking_payment';
  @override
  void initState() {
    super.initState();

    fetchProductDetail();
    productId = widget.productId;
    userId = widget.userId;
  }

  double get totalPrice {
    if (product == null) return 0;
    // Ensures price calculation works for your data model
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
      print("🛒 Response: $jsonMap");

      if (response.statusCode == 200 || response.statusCode == 201) {
        cartId = jsonMap["cart_item"]["id"];
        //   print('cartID=$cartId');

        // ✅ Save to SharedPreferences

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
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
        SnackBar(
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

    // final String paymentOption = (selectPayMethod == "card") ? "card" : "cash";

    final Map<String, dynamic> requestBody = {
      "user_id": widget.userId,
      "product_id": widget.productId,
      "quantity": quantity,
      "total_price": totalPrice,
    };

    print("Request Body: $requestBody");

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      final Map<String, dynamic> jsonMap = jsonDecode(response.body);
      print("🛒 Response: $jsonMap");

      if (response.statusCode == 200 || response.statusCode == 201) {
        print(response);
        print(response.statusCode);
        print(response.body);
        bookingId = jsonMap["data"]["id"];
        print('booking ID=$bookingId');

        // ✅ Save to SharedPreferences

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
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
        print("❌ Failed: ${response.body}");
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
      print('🚫 Add to cart error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: Could not add item to cart'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Color(0xFFF8F9FC),
      body: SafeArea(
        child: loading
            ? Center(child: CircularProgressIndicator())
            : product == null
            ? Center(child: Text("Product not found"))
            : SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8.0,
                    vertical: 10,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Top bar
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            icon: Icon(Icons.arrow_back, size: 30),
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                          // IconButton(
                          //   icon: Icon(
                          //     Icons.shopping_cart_outlined,
                          //     color: Colors.grey[800],
                          //   ),
                          //   onPressed: () {},
                          // ),
                          // IconButton(
                          //   icon: Icon(Icons.favorite_border, size: 28),
                          //   onPressed: () {},
                          // ),
                        ],
                      ),
                      SizedBox(height: 7),
                      // Image
                      Center(
                        child: Container(
                          decoration: BoxDecoration(
                            border: BoxBorder.all(color: Colors.cyan),
                          ),
                          height: height * 0.4,
                          width: width * 0.5,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(22),
                            child: Image.network(
                              getImageUrl(product!.image),
                              height: 240,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                height: 240,
                                color: Colors.grey[300],
                                child: Icon(
                                  Icons.image,
                                  size: 44,
                                  color: Colors.grey[400],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 18),
                      Text(
                        product!.name,
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        '₹${totalPrice.toStringAsFixed(2)}', // <-- Dynamic total price shown here
                        style: TextStyle(
                          fontSize: 22,
                          color: Colors.blue[700],
                          fontWeight: FontWeight.w600,
                        ),
                      ),

                      // Row(
                      //   children: [
                      //     Text(
                      //       '₹${totalPrice.toStringAsFixed(2)}', // <-- Dynamic total price shown here
                      //       style: TextStyle(
                      //         fontSize: 22,
                      //         color: Colors.blue[700],
                      //         fontWeight: FontWeight.w600,
                      //       ),
                      //     ),
                      //     Spacer(),
                      //     Container(
                      //       decoration: BoxDecoration(
                      //         color: Colors.white,
                      //         borderRadius: BorderRadius.circular(22),
                      //       ),
                      //       padding: EdgeInsets.symmetric(
                      //         horizontal: 8,
                      //         vertical: 4,
                      //       ),
                      //       child: Row(
                      //         children: [
                      //           IconButton(
                      //             icon: Icon(Icons.remove, size: 21),
                      //             onPressed: () {
                      //               setState(() {
                      //                 if (quantity > 1) quantity--;
                      //               });
                      //             },
                      //           ),
                      //           Text(
                      //             quantity.toString(),
                      //             style: TextStyle(
                      //               fontSize: 18,
                      //               fontWeight: FontWeight.w600,
                      //             ),
                      //           ),
                      //           IconButton(
                      //             icon: Icon(Icons.add, size: 21),
                      //             onPressed: () {
                      //               setState(() {
                      //                 if (quantity < product!.quantity) {
                      //                   quantity++;
                      //                 }
                      //               });
                      //             },
                      //           ),
                      //         ],
                      //       ),
                      //     ),
                      //   ],
                      // ),
                      SizedBox(height: 12),
                      Text(
                        product!.description,
                        style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                      ),
                      // SizedBox(height: 22),
                      // // Ratings row (static for demo)
                      // Row(
                      //   children: [
                      //     ...List.generate(
                      //       5,
                      //       (i) => Icon(
                      //         Icons.star,
                      //         color: i < 4 ? Colors.amber : Colors.grey[300],
                      //         size: 21,
                      //       ),
                      //     ),
                      //     SizedBox(width: 10),
                      //     Text(
                      //       "4.5",
                      //       style: TextStyle(
                      //         fontSize: 18,
                      //         fontWeight: FontWeight.bold,
                      //         color: Colors.grey[900],
                      //       ),
                      //     ),
                      //     SizedBox(width: 6),
                      //     Text(
                      //       "(327 Reviews)",
                      //       style: TextStyle(
                      //         color: Colors.grey[600],
                      //         fontSize: 13,
                      //       ),
                      //     ),
                      //   ],
                      // ),
                      SizedBox(height: 40),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(color: Colors.blue, width: 2),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(32),
                                ),
                                padding: EdgeInsets.symmetric(vertical: 16),
                              ),
                              child: Text(
                                'Add to Cart',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.blue,
                                ),
                              ),
                              onPressed: () async {
                                print("🛍 Adding item...");
                                await addToCart(); // Wait until addToCart finishes

                                final prefs =
                                    await SharedPreferences.getInstance();
                                final storedCartId = prefs.getInt('cart_id');
                                print("🧾 Retrieved Cart ID: $storedCartId");

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
                            ),
                          ),
                          SizedBox(width: 16),
                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(32),
                                ),
                                padding: EdgeInsets.symmetric(vertical: 16),
                                backgroundColor: Colors.blue[500],
                                elevation: 0,
                              ),
                              child: Text(
                                'Buy Now',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.white,
                                ),
                              ),
                              onPressed: () async {
                                await saveBuyNow(context);

                                // Buy now logic here
                              },
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 18),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}
