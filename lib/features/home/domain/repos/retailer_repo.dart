import '../entities/customer.dart';
import '../entities/inventory_item.dart';
import '../entities/order.dart';
import '../entities/product.dart';
import '../entities/retailer.dart';

abstract class RetailerRepo {
  // Get retailer data from Firestore
  Future<Retailer?> getRetailerData(String uid);

  // Get retailer's inventory from RTDB
  Future<List<InventoryItem>> getRetailerInventory(String uid);

  // Get all products from RTDB (for browsing/purchasing)
  Future<List<Product>> getAllProducts();

  // Get orders where retailer is the seller (customer orders)
  Future<List<Order>> getCustomerOrders(String retailerId);

  // Get orders where retailer is the buyer (purchases from wholesalers)
  Future<List<Order>> getRetailerPurchases(String retailerId);

  // Get customers who have ordered from this retailer
  Future<List<Customer>> getRetailerCustomers(String retailerId);

  // Add inventory item
  Future<void> addInventoryItem(String uid, String itemId, InventoryItem item);

  // Update inventory item
  Future<void> updateInventoryItem(String uid, String itemId, InventoryItem item);

  // Delete inventory item
  Future<void> deleteInventoryItem(String uid, String itemId);
}
