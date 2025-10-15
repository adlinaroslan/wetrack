import 'package:flutter/material.dart';
import 'role_selection.dart'; // import your role selection page

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Role Selection & Sign In',
      theme: ThemeData(
        primarySwatch: Colors.green,
        scaffoldBackgroundColor: Colors.grey[200],
      ),
      home: RoleSelectionPage(),
    );
  }
}
