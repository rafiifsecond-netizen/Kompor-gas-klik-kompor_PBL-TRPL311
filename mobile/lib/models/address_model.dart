class AddressModel {
  final int id;
  final int userId;
  final String label;
  final String recipientName;
  final String recipientPhone;
  final String addressLine;
  final String? city;
  final String? postalCode;
  final String? notes;
  final double? latitude;
  final double? longitude;
  final bool isDefault;

  AddressModel({
    required this.id,
    required this.userId,
    required this.label,
    required this.recipientName,
    required this.recipientPhone,
    required this.addressLine,
    this.city,
    this.postalCode,
    this.notes,
    this.latitude,
    this.longitude,
    this.isDefault = false,
  });

  factory AddressModel.fromJson(Map<String, dynamic> json) {
    return AddressModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      userId: json['user_id'] is int ? json['user_id'] : int.tryParse(json['user_id']?.toString() ?? '') ?? 0,
      label: json['label'] as String? ?? 'Rumah',
      recipientName: json['recipient_name'] as String? ?? '',
      recipientPhone: json['recipient_phone'] as String? ?? '',
      addressLine: json['address_line'] as String? ?? '',
      city: json['city'] as String?,
      postalCode: json['postal_code'] as String?,
      notes: json['notes'] as String?,
      latitude: json['latitude'] != null ? double.tryParse(json['latitude'].toString()) : null,
      longitude: json['longitude'] != null ? double.tryParse(json['longitude'].toString()) : null,
      isDefault: json['is_default'] == true || json['is_default'] == 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'label': label,
      'recipient_name': recipientName,
      'recipient_phone': recipientPhone,
      'address_line': addressLine,
      'city': city,
      'postal_code': postalCode,
      'notes': notes,
      'latitude': latitude,
      'longitude': longitude,
      'is_default': isDefault,
    };
  }
}
