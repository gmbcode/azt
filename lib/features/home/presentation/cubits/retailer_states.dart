import '../../domain/entities/customer.dart';
import '../../domain/entities/inventory_item.dart';
import '../../domain/entities/order.dart';
import '../../domain/entities/product.dart';

abstract class RetailerState {}

class RetailerInitial extends RetailerState {}

class RetailerLoading extends RetailerState {}

class RetailerInventoryLoaded extends RetailerState {
  final List<InventoryItem> items;
  RetailerInventoryLoaded(this.items);
}

class RetailerProductsLoaded extends RetailerState {
  final List<Product> products;
  RetailerProductsLoaded(this.products);
}

class RetailerCustomerOrdersLoaded extends RetailerState {
  final List<Order> orders;
  RetailerCustomerOrdersLoaded(this.orders);
}

class RetailerPurchasesLoaded extends RetailerState {
  final List<Order> purchases;
  RetailerPurchasesLoaded(this.purchases);
}

class RetailerCustomersLoaded extends RetailerState {
  final List<Customer> customers;
  RetailerCustomersLoaded(this.customers);
}

class RetailerError extends RetailerState {
  final String message;
  RetailerError(this.message);
}
