import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:house_construction_pro/purchase_screen/add_cart/add_cart_model.dart';
import 'package:house_construction_pro/purchase_screen/payment.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class CartScreen extends StatefulWidget {
  final int userId;
  final int productId;
  final int cartId;

  const CartScreen({
    super.key,
    required this.userId,
    required this.productId,
    required this.cartId,
  });

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  List<CartItem> cartItems = [];
  bool loading = true;
  int? cartId;
  int? userId;
  int? productId;
  List<int> cartIds = [];
  String paymentChoice = 'cart_payment';

  static const Color kBg = Color(0xFF050505);
  static const Color kCard = Color(0xFF0D0D0D);
  static const Color kCard2 = Color(0xFF151515);
  static const Color kGold = Color(0xFFD4AF37);
  static const Color kGoldSoft = Color(0xFFE7C65A);
  static const Color kText = Color(0xFFF5F1E8);
  static const Color kSubText = Color(0xFFA4A099);
  static const Color kMuted = Color(0xFF6E675D);
  static const Color kBorder = Color(0xFF2A2316);
  static const Color kDanger = Color(0xFFE57373);

  @override
  void initState() {
    super.initState();
    fetchCartItems();
    userId = widget.userId;
    productId = widget.productId;
    cartId = widget.cartId;
  }

  String getFullImageUrl(String relativePath) {
    return "https://417sptdw-8001.inc1.devtunnels.ms$relativePath";
  }

  Future<void> fetchCartItems() async {
    final url =
        'https://417sptdw-8001.inc1.devtunnels.ms/userapp/user-cart/${widget.userId}/';
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        cartItems = (data['cart_items'] as List)
            .map((json) => CartItem.fromJson(json))
            .toList();
        loading = false;
        cartIds = cartItems.map((item) => item.id).toList();
      });
    } else {
      setState(() {
        loading = false;
      });
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to load cart items')),
      );
    }
  }

  Future<void> removeCartItem(int cartId) async {
    final url =
        'https://417sptdw-8001.inc1.devtunnels.ms/userapp/remove-cart-item/$cartId/';
    final response = await http.delete(Uri.parse(url));
    if (response.statusCode == 200) {
      fetchCartItems();
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Item removed from cart!'),
          backgroundColor: Colors.green,
        ),
      );
    } else if (response.statusCode == 404) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Item not found'),
          backgroundColor: Colors.red,
        ),
      );
    } else {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to remove item'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  double get subtotal {
    return cartItems.fold(0.0, (sum, item) {
      final double unitPrice =
          item.quantity != 0 ? (item.totalPrice / item.quantity) : 0.0;
      return sum + (unitPrice * item.quantity);
    });
  }

  double get shipping => 50.0;
  double get grandTotal => subtotal + shipping;

  Future<void> showQuantityDialog(BuildContext context, CartItem item) async {
    int selectedQty = item.quantity;

    // fixed unit price calculation
    double unitPrice =
        item.quantity != 0 ? (item.totalPrice / item.quantity) : 0.0;

    await showDialog(
      context: context,
      // ignore: deprecated_member_use
      barrierColor: Colors.black.withOpacity(0.6),
      builder: (_) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
            decoration: BoxDecoration(
              color: kCard2,
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: kBorder),
              boxShadow: [
                BoxShadow(
                  // ignore: deprecated_member_use
                  color: Colors.black.withOpacity(0.45),
                  blurRadius: 28,
                  offset: const Offset(0, 16),
                ),
                BoxShadow(
                  // ignore: deprecated_member_use
                  color: kGold.withOpacity(0.05),
                  blurRadius: 30,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: StatefulBuilder(
              builder: (context, setInnerState) {
                final total = unitPrice * selectedQty;

                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Container(
                          height: 68,
                          width: 68,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(18),
                            color: Colors.black,
                            border: Border.all(color: kBorder),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(18),
                            child: Image.network(
                              getFullImageUrl(item.productImage),
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stack) =>
                                  const Icon(
                                Icons.broken_image,
                                size: 36,
                                color: Colors.white30,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            item.productName,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: kText,
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.of(context).pop(),
                          icon: const Icon(Icons.close, color: kSubText),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        '₹${total.toStringAsFixed(2)}',
                        style: const TextStyle(
                          color: kGoldSoft,
                          fontSize: 26,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'Serif',
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: kCard,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: kBorder),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Quantity",
                            style: TextStyle(
                              color: kSubText,
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Row(
                            children: [
                              _dialogQtyButton(
                                icon: Icons.remove,
                                onTap: selectedQty > 1
                                    ? () {
                                        setInnerState(() {
                                          selectedQty--;
                                        });
                                      }
                                    : null,
                              ),
                              Container(
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 10),
                                width: 42,
                                alignment: Alignment.center,
                                child: Text(
                                  "$selectedQty",
                                  style: const TextStyle(
                                    color: kText,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              _dialogQtyButton(
                                icon: Icons.add,
                                onTap: () {
                                  setInnerState(() {
                                    selectedQty++;
                                  });
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Total Price",
                          style: TextStyle(
                            color: kSubText,
                            fontSize: 15,
                          ),
                        ),
                        Text(
                          '₹${total.toStringAsFixed(2)}',
                          style: const TextStyle(
                            color: kGoldSoft,
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 22),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kGold,
                          foregroundColor: Colors.black,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),
                        onPressed: () async {
                          await updateCartQuantity(
                            item.id,
                            selectedQty,
                            unitPrice,
                          );
                          // ignore: use_build_context_synchronously
                          Navigator.of(context).pop();
                        },
                        child: const Text(
                          "Continue",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }

  Future<void> updateCartQuantity(
    int cartId,
    int quantity,
    double unitPrice,
  ) async {
    double total = unitPrice * quantity;
    final url =
        'https://417sptdw-8001.inc1.devtunnels.ms/userapp/update-cart-quantity/';
    final body = jsonEncode({
      "cart_id": cartId,
      "quantity": quantity,
      "total_price": total,
    });

    final response = await http.patch(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: body,
    );

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      if (decoded["cart_item"] != null && decoded["cart_item"]["id"] != null) {
        final int cartIdFromServer = decoded["cart_item"]["id"];
        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt('cart_id', cartIdFromServer);
        await prefs.setString(
          'last_cart_item',
          jsonEncode(decoded["cart_item"]),
        );
      }
      fetchCartItems();
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Updated successfully',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to update quantity')),
      );
    }
  }

  Future<int?> getStoredCartId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('cart_id');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      appBar: AppBar(
        backgroundColor: kBg,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: kText),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          "My Cart",
          style: TextStyle(
            color: kText,
            fontWeight: FontWeight.w700,
            fontSize: 20,
          ),
        ),
      ),
      body: loading
          ? const Center(
              child: CircularProgressIndicator(color: kGold),
            )
          : cartItems.isEmpty
              ? Center(
                  child: Text(
                    'No items found in your cart.',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[500],
                    ),
                  ),
                )
              : Stack(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 250),
                      child: ListView.builder(
                        padding: const EdgeInsets.fromLTRB(14, 10, 14, 24),
                        itemCount: cartItems.length,
                        itemBuilder: (context, index) {
                          final item = cartItems[index];
                          final double unitPrice = item.quantity != 0
                              ? (item.totalPrice / item.quantity)
                              : 0.0;

                          return Container(
                            margin: const EdgeInsets.only(bottom: 16),
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(28),
                              gradient: const LinearGradient(
                                colors: [
                                  Color(0xFF101010),
                                  Color(0xFF080808),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              border: Border.all(
                                // ignore: deprecated_member_use
                                color: kGold.withOpacity(0.16),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  // ignore: deprecated_member_use
                                  color: Colors.black.withOpacity(0.38),
                                  blurRadius: 24,
                                  offset: const Offset(0, 14),
                                ),
                                BoxShadow(
                                  // ignore: deprecated_member_use
                                  color: kGold.withOpacity(0.04),
                                  blurRadius: 24,
                                  spreadRadius: 1,
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      height: 96,
                                      width: 96,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(22),
                                        color: Colors.black,
                                        border: Border.all(color: kBorder),
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(22),
                                        child: item.productImage.isNotEmpty
                                            ? Image.network(
                                                getFullImageUrl(item.productImage),
                                                fit: BoxFit.cover,
                                                errorBuilder:
                                                    (context, error, stackTrace) =>
                                                        const Icon(
                                                  Icons.broken_image,
                                                  size: 38,
                                                  color: Colors.white30,
                                                ),
                                              )
                                            : const Icon(
                                                Icons.image,
                                                size: 38,
                                                color: Colors.white30,
                                              ),
                                      ),
                                    ),
                                    const SizedBox(width: 14),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            item.productName,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w700,
                                              fontSize: 18,
                                              height: 1.15,
                                              color: kText,
                                            ),
                                          ),
                                          const SizedBox(height: 6),
                                          Text(
                                            item.categoryName,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              fontSize: 13,
                                              color: kSubText,
                                            ),
                                          ),
                                          const SizedBox(height: 16),
                                          Text(
                                            "₹${(unitPrice * item.quantity).toStringAsFixed(2)}",
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w700,
                                              fontSize: 24,
                                              color: kGoldSoft,
                                              fontFamily: 'Serif',
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(
                                        Icons.delete_outline,
                                        color: kDanger,
                                      ),
                                      onPressed: () {
                                        removeCartItem(item.id);
                                      },
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 12,
                                  ),
                                  decoration: BoxDecoration(
                                    color: kCard2,
                                    borderRadius: BorderRadius.circular(18),
                                    border: Border.all(color: kBorder),
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text(
                                        "Quantity",
                                        style: TextStyle(
                                          color: kSubText,
                                          fontSize: 14,
                                        ),
                                      ),
                                      GestureDetector(
                                        onTap: () {
                                          showQuantityDialog(context, item);
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 14,
                                            vertical: 8,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.black,
                                            borderRadius:
                                                BorderRadius.circular(14),
                                            border: Border.all(
                                              // ignore: deprecated_member_use
                                              color: kGold.withOpacity(0.35),
                                            ),
                                          ),
                                          child: Text(
                                            "Qty: ${item.quantity}",
                                            style: const TextStyle(
                                              color: kGold,
                                              fontWeight: FontWeight.w700,
                                              fontSize: 13,
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
                        },
                      ),
                    ),
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      child: Container(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0A0A0A),
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(30),
                          ),
                          border: Border(
                            top: BorderSide(
                              // ignore: deprecated_member_use
                              color: kGold.withOpacity(0.14),
                            ),
                          ),
                          boxShadow: [
                            BoxShadow(
                              // ignore: deprecated_member_use
                              color: Colors.black.withOpacity(0.35),
                              blurRadius: 20,
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 48,
                              height: 4,
                              margin: const EdgeInsets.only(bottom: 14),
                              decoration: BoxDecoration(
                                color: kMuted,
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.all(18.0),
                              decoration: BoxDecoration(
                                color: kCard,
                                borderRadius: BorderRadius.circular(22),
                                border: Border.all(color: kBorder),
                              ),
                              child: Column(
                                children: [
                                  _summaryRow(
                                    "Subtotal",
                                    "₹${subtotal.toStringAsFixed(2)}",
                                  ),
                                  const SizedBox(height: 10),
                                  _summaryRow(
                                    "Shipping",
                                    "₹${shipping.toStringAsFixed(2)}",
                                  ),
                                  const Padding(
                                    padding: EdgeInsets.symmetric(vertical: 12),
                                    child: Divider(color: kBorder, height: 1),
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text(
                                        "Grand Total",
                                        style: TextStyle(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 18,
                                          color: kText,
                                        ),
                                      ),
                                      Text(
                                        "₹${grandTotal.toStringAsFixed(2)}",
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w800,
                                          fontSize: 24,
                                          color: kGoldSoft,
                                          fontFamily: 'Serif',
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 14),
                            SizedBox(
                              width: double.infinity,
                              height: 54,
                              child: ElevatedButton(
                                onPressed: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) {
                                        return PaymentOpp(
                                          totalPayment: grandTotal,
                                          userId: widget.userId,
                                          cartIds: cartIds,
                                          paymentChoice: paymentChoice,
                                        );
                                      },
                                    ),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: kGold,
                                  foregroundColor: Colors.black,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                ),
                                child: const Text(
                                  "Proceed to Payment",
                                  style: TextStyle(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 17,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
    );
  }

  Widget _summaryRow(String title, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: kSubText,
            fontSize: 14,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            color: kText,
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _dialogQtyButton({
    required IconData icon,
    required VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        height: 36,
        width: 36,
        decoration: BoxDecoration(
          // ignore: deprecated_member_use
          color: kGold.withOpacity(0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            // ignore: deprecated_member_use
            color: kGold.withOpacity(0.22),
          ),
        ),
        child: Icon(
          icon,
          color: onTap == null ? kMuted : kGold,
          size: 18,
        ),
      ),
    );
  }
}