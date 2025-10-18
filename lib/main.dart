import 'package:flutter/material.dart';
import 'package:btl_nhom2/screens/splash_screen.dart'; // THAY 'package_name' BẰNG TÊN DỰ ÁN CỦA BẠN

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TLU Teaching Schedule',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Roboto', // Sử dụng font nhất quán
        scaffoldBackgroundColor: const Color(0xFFF0F4F8),
        useMaterial3: true,
      ),
      home: const SplashScreen(),
    );
  }
}