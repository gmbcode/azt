import 'package:flutter/material.dart';

class OrderModel {
  final String id;
  final String customerId;
  final String orderTime;
  final double total;
  final String deliveryAddress;
  final String orderStatus;

  OrderModel({
    required this.id,
    required this.customerId,
    required this.orderTime,
    required this.total,
    required this.deliveryAddress,
    required this.orderStatus,
  });

  factory OrderModel.fromJson(String id, Map<String, dynamic> json) {
    String customerId = json['orderbyid']?.split('/').first ?? 'N/A';
    
    double totalValue = 0.0;
    if (json['total'] is num) {
      totalValue = (json['total'] as num).toDouble();
    } else if (json['total'] is String) {
      totalValue = double.tryParse(json['total']!) ?? 0.0;
    }
    
    // Normalize status
    String status = json['status']?.toString().toLowerCase() ?? 'pending';
    String normalizedStatus = 'Pending';
    if (status.contains('delivered') || status.contains('completed')) {
      normalizedStatus = 'Completed';
    } else if (status.contains('confirmed') || status.contains('processing')) {
      normalizedStatus = 'Processing';
    } else if (status.contains('shipped')) {
      normalizedStatus = 'Shipped';
    } else if (status.contains('cancelled')) {
      normalizedStatus = 'Cancelled';
    }

    return OrderModel(
      id: id,
      customerId: customerId,
      orderTime: json['ordertime'] ?? DateTime.now().toIso8601String(),
      total: totalValue,
      deliveryAddress: json['deliveryaddress'] ?? 'Unknown Address',
      orderStatus: normalizedStatus,
    );
  }

  // Helper for UI colors
  Color get statusColor {
    switch (orderStatus) {
      case 'Completed': return Colors.green;
      case 'Processing': return Colors.blue;
      case 'Shipped': return Colors.purple;
      case 'Cancelled': return Colors.red;
      default: return Colors.orange;
    }
  }
}