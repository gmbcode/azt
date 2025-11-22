import 'package:firebase_database/firebase_database.dart';
import 'package:cloud_firestore/cloud_firestore.dart' hide Transaction;
import '../models/retailer_model.dart';
import '../models/wholesaler_inventory_model.dart';
import '../models/order_model.dart';
import '../models/wholesaler_listing_model.dart';
import 'package:azt/services/mail_helper.dart';
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
        // Note: We don't auto-update name here to keep it fast. 
        // If name changes, toggle listing off/on.
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
       oldListedQty = item.listedQty; 
    }

    int newListedQty = qtyToList;
    int delta = newListedQty - oldListedQty; 

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

      // --- FEATURE: Fetch Business Name ---
      String businessName = 'Verified Seller';
      try {
        final docSnapshot = await _firestore.collection('wholesalers').doc(uid).get();
        if (docSnapshot.exists) {
          businessName = docSnapshot.data()?['businessName'] ?? 'Verified Seller';
        }
      } catch (e) {
        print("Error fetching business name: $e");
      }
      // ------------------------------------

      final listingData = {
        'wholesalerId': uid,
        'inventoryItemId': item.id,
        'available_listed_qty': newListedQty,
        'name': item.name,           
        'price': item.price,
        'imageUrl': item.imageUrl,
        'category': item.category,
        'moq': item.moq,
        'wholesalerName': businessName, // SAVED HERE
      };
      await _rtdb.ref().child('listings_wholesaler/$listingId').set(listingData);

      // Update Private Inventory with SPLIT data
      await _rtdb.ref().child('wholesalers/$uid/inventory/${item.id}').update({
        'isListed': true,
        'listingId': listingId,
        'stock': newUnlistedStock, 
        'listedQty': newListedQty, 
      });

    } else {
      // DELIST
      if (item.listingId != null) {
        await _rtdb.ref().child('listings_wholesaler/${item.listingId}').remove();
      }
      
      await _rtdb.ref().child('wholesalers/$uid/inventory/${item.id}').update({
        'isListed': false,
        'listingId': null,
        'listedQty': 0,
        'stock': newUnlistedStock, 
      });
    }
  }

  Future<void> deleteListing(String listingId, String inventoryItemId, String uid) async {
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
      m['listedQty'] = 0; 
      m['stock'] = (m['stock'] ?? 0) + qtyToReturn; 
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

  // ... inside WholesalerRepo class ...

// Import your MailService
// import 'package:your_app/core/services/mail_service.dart'; 

Future<void> updateOrderStatus(String orderId, String newStatus) async {
  //Update the status in Firestore
  await _firestore.collection('orders_retailer').doc(orderId).update({'status': newStatus.toLowerCase()});

  //Fetch Order details to get Retailer UID
  try {
    DocumentSnapshot orderSnap = await _firestore.collection('orders_retailer').doc(orderId).get();
    if (orderSnap.exists) {
      String retailerUid = orderSnap.get('retailer_uid');
      
      //Fetch Retailer Email 
      DocumentSnapshot userSnap = await _firestore.collection('users').doc(retailerUid).get();
      // Alternatively check 'retailers' collection if email is stored there:
      // DocumentSnapshot userSnap = await _firestore.collection('retailers').doc(retailerUid).get();

      if (userSnap.exists) {
        String email = userSnap.get('email');
        String name = userSnap.get('username') ?? 'Retailer'; // Adjust field name as needed

        // 4. Send Email
        await MailService.sendStatusUpdateEmail(email, name, orderId, newStatus);
      }
    }
  } catch (e) {
    print("Error sending email notification: $e");
  }
}

  Future<void> cancelOrderAndRestock(String orderId, List<dynamic> items) async {
    // --- ORIGINAL LOGIC START ---
    await _firestore.collection('orders_retailer').doc(orderId).update({'status': 'cancelled'});

    for (var item in items) {
      if (item is Map) {
        final String listingId = item['listingId'] ?? item['id'];
        final int quantity = int.tryParse(item['quantity'].toString()) ?? int.tryParse(item['qty'].toString()) ?? 0;
        if (quantity <= 0) continue;

        final listingSnap = await _rtdb.ref().child('listings_wholesaler/$listingId').get();

        if (listingSnap.exists) {
           await _rtdb.ref().child('listings_wholesaler/$listingId/available_listed_qty').runTransaction((data) {
             if (data == null) return Transaction.success(quantity);
             return Transaction.success((data as num).toInt() + quantity);
           });
           
           final String? invId = (listingSnap.value as Map)['inventoryItemId'];
           final String? uid = (listingSnap.value as Map)['wholesalerId'];
           if (invId != null && uid != null) {
              await _rtdb.ref().child('wholesalers/$uid/inventory/$invId/listedQty').runTransaction((data) {
                 if (data == null) return Transaction.success(quantity);
                 return Transaction.success((data as num).toInt() + quantity);
              });
           }
        } else {
           // RESTORED MISSING LINE
           print("Listing deleted, stock restoration requires manual intervention or ID lookup.");
        }
      }
    }
    // --- ORIGINAL LOGIC END ---

    // --- NEW EMAIL LOGIC START ---
    try {
      final orderDoc = await _firestore.collection('orders_retailer').doc(orderId).get();
      if (orderDoc.exists) {
        final retailerUid = orderDoc.get('retailer_uid');
        final userDoc = await _firestore.collection('users').doc(retailerUid).get();
        
        if (userDoc.exists) {
          final String email = userDoc.get('email');
          // Check for username safely
          final String name = (userDoc.data() as Map<String, dynamic>).containsKey('username') 
              ? userDoc.get('username') 
              : 'Retailer';

          await MailService.sendStatusUpdateEmail(email, name, orderId, 'Cancelled');
        }
      }
    } catch (e) {
      print("Failed to send cancellation email: $e");
    }
    // --- NEW EMAIL LOGIC END ---
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