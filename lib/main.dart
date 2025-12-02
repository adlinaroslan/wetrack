import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:wetrack/services/firebase_options.dart';
import 'package:wetrack/screens/user/user_homepage.dart';
import 'package:wetrack/screens/user/user_list_asset.dart';
import 'package:wetrack/screens/user/user_asset_request.dart';
import 'package:wetrack/screens/user/user_notification.dart';
import 'package:wetrack/screens/user/logout_page.dart';
import 'package:wetrack/screens/user/user_scan_qr_page.dart';
import 'package:wetrack/screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (!kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS)) {
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    } catch (e) {
      // Firebase app already initialized (common during hot reload)
      if (!e.toString().contains('duplicate')) {
        rethrow;
      }
    }
  }

  runApp(const WeTrackApp());
}

class WeTrackApp extends StatelessWidget {
  const WeTrackApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WeTrack',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color(0xFF00A7A7),
        scaffoldBackgroundColor: const Color(0xFFEFF9F9),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF00A7A7),
          elevation: 0,
          titleTextStyle: TextStyle(color: Colors.white, fontSize: 20),
          iconTheme: IconThemeData(color: Colors.white),
        ),
      ),
      initialRoute: '/',
      routes: {
        // 1. The main route now points to the SplashScreen
        '/': (context) => const SplashScreen(),
        // 2. We move the previous content of '/' (HomePage) to a new named route '/homepage'
        '/homepage': (context) => const HomePage(),
        '/listasset': (context) => const ListAssetPage(),
        '/assetrequest': (context) => const RequestAssetPage(
              assetName: "Default Asset",
              assetId: "A-000",
            ),
        '/notification': (context) => const UserNotificationPage(),
        '/logout': (context) => const LogoutPage(),
        '/scanqr': (context) => const ScanQRPage(),
      },
    );
  }
}
