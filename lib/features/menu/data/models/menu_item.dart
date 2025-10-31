class Discount {
  final String type;
  final double value;
  final DateTime startDate;
  final DateTime endDate;
  final bool isActive;

  Discount({
    required this.type,
    required this.value,
    required this.startDate,
    required this.endDate,
    required this.isActive,
  });

  factory Discount.fromJson(Map<String, dynamic> json) {
    return Discount(
      type: json['type'] as String,
      value: (json['value'] as num).toDouble(),
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: DateTime.parse(json['endDate'] as String),
      isActive: json['isActive'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'value': value,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'isActive': isActive,
    };
  }

  @override
  String toString() {
    return 'Discount(type: $type, value: $value, startDate: $startDate, endDate: $endDate, isActive: $isActive)';
  }
}

class MenuItem {
  final String id;
  final String name;
  final String description;
  final double basePrice;
  final int prepTime;
  final Discount? discount;
  final bool isActive;
  final bool isAvailable;
  final int order;
  final String category;
  final String? imagePath;
  final DateTime createdAt;
  final DateTime updatedAt;

  MenuItem({
    required this.id,
    required this.name,
    required this.description,
    required this.basePrice,
    required this.prepTime,
    this.discount,
    required this.isActive,
    required this.isAvailable,
    required this.order,
    required this.category,
    this.imagePath,
    required this.createdAt,
    required this.updatedAt,
  });

  factory MenuItem.fromJson(Map<String, dynamic> json) {
    return MenuItem(
      id: json['_id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      basePrice: (json['basePrice'] as num).toDouble(),
        prepTime: json['prepTime'] is int
            ? json['prepTime']
            : int.tryParse(json['prepTime'].toString()) ?? 0,
      discount: json['discount'] != null ? Discount.fromJson(json['discount']) : null,
      isActive: json['isActive'] as bool,
      isAvailable: json['isAvailable'] as bool,
      order: json['order'] is int
          ? json['order']
          : int.tryParse(json['order'].toString()) ?? 0,
      category: json['category'] as String,
      imagePath: json['imagePath'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'description': description,
      'basePrice': basePrice,
      'prepTime': prepTime,
      'discount': discount?.toJson(),
      'isActive': isActive,
      'isAvailable': isAvailable,
      'order': order,
      'category': category,
      'imagePath': imagePath,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  MenuItem copyWith({
    String? id,
    String? name,
    String? description,
    double? basePrice,
    int? prepTime,
    Discount? discount,
    bool? isActive,
    bool? isAvailable,
    int? order,
    String? category,
    String? imagePath,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return MenuItem(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      basePrice: basePrice ?? this.basePrice,
      prepTime: prepTime ?? this.prepTime,
      discount: discount ?? this.discount,
      isActive: isActive ?? this.isActive,
      isAvailable: isAvailable ?? this.isAvailable,
      order: order ?? this.order,
      category: category ?? this.category,
      imagePath: imagePath ?? this.imagePath,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'MenuItem(id: $id, name: $name, description: $description, basePrice: $basePrice, prepTime: $prepTime, discount: $discount, isActive: $isActive, isAvailable: $isAvailable, order: $order, category: $category, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MenuItem &&
        other.id == id &&
        other.name == name &&
        other.description == description &&
        other.basePrice == basePrice &&
        other.prepTime == prepTime &&
        other.discount == discount &&
        other.isActive == isActive &&
        other.isAvailable == isAvailable &&
        other.order == order &&
        other.category == category &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        name.hashCode ^
        description.hashCode ^
        basePrice.hashCode ^
        prepTime.hashCode ^
        discount.hashCode ^
        isActive.hashCode ^
        isAvailable.hashCode ^
        order.hashCode ^
        category.hashCode ^
        createdAt.hashCode ^
        updatedAt.hashCode;
  }
}

class CreateMenuItemRequest {
  final String name;
  final String description;
  final double basePrice;
  final int prepTime;

  CreateMenuItemRequest({
    required this.name,
    required this.description,
    required this.basePrice,
    required this.prepTime,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name.trim(),
      'description': description.trim(),
      'basePrice': basePrice.toDouble(), // Ensure it's a double
      'prepTime': prepTime.toInt(), // Ensure it's an int
    };
  }

  @override
  String toString() {
    return 'CreateMenuItemRequest(name: $name, description: $description, basePrice: $basePrice, prepTime: $prepTime)';
  }
}