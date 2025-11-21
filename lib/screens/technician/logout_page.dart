import 'package:flutter/material.dart';
import 'package:wetrack/screens/role_selection.dart';

class LogoutPage extends StatelessWidget {
  final String role;

  const LogoutPage({super.key, this.role = 'Technician'});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Log Out'),
        centerTitle: true,
        backgroundColor: const Color(0xFF00A7A7),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        // 🔹 Gradient background (same as Sign In & Success Page)
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF00A7A7), Color(0xFF004C5C)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: Container(
            width: MediaQuery.of(context).size.width * 0.85,
            // 🔹 UPDATED: Increased vertical padding to make the box "higher"
            padding: const EdgeInsets.symmetric(vertical: 35, horizontal: 24),
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(242),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26.withAlpha(26),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.power_settings_new,
                  color: Colors.redAccent,
                  size: 90,
                ),
                const SizedBox(height: 20),
                Text(
                  'You are logged in as $role.\nAre you sure you want to log out?',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16, // 🔹 UPDATED: Made font smaller (was 22)
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF333333),
                  ),
                ),
                const SizedBox(height: 40), // Added a bit more spacing

                // ✅ Log Out Button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (context) => RoleSelectionPage(),
                        ),
                        (route) => false,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF004C5C),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 3,
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.logout, color: Colors.white),
                        SizedBox(width: 8),
                        Text(
                          "Log Out",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize:
                                14, // 🔹 UPDATED: Made font smaller (was 16)
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 15),

                // ❌ Cancel Button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.pop(context); // Back to previous (Home)
                    },
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(
                        color: Color(0xFF004C5C),
                        width: 2,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.cancel, color: Color(0xFF004C5C)),
                        SizedBox(width: 8),
                        Text(
                          "Cancel",
                          style: TextStyle(
                            color: Color(0xFF004C5C),
                            fontWeight: FontWeight.bold,
                            fontSize:
                                14, // 🔹 UPDATED: Made font smaller (was 16)
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
