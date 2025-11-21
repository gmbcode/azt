import 'package:firebase_database/firebase_database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../wholesaler/data/models/wholesaler_listing_model.dart';
import '../../../wholesaler/data/models/order_model.dart';
import '../../../home/presentation/retailer_models/retailer_inventory_item_model.dart';
import '../../../home/presentation/retailer_models/retailer_customer_model.dart';

class RetailerRepo {
  final FirebaseDatabase _rtdb = FirebaseDatabase.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // --- BROWSE (Fetch Wholesaler Listings) ---
  Stream<List<WholesalerListing>> getWholesalerListingsStream() {
    return _rtdb.ref().child('listings_wholesaler').onValue.map((event) {
      final List<WholesalerListing> items = [];
      if (event.snapshot.value != null && event.snapshot.value is Map) {
        final Map<dynamic, dynamic> map = event.snapshot.value as Map<dynamic, dynamic>;
        map.forEach((key, value) {
          try {
            final item = WholesalerListing.fromMap(key, value);
            if (item.availableQty > 0) {
              items.add(item);
            }
          } catch (e) {
            print("Error parsing listing $key: $e");
          }
        });
      }
      return items;
    });
  }

  // --- ORDERS & CART ---
  Future<void> placeOrderToWholesaler({
    required String retailerUid,
    required String wholesalerUid,
    required List<Map<String, dynamic>> items,
    required double total,
    required String address,
  }) async {
    final orderRef = _firestore.collection('orders_retailer').doc();
    final orderData = {
      'retailer_uid': retailerUid,
      'wholesaler_seller_uid': wholesalerUid,
      'items': items,
      'total': total,
      'deliveryaddress': address,
      'status': 'pending',
      'ordertime': DateTime.now().toIso8601String(),
      'inventoryAdded': false,
    };
    await orderRef.set(orderData);
  }

  Stream<List<OrderModel>> getMyPurchasesStream(String retailerUid) {
    return _firestore
        .collection('orders_retailer')
        .where('retailer_uid', isEqualTo: retailerUid)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return OrderModel.fromJson(doc.id, doc.data());
      }).toList();
    });
  }

  // --- INVENTORY ---
  Future<void> addPurchasedItemsToInventory(String retailerUid, OrderModel order) async {
    if (order.orderStatus.toLowerCase() != 'completed' && order.orderStatus.toLowerCase() != 'delivered') {
      throw Exception("Order must be Delivered before adding to inventory.");
    }
    final docRef = _firestore.collection('orders_retailer').doc(order.id);
    final docSnap = await docRef.get();
    if (docSnap.data()?['inventoryAdded'] == true) return;

    final List<dynamic> items = docSnap.data()?['items'] ?? [];
    
    for (var item in items) {
      final String name = item['name'];
      final double costPrice = (item['price'] as num).toDouble();
      final int qty = (item['qty'] as num).toInt();
      final String imageUrl = item['imageUrl'] ?? '';
      final String category = item['category'] ?? 'General';

      final invRef = _rtdb.ref().child('retailers/$retailerUid/inventory');
      final snapshot = await invRef.orderByChild('name').equalTo(name).get();

      if (snapshot.exists) {
        final key = snapshot.children.first.key;
        final existingQty = (snapshot.children.first.value as Map)['stockremain'] as int;
        await invRef.child(key!).update({'stockremain': existingQty + qty});
      } else {
        final newRef = invRef.push();
        final newItem = RetailerInventoryItemModel(
          id: newRef.key!,
          name: name,
          category: category,
          price: costPrice * 1.2, 
          costPrice: costPrice,
          stockremain: qty,
          description: 'Imported from Wholesaler',
          imageUrl: imageUrl,
        );
        await newRef.set(newItem.toMap());
      }
    }
    await docRef.update({'inventoryAdded': true});
  }

  Stream<List<RetailerInventoryItemModel>> getInventoryStream(String uid) {
    return _rtdb.ref().child('retailers/$uid/inventory').onValue.map((event) {
      final List<RetailerInventoryItemModel> items = [];
      if (event.snapshot.value != null && event.snapshot.value is Map) {
        final Map<dynamic, dynamic> map = event.snapshot.value as Map<dynamic, dynamic>;
        map.forEach((key, value) {
          items.add(RetailerInventoryItemModel.fromMap(key, value));
        });
      }
      return items;
    });
  }

  // UPDATED: Added optional newPrice parameter
  Future<void> toggleProductListing(String uid, RetailerInventoryItemModel item, int qtyToList, {double? newPrice}) async {
    if (!item.isLive) {
      // GOING LIVE
      final double listingPrice = newPrice ?? item.price;

      final listingRef = _rtdb.ref().child('listings_retailer').push();
      final listingData = {
        'retailerId': uid,
        'inventoryItemId': item.id,
        'available_listed_qty': qtyToList,
        'name': item.name,
        'price': listingPrice, // Use new price
        'imageUrl': item.imageUrl,
        'category': item.category,
      };
      await listingRef.set(listingData);
      
      // Update Inventory to reflect status AND new price
      await _rtdb.ref().child('retailers/$uid/inventory/${item.id}').update({
        'isLive': true,
        'listingId': listingRef.key,
        'listedQty': qtyToList,
        'price': listingPrice, // Update inventory price to match listing
      });
    } else {
      // REMOVING LISTING
      if (item.listingId != null) {
        await _rtdb.ref().child('listings_retailer/${item.listingId}').remove();
      }
      await _rtdb.ref().child('retailers/$uid/inventory/${item.id}').update({
        'isLive': false,
        'listingId': null,
        'listedQty': 0,
      });
    }
  }
  
  Future<void> addInventoryItem(String uid, RetailerInventoryItemModel item) async {
    final newRef = _rtdb.ref().child('retailers/$uid/inventory').push();
    await newRef.set(item.toMap());
  }
  
  Future<void> deleteInventoryItem(String uid, String itemId) async {
     await _rtdb.ref().child('retailers/$uid/inventory/$itemId').remove();
  }

  // --- CUSTOMERS & ORDERS ---
  Stream<List<OrderModel>> getCustomerOrdersStream(String retailerUid) {
    return _firestore
        .collection('orders_customer')
        .where('retailer_seller_uid', isEqualTo: retailerUid)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return OrderModel.fromJson(doc.id, doc.data());
      }).toList();
    });
  }

  Future<void> updateCustomerOrderStatus(String orderId, String status) async {
    await _firestore.collection('orders_customer').doc(orderId).update({
      'status': status.toLowerCase(),
    });
  }

  Stream<List<Map<String, dynamic>>> getAppUsersStream() {
    return _firestore
        .collection('users')
        .where('roleAllot', isEqualTo: 'customer')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['uid'] = doc.id;
        return data;
      }).toList();
    });
  }

  Stream<Map<String, dynamic>> getCustomerProfilesStream() {
    return _firestore.collection('customers').snapshots().map((snapshot) {
      final Map<String, dynamic> profiles = {};
      for (var doc in snapshot.docs) {
        profiles[doc.id] = doc.data();
      }
      return profiles;
    });
  }
}