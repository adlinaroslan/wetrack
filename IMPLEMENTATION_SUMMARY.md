# Real Request & Return Asset Implementation - Summary

## What's Been Implemented

You now have a **fully functional asset request and return system** integrated with Firestore. Users can request available assets from a real database and return borrowed assets with condition tracking.

## Files Created/Modified

### New Files

1. **`lib/user/user_request_asset.dart`**
   - Page for requesting assets
   - Date picker for selecting required date
   - Reason/notes field (optional)
   - Submits to Firestore requests collection

### Modified Files

1. **`lib/user/user_list_asset.dart`** 
   - Now uses real Firestore stream of available assets
   - Shows AVAILABLE assets only
   - Tap asset → UserRequestAssetPage
   - Real-time updates

2. **`lib/user/user_asset_inuse.dart`**
   - Now uses real Firestore stream of borrowed assets
   - Shows assets borrowed by current user
   - Displays due dates with overdue indicator
   - Return button on each asset

3. **`lib/user/user_return_asset_details.dart`**
   - Integrated with Firestore confirmReturn()
   - Saves condition and comments to asset_history
   - Updates asset status back to AVAILABLE
   - Uses atomic transaction for consistency

4. **`lib/user/user_homepage.dart`**
   - Uses FirebaseAuth.currentUser?.uid instead of hard-coded user ID

## Key Database Operations

### 1. Stream Available Assets
```dart
Stream<List<Asset>> getAvailableAssets()
// Returns all assets with status = "AVAILABLE"
```

### 2. Request Asset
```dart
Future<void> requestAsset({
  required String assetId,
  required String assetName,
  required DateTime requiredDate,
  required String userId,
  required String userName,
})
// Creates request document and updates asset status to PENDING_REQUEST
```

### 3. Stream Borrowed Assets
```dart
Stream<List<Asset>> getBorrowedAssets(String userId)
// Returns assets borrowed by specific user (status = "BORROWED")
```

### 4. Confirm Return
```dart
Future<void> confirmReturn({
  required String assetId,
  required String condition,
  String? comments,
})
// Atomic transaction:
// - Changes status back to AVAILABLE
// - Removes borrower info
// - Logs return in asset_history collection
```

## User Journey

### Requesting an Asset
1. Home Page → "Asset" card
2. Sees list of AVAILABLE assets (real-time from Firestore)
3. Taps asset → Request page
4. Picks required date
5. Submits request
6. ✅ Request saved to Firestore

### Borrowing an Asset
*(Admin approves in Firestore)*
1. Request status → "APPROVED"
2. Asset status → "BORROWED"
3. borrowedByUserId + dueDateTime saved

### Returning an Asset
1. Home Page → "Assets In Use" card
2. Sees borrowed assets (real-time from Firestore)
3. Overdue items show red "OVERDUE" badge
4. Taps "Return" button
5. Selects condition (Good/Minor Damage/Major Damage)
6. (Optional) Adds damage comments
7. Confirms return
8. ✅ Return logged to Firestore

## Database Schema

### assets collection
```
{
  "id": "A67495",
  "name": "HDMI - cable",
  "category": "Cable",
  "location": "Warehouse",
  "status": "AVAILABLE|BORROWED|PENDING_REQUEST",
  "borrowedByUserId": "user-123" (nullable),
  "dueDateTime": Timestamp (nullable)
}
```

### requests collection
```
{
  "userId": "user-123",
  "userName": "John Doe",
  "assetId": "A67495",
  "assetName": "HDMI - cable",
  "requestedDate": Timestamp,
  "requiredDate": Timestamp,
  "status": "PENDING|APPROVED|REJECTED"
}
```

### asset_history collection (audit log)
```
{
  "assetId": "A67495",
  "action": "RETURNED",
  "condition": "Good|Minor Damage|Major Damage",
  "comments": "Some notes",
  "returnedByUserId": "user-123",
  "timestamp": Timestamp
}
```

## Getting Started

### Step 1: Enable Firestore API
1. Go to Firebase Console
2. Select your project (wetrack-fc09f)
3. Enable Cloud Firestore API (if not already enabled)
4. Wait 2-3 minutes for activation

### Step 2: Create Sample Data

Add sample assets to Firestore `assets` collection:

```
Document 1:
- id: "A67495"
- name: "HDMI - cable"
- category: "Cable"
- location: "Lab 1"
- status: "AVAILABLE"

Document 2:
- id: "L99821"
- name: "Laptop"
- category: "Electronics"
- location: "Lab 2"
- status: "AVAILABLE"

Document 3:
- id: "B02136"
- name: "USB Pendrive"
- category: "Electronics"
- location: "Warehouse"
- status: "AVAILABLE"
```

### Step 3: Test the App

```bash
cd "c:\Desktop\UIA DEGREE\FYP ASSETS TRACKING\wetrack-1"
flutter run
```

Then:
1. Sign up / Sign in
2. Navigate to "Asset" card
3. See available assets from Firestore
4. Tap an asset and request it
5. Check Firestore console to see new request created

## Real-Time Features

✅ **Assets List** - Updates in real-time as assets are borrowed/returned  
✅ **Borrowed Assets** - Shows current user's borrowed items with due dates  
✅ **Asset Status** - Automatically reflects AVAILABLE/BORROWED/PENDING_REQUEST  
✅ **Overdue Detection** - Red badge for items past due date  
✅ **Return History** - Logs all returns with condition info  

## Error Handling

The system gracefully handles:
- Network errors (shows snackbar message)
- Authentication errors (prompts to sign in)
- Missing assets (shows error message)
- Firestore permission errors (guides to enable API)

## Recommended Next Steps

1. **Enable Firestore Security Rules** (see ASSET_REQUEST_RETURN_GUIDE.md)
2. **Create Admin Dashboard** to approve/reject requests
3. **Add Notification System** for request status updates
4. **Implement QR Code Handoff** using mobile_scanner
5. **Add Damage Photo Upload** to Firebase Storage
6. **Set Up Return Reminders** (due date notifications)

## Testing Checklist

- [ ] App compiles without errors (`flutter pub get` success)
- [ ] User signs in successfully
- [ ] Asset list shows AVAILABLE assets from Firestore
- [ ] Can request an asset (creates request document)
- [ ] Can view borrowed assets (when status = BORROWED)
- [ ] Can return asset with condition selection
- [ ] Overdue date shows red badge
- [ ] Asset history is logged in asset_history collection
- [ ] Status changes reflect real-time

## Documentation

See **ASSET_REQUEST_RETURN_GUIDE.md** for:
- Detailed implementation guide
- Database structure explanation
- Security rules recommendations
- Troubleshooting tips
- Architecture diagram

## Key Improvements Over Previous Version

| Feature | Before | After |
|---------|--------|-------|
| Asset List | Hard-coded sample data | Real Firestore stream |
| Request System | No real requests | Full Firestore integration |
| Borrowed Assets | Static list | Dynamic stream of user's assets |
| Asset Status | Not tracked | AVAILABLE/BORROWED/PENDING_REQUEST |
| Return Process | UI only | Full database transaction |
| Audit Trail | None | asset_history collection |
| Real-time Updates | No | Yes, StreamBuilder |
| Overdue Tracking | Manual | Automatic date comparison |

---

**Status:** ✅ **Ready for Testing**

The implementation is complete and ready to test with real Firestore data. Enable the Firestore API and create sample assets to get started!
