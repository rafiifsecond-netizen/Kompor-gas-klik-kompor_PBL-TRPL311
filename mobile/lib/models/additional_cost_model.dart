class AdditionalCostModel {
  final int id;
  final int orderId;
  final String title;
  final String? description;
  final double amount;
  final String status; // 'pending', 'approved', 'rejected'
  final String? rejectionReason;

  AdditionalCostModel({
    required this.id,
    required this.orderId,
    required this.title,
    this.description,
    required this.amount,
    required this.status,
    this.rejectionReason,
  });

  bool get isApproved => status == 'approved';
  bool get isRejected => status == 'rejected';
  bool get isPending => status == 'pending';

  factory AdditionalCostModel.fromJson(Map<String, dynamic> json) {
    return AdditionalCostModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      orderId: json['order_id'] is int
          ? json['order_id']
          : int.tryParse(json['order_id']?.toString() ?? '') ?? 0,
      title: json['title'] as String? ?? '',
      description: json['description'] as String?,
      amount: json['amount'] != null
          ? (double.tryParse(json['amount'].toString()) ?? 0.0)
          : 0.0,
      status: json['status'] as String? ?? 'pending',
      rejectionReason: json['rejection_reason'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'order_id': orderId,
      'title': title,
      'description': description,
      'amount': amount,
      'status': status,
      'rejection_reason': rejectionReason,
    };
  }
}
