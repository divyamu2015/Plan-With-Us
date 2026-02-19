import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:house_construction_pro/purchase_screen/cart_screen.dart';
//import 'package:razorpay_flutter/razorpay_flutter.dart';

class ItemDetail extends StatefulWidget {
  final String itemName;
  final String description;
  final double price;
  final double offerPrice;
  final String imagePath;

  const ItemDetail({
    super.key,
    required this.itemName,
    required this.description,
    required this.price,
    required this.offerPrice,
    required this.imagePath,
  });



  @override
  State<ItemDetail> createState() => _ItemDetailState();
}

class _ItemDetailState extends State<ItemDetail> {
 // final Razorpay _razorpay = Razorpay();
  List<Map<String, dynamic>> wishlistItems = [];
  int quantity = 1;
  bool isFavorite = false;

  

  @override
  void initState() {
    super.initState();
    isFavorite = wishlistItems.any((item) => item['itemName'] == widget.itemName);
    // _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    // _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    // _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

    // void _handlePaymentSuccess(PaymentSuccessResponse response) {
    // // Do something when payment succeeds
    // }

    // void _handlePaymentError(PaymentFailureResponse response) {
    //   // Do something when payment fails
    // }

    // void _handleExternalWallet(ExternalWalletResponse response) {
    //   // Do something when an external wallet is selected
    // }

    @override
  void dispose() {
   // _razorpay.clear(); // Removes all listeners
    super.dispose();
  }

  void _increment() {
    setState(() {
      quantity++;
    });
  }

  void _decrement() {
    if (quantity > 1) {
      setState(() {
        quantity--;
      });
    }
  }

  void _toggleFavorite() {
    setState(() {
      isFavorite = !isFavorite;
    });

    if (isFavorite) {
      wishlistItems.add({
        'itemName': widget.itemName,
        'description': widget.description,
        'price': widget.price,
        'offerPrice': widget.offerPrice,
        'imagePath': widget.imagePath,
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${widget.itemName} added to wishlist ❤️'),
          duration: const Duration(seconds: 1),
        ),
      );
    } else {
      wishlistItems.removeWhere((item) => item['itemName'] == widget.itemName);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${widget.itemName} removed from wishlist 💔'),
          duration: const Duration(seconds: 1),
        ),
      );
    }
  }

  void _goToCart() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CartScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    double totalPrice = widget.price * quantity;
    double totalOfferPrice = widget.offerPrice * quantity;

    return Scaffold(
      appBar: AppBar(
        title: Text("Product Detail",
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product image
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset(
                  widget.imagePath,
                  height: 250,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 20),

            Text(
              widget.itemName,
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),

            Text(
              widget.description,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.grey[700],
                height: 1.5,
              ),
            ),
            const SizedBox(height: 12),

            // Dynamic Price Row
            Row(
              children: [
                Text(
                  "Rs.${totalPrice.toStringAsFixed(0)}",
                  style: GoogleFonts.poppins(
                    color: Colors.grey,
                    fontSize: 16,
                    decoration: TextDecoration.lineThrough,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  "Rs.${totalOfferPrice.toStringAsFixed(0)}",
                  style: GoogleFonts.poppins(
                    color: Colors.green[700],
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
                        const SizedBox(height: 4),
            Text(
              "Out of Stock",
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),

            const SizedBox(height: 24),

            // Quantity selector
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  "Quantity:",
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w500,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade400),
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: _decrement,
                        icon: const Icon(Icons.remove),
                        splashRadius: 20,
                      ),
                      Text(
                        quantity.toString(),
                        style: GoogleFonts.poppins(fontSize: 16),
                      ),
                      IconButton(
                        onPressed: _increment,
                        icon: const Icon(Icons.add),
                        splashRadius: 20,
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Buttons
            Row(
              children: [
                // ❤️ Favorite Button
                IconButton(
                  onPressed: _toggleFavorite,
                  icon: Icon(
                    isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: isFavorite ? Colors.redAccent : Colors.grey,
                    size: 30,
                  ),
                ),
                const SizedBox(width: 8),

                // 🛒 Add to Cart
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _goToCart,
                    label: Text(
                      "Add to Cart",
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.black,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: const BorderSide(color: Colors.black, width: 1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      elevation: 0,
                    ),
                  ),
                ),

                const SizedBox(width: 12),

                // ⚡ Buy Now
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      // Show bottom sheet and wait for selected method
                      final method = await showModalBottomSheet<String>(
                        context: context,
                        backgroundColor: Colors.transparent,
                        builder: (context) => const PaymentBottomSheet(),
                      );

                      if (method == 'upi') {
                        var options = {
                              'key': 'rzp_test_RZBBdT1yj6ZP2M', // 🔑 Replace with your Razorpay Test key
                              'amount': 50000, // in paise => ₹500
                              'name': 'ECE Store',
                              'description': 'Test Payment',
                              'prefill': {
                                'contact': '9876543210',
                                'email': 'testuser@example.com',
                              },
                              'theme': {
                                'color': '#3399cc',
                              },
                              'method': {
                                'netbanking': true,
                                'card': true, // ✅ Enable card payments
                                'upi': true,
                                'wallet': true,
      }
                        };
                      //  _razorpay.open(options);
                      } else if (method == 'cod') {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('COD Selected')),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 251, 221, 172),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: Text(
                      "Buy Now",
                      style: GoogleFonts.poppins(
                        color: Colors.black,
                        fontWeight: FontWeight.w500,
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
  }

}


class PaymentBottomSheet extends StatelessWidget {
  const PaymentBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Select Payment Method',
            style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),

          // COD
          ElevatedButton(
            onPressed: () => Navigator.pop(context, 'cod'),
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadiusGeometry.circular(15)
              ),
              backgroundColor:  Color.fromARGB(255, 251, 221, 172),
              padding: const EdgeInsets.symmetric(vertical: 14,horizontal: 72),
            ),
            child: Text('Cash on Delivery (COD)',
                style: GoogleFonts.poppins(fontSize: 16, color: Colors.black)),
          ),
          const SizedBox(height: 12),

          // UPI
          ElevatedButton(
            onPressed: () => Navigator.pop(context, 'upi'),
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadiusGeometry.circular(15)
              ),
              backgroundColor: Color(0xFFB3E5FC),
              padding: const EdgeInsets.symmetric(vertical: 14,horizontal: 124),
            ),
            child: Text('Pay via UPI',
                style: GoogleFonts.poppins(fontSize: 16, color: Colors.black)),
          ),
        ],
      ),
    );
  }
}


