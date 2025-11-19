# Retailer Feature Setup Guide

## Prerequisites

1. Firebase project configured with:
   - Firebase Realtime Database
   - Cloud Firestore
   - Firebase Authentication

2. Flutter SDK installed

## Installation Steps

### 1. Install Dependencies

The required dependencies have already been added to `pubspec.yaml`:

```bash
flutter pub get
```

This will install:
- `firebase_database: ^11.1.4` - Firebase Realtime Database
- `firebase_core: ^4.2.0` - Firebase core functionality
- `cloud_firestore: ^6.1.0` - Cloud Firestore
- `firebase_auth: ^6.1.1` - Firebase Authentication
- `flutter_bloc: ^9.1.1` - State management

### 2. Configure Firebase

Ensure your Firebase project has both Realtime Database and Firestore enabled:

**Realtime Database:**
1. Go to Firebase Console → Realtime Database
2. Create a database if not already created
3. Start in test mode (or configure security rules)

**Firestore:**
1. Go to Firebase Console → Firestore Database
2. Create database if not already created
3. Start in test mode (or configure security rules)

### 3. Set Up Database Structure

#### Firestore Collections

Create these collections in Firestore:

1. **users** collection:
   - Document ID: User's UID
   - Fields:
     - `email` (string)
     - `username` (string)
     - `roleAllot` (string) - values: "customer", "retailer", "wholesaler"

2. **retailers** collection:
   - Document ID: User's UID
   - Fields:
     - `uid` (string)
     - `address` (string)
     - `businessName` (string)
     - `pincode` (string)

#### RTDB Structure

Set up these paths in Realtime Database:

```json
{
  "retailers": {
    "{uid}": {
      "inventory": {
        "{itemId}": {
          "category": "Fruits",
          "description": "Fresh apples",
          "imageUrl": "https://example.com/image.jpg",
          "name": "Apples",
          "price": 100,
          "stockremain": 50,
          "stocksold": 10
        }
      }
    }
  },
  "products": {
    "{productId}": {
      "category": "Fruits",
      "description": "Fresh oranges",
      "imageurl": "https://example.com/orange.jpg",
      "name": "Oranges",
      "price": 80,
      "productid": 1
    }
  },
  "orders": {
    "{orderId}": {
      "deliveryaddress": "123 Main St",
      "items": [],
      "orderbyid": "customer_id/retailer_id",
      "orderfromid": "retailer_id/wholesaler_id",
      "ordertime": "2025-11-19T12:00:00Z",
      "paymentstatus": {
        "method": "online",
        "status": "paid"
      },
      "status": "delivered",
      "total": 150,
      "trackinghistory": [
        {
          "status": "pending",
          "timestamp": "2025-11-19T09:00:00Z"
        }
      ]
    }
  },
  "customer": {
    "{customerId}": {
      "address": "456 Oak Ave",
      "customerid": 1,
      "emailid": "customer@example.com",
      "pincode": 110016
    }
  }
}
```

### 4. Configure Security Rules

#### Firestore Security Rules

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users can read and write their own user document
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Users can read and write their own retailer document
    match /retailers/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

#### RTDB Security Rules

```json
{
  "rules": {
    "retailers": {
      "$uid": {
        ".read": "auth != null && auth.uid == $uid",
        ".write": "auth != null && auth.uid == $uid"
      }
    },
    "products": {
      ".read": "auth != null",
      ".write": false
    },
    "orders": {
      ".read": "auth != null",
      ".indexOn": ["orderbyid", "orderfromid"]
    },
    "customer": {
      ".read": "auth != null"
    }
  }
}
```

## Testing the Implementation

### 1. Create Test Data

#### Add a Test Retailer in Firestore

1. Go to Firestore Console
2. Navigate to `retailers` collection
3. Add a document with your test user's UID:
```json
{
  "uid": "your-test-uid",
  "address": "123 Test Street",
  "businessName": "Test Store",
  "pincode": "110001"
}
```

#### Add Test Inventory in RTDB

1. Go to Realtime Database Console
2. Navigate to `retailers/{your-test-uid}/inventory`
3. Add test items:
```json
{
  "item1": {
    "category": "Fruits",
    "description": "Fresh red apples",
    "imageUrl": "https://placehold.co/400x400/red/fff?text=Apples",
    "name": "Red Apples",
    "price": 120,
    "stockremain": 45,
    "stocksold": 5
  },
  "item2": {
    "category": "Vegetables",
    "description": "Organic carrots",
    "imageUrl": "https://placehold.co/400x400/orange/fff?text=Carrots",
    "name": "Carrots",
    "price": 60,
    "stockremain": 30,
    "stocksold": 10
  }
}
```

#### Add Test Products in RTDB

```json
{
  "products": {
    "prod1": {
      "category": "Bakery",
      "description": "Fresh bread",
      "imageurl": "https://placehold.co/400x400/brown/fff?text=Bread",
      "name": "Sourdough Bread",
      "price": 50,
      "productid": 1
    },
    "prod2": {
      "category": "Dairy",
      "description": "Fresh milk",
      "imageurl": "https://placehold.co/400x400/white/000?text=Milk",
      "name": "Whole Milk",
      "price": 40,
      "productid": 2
    }
  }
}
```

### 2. Run the App

```bash
flutter run
```

### 3. Test Flow

1. **Login**: Login with your test retailer account
2. **View Dashboard**: Should see stats calculated from orders
3. **My Inventory**: Should display test inventory items from RTDB
4. **Browse Products**: Should display products from RTDB
5. **Add Inventory**: Add a new item and verify it appears in RTDB
6. **Delete Inventory**: Delete an item and verify it's removed from RTDB

### 4. Verify Data Persistence

After adding/updating/deleting items:
1. Go to Firebase Console → Realtime Database
2. Navigate to `retailers/{your-uid}/inventory`
3. Verify changes are reflected in the database

## Troubleshooting

### Common Issues

#### 1. "Failed to get retailer inventory"

**Cause:** User not authenticated or UID not found in database

**Solution:**
- Ensure user is logged in
- Check Firebase Authentication console
- Verify retailer document exists in Firestore
- Check RTDB security rules allow read access

#### 2. "No data displayed in UI"

**Cause:** Empty database or data structure mismatch

**Solution:**
- Add test data to RTDB as shown above
- Check browser/app console for errors
- Verify data structure matches the schema

#### 3. "Permission denied"

**Cause:** Security rules too restrictive

**Solution:**
- Temporarily set rules to test mode:
```json
{
  "rules": {
    ".read": "auth != null",
    ".write": "auth != null"
  }
}
```
- Test again
- Once working, configure proper security rules

#### 4. Data not updating in real-time

**Cause:** Not using real-time listeners

**Solution:**
- Current implementation uses one-time reads
- To add real-time updates, modify `FirebaseRetailerRepo` to use `onValue` instead of `get()`

#### 5. "Failed to add inventory item"

**Cause:** Missing required fields or wrong data types

**Solution:**
- Ensure all required fields are provided
- Check that numeric fields (price, stock) are numbers, not strings
- Verify user has write permission to their retailer path

## Development Tips

### 1. Enable Firebase Debugging

Add to your app's initialization:
```dart
await Firebase.initializeApp(
  options: DefaultFirebaseOptions.currentPlatform,
);

// Enable Firestore logging (debug only)
FirebaseFirestore.instance.settings = const Settings(
  persistenceEnabled: true,
);
```

### 2. Test with Firebase Emulator (Optional)

```bash
firebase init emulators
firebase emulators:start
```

Then connect your app to emulators instead of production.

### 3. Monitor Firebase Usage

- Go to Firebase Console → Usage and Billing
- Monitor Realtime Database and Firestore read/write counts
- Set up budget alerts to avoid unexpected charges

### 4. Optimize for Production

Before going to production:
1. Review and tighten security rules
2. Add indexes for frequently queried fields
3. Implement proper error handling
4. Add loading indicators
5. Consider adding caching to reduce Firebase reads
6. Test with larger datasets

## Next Steps

After basic setup:

1. **Add Real-time Updates**: Modify repository to use Firebase listeners for live data
2. **Implement Search**: Add search functionality using Algolia or custom indexes
3. **Add Analytics**: Track user actions with Firebase Analytics
4. **Performance**: Add pagination for large datasets
5. **Offline Support**: Enable Firestore offline persistence
6. **Testing**: Write unit and integration tests for the repository layer

## Support

For issues specific to this implementation:
1. Check the RETAILER_API_DOCUMENTATION.md file
2. Review Firebase Console logs
3. Check Flutter/Dart error messages in the console

For Firebase-specific issues:
- [Firebase Documentation](https://firebase.google.com/docs)
- [FlutterFire Documentation](https://firebase.flutter.dev/)
- [Firebase Support](https://firebase.google.com/support)
