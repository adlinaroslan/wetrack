# WeTrack Authentication System Guide

## Overview
A complete email/password authentication system with role-based access (User, Technician, Administrator) that integrates Firebase Auth and Firestore.

## Authentication Flow

### 1. **Splash Screen** (`splash_screen.dart`)
- **Duration**: 3 seconds
- **Features**: Fade-in and zoom animation
- **Navigation**: Shows animated WeTrack logo, then navigates to Role Selection

### 2. **Role Selection** (`role_selection.dart`)
- **Purpose**: User selects their role before authentication
- **Roles Available**:
  - User (borrowing and returning assets)
  - Technician (managing assets)
  - Administrator (system management)
- **Navigation**: Passes selected role to SignInPage

### 3. **Sign In Page** (`signin_page.dart`)
- **Features**:
  - Email and password fields
  - Error messages for failed login
  - Loading indicator during authentication
  - Link to Sign Up for new users
- **Authentication**: Uses Firebase Authentication
- **On Success**: 
  - User directed to HomePage
  - Role information passed through navigation
- **Error Handling**: Displays Firebase auth errors (invalid email, wrong password, etc.)

### 4. **Sign Up Page** (`signup_page.dart`)
- **Fields**:
  - Email
  - Password (minimum 6 characters)
  - Confirm Password
  - Phone Number
- **Validation**:
  - All fields required
  - Passwords must match
  - Minimum 6 character password
- **On Success**:
  - Creates Firebase Auth user
  - Stores user data in Firestore under `users` collection
  - Navigates to Success Page
- **Firestore User Document Structure**:
```json
{
  "uid": "user_uid",
  "email": "user@example.com",
  "phone": "1234567890",
  "role": "User|Technician|Administrator",
  "createdAt": "2025-11-14T...",
  "displayName": "user"
}
```

### 5. **Success Page** (`success_page.dart`)
- **Purpose**: Confirmation after successful account creation
- **Features**:
  - Success message with icon
  - Dynamic messaging (shows role if available)
  - Continue button to return to Sign In
- **Navigation**: Returns user to Sign In page with appropriate role

## Key Components

### Firebase Services Used
1. **Firebase Authentication**
   - Email/Password sign in
   - Email/Password registration
   - Error handling for auth failures

2. **Cloud Firestore**
   - Stores user profile data
   - Collection: `users`
   - Document ID: Firebase UID

### Navigation Flow
```
Splash Screen (3 sec)
    ↓
Role Selection Page
    ↓
Sign In Page ←→ Sign Up Page (new users)
    ↓                ↓
HomePage       Success Page
                    ↓
               Sign In Page
```

## User Registration Flow

1. User sees Splash Screen (3 seconds)
2. User selects role (User/Technician/Administrator)
3. User clicks "Don't have an account? Sign Up"
4. User fills in Sign Up form
5. System validates inputs
6. Firebase creates auth user
7. Firestore stores user profile with role
8. Success page shown
9. User returned to Sign In with their role pre-filled

## User Login Flow

1. User sees Splash Screen (3 seconds)
2. User selects role
3. User enters credentials
4. Firebase authenticates
5. On success → HomePage
6. On error → Error displayed, can retry

## Authentication Error Handling

| Error | Message | Solution |
|-------|---------|----------|
| Empty Fields | "Please fill in all fields" | Fill in all required fields |
| Password Mismatch | "Passwords do not match" | Ensure passwords are identical |
| Short Password | "Password must be at least 6 characters" | Use stronger password |
| Invalid Email | Firebase error | Use valid email format |
| User Not Found | Firebase error | Create new account or check email |
| Wrong Password | Firebase error | Check password spelling |
| Email Already Exists | Firebase error | Use different email or login |

## Testing the Authentication

### Test Case 1: New User Registration
```
1. Role: User
2. Email: test@example.com
3. Password: Test123
4. Phone: 0123456789
5. Expected: Account created, Success page shown
```

### Test Case 2: Login with Correct Credentials
```
1. Role: User
2. Email: test@example.com
3. Password: Test123
4. Expected: Navigate to HomePage
```

### Test Case 3: Login with Wrong Password
```
1. Role: User
2. Email: test@example.com
3. Password: WrongPassword
4. Expected: Error message shown
```

## Integration with HomePage

After successful authentication, users are directed to `HomePage` (`user/user_homepage.dart`) where they can:
- View asset lists
- Request assets
- Track requests
- Scan QR codes
- Access notifications
- View profile

## Security Notes

1. **Passwords**: Firebase Auth handles password security
2. **User Data**: Role stored in Firestore for access control
3. **Session**: Firebase handles session management
4. **Device Storage**: No credentials stored locally (Firebase handles this)

## Future Enhancements

1. **Email Verification**: Add email verification before account activation
2. **Password Reset**: Implement forgot password functionality
3. **Google/Facebook Login**: Add social authentication
4. **Two-Factor Authentication**: Add 2FA for security
5. **Role-Based UI**: Different homepage layouts per role
6. **Activity Logging**: Track authentication events

## Troubleshooting

### App Crashes on Startup
- Ensure Firebase is initialized in `main.dart`
- Check Firestore API is enabled in Firebase Console

### Sign In Not Working
- Verify Firestore API is enabled
- Check internet connection
- Ensure correct credentials are used

### Sign Up Creates Account But Shows Error
- Check Firestore is accessible
- Verify user collection exists or can be created
- Check cloud_firestore dependency is correct version

### Navigation Issues
- Ensure all imported pages exist
- Check route parameters match page constructors
- Verify MaterialPageRoute is used correctly
