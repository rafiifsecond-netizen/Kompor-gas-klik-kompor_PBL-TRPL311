import 'additional_cost_model.dart';
import 'address_model.dart';
import 'order_item_model.dart';
import 'order_review_model.dart';
import 'user_model.dart';

class OrderModel {
  final int id;
  final String orderNumber;
  final int customerId;
  final int? technicianId;
  final int? addressId;
  final String status;
  final String bookingDate;
  final String bookingTime;
  final double subtotal;
  final double totalAmount;
  final String paymentStatus;
  final String? paymentMethod;
  final String? cancellationReason;
  final UserModel? customer;
  final UserModel? technician;
  final AddressModel? address;
  final List<OrderItemModel> items;
  final List<AdditionalCostModel> additionalCosts;
  final OrderReviewModel? review;

  OrderModel({
    required this.id,
    required this.orderNumber,
    required this.customerId,
    this.technicianId,
    this.addressId,
    required this.status,
    required this.bookingDate,
    required this.bookingTime,
    required this.subtotal,
    required this.totalAmount,
    required this.paymentStatus,
    this.paymentMethod,
    this.cancellationReason,
    this.customer,
    this.technician,
    this.address,
    this.items = const [],
    this.additionalCosts = const [],
    this.review,
  });

  bool get isPending => status == 'pending';
  bool get isAccepted => status == 'accepted';
  bool get isOnTheWay => status == 'on_the_way';
  bool get isInProgress => status == 'in_progress';
  bool get isCompleted => status == 'completed';
  bool get isCancelled => status == 'cancelled';
  bool get isPaid => paymentStatus == 'paid';

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      orderNumber: json['order_number'] as String? ?? '',
      customerId: json['customer_id'] is int
          ? json['customer_id']
          : int.tryParse(json['customer_id']?.toString() ?? '') ?? 0,
      technicianId: json['technician_id'] != null
          ? int.tryParse(json['technician_id'].toString())
          : null,
      addressId: json['address_id'] != null
          ? int.tryParse(json['address_id'].toString())
          : null,
      status: json['status'] as String? ?? 'pending',
      bookingDate: json['booking_date'] as String? ?? '',
      bookingTime: json['booking_time'] as String? ?? '',
      subtotal: json['subtotal'] != null
          ? (double.tryParse(json['subtotal'].toString()) ?? 0.0)
          : 0.0,
      totalAmount: json['total_amount'] != null
          ? (double.tryParse(json['total_amount'].toString()) ?? 0.0)
          : 0.0,
      paymentStatus: json['payment_status'] as String? ?? 'unpaid',
      paymentMethod: json['payment_method'] as String?,
      cancellationReason: json['cancellation_reason'] as String?,
      customer: json['customer'] != null && json['customer'] is Map
          ? UserModel.fromJson(Map<String, dynamic>.from(json['customer'] as Map))
          : null,
      technician: json['technician'] != null && json['technician'] is Map
          ? UserModel.fromJson(Map<String, dynamic>.from(json['technician'] as Map))
          : null,
      address: json['address'] != null && json['address'] is Map
          ? AddressModel.fromJson(Map<String, dynamic>.from(json['address'] as Map))
          : null,
      items: (json['items'] is List)
          ? (json['items'] as List)
              .map((i) => OrderItemModel.fromJson(Map<String, dynamic>.from(i as Map)))
              .toList()
          : [],
      additionalCosts: (json['additional_costs'] is List)
          ? (json['additional_costs'] as List)
              .map((c) =>
                  AdditionalCostModel.fromJson(Map<String, dynamic>.from(c as Map)))
              .toList()
          : [],
      review: json['review'] != null && json['review'] is Map
          ? OrderReviewModel.fromJson(Map<String, dynamic>.from(json['review'] as Map))
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'order_number': orderNumber,
      'customer_id': customerId,
      'technician_id': technicianId,
      'address_id': addressId,
      'status': status,
      'booking_date': bookingDate,
      'booking_time': bookingTime,
      'subtotal': subtotal,
      'total_amount': totalAmount,
      'payment_status': paymentStatus,
      'payment_method': paymentMethod,
      'cancellation_reason': cancellationReason,
      'customer': customer?.toJson(),
      'technician': technician?.toJson(),
      'address': address?.toJson(),
      'items': items.map((i) => i.toJson()).toList(),
      'additional_costs': additionalCosts.map((c) => c.toJson()).toList(),
      'review': review?.toJson(),
    };
  }
}
