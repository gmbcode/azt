import 'package:firebase_database/firebase_database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/retailer_model.dart';
import '../models/wholesaler_inventory_model.dart';
import '../models/order_model.dart';
import '../models/wholesaler_listing_model.dart';

class WholesalerRepo {
  final FirebaseDatabase _rtdb = FirebaseDatabase.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // --- INVENTORY (RTDB) ---

  Stream<List<WholesalerInventoryItem>> getInventoryStream(String uid) {
    return _rtdb.ref().child('wholesalers/$uid/inventory').onValue.map((event) {
      final List<WholesalerInventoryItem> items = [];
      if (event.snapshot.value != null && event.snapshot.value is Map) {
        final Map<dynamic, dynamic> map = event.snapshot.value as Map<dynamic, dynamic>;
        map.forEach((key, value) {
          items.add(WholesalerInventoryItem.fromMap(key, value));
        });
      }
      return items;
    });
  }

  Future<void> addInventoryItem(String uid, WholesalerInventoryItem item) async {
    final newRef = _rtdb.ref().child('wholesalers/$uid/inventory').push();
    await newRef.set(item.toMap());
  }

  // FIXED: Updates both Inventory AND Public Listing if it exists
  Future<void> updateInventoryItem(String uid, WholesalerInventoryItem item) async {
    // 1. Update Private Inventory
    await _rtdb.ref().child('wholesalers/$uid/inventory/${item.id}').update(item.toMap());

    // 2. Check if Listed & Sync Changes
    if (item.isListed && item.listingId != null) {
      await _rtdb.ref().child('listings_wholesaler/${item.listingId}').update({
        'name': item.name,
        'price': item.price,
        'imageUrl': item.imageUrl,
        'category': item.category,
        'moq': item.moq,
        // Note: We typically don't sync 'stock' directly to 'available_listed_qty' 
        // automatically unless you want stock changes to override listed qty. 
        // For safety, we usually leave qty management to the "List" action, 
        // but price/name/image updates should definitely sync.
      });
    }
  }

  Future<void> deleteInventoryItem(String uid, String itemId) async {
    final snapshot = await _rtdb.ref().child('wholesalers/$uid/inventory/$itemId').get();
    if (snapshot.exists && snapshot.value is Map) {
      final data = snapshot.value as Map;
      final String? listingId = data['listingId'];
      if (listingId != null && listingId.isNotEmpty) {
        await _rtdb.ref().child('listings_wholesaler/$listingId').remove();
      }
    }
    await _rtdb.ref().child('wholesalers/$uid/inventory/$itemId').remove();
  }

  // --- LISTINGS ---
  
  Future<void> listProduct(String uid, WholesalerInventoryItem item, int quantityToList) async {
    final listingRef = _rtdb.ref().child('listings_wholesaler').push();
    final listingData = {
      'wholesalerId': uid,
      'inventoryItemId': item.id,
      'available_listed_qty': quantityToList,
      'name': item.name,           
      'price': item.price,
      'imageUrl': item.imageUrl,
      'category': item.category,
      'moq': item.moq,
    };
    await listingRef.set(listingData);
    await _rtdb.ref().child('wholesalers/$uid/inventory/${item.id}').update({
      'isListed': true,
      'listingId': listingRef.key,
    });
  }

  Future<void> deleteListing(String listingId, String inventoryItemId, String uid) async {
    await _rtdb.ref().child('listings_wholesaler/$listingId').remove();
    await _rtdb.ref().child('wholesalers/$uid/inventory/$inventoryItemId').update({
      'isListed': false,
      'listingId': null,
    });
  }

  Stream<List<WholesalerListing>> getListingsStream(String uid) {
    return _rtdb.ref().child('listings_wholesaler').orderByChild('wholesalerId').equalTo(uid).onValue.map((event) {
      final List<WholesalerListing> items = [];
      if (event.snapshot.value != null && event.snapshot.value is Map) {
        final Map<dynamic, dynamic> map = event.snapshot.value as Map<dynamic, dynamic>;
        map.forEach((key, value) {
          items.add(WholesalerListing.fromMap(key, value));
        });
      }
      return items;
    });
  }

  // --- ORDERS & RETAILERS ---

  Stream<List<OrderModel>> getOrdersStream(String wholesalerId) {
    return _firestore.collection('orders_retailer').where('wholesaler_seller_uid', isEqualTo: wholesalerId).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return OrderModel.fromJson(doc.id, doc.data());
      }).toList();
    });
  }

  Future<void> updateOrderStatus(String orderId, String newStatus) async {
    await _firestore.collection('orders_retailer').doc(orderId).update({'status': newStatus.toLowerCase()});
  }

  Stream<List<WholesalerViewRetailerModel>> getRetailersStream() {
    return _firestore.collection('retailers').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        if (data['uid'] == null) data['uid'] = doc.id;
        return WholesalerViewRetailerModel.fromMap(data);
      }).toList();
    });
  }
}