class PaymentStatusModel {
  final String method;
  final String status;

  PaymentStatusModel({
    required this.method,
    required this.status,
  });

  factory PaymentStatusModel.fromJson(Map<String, dynamic> json) {
    return PaymentStatusModel(
      method: json['method'] ?? 'offline',
      status: json['status'] ?? 'pending',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'method': method,
      'status': status,
    };
  }
}