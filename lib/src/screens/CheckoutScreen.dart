import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';
import '../widgets/custom_appbar.dart';
import '../widgets/custom_button.dart';
import 'payment_screen.dart';

class CheckoutScreen extends StatelessWidget {
  const CheckoutScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);
    final total = cartProvider.totalPrice;

    return Scaffold(
      appBar: const CustomAppBar(title: "Checkout"),
      backgroundColor: Colors.grey[100],
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Expanded(
              child: ListView(
                children: [
                  const Text(
                    "Your Order Summary",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...cartProvider.items.values.map(
                        (item) => ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(item.product.title),
                      subtitle: Text(
                          "Quantity: ${item.quantity} • \$${item.product.price.toStringAsFixed(2)}"),
                      trailing: Text(
                        "\$${(item.product.price * item.quantity).toStringAsFixed(2)}",
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const Divider(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Total:",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "\$${total.toStringAsFixed(2)}",
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.deepPurple,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            CustomButton(
              label: "Confirm Payment",
              onPressed: () {
                // _confirmOrder(context);
                Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => PaymentScreen(
                            totalAmount: total,
                            cartItems: cartProvider.items.values
                                .map((e) => e.product)
                                .toList(),
                          ),
                        ),
                      );
              },
            ),
            const SizedBox(height: 12)
          ],
        ),
      ),
    );
  }
}

