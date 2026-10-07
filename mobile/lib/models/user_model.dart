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
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      phone: json['phone'] as String?,
      role: json['role'] as String? ?? 'customer',
      avatarUrl: json['avatar_url'] as String?,
      address: json['address'] as String?,
      isActive: json['is_active'] == true || json['is_active'] == 1,
      technicianProfile: json['technician_profile'] != null && json['technician_profile'] is Map
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
  final int? experienceYears;
  final String? specialization;
  final bool isVerified;
  final bool isAvailable;
  final double ratingAverage;
  final int totalReviews;
  final int totalCompletedOrders;
  final double? currentLatitude;
  final double? currentLongitude;

  TechnicianProfileModel({
    required this.id,
    this.experienceYears,
    this.specialization,
    this.isVerified = false,
    this.isAvailable = true,
    this.ratingAverage = 0.0,
    this.totalReviews = 0,
    this.totalCompletedOrders = 0,
    this.currentLatitude,
    this.currentLongitude,
  });

  factory TechnicianProfileModel.fromJson(Map<String, dynamic> json) {
    return TechnicianProfileModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      experienceYears: json['experience_years'] is int
          ? json['experience_years']
          : int.tryParse(json['experience_years']?.toString() ?? ''),
      specialization: json['specialization'] as String?,
      isVerified: json['is_verified'] == true || json['is_verified'] == 1,
      isAvailable: json['is_available'] == true || json['is_available'] == 1,
      ratingAverage: (json['rating_average'] != null)
          ? (double.tryParse(json['rating_average'].toString()) ?? 0.0)
          : 0.0,
      totalReviews: json['total_reviews'] is int
          ? json['total_reviews']
          : int.tryParse(json['total_reviews']?.toString() ?? '') ?? 0,
      totalCompletedOrders: json['total_completed_orders'] is int
          ? json['total_completed_orders']
          : int.tryParse(json['total_completed_orders']?.toString() ?? '') ?? 0,
      currentLatitude: json['current_latitude'] != null
          ? double.tryParse(json['current_latitude'].toString())
          : null,
      currentLongitude: json['current_longitude'] != null
          ? double.tryParse(json['current_longitude'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'experience_years': experienceYears,
      'specialization': specialization,
      'is_verified': isVerified,
      'is_available': isAvailable,
      'rating_average': ratingAverage,
      'total_reviews': totalReviews,
      'total_completed_orders': totalCompletedOrders,
      'current_latitude': currentLatitude,
      'current_longitude': currentLongitude,
    };
  }
}
