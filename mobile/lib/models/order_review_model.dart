class OrderReviewModel {
  final int id;
  final int orderId;
  final int customerId;
  final int technicianId;
  final int rating;
  final String? comment;

  OrderReviewModel({
    required this.id,
    required this.orderId,
    required this.customerId,
    required this.technicianId,
    required this.rating,
    this.comment,
  });

  factory OrderReviewModel.fromJson(Map<String, dynamic> json) {
    return OrderReviewModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      orderId: json['order_id'] is int
          ? json['order_id']
          : int.tryParse(json['order_id']?.toString() ?? '') ?? 0,
      customerId: json['customer_id'] is int
          ? json['customer_id']
          : int.tryParse(json['customer_id']?.toString() ?? '') ?? 0,
      technicianId: json['technician_id'] is int
          ? json['technician_id']
          : int.tryParse(json['technician_id']?.toString() ?? '') ?? 0,
      rating: json['rating'] is int
          ? json['rating']
          : int.tryParse(json['rating']?.toString() ?? '5') ?? 5,
      comment: json['comment'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'order_id': orderId,
      'customer_id': customerId,
      'technician_id': technicianId,
      'rating': rating,
      'comment': comment,
    };
  }
}
