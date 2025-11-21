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
  final List<CustomerCartItemModel> cart;
  final List<OrderModel> orders;
  
  CustomerLoaded({
    this.products = const [], 
    this.cart = const [], 
    this.orders = const [],
  });
}
class CustomerError extends CustomerState { final String message; CustomerError(this.message); }

class CustomerCubit extends Cubit<CustomerState> {
  final CustomerRepo _repo;
  final String _uid;

  CustomerCubit(this._repo, this._uid) : super(CustomerInitial()) {
    _init();
  }

  void _init() {
    emit(CustomerLoading());
    
    // Listen to Products
    _repo.getProductsStream().listen((products) {
      _emitState(products: products);
    });

    // Listen to Orders
    _repo.getMyOrdersStream(_uid).listen((orders) {
      _emitState(orders: orders);
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
    emit(CustomerLoaded(products: p, cart: c, orders: o));
  }

  // Cart Logic (Local Memory for now)
  void addToCart(CustomerProductModel product) {
    if (state is CustomerLoaded) {
      final currentCart = List<CustomerCartItemModel>.from((state as CustomerLoaded).cart);
      final index = currentCart.indexWhere((item) => item.productId == product.id);

      if (index >= 0) {
        currentCart[index] = currentCart[index].copyWith(qty: currentCart[index].qty + 1);
      } else {
        currentCart.add(CustomerCartItemModel(
          productId: product.id,
          retailerId: product.retailerId,
          name: product.name,
          price: product.price,
          imageUrl: product.imageUrl,
          qty: 1,
        ));
      }
      _emitState(cart: currentCart);
    }
  }

  void removeFromCart(String productId) {
    if (state is CustomerLoaded) {
      final currentCart = List<CustomerCartItemModel>.from((state as CustomerLoaded).cart);
      currentCart.removeWhere((item) => item.productId == productId);
      _emitState(cart: currentCart);
    }
  }
  
  void decrementCartItem(String productId) {
    if (state is CustomerLoaded) {
      final currentCart = List<CustomerCartItemModel>.from((state as CustomerLoaded).cart);
      final index = currentCart.indexWhere((item) => item.productId == productId);
      if (index >= 0) {
        if (currentCart[index].qty > 1) {
          currentCart[index] = currentCart[index].copyWith(qty: currentCart[index].qty - 1);
        } else {
          currentCart.removeAt(index);
        }
        _emitState(cart: currentCart);
      }
    }
  }

  void incrementCartItem(String productId) {
    if (state is CustomerLoaded) {
      final currentCart = List<CustomerCartItemModel>.from((state as CustomerLoaded).cart);
      final index = currentCart.indexWhere((item) => item.productId == productId);

      if (index >= 0) {
        // Create a copy with quantity + 1
        currentCart[index] = currentCart[index].copyWith(qty: currentCart[index].qty + 1);
        _emitState(cart: currentCart);
      }
    }
  }

  Future<void> checkout(String address) async {
    if (state is! CustomerLoaded) return;
    final cart = (state as CustomerLoaded).cart;
    if (cart.isEmpty) return;

    try {
      // Group by Retailer because orders must be separated per retailer
      Map<String, List<Map<String, dynamic>>> ordersByRetailer = {};
      Map<String, double> totalsByRetailer = {};

      for (var item in cart) {
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
      
      // Clear cart
      _emitState(cart: []);
    } catch (e) {
      emit(CustomerError("Checkout Failed: $e"));
      // Revert to loaded to allow retry
      _init(); 
    }
  }
}