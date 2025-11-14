# Asset Request & Return Guide

This guide explains how the real request and return asset functionality works in WeTrack.

## Overview

The asset request and return system is now fully integrated with Firestore database. Users can:

1. **Request Assets** - Browse available assets and submit requests with a required date
2. **View Borrowed Assets** - See all assets currently borrowed by the user
3. **Return Assets** - Confirm asset returns with condition assessment and damage reporting

## Database Structure

### Collections

#### `assets` Collection
Each document represents an asset available in the system:

```
{
  "id": "A67495",
  "name": "HDMI - cable",
  "category": "Cable",
  "location": "Warehouse",
  "status": "AVAILABLE" | "BORROWED" | "PENDING_REQUEST",
  "borrowedByUserId": "user-123" (nullable),
  "dueDateTime": Timestamp (nullable)
}
```

#### `requests` Collection
Tracks all asset requests from users:

```
{
  "id": "request-001",
  "userId": "user-123",
  "userName": "John Doe",
  "assetId": "A67495",
  "assetName": "HDMI - cable",
  "requestedDate": Timestamp,
  "requiredDate": Timestamp,
  "status": "PENDING" | "APPROVED" | "REJECTED"
}
```

#### `asset_history` Collection
Logs all asset transactions (returns, damages, etc.):

```
{
  "assetId": "A67495",
  "action": "RETURNED",
  "condition": "Good" | "Minor Damage" | "Major Damage",
  "comments": "Some damage notes",
  "returnedByUserId": "user-123",
  "timestamp": Timestamp
}
```

## Key Features

### 1. Request Asset Page (`user_request_asset.dart`)

Users can request an available asset by:

1. Viewing asset details (name, category, location)
2. Selecting a required date using a date picker
3. (Optional) Adding a reason for the request
4. Submitting the request

**Database Operations:**
- Creates a new request document in `requests` collection with status "PENDING"
- Updates the asset status to "PENDING_REQUEST" in `assets` collection

**File:** `lib/user/user_request_asset.dart`

### 2. Assets List Page (`user_list_asset.dart`)

Displays available assets with real-time updates from Firestore:

- **Real-time stream** of AVAILABLE assets from database
- **Search functionality** by asset name or ID
- **Category filtering** (All, Electronics, Laptop, Cable)
- **Tap to request** - navigates to request page with asset details

**Database Operations:**
- Streams available assets: `FirestoreService.getAvailableAssets()`
- Filters by status = "AVAILABLE"

**File:** `lib/user/user_list_asset.dart`

### 3. Assets In Use Page (`user_asset_inuse.dart`)

Shows all assets currently borrowed by the signed-in user:

- **Real-time list** of borrowed assets
- **Due date tracking** with overdue status indication (red flag)
- **Return button** for each asset to initiate return process

**Database Operations:**
- Streams borrowed assets: `FirestoreService.getBorrowedAssets(userId)`
- Filters by status = "BORROWED" and borrowedByUserId = current user

**File:** `lib/user/user_asset_inuse.dart`

### 4. Return Asset Details Page (`user_return_asset_details.dart`)

Handles asset returns with condition assessment:

**Features:**
- Displays asset information
- Condition selection: "Good", "Minor Damage", "Major Damage"
- For damaged items:
  - Damage reporting via comments field
  - Action buttons for "REQUEST REPAIR" or "REQUEST REPLACE"
- Database transaction to confirm return

**Database Operations:**
- Uses `FirestoreService.confirmReturn()` which:
  1. Updates asset status back to "AVAILABLE"
  2. Removes `borrowedByUserId` and `dueDateTime`
  3. Logs the return in `asset_history` collection

**File:** `lib/user/user_return_asset_details.dart`

## Implementation Details

### FirestoreService Methods

#### Request Asset
```dart
Future<void> requestAsset({
  required String assetId,
  required String assetName,
  required DateTime requiredDate,
  required String userId,
  required String userName,
})
```

Creates a request and updates asset status to PENDING_REQUEST.

#### Get Borrowed Assets
```dart
Stream<List<Asset>> getBorrowedAssets(String userId)
```

Streams assets where status = "BORROWED" and borrowedByUserId = userId.

#### Confirm Return
```dart
Future<void> confirmReturn({
  required String assetId,
  required String condition,
  String? comments,
})
```

Atomically updates asset status and logs the return transaction.

## User Flow

### Requesting an Asset

1. User navigates to "Assets" section in home page
2. Sees list of AVAILABLE assets (real-time from Firestore)
3. Taps on an asset to request
4. **RequestAssetPage** shows:
   - Asset details (name, category, location)
   - Date picker to select when asset is needed
   - Optional reason field
5. User taps "Submit Request"
6. Request saved to Firestore with status "PENDING"
7. Asset status changes to "PENDING_REQUEST"
8. User sees confirmation message

### Borrowing an Asset

When admin approves a request:

1. Request status changes to "APPROVED"
2. Asset status changes to "BORROWED"
3. `borrowedByUserId` set to the user's ID
4. `dueDateTime` set to the required date
5. Asset appears in user's "Assets In Use" page

### Returning an Asset

1. User navigates to "Assets In Use" section
2. Sees list of borrowed assets (real-time from Firestore)
3. Overdue items show with red "OVERDUE" badge
4. User taps "Return" button on an asset
5. **ReturnAssetDetailsPage** shows asset info and condition options
6. User selects condition: Good / Minor Damage / Major Damage
7. If damaged, user can:
   - Add damage comments
   - (Optional) Request repair or replacement
8. User taps "CONFIRM RETURN"
9. Firestore transaction executes:
   - Asset status → "AVAILABLE"
   - Borrower info removed
   - Return logged in history
10. Success message shown
11. User returned to "Assets In Use" list

## Testing the Feature

### Prerequisites

1. **Enable Firestore in Google Cloud Console:**
   - Go to Firebase Console
   - Select your project
   - Enable Cloud Firestore API

2. **Create Sample Assets in Firestore:**

Create documents in `assets` collection:

```
Asset 1:
- id: "A67495"
- name: "HDMI - cable"
- category: "Cable"
- location: "Warehouse A"
- status: "AVAILABLE"

Asset 2:
- id: "L99821"
- name: "Laptop"
- category: "Electronics"
- location: "Lab 2"
- status: "AVAILABLE"
```

### Test Scenarios

**Test 1: Request an Asset**
1. Sign in to app
2. Navigate to "Assets" card
3. See list of available assets
4. Tap on "Laptop"
5. Select a date (tomorrow or later)
6. Tap "Submit Request"
7. Verify in Firestore that:
   - New doc created in `requests` collection with status "PENDING"
   - Asset status changed to "PENDING_REQUEST"

**Test 2: View Borrowed Assets**
1. (Admin: Approve the request and set asset status to "BORROWED")
2. Navigate to "Assets In Use" card
3. Should see the requested asset in the list
4. Due date should be highlighted in red if overdue

**Test 3: Return an Asset**
1. In "Assets In Use", tap "Return" on a borrowed asset
2. Select condition (e.g., "Good")
3. Optionally add comments
4. Tap "CONFIRM RETURN"
5. Verify in Firestore that:
   - Asset status back to "AVAILABLE"
   - New entry in `asset_history` collection with action "RETURNED"
   - Asset disappears from "Assets In Use" list

## Firestore Security Rules (Recommended)

```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    
    // Users can read their own profile and all public asset info
    match /users/{userId} {
      allow read: if request.auth.uid == userId;
      allow update: if request.auth.uid == userId;
    }
    
    match /assets/{assetId} {
      allow read: if request.auth != null;
      allow write: if request.auth.token.admin == true;
    }
    
    // Users can create requests and see their own
    match /requests/{requestId} {
      allow read: if request.auth.uid == resource.data.userId || request.auth.token.admin == true;
      allow create: if request.auth != null;
    }
    
    // History is append-only for auditing
    match /asset_history/{historyId} {
      allow read: if request.auth != null;
      allow create: if request.auth != null;
    }
  }
}
```

## Error Handling

The system includes comprehensive error handling:

- **Network errors**: User sees error message with retry option
- **Authentication errors**: Prompts user to sign in
- **Database errors**: Shows specific error message (e.g., "Asset not found")
- **Permission errors**: Informs user if Firestore API is not enabled

## Future Enhancements

1. **Request Approval Workflow**: Admin dashboard to approve/reject requests
2. **Notification System**: Notify users when requests are approved/denied
3. **Extended Return**: Allow users to request deadline extensions
4. **Damage Assessment**: Upload photos of damaged assets
5. **Return Reminders**: Send notifications as due dates approach
6. **Asset Handoff**: QR code scanning to confirm asset handoff

## Troubleshooting

**Issue:** Assets not showing in list
- **Solution:** Verify assets exist in Firestore with status = "AVAILABLE"

**Issue:** "Assets In Use" list is empty
- **Solution:** 
  - Check that user is signed in (prints to console)
  - Verify asset status = "BORROWED" and borrowedByUserId = current user ID

**Issue:** Return confirmation fails
- **Solution:** 
  - Check Firestore rules allow the operation
  - Verify asset exists in database

**Issue:** Overdue badge not showing
- **Solution:** Compare current date with dueDateTime in Firestore

## Files Modified

- `lib/user/user_list_asset.dart` - Asset browsing with request
- `lib/user/user_asset_inuse.dart` - Borrowed assets display
- `lib/user/user_return_asset_details.dart` - Return confirmation
- `lib/user/user_request_asset.dart` - NEW - Request submission page
- `lib/user/user_homepage.dart` - Updated to use real Firebase user ID

## Architecture

```
User Flow:
┌─────────────────┐
│   HomePage      │
└────────┬────────┘
         │
         ├─→ Assets (List Card)
         │   └─→ user_list_asset.dart
         │       └─→ Stream: getAvailableAssets()
         │           └─→ user_request_asset.dart
         │               └─→ requestAsset()
         │
         └─→ Assets In Use (List Card)
             └─→ user_asset_inuse.dart
                 └─→ Stream: getBorrowedAssets(userId)
                     └─→ user_return_asset_details.dart
                         └─→ confirmReturn()

Database:
┌──────────────────┐
│   Firestore      │
├──────────────────┤
│ assets           │ (Available, Borrowed, Pending)
│ requests         │ (User requests for assets)
│ asset_history    │ (Transaction log)
│ users            │ (User profiles)
└──────────────────┘
```
