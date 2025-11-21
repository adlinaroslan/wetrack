import 'package:flutter/material.dart';
import 'package:wetrack/services/chat_list_page.dart';
import 'package:wetrack/screens/user/logout_page.dart';
import 'user_notification.dart';
import 'user_profile_page.dart';
import 'user_return_asset_details.dart';

class UserReturnAssetPage extends StatelessWidget {
  const UserReturnAssetPage({super.key});

  // Define a constant for the main gradient
  static const LinearGradient mainGradient = LinearGradient(
    colors: [Color(0xFF00A7A7), Color(0xFF004C5C)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80),
        child: Container(
          decoration: const BoxDecoration(gradient: mainGradient),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 8.0,
                vertical: 20.0,
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Expanded(
                    child: Text(
                      "Return Asset",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  // Message icon
                  IconButton(
                    icon: const Icon(Icons.message, color: Colors.white),
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => ChatListPage()),
                    ),
                  ),
                  // Notification icon
                  IconButton(
                    icon: const Icon(Icons.notifications, color: Colors.white),
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const UserNotificationPage(),
                      ),
                    ),
                  ),
                  // Profile icon
                  IconButton(
                    icon: const Icon(Icons.person, color: Colors.white),
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const UserProfilePage(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),

      // Body
      body: Padding(
        padding: const EdgeInsets.all(25.0),
        child: Column(
          children: [
            // 🔹 HDMI cable item
            _assetCard(
              context,
              image: 'assets/images/hdmi.png',
              name: 'HDMI - cable',
              date: '23 Jan 2025 - 25 Jan 2025',
              status: 'Overdue',
              color: Colors.red,
            ),
            const SizedBox(height: 20),

            // 🔹 Extension item
            _assetCard(
              context,
              image: 'assets/images/extension.png',
              name: 'Extension',
              date: '25 Jan 2025 - 30 Jan 2025',
              status: 'In-use',
              color: Colors.orange,
            ),
          ],
        ),
      ),

      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: mainGradient,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(50),
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
            child: BottomNavigationBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              currentIndex: 0,
              selectedItemColor: const Color.fromARGB(255, 255, 255, 255),
              unselectedItemColor: Colors.white,
              items: const [
                BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
                BottomNavigationBarItem(
                  icon: Icon(Icons.qr_code_scanner),
                  label: "Scan",
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.logout),
                  label: "Logout",
                ),
              ],
              onTap: (index) {
                if (index == 0) {
                  Navigator.pop(context);
                } else if (index == 1) {
                  Navigator.pushNamed(context, '/scanqr');
                } else if (index == 2) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const LogoutPage()),
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  // --- UPDATED _assetCard Widget with Colored Badges ---
  Widget _assetCard(
    BuildContext context, {
    required String image,
    required String name,
    required String date,
    required String status,
    required Color color,
  }) {
    // 1. Determine the status color based on the status string
    Color statusBgColor;
    Color statusTextColor = Colors.white; // Text color is white for contrast

    if (status == 'Overdue') {
      statusBgColor = Colors.red.shade600;
    } else if (status == 'In-use') {
      statusBgColor = Colors.orange.shade600;
    } else {
      statusBgColor = Colors.grey.shade600;
    }

    return Container(
      decoration: BoxDecoration(
        gradient: mainGradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(38),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            // Navigate to details page
            final assetId = name.replaceAll(' ', '_').toLowerCase();
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => UserReturnAssetDetailsPage(
                  assetName: name,
                  assetId: assetId,
                  category: 'General',
                  location: 'Storage',
                  status: status,
                  imagePath: image,
                ),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 18.0,
              vertical: 16.0,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Bigger Image: CircleAvatar with radius 50
                CircleAvatar(
                  backgroundColor: const Color(0xFFEFFBFA),
                  backgroundImage: AssetImage(image),
                  radius: 50,
                ),
                const SizedBox(width: 15),

                // Asset Details (Title and Date)
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        date,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),

                // Status Badge and Arrow
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // ⭐ The status badge container now uses the determined statusBgColor
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: statusBgColor,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        status,
                        style: TextStyle(
                          color: statusTextColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Icon(
                      Icons.arrow_forward_ios,
                      color: Colors.white70,
                      size: 18,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
