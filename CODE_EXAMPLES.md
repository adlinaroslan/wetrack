# Authentication Code Examples

## Complete Authentication Flow Code Snippets

### 1. Sign In Page Implementation

```dart
// lib/signin_page.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'user/user_homepage.dart';
import 'signup_page.dart';

class SignInPage extends StatefulWidget {
  final String role;
  const SignInPage({super.key, required this.role});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  String? errorText;
  bool isLoading = false;

  Future<void> handleLogin() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      setState(() => errorText = "Please fill in all fields");
      return;
    }

    try {
      setState(() => isLoading = true);
      setState(() => errorText = null);

      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomePage()),
        );
      }
    } on FirebaseAuthException catch (e) {
      setState(() => errorText = e.message ?? "Login failed");
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF00A7A7), Color(0xFF004C5C)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text(
                    "WeTrack.",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "Sign In as ${widget.role}",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 30),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        TextField(
                          controller: emailController,
                          decoration: InputDecoration(
                            labelText: "Email",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8)
                            ),
                            filled: true,
                            fillColor: Colors.grey[100],
                          ),
                        ),
                        const SizedBox(height: 14),
                        TextField(
                          controller: passwordController,
                          obscureText: true,
                          decoration: InputDecoration(
                            labelText: "Password",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8)
                            ),
                            filled: true,
                            fillColor: Colors.grey[100],
                          ),
                        ),
                        if (errorText != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 12),
                            child: Text(
                              errorText!,
                              style: const TextStyle(color: Colors.red),
                            ),
                          ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF004C5C),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            onPressed: isLoading ? null : handleLogin,
                            child: isLoading
                                ? const CircularProgressIndicator(
                                    color: Colors.white)
                                : const Text(
                                    "SIGN IN",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextButton(
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => SignUpPage(role: widget.role),
                            ),
                          ),
                          child: const Text("Don't have an account? Sign Up"),
                        ),
                      ],
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
```

### 2. Sign Up Page with Firestore Integration

```dart
// lib/signup_page.dart - Key method
Future<void> handleSignUp() async {
  final email = emailController.text.trim();
  final password = passwordController.text.trim();
  final confirmPassword = confirmPasswordController.text.trim();
  final phone = phoneController.text.trim();

  // Validation
  if (email.isEmpty || password.isEmpty || phone.isEmpty) {
    setState(() => errorText = "Please fill in all fields");
    return;
  }

  if (password != confirmPassword) {
    setState(() => errorText = "Passwords do not match");
    return;
  }

  if (password.length < 6) {
    setState(() => errorText = "Password must be at least 6 characters");
    return;
  }

  try {
    setState(() => isLoading = true);
    setState(() => errorText = null);

    // Create user with Firebase Authentication
    final UserCredential userCredential =
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    // Store user data in Firestore
    await FirebaseFirestore.instance
        .collection('users')
        .doc(userCredential.user!.uid)
        .set({
      'uid': userCredential.user!.uid,
      'email': email,
      'phone': phone,
      'role': widget.role,
      'createdAt': DateTime.now().toIso8601String(),
      'displayName': email.split('@')[0],
    });

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => SuccessPage(role: widget.role),
        ),
      );
    }
  } on FirebaseAuthException catch (e) {
    setState(() => errorText = e.message ?? "Sign up failed");
  } catch (e) {
    setState(() => errorText = "An error occurred: $e");
  } finally {
    if (mounted) {
      setState(() => isLoading = false);
    }
  }
}
```

### 3. Role Selection with Navigation

```dart
// lib/role_selection.dart
Widget buildRoleButton(String role) {
  final bool isSelected = selectedRole == role;

  return GestureDetector(
    onTap: () {
      setState(() => selectedRole = role);
      Future.delayed(const Duration(milliseconds: 200), () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => SignInPage(role: role)),
        );
      });
    },
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: double.infinity,
      height: 50,
      decoration: BoxDecoration(
        color: isSelected
            ? const Color.fromARGB(255, 104, 255, 157)
            : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 6,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      alignment: Alignment.center,
      child: Text(
        role,
        style: TextStyle(
          color: isSelected ? Colors.white : Colors.black,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
  );
}
```

### 4. Firebase Initialization in main.dart

```dart
// lib/main.dart
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
```

### 5. Retrieving User Data After Login

```dart
// Example: Get current user info after login
void getCurrentUser() {
  final user = FirebaseAuth.instance.currentUser;
  
  if (user != null) {
    // Get user profile from Firestore
    FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get()
        .then((doc) {
      final userData = doc.data();
      final role = userData?['role'];
      final email = userData?['email'];
      final displayName = userData?['displayName'];
      
      print('User Role: $role');
      print('User Email: $email');
      print('Display Name: $displayName');
    });
  }
}
```

### 6. Logout Implementation

```dart
// lib/logout.dart - Example logout method
Future<void> logout() async {
  try {
    await FirebaseAuth.instance.signOut();
    
    // Navigate back to role selection
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const RoleSelectionPage()),
      (route) => false,
    );
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error logging out: $e')),
    );
  }
}
```

## pubspec.yaml Dependencies

```yaml
dependencies:
  flutter:
    sdk: flutter
  firebase_core: ^2.32.0
  firebase_auth: ^4.17.0
  cloud_firestore: ^4.13.6
  mobile_scanner: ^7.0.0
  permission_handler: ^11.4.0
```

## Testing Credentials

Use these for testing (after creating accounts):

```
Email: test.user@example.com
Password: TestUser@123
Role: User
---
Email: test.tech@example.com
Password: TestTech@123
Role: Technician
---
Email: test.admin@example.com
Password: TestAdmin@123
Role: Administrator
```

## Error Messages Handled

| Scenario | Error Code | Message |
|----------|-----------|---------|
| Empty fields | Manual | "Please fill in all fields" |
| Password mismatch | Manual | "Passwords do not match" |
| Short password | Manual | "Password must be at least 6 characters" |
| Invalid email format | auth/invalid-email | Firebase error message |
| User not found | auth/user-not-found | Firebase error message |
| Wrong password | auth/wrong-password | Firebase error message |
| Email already in use | auth/email-already-in-use | Firebase error message |
| Weak password | auth/weak-password | Firebase error message |

All error handling displays user-friendly messages and allows retry without force-closing the app.
