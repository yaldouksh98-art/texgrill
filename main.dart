import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'screens/splash_page.dart';
import 'screens/onboarding_page.dart';
import 'screens/login_page.dart';
import 'screens/home_page.dart';
import 'screens/menu_page.dart'; // ✅ Corretto
import 'screens/scelta_ordine_page.dart';
import 'screens/ordine_page.dart';
import 'screens/carrello_page.dart';
import 'screens/storico_ordini_page.dart';
import 'screens/opinione_page.dart';
import 'screens/lavora_con_noi_page.dart';
import 'screens/coupon_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "AIzaSyCtY9_mMreWWCZT33uyAbni4nBBY5TtaSE",
      authDomain: "texgrill-62bca.firebaseapp.com",
      projectId: "texgrill-62bca",
      storageBucket: "texgrill-62bca.appspot.com", // ✅ corretto
      messagingSenderId: "646506090092",
      appId: "1:646506090092:web:13051ccb27e3ed27095249",
    ),
  );
  
  runApp(const TexGrillApp());
}

class TexGrillApp extends StatelessWidget {
  const TexGrillApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'TexGrill App',
      
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('it', 'IT'),
        Locale('en', 'US'),
      ],
      locale: const Locale('it', 'IT'),

      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0F0F0F),
        primaryColor: const Color(0xFFFF4500),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFFF4500),
          secondary: Colors.amber,
        ),
        cardTheme: CardTheme(
          color: const Color(0xFF1E1E1E),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFFF4500),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ),

      initialRoute: '/',
      routes: {
        '/': (context) => const SplashPage(),
        '/onboarding': (context) => const OnboardingPage(),
        '/login': (context) => const LoginPage(),
        '/home': (context) => const HomePage(),
        '/menu': (context) => const MenuPage(),
        '/carrello': (context) => const CarrelloPage(),
        '/storico': (context) => const StoricoOrdiniPage(),
        '/opinione': (context) => const OpinionePage(),
        '/lavora': (context) => const LavoraConNoiPage(),
        '/coupon': (context) => const CouponPage(),
      },
    );
  }
}