import 'package:flutter/material.dart';
import 'signin_page.dart';

class SuccessPage extends StatelessWidget {
  final String? assetName;
  final String? role;

  const SuccessPage({super.key, this.assetName, this.role});

  @override
  Widget build(BuildContext context) {
    // Determine the message dynamically, using Markdown for emphasis
    final String message = assetName == null
        ? "Your account has been created successfully!"
        : "You’ve successfully requested $assetName.";

    // Define the primary teal color palette for consistency
    const Color primaryColor = Color(0xFF00A7A7); // Lighter Teal
    const Color secondaryColor = Color(0xFF004C5C); // Darker Teal

    return Scaffold(
      // Scaffold background is transparent to show the full-screen gradient
      backgroundColor: Colors.transparent,
      body: Container(
        // Full-screen gradient background (Dark Teal/Cyan)
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [secondaryColor, primaryColor],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30.0),
            child: Container(
              // Using a subtle white overlay for a modern, high-contrast card
              decoration: BoxDecoration(
                color: Colors.white
                    .withOpacity(0.15), // Corrected to use withOpacity
                borderRadius: BorderRadius.circular(25.0),
                border: Border.all(
                    color: Colors.white.withOpacity(0.3), width: 1.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.25),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(30),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // --- Success Icon Container ---
                  Container(
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      // Lighter, more vibrant gradient for the icon background
                      gradient: LinearGradient(
                        colors: [Color(0xFF33D1C8), primaryColor],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 15,
                          offset: Offset(0, 5),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(25),
                    child: const Icon(
                      Icons.check_circle_outline,
                      size: 55,
                      color: Colors.white, // White icon for maximum contrast
                    ),
                  ),
                  const SizedBox(height: 30),

                  // --- Title ---
                  const Text(
                    "SUCCESS!",
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 28,
                      color: Colors.white, // High contrast text on dark card
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 15),

                  // --- Message ---
                  Text(
                    message,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18,
                      color:
                          Colors.white.withOpacity(0.9), // Slightly faded white
                      height: 1.4,
                    ),
                  ),

                  const SizedBox(height: 40),

                  // --- Continue Button ---
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            primaryColor, // Consistent primary color
                        foregroundColor: Colors.white,
                        elevation: 10,
                        shadowColor: secondaryColor.withOpacity(0.6),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        textStyle: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          letterSpacing: 1,
                        ),
                      ),
                      onPressed: () {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                SignInPage(role: role ?? "User"),
                          ),
                          (route) => false,
                        );
                      },
                      child: const Text("CONTINUE TO LOGIN"),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
