import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../wholesaler/data/models/order_model.dart';
import '../../data/repos/customer_repo.dart';
import '../../data/models/customer_product_model.dart';
import '../../data/models/customer_cart_item_model.dart';

abstract class CustomerState {}
class CustomerInitial extends CustomerState {}
class CustomerLoading extends CustomerState {}
class CustomerLoaded extends CustomerState {
  final List<CustomerProductModel> products;
  final List<CustomerProductModel> productsForYou; // NEW: The filtered list
  final List<CustomerCartItemModel> cart;
  final List<OrderModel> orders;
  
  CustomerLoaded({
    this.products = const [], 
    this.productsForYou = const [],
    this.cart = const [], 
    this.orders = const [],
  });
}
class CustomerError extends CustomerState { final String message; CustomerError(this.message); }

class CustomerCubit extends Cubit<CustomerState> {
  final CustomerRepo _repo;
  final String _uid;

  // Local Cache for filtering
  List<String> _localRetailerIds = [];
  String? _userPincode;

  CustomerCubit(this._repo, this._uid) : super(CustomerInitial()) {
    _init();
  }

  void _init() async {
    emit(CustomerLoading());
    
    // 1. Initialize Location Data
    try {
      _userPincode = await _repo.getUserPincode(_uid);
      if (_userPincode != null) {
        _localRetailerIds = await _repo.getLocalRetailerIds(_userPincode!);
      }
    } catch (e) {
      print("Error initializing location logic: $e");
    }

    // 2. Listen to streams
    _repo.getProductsStream().listen((products) {
      _emitState(products: products);
    });

    _repo.getMyOrdersStream(_uid).listen((orders) {
      _emitState(orders: orders);
    });

    _repo.getCartStream(_uid).listen((cartItems) {
      _emitState(cart: cartItems);
    });
  }

  void _emitState({List<CustomerProductModel>? products, List<CustomerCartItemModel>? cart, List<OrderModel>? orders}) {
    final currentState = state;
    List<CustomerProductModel> p = products ?? [];
    List<CustomerCartItemModel> c = cart ?? [];
    List<OrderModel> o = orders ?? [];

    if (currentState is CustomerLoaded) {
      p = products ?? currentState.products;
      c = cart ?? currentState.cart;
      o = orders ?? currentState.orders;
    }

    // 3. Filter 'Products For You' logic
    // We filter the main product list against our local retailer IDs
    List<CustomerProductModel> pForYou = [];
    if (_localRetailerIds.isNotEmpty) {
      pForYou = p.where((prod) => _localRetailerIds.contains(prod.retailerId)).toList();
    }

    emit(CustomerLoaded(
      products: p, 
      productsForYou: pForYou, // Emit the filtered list
      cart: c, 
      orders: o
    ));
  }

  void addToCart(CustomerProductModel product) {
    if (state is CustomerLoaded) {
      final loaded = state as CustomerLoaded;
      final currentItem = loaded.cart.firstWhere(
        (item) => item.productId == product.id, 
        orElse: () => CustomerCartItemModel(
          productId: product.id, 
          retailerId: product.retailerId, 
          inventoryItemId: product.inventoryItemId, 
          name: product.name, 
          price: product.price, 
          imageUrl: product.imageUrl, 
          qty: 0
        )
      );
      if (currentItem.qty + 1 > product.availableQty) return;
      final newItem = currentItem.copyWith(qty: currentItem.qty + 1);
      _repo.updateCartItem(_uid, newItem);
    }
  }

  void removeFromCart(String productId) {
    if (state is CustomerLoaded) {
      final loaded = state as CustomerLoaded;
      final itemIndex = loaded.cart.indexWhere((e) => e.productId == productId);
      if (itemIndex >= 0) {
        final itemToRemove = loaded.cart[itemIndex];
        _repo.removeCartItem(_uid, itemToRemove.retailerId, productId);
      }
    }
  }
  
  void decrementCartItem(String productId) {
    if (state is CustomerLoaded) {
      final loaded = state as CustomerLoaded;
      final itemIndex = loaded.cart.indexWhere((e) => e.productId == productId);
      if (itemIndex >= 0) {
        final item = loaded.cart[itemIndex];
        if (item.qty > 1) {
           _repo.updateCartItem(_uid, item.copyWith(qty: item.qty - 1));
        } else {
           _repo.removeCartItem(_uid, item.retailerId, productId);
        }
      }
    }
  }

  void incrementCartItem(String productId) {
    if (state is CustomerLoaded) {
      final loaded = state as CustomerLoaded;
      final itemIndex = loaded.cart.indexWhere((e) => e.productId == productId);
      if (itemIndex >= 0) {
        final item = loaded.cart[itemIndex];
        final product = loaded.products.firstWhere(
          (p) => p.id == productId, 
          orElse: () => CustomerProductModel(
            id: '', retailerId: '', inventoryItemId: '', name: '', price: 0, availableQty: 9999, imageUrl: '', category: '', retailerName: '' 
          )
        );
        if (item.qty + 1 > product.availableQty) return;
        _repo.updateCartItem(_uid, item.copyWith(qty: item.qty + 1));
      }
    }
  }

  Future<void> checkout(String address) async {
    if (state is! CustomerLoaded) return;
    final cartBackup = List<CustomerCartItemModel>.from((state as CustomerLoaded).cart);
    if (cartBackup.isEmpty) return;
    try {
      await _repo.clearCart(_uid); 
      Map<String, List<Map<String, dynamic>>> ordersByRetailer = {};
      Map<String, double> totalsByRetailer = {};
      for (var item in cartBackup) {
        if (!ordersByRetailer.containsKey(item.retailerId)) {
          ordersByRetailer[item.retailerId] = [];
          totalsByRetailer[item.retailerId] = 0;
        }
        ordersByRetailer[item.retailerId]!.add(item.toMap());
        totalsByRetailer[item.retailerId] = totalsByRetailer[item.retailerId]! + (item.price * item.qty);
      }
      for (var retailerId in ordersByRetailer.keys) {
        await _repo.placeOrder(
          customerUid: _uid,
          retailerUid: retailerId,
          items: ordersByRetailer[retailerId]!,
          total: totalsByRetailer[retailerId]!,
          address: address,
        );
      }
    } catch (e) {
      emit(CustomerError("Checkout Failed: $e"));
      _init(); 
    }
  }
}