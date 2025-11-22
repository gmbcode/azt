import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../wholesaler/data/models/wholesaler_listing_model.dart';
import '../../../wholesaler/data/models/order_model.dart';
import '../../../home/presentation/retailer_models/retailer_inventory_item_model.dart';
import '../../../home/presentation/retailer_models/retailer_customer_model.dart';
import '../../data/repos/retailer_repo.dart';

abstract class RetailerState {}
class RetailerInitial extends RetailerState {}
class RetailerLoading extends RetailerState {}
class RetailerError extends RetailerState { final String message; RetailerError(this.message); }

class RetailerLoaded extends RetailerState {
  final List<WholesalerListing> wholesalerListings;
  final List<RetailerInventoryItemModel> inventory;
  final List<OrderModel> myPurchases;
  final List<OrderModel> customerOrders;
  final List<CustomerModel> customers;
  final List<Map<String, dynamic>> cartItems;

  RetailerLoaded({
    this.wholesalerListings = const [],
    this.inventory = const [],
    this.myPurchases = const [],
    this.customerOrders = const [],
    this.customers = const [],
    this.cartItems = const [],
  });
}

class RetailerCubit extends Cubit<RetailerState> {
  final RetailerRepo _repo;
  final String _uid; 

  List<Map<String, dynamic>> _cachedUsers = [];
  Map<String, dynamic> _cachedProfiles = {};

  RetailerCubit(this._repo, this._uid) : super(RetailerInitial()) {
    _initializeStreams();
  }

  void _initializeStreams() {
    emit(RetailerLoading());
    
    _repo.getWholesalerListingsStream().listen((l) => _emitState(wholesalerListings: l));
    _repo.getInventoryStream(_uid).listen((i) => _emitState(inventory: i));
    
    _repo.getMyPurchasesStream(_uid).listen((orders) {
      _emitState(myPurchases: orders);
      for (var order in orders) {
        final isCompleted = order.orderStatus.toLowerCase() == 'completed' || 
                            order.orderStatus.toLowerCase() == 'delivered';
        if (isCompleted && !order.inventoryAdded) {
          receiveOrderToInventory(order);
        }
      }
    });

    _repo.getCustomerOrdersStream(_uid).listen((c) => _emitState(customerOrders: c));
    
    _repo.getAppUsersStream().listen((users) {
      _cachedUsers = users;
      _mergeAndEmitCustomers();
    });

    _repo.getCustomerProfilesStream().listen((profiles) {
      _cachedProfiles = profiles;
      _mergeAndEmitCustomers();
    });
  }

  void _mergeAndEmitCustomers() {
    List<CustomerModel> mergedCustomers = [];
    for (var user in _cachedUsers) {
      final String uid = user['uid'];
      final String username = user['username'] ?? 'Unknown';
      final String email = user['email'] ?? 'No Email';
      String address = 'No Address';
      if (_cachedProfiles.containsKey(uid)) {
        address = _cachedProfiles[uid]['address'] ?? 'No Address';
      }
      mergedCustomers.add(CustomerModel(id: uid, username: username, email: email, address: address, usertype: 'consumer'));
    }
    _emitState(customers: mergedCustomers);
  }

  void _emitState({
    List<WholesalerListing>? wholesalerListings,
    List<RetailerInventoryItemModel>? inventory,
    List<OrderModel>? myPurchases,
    List<OrderModel>? customerOrders,
    List<CustomerModel>? customers,
    List<Map<String, dynamic>>? cartItems,
  }) {
    final currentState = state;
    var nextListings = wholesalerListings ?? [];
    var nextInventory = inventory ?? [];
    var nextPurchases = myPurchases ?? [];
    var nextCustomerOrders = customerOrders ?? [];
    var nextCustomers = customers ?? [];
    var nextCart = cartItems ?? [];

    if (currentState is RetailerLoaded) {
      nextListings = wholesalerListings ?? currentState.wholesalerListings;
      nextInventory = inventory ?? currentState.inventory;
      nextPurchases = myPurchases ?? currentState.myPurchases;
      nextCustomerOrders = customerOrders ?? currentState.customerOrders;
      nextCustomers = customers ?? currentState.customers;
      nextCart = cartItems ?? currentState.cartItems;
    }

    emit(RetailerLoaded(
      wholesalerListings: nextListings,
      inventory: nextInventory,
      myPurchases: nextPurchases,
      customerOrders: nextCustomerOrders,
      customers: nextCustomers,
      cartItems: nextCart,
    ));
  }

  // --- CART & CHECKOUT ---
  void addToCart(WholesalerListing product) {
    final currentState = state;
    if (currentState is RetailerLoaded) {
      final updatedCart = List<Map<String, dynamic>>.from(currentState.cartItems);
      final index = updatedCart.indexWhere((item) => item['id'] == product.id);
      if (index >= 0) {
        updatedCart[index]['qty'] = updatedCart[index]['qty'] + 1;
      } else {
        updatedCart.add({
          'id': product.id,
          'name': product.name,
          'price': product.price,
          'imageUrl': product.imageUrl,
          'category': product.category,
          'wholesaler_uid': product.wholesalerId, 
          'qty': 1,
        });
      }
      _emitState(cartItems: updatedCart);
    }
  }
  
  void removeFromCart(String productId) {
    if (state is RetailerLoaded) {
       final updatedCart = List<Map<String, dynamic>>.from((state as RetailerLoaded).cartItems);
       updatedCart.removeWhere((item) => item['id'] == productId);
       _emitState(cartItems: updatedCart);
    }
  }

  void clearCart() => _emitState(cartItems: []);

  Future<void> checkout(String address) async {
    if (state is! RetailerLoaded) return;
    final cart = (state as RetailerLoaded).cartItems;
    if (cart.isEmpty) return;

    try {
       Map<String, List<Map<String, dynamic>>> orders = {};
       Map<String, double> totals = {};

       for(var item in cart) {
         String wid = item['wholesaler_uid'] ?? 'unknown_wholesaler';
         if (wid.isEmpty) wid = 'unknown_wholesaler';

         if (!orders.containsKey(wid)) {
           orders[wid] = [];
           totals[wid] = 0;
         }
         orders[wid]!.add(item);
         totals[wid] = totals[wid]! + (item['price'] * item['qty']);
       }

       for(var wid in orders.keys) {
          await _repo.placeOrderToWholesaler(
            retailerUid: _uid,
            wholesalerUid: wid,
            items: orders[wid]!,
            total: totals[wid]!,
            address: address,
          );
       }
       clearCart();
    } catch (e) {
      emit(RetailerError("Checkout failed: $e"));
    }
  }

  // --- INVENTORY ACTIONS ---
  Future<void> receiveOrderToInventory(OrderModel order) async {
    try { await _repo.addPurchasedItemsToInventory(_uid, order); } 
    catch (e) { emit(RetailerError(e.toString())); }
  }
  
  // FIXED: Calls the new toggleProductListing which handles the math
  Future<void> toggleListing(RetailerInventoryItemModel item, int qty, {double? newPrice}) async {
     try { 
       await _repo.toggleProductListing(_uid, item, qty, newPrice: newPrice); 
     } catch (e) { 
       emit(RetailerError(e.toString())); 
     }
  }
  
  Future<void> addInventoryItem(RetailerInventoryItemModel item) async {
    try { await _repo.addInventoryItem(_uid, item); } 
    catch (e) { emit(RetailerError(e.toString())); }
  }
  
  Future<void> deleteInventoryItem(String id) async {
    try { await _repo.deleteInventoryItem(_uid, id); } 
    catch (e) { emit(RetailerError(e.toString())); }
  }

  // FIXED: Calls new repo method for cancelling + restocking
  Future<void> updateCustomerOrderStatus(String orderId, String status, {List<dynamic>? itemsToRestock}) async {
    try { 
      if (status.toLowerCase() == 'cancelled' && itemsToRestock != null) {
        await _repo.cancelCustomerOrderAndRestock(orderId, itemsToRestock, _uid);
      } else {
        await _repo.updateCustomerOrderStatus(orderId, status); 
      }
    } 
    catch (e) { emit(RetailerError(e.toString())); }
  }
  
  Future<void> updateInventoryItem(RetailerInventoryItemModel item) async {
    try { await _repo.updateInventoryItem(_uid, item); }
    catch (e) { emit(RetailerError(e.toString())); }
  }
}