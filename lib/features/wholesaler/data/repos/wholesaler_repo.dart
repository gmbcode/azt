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

  Future<void> deleteInventoryItem(String uid, String itemId) async {
    await _rtdb.ref().child('wholesalers/$uid/inventory/$itemId').remove();
  }

  // --- LISTINGS (RTDB) ---
  
  Future<void> listProduct(String uid, WholesalerInventoryItem item, int quantityToList) async {
    // 1. Create entry in listings_wholesaler (publicly visible)
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

    // 2. Update private inventory to mark as listed
    await _rtdb.ref().child('wholesalers/$uid/inventory/${item.id}').update({
      'isListed': true,
      'listingId': listingRef.key,
    });
  }

  // --- ORDERS (Firestore) ---

  Stream<List<OrderModel>> getOrdersStream(String wholesalerId) {
    // NOTE: Ensure you have a composite index if you add more filters/sorts
    return _firestore
        .collection('orders_retailer')
        .where('wholesaler_seller_uid', isEqualTo: wholesalerId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return OrderModel.fromJson(doc.id, doc.data());
      }).toList();
    });
  }

  Future<void> updateOrderStatus(String orderId, String newStatus) async {
    await _firestore.collection('orders_retailer').doc(orderId).update({
      'status': newStatus.toLowerCase(),
    });
  }
  Stream<List<WholesalerViewRetailerModel>> getRetailersStream() {
    return _firestore.collection('retailers').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return WholesalerViewRetailerModel.fromMap(doc.data());
      }).toList();
    });
  }
  Stream<List<WholesalerListing>> getListingsStream(String uid) {
    // Query 'listings_wholesaler' where 'wholesalerId' matches current user
    return _rtdb.ref()
        .child('listings_wholesaler')
        .orderByChild('wholesalerId')
        .equalTo(uid)
        .onValue
        .map((event) {
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

  // Add logic to delete/delist a product
  Future<void> deleteListing(String listingId, String inventoryItemId, String uid) async {
    // 1. Remove from listings
    await _rtdb.ref().child('listings_wholesaler/$listingId').remove();
    
    // 2. Update inventory to show it is no longer listed
    await _rtdb.ref().child('wholesalers/$uid/inventory/$inventoryItemId').update({
      'isListed': false,
      'listingId': null,
    });
  }
}