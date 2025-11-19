import 'package:firebase_database/firebase_database.dart';
import '../presentation/retailer_models/retailer_product_model.dart';
import '../presentation/retailer_models/retailer_inventory_item_model.dart';
import '../presentation/retailer_models/retailer_order_model.dart';

class RetailerRepository {
  final DatabaseReference _db = FirebaseDatabase.instance.ref();

  // 1. Fetch Global Products (for "Browse Products")
  Future<List<ProductModel>> getGlobalProducts() async {
    try {
      final snapshot = await _db.child('products').get();
      if (snapshot.exists && snapshot.value != null) {
        final data = snapshot.value as Map<dynamic, dynamic>;
        List<ProductModel> products = [];
        data.forEach((key, value) {
          products.add(ProductModel.fromJson(key.toString(), value));
        });
        return products;
      }
      return [];
    } catch (e) {
      print("Error fetching products: $e");
      return [];
    }
  }

  // 2. Fetch Retailer's Specific Inventory
  Future<List<RetailerInventoryItemModel>> getMyInventory(String uid) async {
    try {
      // Path: retailers/{uid}/inventory
      final snapshot = await _db.child('retailers').child(uid).child('inventory').get();
      
      if (snapshot.exists && snapshot.value != null) {
        final data = snapshot.value as Map<dynamic, dynamic>;
        List<RetailerInventoryItemModel> inventory = [];
        data.forEach((key, value) {
          inventory.add(RetailerInventoryItemModel.fromJson(key.toString(), value));
        });
        return inventory;
      }
      return [];
    } catch (e) {
      print("Error fetching inventory: $e");
      return [];
    }
  }

  // 3. Add Item to Inventory
  Future<void> addInventoryItem(String uid, RetailerInventoryItemModel item) async {
    try {
      // Push generates a unique key
      await _db.child('retailers').child(uid).child('inventory').push().set(item.toJson());
    } catch (e) {
      print("Error adding inventory: $e");
      rethrow;
    }
  }

  // 4. Delete Inventory Item
  Future<void> deleteInventoryItem(String uid, String itemId) async {
    await _db.child('retailers').child(uid).child('inventory').child(itemId).remove();
  }

  // 5. Fetch Incoming Orders (Orders FROM Customers)
  // Filter logic: orderfromid == retailerUID
  Future<List<OrderModel>> getIncomingOrders(String retailerUid) async {
    try {
      final snapshot = await _db.child('orders').get();
      if (snapshot.exists && snapshot.value != null) {
        final data = snapshot.value as Map<dynamic, dynamic>;
        List<OrderModel> orders = [];
        data.forEach((key, value) {
          final order = OrderModel.fromJson(key.toString(), value);
          // Filter client-side for simplicity
          if (order.orderfromid == retailerUid) {
            orders.add(order);
          }
        });
        return orders;
      }
      return [];
    } catch (e) {
      print("Error fetching incoming orders: $e");
      return [];
    }
  }

  // 6. Fetch Outgoing Orders (Purchases BY Retailer)
  // Filter logic: orderbyid == retailerUID
  Future<List<OrderModel>> getMyPurchases(String retailerUid) async {
    try {
      final snapshot = await _db.child('orders').get();
      if (snapshot.exists && snapshot.value != null) {
        final data = snapshot.value as Map<dynamic, dynamic>;
        List<OrderModel> purchases = [];
        data.forEach((key, value) {
          final order = OrderModel.fromJson(key.toString(), value);
          if (order.orderbyid == retailerUid) {
            purchases.add(order);
          }
        });
        return purchases;
      }
      return [];
    } catch (e) {
      print("Error fetching purchases: $e");
      return [];
    }
  }
}