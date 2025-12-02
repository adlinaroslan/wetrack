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
                        fontSize: 20,
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

  // --- REVISED _assetCard Widget ---
  Widget _assetCard(
    BuildContext context, {
    required String image,
    required String name,
    required String date,
    required String status,
    required Color
        color, // This parameter is now redundant but kept for consistency
  }) {
    // Define the main gradient (copied from the class)
    const LinearGradient mainGradient = LinearGradient(
      colors: [Color(0xFF00A7A7), Color(0xFF004C5C)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );

    // Determine the status color based on the status string
    Color statusBgColor;
    if (status == 'Overdue') {
      statusBgColor = Colors.red.shade600;
    } else if (status == 'In-use') {
      statusBgColor = Colors.orange.shade600;
    } else {
      statusBgColor = Colors.grey.shade600;
    }
    const Color statusTextColor = Colors.white;

    return Container(
      margin:
          const EdgeInsets.only(bottom: 15), // Added margin to separate cards
      decoration: BoxDecoration(
        gradient: mainGradient,
        borderRadius: BorderRadius.circular(16), // Slightly smaller radius
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
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
            // Reduced Padding for a tighter fit
            padding: const EdgeInsets.symmetric(
              horizontal: 15.0,
              vertical: 12.0,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Smaller Image: CircleAvatar with radius 30
                CircleAvatar(
                  backgroundColor: const Color(0xFFEFFBFA),
                  backgroundImage: AssetImage(image),
                  radius:
                      30, // Reduced radius for a more standard list item height
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
                          fontSize: 16, // Adjusted font size
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        date,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12, // Adjusted font size
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 15),

                // Status Badge and Arrow
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: statusBgColor,
                    borderRadius:
                        BorderRadius.circular(8), // Reduced badge radius
                  ),
                  child: Text(
                    status,
                    style: const TextStyle(
                      color: statusTextColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 12, // Adjusted font size
                    ),
                  ),
                ),
                const SizedBox(width: 8), // Smaller gap between badge and arrow
                const Icon(
                  Icons.arrow_forward_ios,
                  color: Color.fromARGB(255, 255, 255, 255),
                  size: 16, // Reduced arrow size
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
