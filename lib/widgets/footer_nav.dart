import 'package:flutter/material.dart';
import '../screens/technician/technician_home.dart';
import '../screens/technician/logout_page.dart';
import '../screens/technician/technician_scan_page.dart';

class FooterNav extends StatelessWidget {
  const FooterNav({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildFooterButton(
            context,
            icon: Icons.home,
            label: "Home",
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const TechnicianHomePage()),
              );
            },
          ),
          _buildFooterButton(
            context,
            icon: Icons.qr_code_scanner,
            label: "Scan",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const TechnicianScanPage()),
              );
            },
          ),
          _buildFooterButton(
            context,
            icon: Icons.logout,
            label: "Logout",
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const LogoutPage()),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFooterButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: const Color(0xFF00BFA6), size: 28),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}
