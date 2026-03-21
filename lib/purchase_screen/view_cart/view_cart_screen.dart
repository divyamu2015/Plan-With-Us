import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:house_construction_pro/purchase_screen/add_cart/add_cart_model.dart';
import 'package:house_construction_pro/purchase_screen/view_product_home/view_product_screen.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ViewCartItem extends StatefulWidget {
  final int userId;

  const ViewCartItem({
    super.key,
    required this.userId,
  });

  @override
  State<ViewCartItem> createState() => _ViewCartItemState();
}

class _ViewCartItemState extends State<ViewCartItem> {
  List<CartItem> cartItems = [];
  bool loading = true;
  int? cartId;
  int? userId;
  int? productId;
  List<int> cartIds = [];

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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Item removed from cart!'),
          backgroundColor: Colors.green,
        ),
      );
    } else if (response.statusCode == 404) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Item not found'),
          backgroundColor: Colors.red,
        ),
      );
    } else {
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
    double unitPrice =
        item.quantity != 0 ? (item.totalPrice / item.quantity) : 0.0;

    await showDialog(
      context: context,
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
                  color: Colors.black.withOpacity(0.45),
                  blurRadius: 28,
                  offset: const Offset(0, 16),
                ),
                BoxShadow(
                  color: kGold.withOpacity(0.05),
                  blurRadius: 24,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: StatefulBuilder(
              builder: (context, setState) {
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
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 17,
                              color: kText,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.close,
                            color: kSubText,
                            size: 24,
                          ),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        '₹${total.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 26,
                          color: kGoldSoft,
                          fontFamily: 'Serif',
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 14,
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
                                        setState(() {
                                          selectedQty--;
                                        });
                                      }
                                    : null,
                              ),
                              Container(
                                width: 42,
                                alignment: Alignment.center,
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 10),
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
                                  setState(() {
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
                            fontWeight: FontWeight.w700,
                            fontSize: 20,
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
                        child: const Text(
                          "Continue",
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 16,
                          ),
                        ),
                        onPressed: () async {
                          await updateCartQuantity(
                            item.id,
                            selectedQty,
                            unitPrice,
                          );
                          Navigator.of(context).pop();
                        },
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
        title: const Text(
          "MY CART VIEW",
          style: TextStyle(
            color: kText,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.2,
            fontStyle: FontStyle.italic,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: kText),
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) {
                return ShopScreen(userId: userId!);
              },
            ),
          ),
        ),
        // actions: const [
        //   Padding(
        //     padding: EdgeInsets.only(right: 14),
        //     child: Icon(
        //       Icons.shopping_bag_outlined,
        //       color: kGold,
        //       size: 18,
        //     ),
        //   ),
        // ],
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
              : Column(
                  children: [
                    const SizedBox(height: 8),
                    // const Text(
                    //   "ENGINEERED EXCELLENCE",
                    //   style: TextStyle(
                    //     color: kGold,
                    //     fontSize: 9,
                    //     fontWeight: FontWeight.w700,
                    //     letterSpacing: 2.4,
                    //   ),
                    // ),
                    // const SizedBox(height: 10),
                    // const Text(
                    //   "THE CURATED\nCOLLECTION",
                    //   textAlign: TextAlign.center,
                    //   style: TextStyle(
                    //     color: kText,
                    //     fontSize: 28,
                    //     fontWeight: FontWeight.w500,
                    //     height: 0.95,
                    //     fontFamily: 'Serif',
                    //   ),
                    // ),
                    const SizedBox(height: 12),
                    Container(
                      width: 70,
                      height: 1.2,
                      color: kGold.withOpacity(0.75),
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: Stack(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(bottom: 245),
                            child: ListView.builder(
                              padding: const EdgeInsets.fromLTRB(14, 6, 14, 20),
                              itemCount: cartItems.length,
                              itemBuilder: (context, index) {
                                final item = cartItems[index];
                                final double unitPrice = item.quantity != 0
                                    ? (item.totalPrice / item.quantity)
                                    : 0.0;

                                return Container(
                                  margin: const EdgeInsets.only(bottom: 18),
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
                                      color: kGold.withOpacity(0.16),
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.38),
                                        blurRadius: 24,
                                        offset: const Offset(0, 14),
                                      ),
                                      BoxShadow(
                                        color: kGold.withOpacity(0.04),
                                        blurRadius: 24,
                                        spreadRadius: 1,
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    children: [
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                            height: 96,
                                            width: 96,
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(22),
                                              color: Colors.black,
                                              border:
                                                  Border.all(color: kBorder),
                                            ),
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(22),
                                              child: item.productImage.isNotEmpty
                                                  ? Image.network(
                                                      getFullImageUrl(
                                                        item.productImage,
                                                      ),
                                                      fit: BoxFit.cover,
                                                      errorBuilder: (
                                                        context,
                                                        error,
                                                        stackTrace,
                                                      ) =>
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
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.w700,
                                                    fontSize: 19,
                                                    height: 1.15,
                                                    color: kText,
                                                  ),
                                                  maxLines: 2,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                                const SizedBox(height: 6),
                                                Text(
                                                  item.categoryName,
                                                  style: const TextStyle(
                                                    fontSize: 13,
                                                    color: kSubText,
                                                  ),
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
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
                                          borderRadius:
                                              BorderRadius.circular(18),
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
                                                showQuantityDialog(
                                                  context,
                                                  item,
                                                );
                                              },
                                              child: Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                  horizontal: 14,
                                                  vertical: 8,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: Colors.black,
                                                  borderRadius:
                                                      BorderRadius.circular(14),
                                                  border: Border.all(
                                                    color: kGold.withOpacity(
                                                      0.35,
                                                    ),
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
                                    color: kGold.withOpacity(0.14),
                                  ),
                                ),
                                boxShadow: [
                                  BoxShadow(
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
                                          padding: EdgeInsets.symmetric(
                                            vertical: 12,
                                          ),
                                          child: Divider(
                                            color: kBorder,
                                            height: 1,
                                          ),
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
                                              return ShopScreen(
                                                userId: widget.userId,
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
                                          borderRadius:
                                              BorderRadius.circular(20),
                                        ),
                                      ),
                                      child: const Text(
                                        "Back to Purchase",
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
                    ),
                    // Container(
                    //   decoration: const BoxDecoration(
                    //     color: kBg,
                    //     border: Border(
                    //       top: BorderSide(color: kBorder, width: 1),
                    //     ),
                    //   ),
                    //   child: BottomNavigationBar(
                    //     currentIndex: 1,
                    //     backgroundColor: kBg,
                    //     type: BottomNavigationBarType.fixed,
                    //     elevation: 0,
                    //     selectedItemColor: kGold,
                    //     unselectedItemColor: kMuted,
                    //     selectedLabelStyle: const TextStyle(
                    //       fontSize: 10,
                    //       fontWeight: FontWeight.w700,
                    //       letterSpacing: 0.8,
                    //     ),
                    //     unselectedLabelStyle: const TextStyle(
                    //       fontSize: 10,
                    //       fontWeight: FontWeight.w500,
                    //     ),
                    //     onTap: (index) {
                    //       if (index == 0) {
                    //         Navigator.of(context).push(
                    //           MaterialPageRoute(
                    //             builder: (context) =>
                    //                 ShopScreen(userId: widget.userId),
                    //           ),
                    //         );
                    //       }
                    //     },
                    //     items: const [
                    //       BottomNavigationBarItem(
                    //         icon: Icon(Icons.auto_awesome_mosaic_outlined),
                    //         activeIcon: Icon(Icons.auto_awesome_mosaic),
                    //         label: "COLLECTION",
                    //       ),
                    //       BottomNavigationBarItem(
                    //         icon: Icon(Icons.shopping_bag_outlined),
                    //         activeIcon: Icon(Icons.shopping_bag),
                    //         label: "CART",
                    //       ),
                    //       BottomNavigationBarItem(
                    //         icon: Icon(Icons.favorite_border),
                    //         activeIcon: Icon(Icons.favorite),
                    //         label: "SAVED",
                    //       ),
                    //       BottomNavigationBarItem(
                    //         icon: Icon(Icons.account_balance_outlined),
                    //         activeIcon: Icon(Icons.account_balance),
                    //         label: "STUDIO",
                    //       ),
                    //     ],
                    //   ),
                    // ),
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
          color: kGold.withOpacity(0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
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