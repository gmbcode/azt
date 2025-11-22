import 'package:firebase_database/firebase_database.dart';
import 'package:cloud_firestore/cloud_firestore.dart' hide Transaction; 
import '../../../wholesaler/data/models/order_model.dart';
import '../models/customer_product_model.dart';
import '../models/customer_cart_item_model.dart';

class CustomerRepo {
  final FirebaseDatabase _rtdb = FirebaseDatabase.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // 1. Fetch Products (Safe Stream)
  Stream<List<CustomerProductModel>> getProductsStream() {
    return _rtdb.ref().child('listings_retailer').onValue.map((event) {
      final List<CustomerProductModel> items = [];
      if (event.snapshot.value != null && event.snapshot.value is Map) {
        final Map<dynamic, dynamic> map = event.snapshot.value as Map<dynamic, dynamic>;
        
        map.forEach((key, value) {
          if (value is Map) {
            try {
              final item = CustomerProductModel.fromMap(key, value);
              if (item.availableQty > 0) {
                items.add(item);
              }
            } catch (e) {
              print("Error parsing product $key: $e");
            }
          }
        });
      }
      return items;
    });
  }
  
  // 2. Get Cart Stream from RTDB (FIXED: Ensures retailerId is captured)
  Stream<List<CustomerCartItemModel>> getCartStream(String uid) {
    return _rtdb.ref().child('customers/$uid/cart').onValue.map((event) {
      final List<CustomerCartItemModel> cartItems = [];
      
      if (event.snapshot.value != null && event.snapshot.value is Map) {
        final Map<dynamic, dynamic> retailersMap = event.snapshot.value as Map;
        
        retailersMap.forEach((retailerKey, retailerValue) {
          if (retailerValue is Map && retailerValue.containsKey('items')) {
             final itemsMap = retailerValue['items'] as Map;
             
             itemsMap.forEach((itemKey, itemValue) {
               try {
                 // FIX: Ensure retailerId is present in the map before creating the model
                 // This prevents 'retailerId' from being empty if it wasn't saved in the item data
                 var itemMap = Map<String, dynamic>.from(itemValue as Map);
                 if (!itemMap.containsKey('retailerId') || itemMap['retailerId'] == null || itemMap['retailerId'] == '') {
                   itemMap['retailerId'] = retailerKey.toString();
                 }

                 final item = CustomerCartItemModel.fromMap(itemMap);
                 cartItems.add(item);
               } catch (e) {
                 print("Error parsing cart item: $e");
               }
             });
          }
        });
      }
      return cartItems;
    });
  }

  // 3. Update/Add Cart Item in RTDB
  Future<void> updateCartItem(String uid, CustomerCartItemModel item) async {
    final ref = _rtdb.ref()
        .child('customers/$uid/cart/${item.retailerId}/items/${item.productId}');
    
    if (item.qty > 0) {
      await ref.set(item.toMap());
    } else {
      await ref.remove();
    }
  }

  // 4. Remove Cart Item from RTDB
  Future<void> removeCartItem(String uid, String retailerId, String productId) async {
    await _rtdb.ref()
        .child('customers/$uid/cart/$retailerId/items/$productId')
        .remove();
  }

  // 5. Clear Entire Cart from RTDB
  Future<void> clearCart(String uid) async {
    await _rtdb.ref().child('customers/$uid/cart').remove();
  }

  // 6. Place Order (FIXED: Added guards against invalid paths)
  Future<void> placeOrder({
    required String customerUid,
    required String retailerUid,
    required List<Map<String, dynamic>> items,
    required double total,
    required String address,
  }) async {
    // Guard: Prevent crash if retailerUid is missing
    if (retailerUid.isEmpty) return;

    // Write to Firestore (Customer View)
    final orderRef = _firestore.collection('orders_customer').doc();
    final orderData = {
      'customer_uid': customerUid,
      'retailer_seller_uid': retailerUid,
      'items': items,
      'total': total,
      'deliveryaddress': address,
      'status': 'pending',
      'ordertime': DateTime.now().toIso8601String(),
    };
    
    // Mirror to Retailer View
    final retailerOrderRef = _firestore.collection('orders_retailer').doc(orderRef.id);
    
    final batch = _firestore.batch();
    batch.set(orderRef, orderData);
    batch.set(retailerOrderRef, {
      ...orderData,
      'orderbyid': 'customers/$customerUid', 
      'inventoryAdded': false,
    });
    await batch.commit();

    // RTDB Logic: Decrement BOTH Public Listing and Private Inventory Listed Qty
    for (var item in items) {
      final String listingId = item['id'] ?? ''; 
      final String? inventoryItemId = item['inventoryItemId']; 
      final int qtyOrdered = item['qty'] ?? 0;

      // Guard: Prevent crash on invalid listingId
      if (listingId.isEmpty) continue;

      // A. Decrement Public Listing
      final listingRef = _rtdb.ref().child('listings_retailer/$listingId/available_listed_qty');
      await listingRef.runTransaction((currentData) {
        if (currentData == null) return Transaction.abort();
        final int currentQty = (currentData as num).toInt();
        if (currentQty >= qtyOrdered) {
          return Transaction.success(currentQty - qtyOrdered);
        } else {
          return Transaction.abort();
        }
      });

      // B. Decrement Retailer's Private "Listed Qty"
      if (inventoryItemId != null && inventoryItemId.isNotEmpty) {
        // Ensure path is valid (retailerUid checked at start)
        final invRef = _rtdb.ref().child('retailers/$retailerUid/inventory/$inventoryItemId/listedQty');
        await invRef.runTransaction((currentData) {
          if (currentData == null) return Transaction.success(0); 
          final int currentQty = (currentData as num).toInt();
          return Transaction.success(currentQty - qtyOrdered);
        });
      }
    }
  }

  // 7. Fetch My Orders
  Stream<List<OrderModel>> getMyOrdersStream(String customerUid) {
    return _firestore
        .collection('orders_customer')
        .where('customer_uid', isEqualTo: customerUid)
        .orderBy('ordertime', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return OrderModel.fromJson(doc.id, doc.data());
      }).toList();
    });
  }
}