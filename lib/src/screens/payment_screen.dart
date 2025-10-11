import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/order_provider.dart';
import '../providers/cart_provider.dart';
import '../model/product.dart';
import '../widgets/custom_appbar.dart';
import '../widgets/custom_button.dart';
import 'order_success_screen.dart';

class PaymentScreen extends StatefulWidget {
  final double totalAmount;
  final List<Product> cartItems;

  const PaymentScreen({
    Key? key,
    required this.totalAmount,
    required this.cartItems,
  }) : super(key: key);

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  String selectedMethod = "Credit Card";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: "Payment"),
      backgroundColor: Colors.grey[100],
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Select Payment Method",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            _paymentOption("Credit Card"),
            _paymentOption("Debit Card"),
            _paymentOption("UPI / Wallet"),
            _paymentOption("Cash on Delivery"),
            const SizedBox(height: 24),
            const Text(
              "Order Summary",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Divider(height: 16),
            Text(
              "Total: \$${widget.totalAmount.toStringAsFixed(2)}",
              style: const TextStyle(
                fontSize: 16,
                color: Colors.deepPurple,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child:  CustomButton(
                label: "Confirm Payment",
                onPressed: () {
                  _confirmOrder(context);
                },
              ),
            ),
            const SizedBox(height: 12)
          ],
        ),
      ),
    );
  }

  Widget _paymentOption(String method) {
    return RadioListTile<String>(
      value: method,
      groupValue: selectedMethod,
      title: Text(method),
      onChanged: (val) {
        setState(() {
          selectedMethod = val!;
        });
      },
    );
  }

  void _confirmOrder(BuildContext context) {
    final orderProvider = Provider.of<OrderProvider>(context, listen: false);
    final cartProvider = Provider.of<CartProvider>(context, listen: false);

    orderProvider.addOrder(
      products: widget.cartItems,
      totalAmount: widget.totalAmount,
      paymentMethod: selectedMethod,
    );

    cartProvider.clearCart();

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const OrderSuccessScreen()),
    );
  }
}

