import 'package:firebase_database/firebase_database.dart';
import 'package:cloud_firestore/cloud_firestore.dart' hide Transaction; 
import '../../../wholesaler/data/models/order_model.dart';
import '../models/customer_product_model.dart';

class CustomerRepo {
  final FirebaseDatabase _rtdb = FirebaseDatabase.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // 1. Fetch Products (Live Listings from Retailers)
  Stream<List<CustomerProductModel>> getProductsStream() {
    return _rtdb.ref().child('listings_retailer').onValue.map((event) {
      final List<CustomerProductModel> items = [];
      if (event.snapshot.value != null && event.snapshot.value is Map) {
        final Map<dynamic, dynamic> map = event.snapshot.value as Map<dynamic, dynamic>;
        map.forEach((key, value) {
          final item = CustomerProductModel.fromMap(key, value);
          // Only show items with stock
          if (item.availableQty > 0) {
            items.add(item);
          }
        });
      }
      return items;
    });
  }

  // 2. Place Order (Decrements Retailer Stock)
  Future<void> placeOrder({
    required String customerUid,
    required String retailerUid,
    required List<Map<String, dynamic>> items,
    required double total,
    required String address,
  }) async {
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

    // Decrement Stock in RTDB (listings_retailer)
    for (var item in items) {
      final String listingId = item['productId']; 
      final int qtyOrdered = item['qty'];

      final ref = _rtdb.ref().child('listings_retailer/$listingId');
      
      await ref.runTransaction((currentData) {
        if (currentData == null) return Transaction.abort();
        
        final Map<dynamic, dynamic> data = currentData as Map<dynamic, dynamic>;
        final int currentQty = (data['available_listed_qty'] as num).toInt();
        
        if (currentQty >= qtyOrdered) {
          final int newQty = currentQty - qtyOrdered;
          // CRITICAL: Update qty. The removal happens by Client Logic usually, 
          // but here we can just set it to 0. 
          // RTDB Transaction doesn't support "delete node" easily inside the object update
          // without replacing the whole parent with null.
          // So we update qty. If 0, the 'getProductsStream' filters it out.
          // Ideally, a Cloud Function cleans up 0-qty listings. 
          data['available_listed_qty'] = newQty;
          return Transaction.success(data);
        } else {
          return Transaction.abort();
        }
      });
      
      // Cleanup: Check if 0 and remove (Best effort from client side)
      final snap = await ref.child('available_listed_qty').get();
      if (snap.exists && (snap.value as num) <= 0) {
         await ref.remove(); 
      }
    }
  }

  // 3. Fetch My Orders
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