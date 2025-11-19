import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import '../domain/entities/customer.dart';
import '../domain/entities/inventory_item.dart';
import '../domain/entities/order.dart';
import '../domain/entities/product.dart';
import '../domain/entities/retailer.dart';
import '../domain/repos/retailer_repo.dart';

class FirebaseRetailerRepo implements RetailerRepo {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final DatabaseReference _database = FirebaseDatabase.instance.ref();

  @override
  Future<Retailer?> getRetailerData(String uid) async {
    try {
      final doc = await _firestore.collection('retailers').doc(uid).get();
      if (!doc.exists || doc.data() == null) return null;
      return Retailer.fromJson(doc.data()!);
    } catch (e) {
      throw Exception('Failed to get retailer data: $e');
    }
  }

  @override
  Future<List<InventoryItem>> getRetailerInventory(String uid) async {
    try {
      final snapshot = await _database.child('retailers/$uid/inventory').get();
      
      if (!snapshot.exists || snapshot.value == null) {
        return [];
      }

      final data = snapshot.value as Map<dynamic, dynamic>;
      final List<InventoryItem> items = [];

      data.forEach((key, value) {
        if (value is Map) {
          final Map<String, dynamic> itemData = Map<String, dynamic>.from(value);
          items.add(InventoryItem.fromJson(key.toString(), itemData));
        }
      });

      return items;
    } catch (e) {
      throw Exception('Failed to get retailer inventory: $e');
    }
  }

  @override
  Future<List<Product>> getAllProducts() async {
    try {
      final snapshot = await _database.child('products').get();
      
      if (!snapshot.exists || snapshot.value == null) {
        return [];
      }

      final data = snapshot.value as Map<dynamic, dynamic>;
      final List<Product> products = [];

      data.forEach((key, value) {
        if (value is Map) {
          final Map<String, dynamic> productData = Map<String, dynamic>.from(value);
          products.add(Product.fromJson(key.toString(), productData));
        }
      });

      return products;
    } catch (e) {
      throw Exception('Failed to get products: $e');
    }
  }

  @override
  Future<List<Order>> getCustomerOrders(String retailerId) async {
    try {
      final snapshot = await _database.child('orders').get();
      
      if (!snapshot.exists || snapshot.value == null) {
        return [];
      }

      final data = snapshot.value as Map<dynamic, dynamic>;
      final List<Order> orders = [];

      data.forEach((key, value) {
        if (value is Map) {
          final Map<String, dynamic> orderData = Map<String, dynamic>.from(value);
          // Filter orders where this retailer is the seller (orderfromid matches)
          if (orderData['orderfromid'] != null && 
              orderData['orderfromid'].toString().contains(retailerId)) {
            orders.add(Order.fromJson(key.toString(), orderData));
          }
        }
      });

      return orders;
    } catch (e) {
      throw Exception('Failed to get customer orders: $e');
    }
  }

  @override
  Future<List<Order>> getRetailerPurchases(String retailerId) async {
    try {
      final snapshot = await _database.child('orders').get();
      
      if (!snapshot.exists || snapshot.value == null) {
        return [];
      }

      final data = snapshot.value as Map<dynamic, dynamic>;
      final List<Order> orders = [];

      data.forEach((key, value) {
        if (value is Map) {
          final Map<String, dynamic> orderData = Map<String, dynamic>.from(value);
          // Filter orders where this retailer is the buyer (orderbyid matches)
          if (orderData['orderbyid'] != null && 
              orderData['orderbyid'].toString().contains(retailerId)) {
            orders.add(Order.fromJson(key.toString(), orderData));
          }
        }
      });

      return orders;
    } catch (e) {
      throw Exception('Failed to get retailer purchases: $e');
    }
  }

  @override
  Future<List<Customer>> getRetailerCustomers(String retailerId) async {
    try {
      final snapshot = await _database.child('customer').get();
      
      if (!snapshot.exists || snapshot.value == null) {
        return [];
      }

      final data = snapshot.value as Map<dynamic, dynamic>;
      final List<Customer> customers = [];

      // Get all customers who have ordered from this retailer
      // First, get customer IDs from orders
      final ordersSnapshot = await _database.child('orders').get();
      Set<String> customerIds = {};

      if (ordersSnapshot.exists && ordersSnapshot.value != null) {
        final ordersData = ordersSnapshot.value as Map<dynamic, dynamic>;
        ordersData.forEach((key, value) {
          if (value is Map) {
            final Map<String, dynamic> orderData = Map<String, dynamic>.from(value);
            if (orderData['orderfromid'] != null && 
                orderData['orderfromid'].toString().contains(retailerId)) {
              if (orderData['orderbyid'] != null) {
                // Extract customer ID from orderbyid (format: "customerid/retailerid")
                final orderById = orderData['orderbyid'].toString();
                if (orderById.contains('/')) {
                  customerIds.add(orderById.split('/')[0]);
                } else {
                  customerIds.add(orderById);
                }
              }
            }
          }
        });
      }

      // Now fetch customer details for those IDs
      data.forEach((key, value) {
        if (value is Map && customerIds.contains(key.toString())) {
          final Map<String, dynamic> customerData = Map<String, dynamic>.from(value);
          customers.add(Customer.fromJson(key.toString(), customerData));
        }
      });

      return customers;
    } catch (e) {
      throw Exception('Failed to get retailer customers: $e');
    }
  }

  @override
  Future<void> addInventoryItem(String uid, String itemId, InventoryItem item) async {
    try {
      await _database.child('retailers/$uid/inventory/$itemId').set(item.toJson());
    } catch (e) {
      throw Exception('Failed to add inventory item: $e');
    }
  }

  @override
  Future<void> updateInventoryItem(String uid, String itemId, InventoryItem item) async {
    try {
      await _database.child('retailers/$uid/inventory/$itemId').update(item.toJson());
    } catch (e) {
      throw Exception('Failed to update inventory item: $e');
    }
  }

  @override
  Future<void> deleteInventoryItem(String uid, String itemId) async {
    try {
      await _database.child('retailers/$uid/inventory/$itemId').remove();
    } catch (e) {
      throw Exception('Failed to delete inventory item: $e');
    }
  }
}
