import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class CheckoutScreen extends StatefulWidget {
  final int userId;
  final List<int> cartIds;
  final double totalAmount;

  const CheckoutScreen({
    super.key,
    required this.userId,
    required this.cartIds,
    required this.totalAmount,
  });

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  bool loading = false;
  List<Map<String, dynamic>>? checkoutResponse;

  Future<void> submitCheckout() async {
    setState(() {
      loading = true;
    });

    final url = 'https://417sptdw-8001.inc1.devtunnels.ms/userapp/cart-checkout/';
    final body = jsonEncode({
      "user": widget.userId,
      "cart_ids": widget.cartIds,
      "total_amount": widget.totalAmount,
    });

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        setState(() {
          checkoutResponse = List<Map<String, dynamic>>.from(data['data']);
        });
      } else {
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Checkout failed: ${response.statusCode}')),
        );
      }
    } catch (e) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() {
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkout'),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : checkoutResponse == null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('User ID: ${widget.userId}'),
                      Text('Cart IDs: ${widget.cartIds.join(', ')}'),
                      Text('Total Amount: ₹${widget.totalAmount}'),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: submitCheckout,
                        child: const Text('Proceed to Checkout'),
                      ),
                    ],
                  ),
                )
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                   // Text('Status: ${jsonDecode(response.body)['status']}'),
                    //Text('Message: ${jsonDecode(response.body)['message']}'),
                    const SizedBox(height: 16),
                    ...checkoutResponse!.map((item) => Card(
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Product: ${item['product_name']}'),
                                Text('Category: ${item['category_name']}'),
                                Text('Total Amount: ₹${item['total_amount']}'),
                                Text('Created At: ${item['created_at']}'),
                              ],
                            ),
                          ),
                        )),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Back to Cart'),
                    ),
                  ],
                ),
    );
  }
}
