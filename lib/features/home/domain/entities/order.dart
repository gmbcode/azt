class Order {
  final String id;
  final String deliveryAddress;
  final List<OrderItem> items;
  final String orderById;
  final String orderFromId;
  final String orderTime;
  final PaymentStatus paymentStatus;
  final String status;
  final double total;
  final List<TrackingHistory> trackingHistory;

  Order({
    required this.id,
    required this.deliveryAddress,
    required this.items,
    required this.orderById,
    required this.orderFromId,
    required this.orderTime,
    required this.paymentStatus,
    required this.status,
    required this.total,
    required this.trackingHistory,
  });

  factory Order.fromJson(String id, Map<String, dynamic> json) {
    List<OrderItem> itemsList = [];
    if (json['items'] != null && json['items'] is List) {
      itemsList = (json['items'] as List)
          .map((item) => OrderItem.fromJson(item))
          .toList();
    }

    List<TrackingHistory> trackingList = [];
    if (json['trackinghistory'] != null && json['trackinghistory'] is List) {
      trackingList = (json['trackinghistory'] as List)
          .map((item) => TrackingHistory.fromJson(item))
          .toList();
    }

    return Order(
      id: id,
      deliveryAddress: json['deliveryaddress'] ?? '',
      items: itemsList,
      orderById: json['orderbyid'] ?? '',
      orderFromId: json['orderfromid'] ?? '',
      orderTime: json['ordertime'] ?? '',
      paymentStatus: PaymentStatus.fromJson(json['paymentstatus'] ?? {}),
      status: json['status'] ?? '',
      total: (json['total'] as num?)?.toDouble() ?? 0.0,
      trackingHistory: trackingList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'deliveryaddress': deliveryAddress,
      'items': items.map((item) => item.toJson()).toList(),
      'orderbyid': orderById,
      'orderfromid': orderFromId,
      'ordertime': orderTime,
      'paymentstatus': paymentStatus.toJson(),
      'status': status,
      'total': total,
      'trackinghistory': trackingHistory.map((item) => item.toJson()).toList(),
    };
  }
}

class OrderItem {
  final String name;
  final double price;
  final int productId;

  OrderItem({
    required this.name,
    required this.price,
    required this.productId,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      name: json['name'] ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      productId: (json['productid'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'price': price,
      'productid': productId,
    };
  }
}

class PaymentStatus {
  final String method;
  final String status;

  PaymentStatus({
    required this.method,
    required this.status,
  });

  factory PaymentStatus.fromJson(Map<String, dynamic> json) {
    return PaymentStatus(
      method: json['method'] ?? '',
      status: json['status'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'method': method,
      'status': status,
    };
  }
}

class TrackingHistory {
  final String status;
  final String timestamp;

  TrackingHistory({
    required this.status,
    required this.timestamp,
  });

  factory TrackingHistory.fromJson(Map<String, dynamic> json) {
    return TrackingHistory(
      status: json['status'] ?? '',
      timestamp: json['timestamp'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'timestamp': timestamp,
    };
  }
}
