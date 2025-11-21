import 'package:firebase_database/firebase_database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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

  // 2. Place Order
  Future<void> placeOrder({
    required String customerUid,
    required String retailerUid,
    required List<Map<String, dynamic>> items,
    required double total,
    required String address,
  }) async {
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
    // Also creating a mirror in 'orders_retailer' logic is usually handled by backend functions 
    // or double writes. For now, writing to 'orders_customer' is sufficient for the View.
    // Ideally, Retailer listens to this or we write to retailer's collection too.
    // Writing to 'orders_retailer' as well for the Retailer UI to pick it up:
    
    final retailerOrderRef = _firestore.collection('orders_retailer').doc(orderRef.id);
    await retailerOrderRef.set({
      ...orderData,
      'orderbyid': 'customers/$customerUid', // Reference
      'inventoryAdded': false,
    });
    
    await orderRef.set(orderData);
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