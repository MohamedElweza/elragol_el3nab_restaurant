class VendorCategory {
  final String id;
  final String name;
  final String description;
  final String? imagePath;
  final bool isActive;
  final int order;
  final DateTime createdAt;
  final DateTime updatedAt;

  VendorCategory({
    required this.id,
    required this.name,
    required this.description,
    this.imagePath,
    required this.isActive,
    required this.order,
    required this.createdAt,
    required this.updatedAt,
  });

  factory VendorCategory.fromJson(Map<String, dynamic> json) {
    return VendorCategory(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      imagePath: json['imagePath'],
      isActive: json['isActive'] ?? false,
      order: json['order'] ?? 0,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'description': description,
      'imagePath': imagePath,
      'isActive': isActive,
      'order': order,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}