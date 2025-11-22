import 'package:flutter/material.dart';

class OrderModel {
  final String id;
  final String customerId;
  final String orderTime;
  final double total;
  final String deliveryAddress;
  final String orderStatus;
  final bool inventoryAdded;
  final List<dynamic> items; // Added field

  OrderModel({
    required this.id,
    required this.customerId,
    required this.orderTime,
    required this.total,
    required this.deliveryAddress,
    required this.orderStatus,
    this.inventoryAdded = false,
    this.items = const [], 
  });

  factory OrderModel.fromJson(String id, Map<String, dynamic> json) {
    // Robust ID parsing
    String customerId = json['orderbyid']?.split('/').first ?? 'N/A';
    if (json.containsKey('customer_uid')) customerId = json['customer_uid'];
    if (json.containsKey('retailer_uid')) customerId = json['retailer_uid'];
    
    // Robust Total parsing
    double totalValue = 0.0;
    if (json['total'] is num) {
      totalValue = (json['total'] as num).toDouble();
    } else if (json['total'] is String) {
      totalValue = double.tryParse(json['total']!) ?? 0.0;
    }
    
    // Status Normalization
    String status = json['status']?.toString().toLowerCase() ?? 'pending';
    String normalizedStatus = 'Pending';
    if (status.contains('delivered') || status.contains('completed')) normalizedStatus = 'Completed';
    else if (status.contains('confirmed') || status.contains('processing')) normalizedStatus = 'Processing';
    else if (status.contains('shipped')) normalizedStatus = 'Shipped';
    else if (status.contains('cancelled')) normalizedStatus = 'Cancelled';

    return OrderModel(
      id: id,
      customerId: customerId,
      orderTime: json['ordertime'] ?? DateTime.now().toIso8601String(),
      total: totalValue,
      deliveryAddress: json['deliveryaddress'] ?? 'Unknown Address',
      orderStatus: normalizedStatus,
      inventoryAdded: json['inventoryAdded'] ?? false,
      items: json['items'] ?? [], // Parsing the items list
    );
  }

  Color get statusColor {
    switch (orderStatus) {
      case 'Completed': return Colors.green;
      case 'Processing': return Colors.blue;
      case 'Shipped': return Colors.purple;
      case 'Cancelled': return Colors.red;
      default: return Colors.orange;
    }
  }
  
  String get formattedOrderTime {
    try {
      return DateTime.parse(orderTime).toLocal().toString().substring(0, 16);
    } catch (e) {
      return orderTime;
    }
  }
}