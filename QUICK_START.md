# Quick Start Guide - Asset Request & Return

## What's New?

Your app now has a **complete asset request and return system** using Firestore database.

## How It Works

### 1. REQUEST AN ASSET
**Path:** Home → Assets Card → Browse assets → Tap asset → Fill request form → Submit

**What happens:**
- Request saved to Firestore `requests` collection
- Asset status changes to "PENDING_REQUEST"
- User gets confirmation

### 2. VIEW BORROWED ASSETS
**Path:** Home → Assets In Use Card → See your borrowed items

**Features:**
- Lists all assets you're borrowing (real-time from Firestore)
- Shows due date
- Red "OVERDUE" badge if past due date
- Return button on each asset

### 3. RETURN AN ASSET
**Path:** Assets In Use → Tap Return → Select condition → Confirm

**What happens:**
- Asset condition recorded (Good / Minor Damage / Major Damage)
- Return logged to Firestore `asset_history`
- Asset returns to "AVAILABLE" status
- Removed from your "Assets In Use" list

## Database Operations

| Action | Database Impact |
|--------|-----------------|
| Browse assets | Reads `assets` where status = "AVAILABLE" |
| Request asset | Creates `requests` doc + updates asset status |
| View borrowed | Reads `assets` where status = "BORROWED" & borrowedByUserId = user |
| Return asset | Updates asset status + creates `asset_history` entry |

## Setup Instructions

### Step 1: Enable Firestore API
```
Firebase Console → wetrack-fc09f → Enable Cloud Firestore API
```
*Wait 2-3 minutes for it to activate*

### Step 2: Create Sample Assets
Add to Firestore `assets` collection:

```
Document 1:
├─ id: "A67495"
├─ name: "HDMI - cable"
├─ category: "Cable"
├─ location: "Lab 1"
├─ status: "AVAILABLE"

Document 2:
├─ id: "L99821"
├─ name: "Laptop"
├─ category: "Electronics"
├─ location: "Lab 2"
├─ status: "AVAILABLE"

Document 3:
├─ id: "B02136"
├─ name: "USB Pendrive"
├─ category: "Electronics"
├─ location: "Warehouse"
└─ status: "AVAILABLE"
```

### Step 3: Run the App
```bash
cd "c:\Desktop\UIA DEGREE\FYP ASSETS TRACKING\wetrack-1"
flutter run
```

## Testing Steps

1. **Sign in** with your test account
2. **Go to Assets** → Should see sample assets from Firestore
3. **Request an asset** → Tap asset → Select date → Submit
4. **Check Firestore** → New request should appear in `requests` collection
5. **Manually approve** → In Firestore, change asset status to "BORROWED" and set `borrowedByUserId` to your user ID
6. **Go to Assets In Use** → Should now see the borrowed asset
7. **Return asset** → Tap Return → Select condition → Confirm
8. **Check Firestore** → Entry should appear in `asset_history` and asset status back to "AVAILABLE"

## File Structure

```
lib/user/
├─ user_list_asset.dart          (Browse & request assets)
├─ user_request_asset.dart       (Request form - NEW)
├─ user_asset_inuse.dart         (View borrowed assets)
├─ user_return_asset_details.dart (Return confirmation)
└─ user_homepage.dart            (Updated for real user ID)
```

## Key Methods Used

```dart
// Get available assets (real-time stream)
_firestoreService.getAvailableAssets()

// Get current user's borrowed assets (real-time stream)
_firestoreService.getBorrowedAssets(userId)

// Submit a request
_firestoreService.requestAsset(...)

// Confirm return
_firestoreService.confirmReturn(...)
```

## Real-Time Features ✨

- **Assets list updates** whenever assets are borrowed/returned
- **Borrowed assets updates** in real-time
- **Overdue status** automatically calculated
- **Status changes** visible instantly

## Troubleshooting

**❌ No assets showing in list?**
- Check Firestore has documents in `assets` collection
- Verify status = "AVAILABLE"
- Check Firestore API is enabled

**❌ "Assets In Use" is empty?**
- Assets must have status = "BORROWED"
- Asset's `borrowedByUserId` must match current user ID
- Check you're signed in

**❌ Return not working?**
- Check Firestore API is enabled
- Verify Firestore security rules allow writes
- Check browser console for detailed error

**❌ Firestore permission denied?**
- Enable Cloud Firestore API in Firebase Console
- Wait 2-3 minutes
- Restart the app

## Architecture Overview

```
┌─────────────────┐
│    Home Page    │
└────────┬────────┘
         │
    ┌────┴────────────────┐
    │                     │
    ↓                     ↓
┌─────────┐        ┌──────────────┐
│ Assets  │        │ Assets In    │
│ List    │        │ Use          │
└────┬────┘        └──────┬───────┘
     │                    │
     ↓                    ↓
┌──────────────┐    ┌──────────────┐
│ Request      │    │ Return       │
│ Asset Form   │    │ Confirmation │
└────┬─────────┘    └──────┬───────┘
     │                     │
     └──────┬──────────────┘
            ↓
      ┌─────────────┐
      │  Firestore  │
      ├─────────────┤
      │ assets      │
      │ requests    │
      │ asset_      │
      │ history     │
      └─────────────┘
```

## Next Steps

1. ✅ Enable Firestore API
2. ✅ Add sample assets
3. ✅ Test request flow
4. ✅ Test return flow
5. 📋 Set up security rules (optional but recommended)
6. 📋 Create admin dashboard for request approval
7. 📋 Add QR code handoff scanning
8. 📋 Add damage photo upload

## Documentation Files

- **IMPLEMENTATION_SUMMARY.md** - Complete overview of what's been done
- **ASSET_REQUEST_RETURN_GUIDE.md** - Detailed technical documentation
- **This file** - Quick reference guide

## Support

If you encounter issues:
1. Check the troubleshooting section above
2. Look at detailed guide in ASSET_REQUEST_RETURN_GUIDE.md
3. Check Firestore console for data
4. Review error messages in app

---

**Status:** ✅ Ready to test!

All code is compiled and ready. Just enable Firestore API and add sample data.
