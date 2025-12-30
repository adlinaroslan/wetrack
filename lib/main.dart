import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:wetrack/services/firebase_options.dart';
import 'package:wetrack/screens/splash_screen.dart';
import 'package:wetrack/screens/user/user_homepage.dart';
import 'package:wetrack/screens/user/user_list_asset.dart';
import 'package:wetrack/screens/user/user_notification.dart';
import 'package:wetrack/screens/user/logout_page.dart';
import 'package:wetrack/screens/user/user_scan_qr_page.dart';
import 'package:wetrack/services/firestore_service.dart';
import 'package:wetrack/services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    await NotificationService.init();

    // Run migration to fix missing borrowDates on app startup
    final firestoreService = FirestoreService();
    await firestoreService.fixMissingBorrowDates();
  } catch (e) {
    if (!e.toString().contains('duplicate')) {
      rethrow;
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
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF00A7A7)),
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
        '/': (context) => const SplashScreen(),
        '/homepage': (context) => const HomePage(),
        '/listasset': (context) => const ListAssetPage(),
        '/notification': (context) => const UserNotificationPage(),
        '/logout': (context) => const LogoutPage(),
        '/scanqr': (context) => const ScanQRPage(),
      },
    );
  }
}
