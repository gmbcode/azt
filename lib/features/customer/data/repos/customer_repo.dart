import 'package:firebase_database/firebase_database.dart';
// FIX: Hide Transaction from Firestore
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
    
    // Batch write for atomicity in Firestore
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
      // Check CustomerCartItemModel for correct key. Usually 'productId' maps to Listing ID.
      final String listingId = item['productId']; 
      final int qtyOrdered = item['qty'];

      final ref = _rtdb.ref().child('listings_retailer/$listingId/available_listed_qty');
      await ref.runTransaction((currentData) {
        if (currentData == null) return Transaction.abort();
        final int currentQty = (currentData as num).toInt();
        if (currentQty >= qtyOrdered) {
          return Transaction.success(currentQty - qtyOrdered);
        } else {
          return Transaction.abort();
        }
      });
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