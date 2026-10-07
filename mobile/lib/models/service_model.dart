class ServiceCategoryModel {
  final int id;
  final String name;
  final String slug;
  final String? description;
  final String? icon;

  ServiceCategoryModel({
    required this.id,
    required this.name,
    required this.slug,
    this.description,
    this.icon,
  });

  factory ServiceCategoryModel.fromJson(Map<String, dynamic> json) {
    return ServiceCategoryModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      name: json['name'] as String? ?? '',
      slug: json['slug'] as String? ?? '',
      description: json['description'] as String?,
      icon: json['icon'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'slug': slug,
      'description': description,
      'icon': icon,
    };
  }
}

class ServiceModel {
  final int id;
  final String name;
  final String slug;
  final int? categoryId;
  final double price;
  final int estimatedDurationMinutes;
  final String? description;
  final String? imageUrl;
  final bool isActive;
  final ServiceCategoryModel? category;

  ServiceModel({
    required this.id,
    required this.name,
    required this.slug,
    this.categoryId,
    required this.price,
    this.estimatedDurationMinutes = 60,
    this.description,
    this.imageUrl,
    this.isActive = true,
    this.category,
  });

  factory ServiceModel.fromJson(Map<String, dynamic> json) {
    return ServiceModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      name: json['name'] as String? ?? '',
      slug: json['slug'] as String? ?? '',
      categoryId: json['category_id'] is int
          ? json['category_id']
          : int.tryParse(json['category_id']?.toString() ?? ''),
      price: json['price'] != null ? (double.tryParse(json['price'].toString()) ?? 0.0) : 0.0,
      estimatedDurationMinutes: json['estimated_duration_minutes'] is int
          ? json['estimated_duration_minutes']
          : int.tryParse(json['estimated_duration_minutes']?.toString() ?? '60') ?? 60,
      description: json['description'] as String?,
      imageUrl: json['image_url'] as String?,
      isActive: json['is_active'] == true || json['is_active'] == 1,
      category: json['category'] != null && json['category'] is Map
          ? ServiceCategoryModel.fromJson(Map<String, dynamic>.from(json['category'] as Map))
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'slug': slug,
      'category_id': categoryId,
      'price': price,
      'estimated_duration_minutes': estimatedDurationMinutes,
      'description': description,
      'image_url': imageUrl,
      'is_active': isActive,
      'category': category?.toJson(),
    };
  }
}
