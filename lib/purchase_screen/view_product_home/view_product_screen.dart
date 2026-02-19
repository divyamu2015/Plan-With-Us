import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:house_construction_pro/authantication/user_authentication/login_screen/login_view_page.dart';
import 'package:house_construction_pro/purchase_screen/view_cart/view_cart_screen.dart';
import 'package:house_construction_pro/purchase_screen/view_each_pro/view_each_pro_screen.dart';
import 'package:house_construction_pro/purchase_screen/view_product_home/view_product_model.dart';
import 'package:house_construction_pro/screen/engineer_screen/engineer_home.dart';
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
  @override
  void initState() {
    super.initState();
    fetchProducts();
    userId = widget.userId;
  }

  Future<void> storeUserId(int productId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('id', productId);
    // print('User ID stored: $userId');
  }

  Future<int?> getUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    productId = prefs.getInt('id');
    // print("Retrieved User ID: $userId");
    return productId;
  }

  Future<void> _showLogoutDialog(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Logout Alert"),
        content: const Text("Are you sure you want to logout?"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) {
                    return LoginScreen();
                  },
                ),
              ); // Close dialog (No)
            },
            child: const Text("No"),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close dialog first
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => LoginScreen()),
              ); // Navigate to login (Yes)
            },
            child: const Text(
              "Yes, Logout",
              style: TextStyle(color: Colors.red),
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
      // Handle error accordingly
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Arrivals'),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 1,
        actions: [
          IconButton(
            icon: Icon(Icons.search, color: Colors.grey[800]),
            onPressed: () {},
          ),

          // IconButton(
          //   icon: Icon(Icons.shopping_cart_outlined, color: Colors.grey[800]),
          //   onPressed: () {},
          // ),
        ],
      ),
      body: loading
          ? Center(child: CircularProgressIndicator())
          : GridView.builder(
              padding: EdgeInsets.all(12),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.64,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: products.length,
              itemBuilder: (context, index) {
                final p = products[index];
                return ProductCard(product: p, userId: userId!);
              },
            ),
      bottomNavigationBar: BottomNavigationBar(
        onTap: (index) {
          if (index == 0) {
            // Navigate to Home Screen
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => DashboardScreen(userId: userId!),
              ),
            );
          } else if (index == 1) {
            // Navigate to Shop Screen (current screen)
            // No need to navigate, already on ShopScreen
          } else if (index == 2) {
            // Navigate to Cart Screen
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => ViewCartItem(
                  userId: userId!,
                  //productId: 0,
                  //cartId: 0,
                ),
              ),
            );
          } else if (index == 3) {
            _showLogoutDialog(context);
            // Navigate to Profile Screen
            // Navigator.of(context).push(
            //   MaterialPageRoute(
            //     builder: (context) => ProfileScreen(),
            //   ),
            // );
          }
        },
        currentIndex: 1,
        selectedItemColor: Colors.purple,
        unselectedItemColor: Colors.grey,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: "Home",
          ),
          BottomNavigationBarItem(icon: Icon(Icons.store), label: "Shop"),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart_outlined),
            label: "Cart",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: "Profile",
          ),
        ],
      ),
    );
  }
}

class ProductCard extends StatelessWidget {
  final Product product;
  final int userId;
  const ProductCard({required this.product, super.key, required this.userId});

  // Helper: resolve image URL if needed
  String getImageUrl(String relativeUrl) {
    return "https://417sptdw-8001.inc1.devtunnels.ms$relativeUrl";
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(13),
              child: Image.network(
                getImageUrl(product.image),
                height: 110,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  height: 110,
                  color: Colors.grey[300],
                  child: Icon(Icons.image, size: 32, color: Colors.grey[500]),
                ),
              ),
            ),
            SizedBox(height: 10),
            Text(
              product.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 17),
            ),
            SizedBox(height: 5),
            Row(
              children: [
                Text(
                  "₹${product.price}",
                  style: TextStyle(
                    color: Colors.purple[200],
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 16),
                Text(
                  "₹${product.quantity}",
                  style: TextStyle(
                    color: Colors.purple[200],
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            SizedBox(height: 7),
            // Quantity progress bar (mock for demo, as per screenshot)
            LinearProgressIndicator(
              minHeight: 5,
              value:
                  (product.quantity.clamp(0, 200) /
                  200.0), // Edit max as needed
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(Colors.teal[200]!),
            ),
            SizedBox(height: 11),
            SizedBox(
              height: 20,
              width: double.infinity,
              child: MaterialButton(
                color: Colors.purple[100],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  "View",
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                onPressed: () async {
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.setInt('id', product.id);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Product ID ${product.id} saved!')),
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
                  // You can also navigate to a product detail page here.
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
