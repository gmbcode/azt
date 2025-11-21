import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/wholesaler_inventory_model.dart';
import '../../data/models/order_model.dart';
import '../../data/models/retailer_model.dart';
import '../../data/models/wholesaler_listing_model.dart'; 
import '../../data/repos/wholesaler_repo.dart';

// --- STATES ---
abstract class WholesalerState {}
class WholesalerInitial extends WholesalerState {}
class WholesalerLoading extends WholesalerState {}
class WholesalerLoaded extends WholesalerState {
  final List<WholesalerInventoryItem> inventory;
  final List<OrderModel> orders;
  final List<WholesalerViewRetailerModel> retailers;
  final List<WholesalerListing> listings; 
  final double totalRevenue;
  final int pendingOrdersCount;

  WholesalerLoaded({
    this.inventory = const [], 
    this.orders = const [],
    this.retailers = const [],
    this.listings = const [], 
    this.totalRevenue = 0,
    this.pendingOrdersCount = 0,
  });
}
class WholesalerError extends WholesalerState {
  final String message;
  WholesalerError(this.message);
}

// --- CUBIT ---
class WholesalerCubit extends Cubit<WholesalerState> {
  final WholesalerRepo _repo;
  final String _uid;

  WholesalerCubit(this._repo, this._uid) : super(WholesalerInitial()) {
    _initializeStreams();
  }

  void _initializeStreams() {
    emit(WholesalerLoading());
    _repo.getInventoryStream(_uid).listen((inv) => _emitUpdatedState(inventory: inv));
    _repo.getOrdersStream(_uid).listen((ord) => _emitUpdatedState(orders: ord));
    _repo.getRetailersStream().listen((ret) => _emitUpdatedState(retailers: ret));
    _repo.getListingsStream(_uid).listen((lst) => _emitUpdatedState(listings: lst), 
      onError: (e) => emit(WholesalerError(e.toString())));
  }

  void _emitUpdatedState({
    List<WholesalerInventoryItem>? inventory, 
    List<OrderModel>? orders,
    List<WholesalerViewRetailerModel>? retailers,
    List<WholesalerListing>? listings,
  }) {
    final currentState = state;
    var nextInventory = inventory ?? [];
    var nextOrders = orders ?? [];
    var nextRetailers = retailers ?? [];
    var nextListings = listings ?? [];

    if (currentState is WholesalerLoaded) {
      nextInventory = inventory ?? currentState.inventory;
      nextOrders = orders ?? currentState.orders;
      nextRetailers = retailers ?? currentState.retailers;
      nextListings = listings ?? currentState.listings;
    }

    double revenue = 0;
    int pending = 0;
    for(var o in nextOrders) {
      if(o.orderStatus == 'Completed') revenue += o.total;
      if(o.orderStatus == 'Pending') pending++;
    }

    emit(WholesalerLoaded(
      inventory: nextInventory,
      orders: nextOrders,
      retailers: nextRetailers,
      listings: nextListings,
      totalRevenue: revenue,
      pendingOrdersCount: pending,
    ));
  }

  // --- ACTIONS ---
  Future<void> addProduct(Map<String, dynamic> data) async {
    try {
      final item = WholesalerInventoryItem(
        id: '', 
        name: data['name'],
        category: data['category'],
        price: double.tryParse(data['price'].toString()) ?? 0.0,
        stock: int.tryParse(data['stock'].toString()) ?? 0,
        moq: int.tryParse(data['moq'].toString()) ?? 1,
        description: data['description'] ?? '',
        imageUrl: data['imageUrl'] ?? '',
      );
      await _repo.addInventoryItem(_uid, item);
    } catch (e) {
      emit(WholesalerError("Add failed: $e"));
    }
  }

  // ADDED: Update Product
  Future<void> updateProduct(WholesalerInventoryItem item) async {
    try {
      await _repo.updateInventoryItem(_uid, item);
    } catch (e) {
      emit(WholesalerError("Update failed: $e"));
    }
  }

  Future<void> listProduct(WholesalerInventoryItem item, int qty) async {
    try { await _repo.listProduct(_uid, item, qty); } 
    catch (e) { emit(WholesalerError("List failed: $e")); }
  }

  Future<void> deleteProduct(String itemId) async {
    try { await _repo.deleteInventoryItem(_uid, itemId); } 
    catch (e) { emit(WholesalerError("Delete failed: $e")); }
  }
  
  Future<void> deleteListing(String listingId, String inventoryItemId) async {
    try { await _repo.deleteListing(listingId, inventoryItemId, _uid); } 
    catch (e) { emit(WholesalerError("Delist failed: $e")); }
  }

  Future<void> updateOrderStatus(String orderId, String status) async {
    try { await _repo.updateOrderStatus(orderId, status); } 
    catch (e) { emit(WholesalerError("Status update failed: $e")); }
  }
}