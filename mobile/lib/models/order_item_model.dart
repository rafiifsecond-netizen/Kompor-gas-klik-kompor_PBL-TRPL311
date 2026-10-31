import 'service_model.dart';

class OrderItemModel {
  final int id;
  final int orderId;
  final int serviceId;
  final int quantity;
  final double unitPrice;
  final double subtotal;
  final String? serviceName;
  final ServiceModel? service;

  OrderItemModel({
    required this.id,
    required this.orderId,
    required this.serviceId,
    required this.quantity,
    required this.unitPrice,
    required this.subtotal,
    this.serviceName,
    this.service,
  });

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    return OrderItemModel(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id'].toString()) ?? 0,
      orderId: json['order_id'] is int
          ? json['order_id']
          : int.tryParse(json['order_id']?.toString() ?? '') ?? 0,
      serviceId: json['service_id'] is int
          ? json['service_id']
          : int.tryParse(
                  (json['service_id'] ?? json['service_item_id'])?.toString() ??
                      '') ??
              0,
      quantity: json['quantity'] is int
          ? json['quantity']
          : int.tryParse(json['quantity']?.toString() ?? '1') ?? 1,
      unitPrice: json['unit_price'] != null
          ? (double.tryParse(json['unit_price'].toString()) ?? 0.0)
          : 0.0,
      subtotal: (json['subtotal'] ?? json['total_price']) != null
          ? (double.tryParse(
                  (json['subtotal'] ?? json['total_price']).toString()) ??
              0.0)
          : 0.0,
      serviceName: json['service_name'] as String?,
      service: (json['service_item'] ?? json['service']) != null &&
              (json['service_item'] ?? json['service']) is Map
          ? ServiceModel.fromJson(Map<String, dynamic>.from(
              (json['service_item'] ?? json['service']) as Map))
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'order_id': orderId,
      'service_id': serviceId,
      'quantity': quantity,
      'unit_price': unitPrice,
      'subtotal': subtotal,
      'service_name': serviceName,
      'service': service?.toJson(),
    };
  }
}
