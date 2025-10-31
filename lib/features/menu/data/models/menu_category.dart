class MenuCategory {
  final String id;
  final String name;
  final String description;
  final String vendor;
  final bool isActive;
  final int order;
  final DateTime createdAt;
  final DateTime updatedAt;

  MenuCategory({
    required this.id,
    required this.name,
    required this.description,
    required this.vendor,
    required this.isActive,
    required this.order,
    required this.createdAt,
    required this.updatedAt,
  });

  factory MenuCategory.fromJson(Map<String, dynamic> json) {
    return MenuCategory(
      id: json['_id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      vendor: json['vendor'] as String,
      isActive: json['isActive'] as bool,
      order: json['order'] as int,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'description': description,
      'vendor': vendor,
      'isActive': isActive,
      'order': order,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  MenuCategory copyWith({
    String? id,
    String? name,
    String? description,
    String? vendor,
    bool? isActive,
    int? order,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return MenuCategory(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      vendor: vendor ?? this.vendor,
      isActive: isActive ?? this.isActive,
      order: order ?? this.order,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'MenuCategory(id: $id, name: $name, description: $description, vendor: $vendor, isActive: $isActive, order: $order, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MenuCategory &&
        other.id == id &&
        other.name == name &&
        other.description == description &&
        other.vendor == vendor &&
        other.isActive == isActive &&
        other.order == order &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        name.hashCode ^
        description.hashCode ^
        vendor.hashCode ^
        isActive.hashCode ^
        order.hashCode ^
        createdAt.hashCode ^
        updatedAt.hashCode;
  }
}

class CreateMenuCategoryRequest {
  final String name;
  final String description;

  CreateMenuCategoryRequest({
    required this.name,
    required this.description,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
    };
  }

  @override
  String toString() {
    return 'CreateMenuCategoryRequest(name: $name, description: $description)';
  }
}