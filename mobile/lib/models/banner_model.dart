class BannerModel {
  final int id;
  final String title;
  final String? description;
  final String imageUrl;
  final String? badgeText;
  final String? linkUrl;
  final int sortOrder;
  final bool isActive;
  final String? startDate;
  final String? endDate;

  BannerModel({
    required this.id,
    required this.title,
    this.description,
    required this.imageUrl,
    this.badgeText,
    this.linkUrl,
    this.sortOrder = 0,
    this.isActive = true,
    this.startDate,
    this.endDate,
  });

  factory BannerModel.fromJson(Map<String, dynamic> json) {
    String img = (json['formatted_image_url'] ?? json['image_url'] ?? '').toString();
    if (img.startsWith('/storage/')) {
      // Local development fallback
      img = 'http://10.0.2.2:8000$img';
    }

    return BannerModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      title: (json['title'] ?? '').toString(),
      description: json['description']?.toString(),
      imageUrl: img,
      badgeText: json['badge_text']?.toString(),
      linkUrl: json['link_url']?.toString(),
      sortOrder: json['sort_order'] is int
          ? json['sort_order']
          : int.tryParse(json['sort_order']?.toString() ?? '0') ?? 0,
      isActive: json['is_active'] == true || json['is_active'] == 1 || json['is_active'] == '1',
      startDate: json['start_date']?.toString(),
      endDate: json['end_date']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'image_url': imageUrl,
      'badge_text': badgeText,
      'link_url': linkUrl,
      'sort_order': sortOrder,
      'is_active': isActive,
      'start_date': startDate,
      'end_date': endDate,
    };
  }
}
