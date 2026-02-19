import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:house_construction_pro/purchase_screen/add_cart/add_cart_model.dart';
import 'package:house_construction_pro/purchase_screen/view_product_home/view_product_screen.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ViewCartItem extends StatefulWidget {
  final int userId;
 // final int productId;
 // final int cartId;

  const ViewCartItem({
    super.key,
    required this.userId,
   // required this.productId,
   // required this.cartId,
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
  List<int> cartIds=[];

  @override
  void initState() {
    super.initState();
    fetchCartItems();
    userId = widget.userId;
   // productId = widget.productId;
   // cartId = widget.cartId;
    print("cartScreen Cart Id=$cartId");
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
      print('fetchCartItems $data');
      print('fetchCartItems response ${response.body}');
      setState(() {
        cartItems = (data['cart_items'] as List)
            .map((json) => CartItem.fromJson(json))
            .toList();
        loading = false;
        print(cartItems);
        cartIds = cartItems.map((item) => item.id).toList();
        print('List of Cart IDs: $cartIds');
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
    SnackBar(
      content: Text('Item removed from cart!'),
      backgroundColor: Colors.green,
    ),
  );
} else if (response.statusCode == 404) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text('Item not found'),
      backgroundColor: Colors.red,
    ),
  );
} else {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text('Failed to remove item'),
      backgroundColor: Colors.red,
    ),
  );
}

  }

  double get subtotal {
    return cartItems.fold(0.0, (sum, item) {
      final double unitPrice = (item.quantity != 0)
          ? ((item.totalPrice) / item.quantity)
          : 0.0;
      return sum + (unitPrice * item.quantity);
    });
  }

  double get shipping => 50.0;
  double get grandTotal => subtotal + shipping;

  Future<void> showQuantityDialog(BuildContext context, CartItem item) async {
    int selectedQty = item.quantity;
    double unitPrice = (item.totalPrice);
    double total = unitPrice * selectedQty;

    await showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.25),
      builder: (_) {
        return Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            child: StatefulBuilder(
              builder: (context, setState) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(14),
                          child: Image.network(
                            getFullImageUrl(item.productImage),
                            height: 54,
                            width: 54,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stack) => Icon(
                              Icons.broken_image,
                              size: 38,
                              color: Colors.grey[400],
                            ),
                          ),
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            item.productName,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 18,
                              color: Colors.black,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.close,
                            color: Colors.black45,
                            size: 28,
                          ),
                          onPressed: () => Navigator.of(context).pop(),
                          splashRadius: 20,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text(
                          // '₹$total',
                          '₹${(unitPrice * selectedQty).toStringAsFixed(2)}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 19,
                            color: Colors.black87,
                          ),
                        ),
                        Spacer(),
                      ],
                    ),
                    SizedBox(height: 8),
                    Container(
                      margin: EdgeInsets.symmetric(vertical: 10),
                      padding: EdgeInsets.symmetric(
                        vertical: 8,
                        horizontal: 16,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Qty",
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 17,
                            ),
                          ),
                          SizedBox(width: 26),
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(9),
                              color: Colors.white,
                              border: Border.all(color: Colors.grey[300]!),
                            ),
                            child: Row(
                              children: [
                                IconButton(
                                  icon: Icon(Icons.remove, size: 20),
                                  splashRadius: 18,
                                  onPressed: selectedQty > 1
                                      ? () => setState(() {
                                          selectedQty--;
                                          total = unitPrice * selectedQty;
                                        })
                                      : null,
                                ),
                                Container(
                                  width: 34,
                                  alignment: Alignment.center,
                                  child: Text(
                                    "$selectedQty",
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                IconButton(
                                  icon: Icon(Icons.add, size: 20),
                                  splashRadius: 18,
                                  onPressed: () =>
                                      setState(() => selectedQty++),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 2, vertical: 4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Total Price",
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            // '₹$total',
                            '₹${(unitPrice * selectedQty).toStringAsFixed(2)}',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 18,
                              color: Color(0xFF8e24aa),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    SizedBox(
                      width: double.infinity,
                      height: 44,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF9C27B0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 0,
                          textStyle: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        child: Text(
                          "Continue",
                          style: TextStyle(color: Colors.white),
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
    // print(total);
    final url =
        'https://417sptdw-8001.inc1.devtunnels.ms/userapp/update-cart-quantity/';
    final body = jsonEncode({
      "cart_id": cartId,
      "quantity": quantity,
      "total_price": total,
    });

    print('Cart Item Id==$cartId');
    print('Total Price==$total');

    final response = await http.patch(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: body,
    );
    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      // print(object)
      print(response.body);
      print(response.statusCode);
      print(decoded);
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
        SnackBar(
          content: Text(
            'Updated successfully',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to update quantity')));
    }
  }

  // Helper for retrieving the latest stored cartId
  Future<int?> getStoredCartId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('cart_id');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF6F7F8), // background-light
      appBar: AppBar(
        backgroundColor: Colors.white.withOpacity(0.8),
        elevation: 0.5,
        centerTitle: true,
        title: const Text(
          "My Cart Items",
          style: TextStyle(
            color: Color(0xFF23272F),
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF23272F)),
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) {
                return ShopScreen(userId: userId!);
              },
            ),
          ),
        ),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : cartItems.isEmpty
        ? Center(
            child: Text(
              'No items found in your cart.',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
            ),
          )
        :  Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 210), // For bottom bar
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: cartItems.length,
                    itemBuilder: (context, index) {
                      final item = cartItems[index];
                      final double unitPrice = (item.quantity != 0)
                          ? ((item.totalPrice) / item.quantity)
                          : 0.0;
                      return Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                        elevation: 1,
                        margin: const EdgeInsets.only(bottom: 16),
                        color: Colors.white,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    height: 64,
                                    width: 64,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      color: Colors.grey[200],
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: (item.productImage.isNotEmpty)
                                          ? Image.network(
                                              getFullImageUrl(
                                                item.productImage,
                                              ),
                                              fit: BoxFit.cover,
                                              errorBuilder:
                                                  (
                                                    context,
                                                    error,
                                                    stackTrace,
                                                  ) => Icon(
                                                    Icons.broken_image,
                                                    size: 36,
                                                    color: Colors.grey[400],
                                                  ),
                                            )
                                          : Icon(
                                              Icons.image,
                                              size: 36,
                                              color: Colors.grey[400],
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
                                            fontWeight: FontWeight.w600,
                                            fontSize: 16.0,
                                            color: Color(0xFF23272F),
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        Text(
                                          item.categoryName,
                                          style: const TextStyle(
                                            fontSize: 13,
                                            color: Colors.grey,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.delete_outline,
                                      color: Colors.grey,
                                    ),
                                    onPressed: () {
                                      removeCartItem(item.id);
                                    },
                                  ),
                                ],
                              ),
                              const SizedBox(height: 14),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "₹${(unitPrice * item.quantity).toStringAsFixed(2)}",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  Container(
                                    height: 25,
                                    width: 65,
                                    decoration: BoxDecoration(
                                      color: Colors.grey[50],
                                      border: Border.all(
                                        color: const Color.fromARGB(
                                          255,
                                          117,
                                          114,
                                          114,
                                        ),
                                        style: BorderStyle.solid,
                                      ),
                                    ),
                                    child: Center(
                                      child: Text(
                                        "Qty: ${item.quantity.toString()} >",
                                        style: TextStyle(
                                          color: Colors.grey[700],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                // --- Bottom Order Summary + Actions ---
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border(
                        top: BorderSide(color: Colors.grey.shade300, width: 1),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.06),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.symmetric(
                      vertical: 18,
                      horizontal: 18,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // --- Order Summary ---
                        Container(
                          padding: const EdgeInsets.all(18.0),
                          decoration: BoxDecoration(
                            color: Color(0xFFF6F7F8),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    "Subtotal",
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 14,
                                    ),
                                  ),
                                  Text(
                                    "₹${subtotal.toStringAsFixed(2)}",
                                    style: const TextStyle(
                                      color: Color(0xFF23272F),
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    "Shipping",
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 14,
                                    ),
                                  ),
                                  Text(
                                    "₹${shipping.toStringAsFixed(2)}",
                                    style: const TextStyle(
                                      color: Color(0xFF23272F),
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                              const Divider(),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    "Grand Total",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 17,
                                    ),
                                  ),
                                  Text(
                                    "₹${grandTotal.toStringAsFixed(2)}",
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 8),
                        OutlinedButton(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) {
                                  return ShopScreen(
                                  //  totalPayment: grandTotal,
                                    userId: widget.userId,
                                  //  cartIds: cartIds,
                                  );
                                },
                              ),
                            );
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Color(0xFF23272F),
                            backgroundColor: Color(0xFFF1F5F9),
                            minimumSize: Size(double.infinity, 50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                          child: const Text(
                            "Back to Purchase",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 17,
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
}
