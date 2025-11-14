# Authentication Setup Checklist

## Firebase Configuration

### Required Firebase Services
- [x] Firebase Authentication (Email/Password)
- [x] Cloud Firestore Database
- [x] Firebase Core initialized in main.dart

### Firebase Console Setup
1. **Enable Cloud Firestore API**
   - Navigate to: https://console.developers.google.com/apis/api/firestore.googleapis.com/overview?project=wetrack-fc09f
   - Click "Enable"
   - Wait for activation (may take a few minutes)

2. **Firestore Security Rules** (Update in Firebase Console)
```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId} {
      allow read, write: if request.auth.uid == userId;
    }
    match /assets/{assetId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null;
    }
    match /requests/{requestId} {
      allow read, write: if request.auth != null;
    }
  }
}
```

## Code Files Modified

✅ `lib/signin_page.dart`
- Updated class name from `LoginPage` to `SignInPage`
- Added role parameter
- Enhanced error handling
- Improved UI with gradient background

✅ `lib/signup_page.dart`
- Added role parameter
- Added Firestore integration
- Enhanced validation (email, password strength, phone)
- Stores user profile in Firestore

✅ `lib/role_selection.dart`
- Removed MouseRegion (mobile-friendly)
- Properly passes role to SignInPage
- Better touch interaction

✅ `lib/success_page.dart`
- Added role parameter
- Routes back to SignIn with preserved role

✅ `lib/main.dart`
- Fixed Firebase initialization
- Proper duplicate-app error handling

✅ `pubspec.yaml`
- Updated firebase_core to ^2.32.0 (compatible with firebase_auth)
- Verified firebase_auth: ^4.17.0
- Verified cloud_firestore: ^4.13.6

## Running the Application

### Prerequisites
```bash
# Flutter version 3.9.2 or higher
flutter --version

# Ensure all dependencies are installed
flutter pub get

# Clean build cache if needed
flutter clean
flutter pub get
```

### Run Commands

**Android Device:**
```bash
flutter run
```

**Windows Desktop:**
```bash
flutter run -d windows
```

**Web:**
```bash
flutter run -d chrome
```

## Testing the Authentication System

### Step 1: Splash Screen
- App displays "WeTrack" logo for 3 seconds
- Automatic animation with fade-in and zoom effect

### Step 2: Role Selection
- Select one of three roles:
  - User
  - Technician
  - Administrator
- Navigates to Sign In page with selected role

### Step 3: New User - Sign Up
```
1. Click "Don't have an account? Sign Up"
2. Fill in registration form:
   - Email: test@example.com
   - Password: Test@123 (min 6 chars)
   - Confirm: Test@123
   - Phone: 0123456789
3. Click "SIGN UP"
4. Success page confirms account created
5. Redirect to Sign In page
```

### Step 4: Existing User - Sign In
```
1. Email: test@example.com
2. Password: Test@123
3. Click "SIGN IN"
4. Navigate to HomePage
```

### Step 5: Error Handling
Test various error scenarios:
- Empty fields → "Please fill in all fields"
- Wrong password → Firebase error
- Non-existent user → Firebase error
- Mismatched passwords (signup) → "Passwords do not match"
- Short password → "Password must be at least 6 characters"

## Firestore Database Structure

After successful sign up, check Firestore Console:

Collection: `users`
```
Document ID: {Firebase UID}
{
  "uid": "firebase-uid",
  "email": "test@example.com",
  "phone": "0123456789",
  "role": "User|Technician|Administrator",
  "createdAt": "2025-11-14T...",
  "displayName": "test"
}
```

## Deployment Checklist

Before deploying to production:

- [ ] Firestore API enabled
- [ ] Firestore Security Rules configured
- [ ] Test email/password authentication works
- [ ] Test Firestore user data storage
- [ ] Test all three roles (User, Technician, Admin)
- [ ] Test error scenarios
- [ ] Verify Firebase project ID matches
- [ ] Test on both Android and iOS (if applicable)

## Common Issues & Solutions

### Issue: "Cloud Firestore API has not been used"
**Solution**: Enable Firestore API in Firebase Console
```
https://console.developers.google.com/apis/api/firestore.googleapis.com/overview?project=wetrack-fc09f
```

### Issue: App crashes on Sign Up
**Solution**: Check Firestore rules allow write access and API is enabled

### Issue: "Undefined name 'FirebaseAuth'"
**Solution**: Run `flutter clean && flutter pub get`

### Issue: Routes/Navigation not working
**Solution**: Ensure page imports are correct and route constructors match

## Next Steps

1. ✅ Enable Firestore API
2. ✅ Test complete authentication flow
3. ✅ Implement role-based access in HomePage
4. ✅ Add email verification (optional)
5. ✅ Add password reset flow (optional)
