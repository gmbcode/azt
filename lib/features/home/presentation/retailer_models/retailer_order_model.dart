import 'package:flutter/material.dart';

import 'retailer_payment_status_model.dart';

class OrderModel {
  final String id; // The "dummy" key
  final String deliveryaddress;
  final List<dynamic> items;
  final String orderbyid;
  final String orderfromid;
  final String ordertime;
  final PaymentStatusModel paymentstatus;
  final String status;
  final double total;
  final List<dynamic> trackinghistory;

  OrderModel({
    required this.id,
    required this.deliveryaddress,
    required this.items,
    required this.orderbyid,
    required this.orderfromid,
    required this.ordertime,
    required this.paymentstatus,
    required this.status,
    required this.total,
    required this.trackinghistory,
  });

  factory OrderModel.fromJson(String id, Map<String, dynamic> json) {
    return OrderModel(
      id: id,
      deliveryaddress: json['deliveryaddress'] ?? '',
      items: json['items'] ?? [],
      orderbyid: json['orderbyid'] ?? '',
      orderfromid: json['orderfromid'] ?? '',
      ordertime: json['ordertime'] ?? '',
      paymentstatus: PaymentStatusModel.fromJson(json['paymentstatus'] ?? {}),
      status: json['status'] ?? 'pending',
      total: (json['total'] as num?)?.toDouble() ?? 0.0,
      trackinghistory: json['trackinghistory'] ?? [],
    );
  }

  Color get statusColor {
    switch (status) {
      case 'delivered': return Colors.green;
      case 'confirmed': return Colors.blue;
      case 'processing': return Colors.blue; // Added processing
      case 'shipped': return Colors.purple; // Added shipped
      case 'pending': return Colors.orange;
      case 'cancelled': return Colors.red;
      default: return Colors.grey;
    }
  }

  String get formattedOrderTime {
    try {
      return DateTime.parse(ordertime).toLocal().toString().substring(0, 16);
    } catch (e) {
      return ordertime;
    }
  }
}