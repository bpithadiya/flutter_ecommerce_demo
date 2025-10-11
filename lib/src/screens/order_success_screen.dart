import 'package:flutter/material.dart';
import '../widgets/custom_button.dart';
import 'home_screen.dart';

class OrderSuccessScreen extends StatelessWidget {
  const OrderSuccessScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.check_circle, color: Colors.green, size: 100),
              const SizedBox(height: 20),
              const Text(
                "Payment Successful!",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              const Text(
                "Your order has been placed successfully.",
                style: TextStyle(color: Colors.black54),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              CustomButton(
                label: "Back to Home",
                onPressed: () {
                  // _confirmOrder(context);
                  Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (_) => const HomeScreen(reload: true)),

                        );
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}
