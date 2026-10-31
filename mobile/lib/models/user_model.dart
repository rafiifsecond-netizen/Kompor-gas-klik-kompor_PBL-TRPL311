class UserModel {
  final int id;
  final String name;
  final String email;
  final String? phone;
  final String role;
  final String? avatarUrl;
  final String? address;
  final bool isActive;
  final TechnicianProfileModel? technicianProfile;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    required this.role,
    this.avatarUrl,
    this.address,
    this.isActive = true,
    this.technicianProfile,
  });

  bool get isCustomer => role == 'customer';
  bool get isTechnician => role == 'technician';
  bool get isAdmin => role == 'admin';

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id'].toString()) ?? 0,
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      phone: json['phone'] as String?,
      role: json['role'] as String? ?? 'customer',
      avatarUrl: json['avatar_url'] as String?,
      address: json['address'] as String?,
      isActive: json['is_active'] == true || json['is_active'] == 1,
      technicianProfile: json['technician_profile'] != null &&
              json['technician_profile'] is Map
          ? TechnicianProfileModel.fromJson(
              Map<String, dynamic>.from(json['technician_profile'] as Map))
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'role': role,
      'avatar_url': avatarUrl,
      'address': address,
      'is_active': isActive,
      'technician_profile': technicianProfile?.toJson(),
    };
  }

  UserModel copyWith({
    int? id,
    String? name,
    String? email,
    String? phone,
    String? role,
    String? avatarUrl,
    String? address,
    bool? isActive,
    TechnicianProfileModel? technicianProfile,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      address: address ?? this.address,
      isActive: isActive ?? this.isActive,
      technicianProfile: technicianProfile ?? this.technicianProfile,
    );
  }
}

class TechnicianProfileModel {
  final int id;
  final String? bio;
  final int? experienceYears;
  final String? specialization;
  final List<String> skills;
  final bool isVerified;
  final bool isAvailable;
  final double ratingAverage;
  final int totalReviews;
  final int totalCompletedOrders;
  final double? currentLatitude;
  final double? currentLongitude;
  final String? lastLocationUpdatedAt;

  TechnicianProfileModel({
    required this.id,
    this.bio,
    this.experienceYears,
    this.specialization,
    this.skills = const [],
    this.isVerified = false,
    this.isAvailable = true,
    this.ratingAverage = 0.0,
    this.totalReviews = 0,
    this.totalCompletedOrders = 0,
    this.currentLatitude,
    this.currentLongitude,
    this.lastLocationUpdatedAt,
  });

  /// Reads both the Laravel column names (years_of_experience, rating_avg,
  /// reviews_count, jobs_completed_count) and the legacy camel/snake variants
  /// so the UI never silently falls back to empty values.
  factory TechnicianProfileModel.fromJson(Map<String, dynamic> json) {
    return TechnicianProfileModel(
      id: _toInt(json['id']),
      bio: json['bio'] as String?,
      experienceYears:
          _toIntOrNull(json['years_of_experience'] ?? json['experience_years']),
      specialization: json['specialization'] as String?,
      skills: json['skills'] is List
          ? (json['skills'] as List).map((e) => e.toString()).toList()
          : const [],
      isVerified: _toBool(json['is_verified']),
      isAvailable: _toBool(json['is_available']),
      ratingAverage: _toDouble(json['rating_avg'] ?? json['rating_average']) ??
          0.0,
      totalReviews: _toInt(json['reviews_count'] ?? json['total_reviews']),
      totalCompletedOrders: _toInt(
          json['jobs_completed_count'] ?? json['total_completed_orders']),
      currentLatitude: _toDouble(json['current_latitude']),
      currentLongitude: _toDouble(json['current_longitude']),
      lastLocationUpdatedAt: json['last_location_updated_at']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'bio': bio,
      'years_of_experience': experienceYears,
      'specialization': specialization,
      'skills': skills,
      'is_verified': isVerified,
      'is_available': isAvailable,
      'rating_avg': ratingAverage,
      'reviews_count': totalReviews,
      'jobs_completed_count': totalCompletedOrders,
      'current_latitude': currentLatitude,
      'current_longitude': currentLongitude,
      'last_location_updated_at': lastLocationUpdatedAt,
    };
  }

  static int _toInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static int? _toIntOrNull(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString());
  }

  static double? _toDouble(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString());
  }

  static bool _toBool(dynamic value) => value == true || value == 1;
}
