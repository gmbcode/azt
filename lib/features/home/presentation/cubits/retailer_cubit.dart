import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/inventory_item.dart';
import '../../domain/repos/retailer_repo.dart';
import 'retailer_states.dart';

class RetailerCubit extends Cubit<RetailerState> {
  final RetailerRepo retailerRepo;
  final String uid;

  RetailerCubit({required this.retailerRepo, required this.uid}) 
      : super(RetailerInitial());

  // Fetch retailer's inventory
  Future<void> fetchInventory() async {
    try {
      emit(RetailerLoading());
      final items = await retailerRepo.getRetailerInventory(uid);
      emit(RetailerInventoryLoaded(items));
    } catch (e) {
      emit(RetailerError('Failed to load inventory: $e'));
    }
  }

  // Fetch all products for browsing
  Future<void> fetchProducts() async {
    try {
      emit(RetailerLoading());
      final products = await retailerRepo.getAllProducts();
      emit(RetailerProductsLoaded(products));
    } catch (e) {
      emit(RetailerError('Failed to load products: $e'));
    }
  }

  // Fetch customer orders
  Future<void> fetchCustomerOrders() async {
    try {
      emit(RetailerLoading());
      final orders = await retailerRepo.getCustomerOrders(uid);
      emit(RetailerCustomerOrdersLoaded(orders));
    } catch (e) {
      emit(RetailerError('Failed to load customer orders: $e'));
    }
  }

  // Fetch retailer's purchases
  Future<void> fetchPurchases() async {
    try {
      emit(RetailerLoading());
      final purchases = await retailerRepo.getRetailerPurchases(uid);
      emit(RetailerPurchasesLoaded(purchases));
    } catch (e) {
      emit(RetailerError('Failed to load purchases: $e'));
    }
  }

  // Fetch retailer's customers
  Future<void> fetchCustomers() async {
    try {
      emit(RetailerLoading());
      final customers = await retailerRepo.getRetailerCustomers(uid);
      emit(RetailerCustomersLoaded(customers));
    } catch (e) {
      emit(RetailerError('Failed to load customers: $e'));
    }
  }

  // Add inventory item
  Future<void> addInventoryItem(String itemId, InventoryItem item) async {
    try {
      await retailerRepo.addInventoryItem(uid, itemId, item);
      await fetchInventory(); // Refresh the list
    } catch (e) {
      emit(RetailerError('Failed to add inventory item: $e'));
    }
  }

  // Update inventory item
  Future<void> updateInventoryItem(String itemId, InventoryItem item) async {
    try {
      await retailerRepo.updateInventoryItem(uid, itemId, item);
      await fetchInventory(); // Refresh the list
    } catch (e) {
      emit(RetailerError('Failed to update inventory item: $e'));
    }
  }

  // Delete inventory item
  Future<void> deleteInventoryItem(String itemId) async {
    try {
      await retailerRepo.deleteInventoryItem(uid, itemId);
      await fetchInventory(); // Refresh the list
    } catch (e) {
      emit(RetailerError('Failed to delete inventory item: $e'));
    }
  }
}
