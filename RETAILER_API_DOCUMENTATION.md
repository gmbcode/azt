# Retailer API Documentation

## Overview
This document describes the retailer API implementation that fetches data from Firebase Realtime Database (RTDB) and Firestore.

## Architecture

The implementation follows a clean architecture pattern with three layers:

### 1. Domain Layer (`lib/features/home/domain/`)
Contains business logic entities and repository interfaces.

**Entities:**
- `Retailer` - Retailer profile information
- `InventoryItem` - Items in retailer's inventory
- `Product` - Products available for purchase
- `Order` - Order information with payment and tracking
- `Customer` - Customer information

**Repository Interface:**
- `RetailerRepo` - Defines all data operations

### 2. Data Layer (`lib/features/home/data/`)
Contains Firebase implementation of repositories.

**Implementation:**
- `FirebaseRetailerRepo` - Implements `RetailerRepo` using Firebase RTDB and Firestore

### 3. Presentation Layer (`lib/features/home/presentation/`)
Contains UI components and state management.

**State Management:**
- `RetailerCubit` - Manages retailer data state
- `RetailerStates` - Different states (loading, loaded, error)

## Database Structure

### Firebase Realtime Database (RTDB)

```
rtdb/
├── retailers/
│   └── {uid}/
│       └── inventory/
│           └── {itemId}/
│               ├── category: string
│               ├── description: string
│               ├── imageUrl: string
│               ├── name: string
│               ├── price: number
│               ├── stockremain: number
│               └── stocksold: number
├── products/
│   └── {productId}/
│       ├── category: string
│       ├── description: string
│       ├── imageurl: string
│       ├── name: string
│       ├── price: number
│       └── productid: number
├── orders/
│   └── {orderId}/
│       ├── deliveryaddress: string
│       ├── items: array
│       ├── orderbyid: string (buyer ID)
│       ├── orderfromid: string (seller ID)
│       ├── ordertime: string (ISO timestamp)
│       ├── paymentstatus: object
│       ├── status: string
│       ├── total: number
│       └── trackinghistory: array
└── customer/
    └── {customerId}/
        ├── address: string
        ├── customerid: number
        ├── emailid: string
        └── pincode: number
```

### Cloud Firestore

```
firestore/
├── users/
│   └── {uid}/
│       ├── email: string
│       ├── username: string
│       └── roleAllot: string
└── retailers/
    └── {uid}/
        ├── uid: string
        ├── address: string
        ├── businessName: string
        └── pincode: string
```

## API Methods

### RetailerRepo Interface

#### 1. Get Retailer Data
```dart
Future<Retailer?> getRetailerData(String uid)
```
Fetches retailer profile information from Firestore.

**Parameters:**
- `uid` - The retailer's user ID

**Returns:**
- `Retailer` object or `null` if not found

**Source:** Firestore `retailers` collection

---

#### 2. Get Retailer Inventory
```dart
Future<List<InventoryItem>> getRetailerInventory(String uid)
```
Fetches all inventory items for a specific retailer.

**Parameters:**
- `uid` - The retailer's user ID

**Returns:**
- List of `InventoryItem` objects

**Source:** RTDB `retailers/{uid}/inventory`

---

#### 3. Get All Products
```dart
Future<List<Product>> getAllProducts()
```
Fetches all products available in the system.

**Parameters:** None

**Returns:**
- List of `Product` objects

**Source:** RTDB `products`

---

#### 4. Get Customer Orders
```dart
Future<List<Order>> getCustomerOrders(String retailerId)
```
Fetches orders where the retailer is the seller (orders from customers).

**Parameters:**
- `retailerId` - The retailer's ID

**Returns:**
- List of `Order` objects where `orderfromid` contains the retailerId

**Source:** RTDB `orders` (filtered)

---

#### 5. Get Retailer Purchases
```dart
Future<List<Order>> getRetailerPurchases(String retailerId)
```
Fetches orders where the retailer is the buyer (purchases from wholesalers).

**Parameters:**
- `retailerId` - The retailer's ID

**Returns:**
- List of `Order` objects where `orderbyid` contains the retailerId

**Source:** RTDB `orders` (filtered)

---

#### 6. Get Retailer Customers
```dart
Future<List<Customer>> getRetailerCustomers(String retailerId)
```
Fetches all customers who have ordered from this retailer.

**Parameters:**
- `retailerId` - The retailer's ID

**Returns:**
- List of `Customer` objects

**Source:** RTDB `customer` (cross-referenced with `orders`)

**Note:** This method:
1. Fetches all orders where the retailer is the seller
2. Extracts unique customer IDs from these orders
3. Fetches customer details for these IDs

---

#### 7. Add Inventory Item
```dart
Future<void> addInventoryItem(String uid, String itemId, InventoryItem item)
```
Adds a new item to the retailer's inventory.

**Parameters:**
- `uid` - The retailer's user ID
- `itemId` - Unique identifier for the item
- `item` - The `InventoryItem` object to add

**Returns:** `void` (throws exception on error)

**Target:** RTDB `retailers/{uid}/inventory/{itemId}`

---

#### 8. Update Inventory Item
```dart
Future<void> updateInventoryItem(String uid, String itemId, InventoryItem item)
```
Updates an existing inventory item.

**Parameters:**
- `uid` - The retailer's user ID
- `itemId` - The item's identifier
- `item` - The updated `InventoryItem` object

**Returns:** `void` (throws exception on error)

**Target:** RTDB `retailers/{uid}/inventory/{itemId}`

---

#### 9. Delete Inventory Item
```dart
Future<void> deleteInventoryItem(String uid, String itemId)
```
Deletes an item from the retailer's inventory.

**Parameters:**
- `uid` - The retailer's user ID
- `itemId` - The item's identifier

**Returns:** `void` (throws exception on error)

**Target:** RTDB `retailers/{uid}/inventory/{itemId}`

---

## Using the API in UI

### Setup

The `RetailerCubit` is provided at the `RetailerHomePage` level and automatically includes the authenticated user's UID.

```dart
// In retailer_home_page.dart
BlocProvider(
  create: (context) => RetailerCubit(
    retailerRepo: FirebaseRetailerRepo(),
    uid: uid, // From authenticated user
  ),
  child: Scaffold(...),
)
```

### Fetching Data

Use the cubit methods to fetch data:

```dart
// Fetch inventory
context.read<RetailerCubit>().fetchInventory();

// Fetch products
context.read<RetailerCubit>().fetchProducts();

// Fetch customer orders
context.read<RetailerCubit>().fetchCustomerOrders();

// Fetch purchases
context.read<RetailerCubit>().fetchPurchases();

// Fetch customers
context.read<RetailerCubit>().fetchCustomers();
```

### Listening to State Changes

Use `BlocListener` to respond to state changes:

```dart
BlocListener<RetailerCubit, RetailerState>(
  listener: (context, state) {
    if (state is RetailerInventoryLoaded) {
      // Handle loaded inventory
      final items = state.items;
      setState(() {
        _allItems = items.map((item) => /* convert to UI model */).toList();
      });
    } else if (state is RetailerError) {
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(state.message)),
      );
    }
  },
  child: /* Your widget tree */,
)
```

### Modifying Data

```dart
// Add inventory item
context.read<RetailerCubit>().addInventoryItem(itemId, item);

// Update inventory item
context.read<RetailerCubit>().updateInventoryItem(itemId, item);

// Delete inventory item
context.read<RetailerCubit>().deleteInventoryItem(itemId);
```

Note: All modification methods automatically refresh the data after the operation completes.

## State Types

The `RetailerState` has the following variants:

- `RetailerInitial` - Initial state before any data is loaded
- `RetailerLoading` - Data is being fetched from Firebase
- `RetailerInventoryLoaded` - Inventory data has been loaded
- `RetailerProductsLoaded` - Products data has been loaded
- `RetailerCustomerOrdersLoaded` - Customer orders have been loaded
- `RetailerPurchasesLoaded` - Purchases have been loaded
- `RetailerCustomersLoaded` - Customers have been loaded
- `RetailerError` - An error occurred (contains error message)

## Example Usage

### Dashboard Page
Fetches customer orders and calculates summary statistics:

```dart
@override
void initState() {
  super.initState();
  context.read<RetailerCubit>().fetchCustomerOrders();
}
```

### Inventory Page
Fetches, adds, updates, and deletes inventory items:

```dart
// Fetch
context.read<RetailerCubit>().fetchInventory();

// Add
final newItem = InventoryItem(...);
context.read<RetailerCubit>().addInventoryItem(itemId, newItem);

// Delete
context.read<RetailerCubit>().deleteInventoryItem(itemId);
```

### Browse Products Page
Fetches all available products:

```dart
context.read<RetailerCubit>().fetchProducts();
```

## Error Handling

All methods throw exceptions with descriptive messages on failure. The `RetailerCubit` catches these exceptions and emits a `RetailerError` state with the error message.

Example error messages:
- `"Failed to get retailer inventory: [error details]"`
- `"Failed to add inventory item: [error details]"`
- `"Failed to get customer orders: [error details]"`

## Important Notes

1. **Authentication Required**: All operations require a valid authenticated user UID
2. **Network Required**: All operations require an active internet connection
3. **Permissions**: Ensure Firebase security rules allow the authenticated user to read/write their data
4. **Data Format**: All dates are stored as ISO 8601 strings (e.g., "2025-11-19T13:54:21.734Z")
5. **Stock Availability**: The `products` collection doesn't include stock information - that's only in inventory collections
6. **Order Filtering**: Orders are filtered based on `orderbyid` (buyer) and `orderfromid` (seller) fields

## Security Considerations

Configure Firebase Realtime Database rules to ensure:
1. Users can only access their own retailer data
2. Users can read products but not modify them
3. Order access is restricted to involved parties
4. Customer data is properly protected

Example security rules:
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
      "$orderId": {
        ".write": "auth != null && (data.child('orderbyid').val().contains(auth.uid) || data.child('orderfromid').val().contains(auth.uid))"
      }
    }
  }
}
```

## Future Enhancements

Potential improvements to consider:
1. Add caching to reduce Firebase reads
2. Implement pagination for large datasets
3. Add real-time listeners for live updates
4. Add batch operations for bulk updates
5. Implement search and filtering at the database level
6. Add analytics and reporting features
7. Implement inventory stock alerts
8. Add order status update functionality
