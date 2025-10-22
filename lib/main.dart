import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';

// 👉 THÊM MỚI: Import để hỗ trợ localization (Tiếng Việt)
import 'package:flutter_localizations/flutter_localizations.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  // Cú pháp constructor hiện đại hơn
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TLU Teaching Schedule',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        // Cập nhật cách dùng theme cho Material 3
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),

      // --- ⬇️ THÊM CẤU HÌNH TIẾNG VIỆT ⬇️ ---
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('vi', ''), // Tiếng Việt
        Locale('en', ''), // Tiếng Anh (dự phòng)
      ],
      // Đặt Tiếng Việt làm mặc định (tùy chọn)
      locale: const Locale('vi', ''),
      // --- ⬆️ KẾT THÚC CẤU HÌNH ⬆️ ---

      home: const SplashScreen(),
    );
  }
}