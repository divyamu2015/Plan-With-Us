import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:house_construction_pro/constant_page.dart';
import 'package:http/http.dart' as http;

class MyOrdersScreen extends StatefulWidget {
  const MyOrdersScreen({super.key, required this.userId});
   final int userId;


  @override
  State<MyOrdersScreen> createState() => _MyOrdersScreenState();
}

class _MyOrdersScreenState extends State<MyOrdersScreen> {
 // final String baseUrl = "http://127.0.0.1:8001";
  bool isLoading = true;
  List orders = [];

  @override
  void initState() {
    super.initState();
    fetchOrders();
  }

  Future<void> fetchOrders() async {
    final url = Uri.parse("$baseUri/userapp/my-orders/2/");

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          orders = data["orders"] ?? [];
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
      }
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  Color statusColor(String status) {
    switch (status.toLowerCase()) {
      case "completed":
      case "paid":
        return Colors.greenAccent;
      case "processing":
        return Colors.orangeAccent;
      default:
        return const Color(0xffd4ad65);
    }
  }

  String formatDate(String date) {
    final d = DateTime.tryParse(date);
    if (d == null) return "";
    return "Ordered on ${d.day}/${d.month}/${d.year}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff1e1b13),
      body: SafeArea(
        child: isLoading
            ? const Center(
                child: CircularProgressIndicator(color: Color(0xffd4ad65)),
              )
            : Column(
                children: [
                  _topBar(),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(14, 20, 14, 110),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // const Text(
                          //   "Engineering\nLegacy",
                          //   style: TextStyle(
                          //     fontSize: 30,
                          //     height: 0.95,
                          //     color: Color(0xffffdea5),
                          //     fontWeight: FontWeight.bold,
                          //     fontFamily: "serif",
                          //   ),
                          // ),
                          // const SizedBox(height: 12),
                          // const Text(
                          //   "Review your curated selection of high-precision materials, manufactured for the modern architectural atelier.",
                          //   style: TextStyle(
                          //     color: Color(0xffe9e2d3),
                          //     fontSize: 13,
                          //     height: 1.5,
                          //   ),
                          // ),
                          const SizedBox(height: 28),

                          ...orders.map((order) => _orderCard(order)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
      ),
     // bottomNavigationBar: _bottomNav(),
    );
  }

  Widget _topBar() {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 18),
      color: const Color(0xffcfc5b4),
      child:  Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(Icons.arrow_back_ios_new),
            color: Color(0xff775a19),
           
          ),
          Icon(Icons.menu, color: Color(0xff775a19), size: 20),
          Text(
            "MY ORDERS",
            style: TextStyle(
              color: Color(0xff775a19),
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
              fontSize: 14,
            ),
          ),
          Icon(Icons.shopping_bag_outlined, color: Color(0xff775a19), size: 18),
        ],
      ),
    );
  }

  Widget _orderCard(dynamic order) {
    final imageUri = "$imageUrl${order["product_image"]}";
    final status = order["status"] ?? "";

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: const Color(0xff343026),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            child: Image.network(
              imageUri,
              height: 180,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                height: 180,
                color: Colors.black26,
                child: const Icon(Icons.image_not_supported, color: Colors.white),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "${order["type"]}".toUpperCase(),
                  style: const TextStyle(
                    color: Color(0xffd4ad65),
                    fontSize: 10,
                    letterSpacing: 1.2,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 4),

                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        order["product_name"] ?? "",
                        style: const TextStyle(
                          color: Color(0xfffff8ef),
                          fontSize: 20,
                          height: 1,
                          fontWeight: FontWeight.bold,
                          fontFamily: "serif",
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor(status).withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: statusColor(status).withOpacity(0.4),
                        ),
                      ),
                      child: Text(
                        status.toUpperCase(),
                        style: TextStyle(
                          color: statusColor(status),
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 6),

                Text(
                  formatDate(order["date"] ?? ""),
                  style: const TextStyle(
                    color: Color(0xffd0c5af),
                    fontSize: 11,
                  ),
                ),

                const SizedBox(height: 14),

                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _chip("Qty: ${order["quantity"]}"),
                    _chip(order["category_name"] ?? ""),
                    _chip("Payment: ${order["payment_type"]}"),
                  ],
                ),

                const SizedBox(height: 18),
                const Divider(color: Color(0x22fff8ef)),

                const Text(
                  "TOTAL VALUATION",
                  style: TextStyle(
                    color: Color(0xffd0c5af),
                    fontSize: 9,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "₹${order["total_price"]}",
                  style: const TextStyle(
                    color: Color(0xffd4ad65),
                    fontSize: 23,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _chip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: const Color(0xff5f5e5e).withOpacity(0.35),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Color(0xfffff8ef),
          fontSize: 9,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _bottomNav() {
    return Container(
      height: 78,
      decoration: const BoxDecoration(
        color: Color(0xfffff8ef),
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: const [
          _NavItem(icon: Icons.grid_view, label: "CATALOG"),
          _NavItem(icon: Icons.receipt_long, label: "ORDERS", active: true),
          _NavItem(icon: Icons.inventory_2_outlined, label: "VAULT"),
          _NavItem(icon: Icons.person_outline, label: "PROFILE"),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;

  const _NavItem({
    required this.icon,
    required this.label,
    this.active = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: active
          ? const EdgeInsets.symmetric(horizontal: 18, vertical: 8)
          : EdgeInsets.zero,
      decoration: active
          ? BoxDecoration(
              color: const Color(0xffa77b25),
              borderRadius: BorderRadius.circular(30),
            )
          : null,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 18,
            color: active ? Colors.white : const Color(0xff5f5e5e),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 8,
              letterSpacing: 1,
              color: active ? Colors.white : const Color(0xff5f5e5e),
            ),
          ),
        ],
      ),
    );
  }
}