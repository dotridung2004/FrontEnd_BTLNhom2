import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'screens/splash_screen.dart';
import 'providers/locale_provider.dart';
import 'generated/l10n.dart'; // <-- Sửa lại import

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => LocaleProvider(),
      builder: (context, child) {
        final provider = Provider.of<LocaleProvider>(context);
        return MaterialApp(
          title: 'TLU Teaching Schedule',
          debugShowCheckedModeBanner: false,

          // SỬA LẠI CÁC DÒNG NÀY
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],

          locale: provider.locale,
          theme: ThemeData(
            primarySwatch: Colors.blue,
            fontFamily: 'Roboto',
            scaffoldBackgroundColor: const Color(0xFFF0F4F8),
            useMaterial3: true,
          ),
          home: const SplashScreen(),
        );
      },
    );
  }
}