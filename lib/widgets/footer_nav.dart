import 'package:flutter/material.dart';

// Footer navigation is for Administrator and Technician only.
import '../screens/technician/technician_home.dart' as tech_home;
import '../screens/administrator/admin_home.dart' as admin_home;
import '../screens/technician/technician_scan_page.dart' as tech_scan;
import '../screens/technician/logout_page.dart' as tech_logout;
import '../screens/administrator/logout_page.dart' as admin_logout;

// ✅ Project gradient (same as your example)
const LinearGradient footerGradient = LinearGradient(
  colors: [Color(0xFF00A7A7), Color(0xFF004C5C)],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

class FooterNav extends StatelessWidget {
  final String role;

  const FooterNav({super.key, this.role = 'Technician'});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80, // ✅ footer height
      decoration: const BoxDecoration(
        gradient: footerGradient,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(50), // ✅ rounded top corners
          topRight: Radius.circular(50),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10,
            offset: Offset(0, -3),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildFooterButton(
            context,
            icon: Icons.home,
            label: "Home",
            onTap: () {
              final r = role.toLowerCase();
              if (r == 'administrator' || r == 'admin') {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const admin_home.AdminHomePage(),
                  ),
                );
              } else {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const tech_home.TechnicianHomePage(),
                  ),
                );
              }
            },
          ),
          _buildFooterButton(
            context,
            icon: Icons.qr_code_scanner,
            label: "Scan",
            onTap: () {
              final r = role.toLowerCase();
              if (r == 'technician') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const tech_scan.TechnicianScanPage(),
                  ),
                );
              } else {
                Navigator.pushNamed(context, '/scanqr');
              }
            },
          ),
          _buildFooterButton(
            context,
            icon: Icons.logout,
            label: "Logout",
            onTap: () {
              final r = role.toLowerCase();
              if (r == 'administrator' || r == 'admin') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        admin_logout.LogoutPage(role: 'Administrator'),
                  ),
                );
              } else {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        tech_logout.LogoutPage(role: 'Technician'),
                  ),
                );
              }
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
          Icon(icon, color: Colors.white, size: 28),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
