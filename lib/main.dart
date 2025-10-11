import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_ecommerce_demo/src/providers/order_provider.dart';
import 'package:flutter_ecommerce_demo/src/providers/product_provider.dart';
import 'package:flutter_ecommerce_demo/src/screens/splash_screen.dart';
import 'package:provider/provider.dart';

import 'src/screens/sign_in.dart';
import 'src/screens/home_screen.dart'; // 👈 move your real HomeScreen here (not dummy)
import 'src/providers/cart_provider.dart';
import 'src/providers/wishlist_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ProductProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => WishlistProvider()),
        ChangeNotifierProvider(create: (_) => OrderProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Flutter E-commerce Demo',
        theme: ThemeData(
          primarySwatch: Colors.deepPurple,
          useMaterial3: true,
        ),
        home: const SplashScreen(),
      ),
    );
  }
}

// 🔑 Auth Wrapper — checks login state
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasData) {
          return const HomeScreen(); // ✅ Redirect after login
        } else {
          return const SignInScreen(); // 👈 Before login
        }
      },
    );
  }
}
