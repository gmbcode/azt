import 'package:firebase_database/firebase_database.dart';
import 'package:cloud_firestore/cloud_firestore.dart' hide Transaction; 
import '../../../wholesaler/data/models/wholesaler_listing_model.dart';
import '../../../wholesaler/data/models/order_model.dart';
import '../../../home/presentation/retailer_models/retailer_inventory_item_model.dart';
import '../../../home/presentation/retailer_models/retailer_customer_model.dart';

class RetailerRepo {
  final FirebaseDatabase _rtdb = FirebaseDatabase.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ... (Other methods like getWholesalerListingsStream, placeOrderToWholesaler, getMyPurchasesStream, addPurchasedItemsToInventory remain same) ...
  
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

    for (var item in items) {
      final String listingId = item['id']; 
      final int qtyOrdered = item['qty'];

      final ref = _rtdb.ref().child('listings_wholesaler/$listingId/available_listed_qty');
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

  // --- LISTINGS & STOCK SPLIT LOGIC ---
  
  Future<void> toggleProductListing(String uid, RetailerInventoryItemModel item, int qtyToList, {double? newPrice}) async {
    // Calculate how much stock is moving from "Unlisted" (stockremain) to "Listed" (listedQty)
    // If item.isLive, 'item.listedQty' is the old amount.
    // If !item.isLive, the old listed amount is effectively 0 (since it was all in stockremain).
    int oldListedQty = item.isLive ? item.listedQty : 0;
    int newListedQty = qtyToList;
    
    // Positive delta means moving FROM Stock TO Listed.
    // Negative delta means moving FROM Listed TO Stock.
    int delta = newListedQty - oldListedQty;
    
    // Check if we have enough stock (only if increasing listing)
    if (delta > 0 && item.stockremain < delta) {
      throw Exception("Not enough unlisted stock.");
    }

    int newStockRemain = item.stockremain - delta;
    final double listingPrice = newPrice ?? item.price;

    if (qtyToList > 0) {
      // LISTING / UPDATING
      // 1. Create/Update Public Listing
      String listingId = item.listingId ?? '';
      if (listingId.isEmpty) {
        final listingRef = _rtdb.ref().child('listings_retailer').push();
        listingId = listingRef.key!;
      }
      
      final listingData = {
        'retailerId': uid,
        'inventoryItemId': item.id,
        'available_listed_qty': newListedQty,
        'name': item.name,
        'price': listingPrice,
        'imageUrl': item.imageUrl,
        'category': item.category,
      };
      await _rtdb.ref().child('listings_retailer/$listingId').set(listingData);
      
      // 2. Update Private Inventory (Apply the Split Logic)
      await _rtdb.ref().child('retailers/$uid/inventory/${item.id}').update({
        'isLive': true,
        'listingId': listingId,
        'listedQty': newListedQty,
        'stockremain': newStockRemain, // Updated Stock
        'price': listingPrice, 
      });
    } else {
      // DELISTING (Removing from Public)
      if (item.listingId != null) {
        await _rtdb.ref().child('listings_retailer/${item.listingId}').remove();
      }
      
      // Return everything to Stock
      // newStockRemain here is: currentStock - (0 - oldListed) = currentStock + oldListed
      await _rtdb.ref().child('retailers/$uid/inventory/${item.id}').update({
        'isLive': false,
        'listingId': null,
        'listedQty': 0,
        'stockremain': newStockRemain, // All stock returned to reserve
      });
    }
  }
  
  Future<void> updateInventoryItem(String uid, RetailerInventoryItemModel item) async {
    if (item.stockremain <= 0 && item.listedQty <= 0) {
      await deleteInventoryItem(uid, item.id);
      return;
    }

    await _rtdb.ref().child('retailers/$uid/inventory/${item.id}').update(item.toMap());

    if (item.isLive && item.listingId != null) {
      await _rtdb.ref().child('listings_retailer/${item.listingId}').update({
        'name': item.name,
        'price': item.price,
        'imageUrl': item.imageUrl,
        'category': item.category,
      });
    }
  }

  Future<void> addInventoryItem(String uid, RetailerInventoryItemModel item) async {
    final newRef = _rtdb.ref().child('retailers/$uid/inventory').push();
    await newRef.set(item.toMap());
  }
  
  Future<void> deleteInventoryItem(String uid, String itemId) async {
     final snap = await _rtdb.ref().child('retailers/$uid/inventory/$itemId').get();
     if (snap.exists) {
       final data = snap.value as Map;
       final listingId = data['listingId'];
       if (listingId != null) {
         await _rtdb.ref().child('listings_retailer/$listingId').remove();
       }
     }
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

  // FIXED: Restock logic - Returns to LISTED stock, NOT unlisted stock
  Future<void> cancelCustomerOrderAndRestock(String orderId, List<dynamic> items, String retailerUid) async {
    await _firestore.collection('orders_customer').doc(orderId).update({'status': 'cancelled'});

    for (var item in items) {
      final String? inventoryItemId = item['inventoryItemId'];
      final String? listingId = item['id']; // Listing ID from order
      final int qty = int.tryParse(item['qty'].toString()) ?? 0;
      
      if (qty <= 0 || inventoryItemId == null) continue;

      final invRef = _rtdb.ref().child('retailers/$retailerUid/inventory/$inventoryItemId');
      final snapshot = await invRef.get();

      if (snapshot.exists) {
        final Map data = snapshot.value as Map;
        final bool isLive = data['isLive'] ?? false;
        final String? currentListingId = data['listingId'];

        if (isLive && currentListingId != null) {
             // If item is currently live, add stock back to LISTED QTY (available for sale again)
             final int currentListed = int.tryParse(data['listedQty'].toString()) ?? 0;
             await invRef.update({'listedQty': currentListed + qty});
             
             // Update Public Listing
             await _rtdb.ref().child('listings_retailer/$currentListingId').runTransaction((mutableData) {
               if (mutableData == null) return Transaction.success({'available_listed_qty': qty});
               final Map existing = mutableData as Map;
               final int pubQty = int.tryParse(existing['available_listed_qty'].toString()) ?? 0;
               existing['available_listed_qty'] = pubQty + qty;
               return Transaction.success(existing);
             });
        } else {
             // If item was delisted in the meantime, add it back to UNLISTED STOCK
             final int currentStock = int.tryParse(data['stockremain'].toString()) ?? 0;
             await invRef.update({'stockremain': currentStock + qty});
        }
      }
    }
  }

  Stream<List<Map<String, dynamic>>> getAppUsersStream() {
    return _firestore.collection('users').where('roleAllot', isEqualTo: 'customer').snapshots().map((snapshot) {
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