import 'package:firebase_database/firebase_database.dart';
import 'package:cloud_firestore/cloud_firestore.dart' hide Transaction;
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

  Future<void> updateInventoryItem(String uid, WholesalerInventoryItem item) async {
    // If both stocks are empty, delete item
    if (item.stock <= 0 && item.listedQty <= 0) {
      await deleteInventoryItem(uid, item.id);
      return;
    }

    await _rtdb.ref().child('wholesalers/$uid/inventory/${item.id}').update(item.toMap());

    // Sync details with Public Listing
    if (item.isListed && item.listingId != null) {
      await _rtdb.ref().child('listings_wholesaler/${item.listingId}').update({
        'name': item.name,
        'price': item.price,
        'imageUrl': item.imageUrl,
        'category': item.category,
        'moq': item.moq,
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

  // --- LISTINGS & SPLIT INVENTORY LOGIC ---
  
  Future<void> toggleProductListing(String uid, WholesalerInventoryItem item, int qtyToList) async {
    // Fetch real-time 'listed' count from DB to ensure accuracy
    int oldListedQty = 0;
    if (item.isListed && item.listingId != null) {
       // Trusting passed item for simplicity, but normally we'd fetch
       oldListedQty = item.listedQty; 
    }

    int newListedQty = qtyToList;
    int delta = newListedQty - oldListedQty; // +ve means adding to list, -ve means removing

    if (delta > 0 && item.stock < delta) {
      throw Exception("Not enough unlisted stock in reserve.");
    }

    int newUnlistedStock = item.stock - delta;

    if (qtyToList > 0) {
      // LIST / UPDATE
      String listingId = item.listingId ?? '';
      if (listingId.isEmpty) {
        final newRef = _rtdb.ref().child('listings_wholesaler').push();
        listingId = newRef.key!;
      }

      final listingData = {
        'wholesalerId': uid,
        'inventoryItemId': item.id,
        'available_listed_qty': newListedQty,
        'name': item.name,           
        'price': item.price,
        'imageUrl': item.imageUrl,
        'category': item.category,
        'moq': item.moq,
      };
      await _rtdb.ref().child('listings_wholesaler/$listingId').set(listingData);

      // Update Private Inventory with SPLIT data
      await _rtdb.ref().child('wholesalers/$uid/inventory/${item.id}').update({
        'isListed': true,
        'listingId': listingId,
        'stock': newUnlistedStock, // Reserve
        'listedQty': newListedQty, // Listed
      });

    } else {
      // DELIST (Qty 0)
      if (item.listingId != null) {
        await _rtdb.ref().child('listings_wholesaler/${item.listingId}').remove();
      }
      
      // Return everything to Reserve
      await _rtdb.ref().child('wholesalers/$uid/inventory/${item.id}').update({
        'isListed': false,
        'listingId': null,
        'listedQty': 0,
        'stock': newUnlistedStock, // Reserve grows back
      });
    }
  }

  Future<void> deleteListing(String listingId, String inventoryItemId, String uid) async {
    // Helper to remove listing without full toggle logic (if needed)
    final snap = await _rtdb.ref().child('listings_wholesaler/$listingId/available_listed_qty').get();
    int qtyToReturn = 0;
    if (snap.exists) qtyToReturn = (snap.value as num).toInt();

    await _rtdb.ref().child('listings_wholesaler/$listingId').remove();
    
    final invRef = _rtdb.ref().child('wholesalers/$uid/inventory/$inventoryItemId');
    await invRef.runTransaction((data) {
      if (data == null) return Transaction.success(data);
      final Map m = data as Map;
      m['isListed'] = false;
      m['listingId'] = null;
      m['listedQty'] = 0; // Reset listed
      m['stock'] = (m['stock'] ?? 0) + qtyToReturn; // Return to stock
      return Transaction.success(m);
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

  // FIXED: Smart Cancellation Restocking for Wholesaler
  Future<void> cancelOrderAndRestock(String orderId, List<dynamic> items) async {
    await _firestore.collection('orders_retailer').doc(orderId).update({'status': 'cancelled'});

    for (var item in items) {
      if (item is Map) {
        final String listingId = item['listingId'] ?? item['id'];
        final int quantity = int.tryParse(item['quantity'].toString()) ?? int.tryParse(item['qty'].toString()) ?? 0;
        if (quantity <= 0) continue;

        final listingSnap = await _rtdb.ref().child('listings_wholesaler/$listingId').get();

        if (listingSnap.exists) {
           // Listing is LIVE -> Add to Public Listed Qty
           await _rtdb.ref().child('listings_wholesaler/$listingId/available_listed_qty').runTransaction((data) {
             if (data == null) return Transaction.success(quantity);
             return Transaction.success((data as num).toInt() + quantity);
           });
           
           // Also try to update Private Listed Qty if we can find the inventory item
           final String? invId = (listingSnap.value as Map)['inventoryItemId'];
           final String? uid = (listingSnap.value as Map)['wholesalerId'];
           if (invId != null && uid != null) {
              await _rtdb.ref().child('wholesalers/$uid/inventory/$invId/listedQty').runTransaction((data) {
                 if (data == null) return Transaction.success(quantity);
                 return Transaction.success((data as num).toInt() + quantity);
              });
           }
        } else {
           print("Listing deleted, stock restoration requires manual intervention or ID lookup.");
        }
      }
    }
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