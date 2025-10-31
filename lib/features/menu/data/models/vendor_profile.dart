class WorkingHours {
  final String open;
  final String close;
  final List<String> days;

  WorkingHours({
    required this.open,
    required this.close,
    required this.days,
  });

  factory WorkingHours.fromJson(Map<String, dynamic> json) {
    return WorkingHours(
      open: json['open'] ?? '',
      close: json['close'] ?? '',
      days: List<String>.from(json['days'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'open': open,
      'close': close,
      'days': days,
    };
  }
}

class VendorProfile {
  final String id;
  final String name;
  final String description;
  final String category;
  final WorkingHours workingHours;
  final String owner;
  final String? logoPath;
  final bool isActive;
  final double? averageRate;
  final int? totalRates;
  final DateTime createdAt;
  final DateTime updatedAt;

  VendorProfile({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.workingHours,
    required this.owner,
    this.logoPath,
    required this.isActive,
    this.averageRate,
    this.totalRates,
    required this.createdAt,
    required this.updatedAt,
  });

  factory VendorProfile.fromJson(Map<String, dynamic> json) {
    return VendorProfile(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      category: json['category'] ?? '',
      workingHours: WorkingHours.fromJson(json['workingHours'] ?? {}),
      owner: json['owner'] ?? '',
      logoPath: json['logoPath'],
      isActive: json['isActive'] ?? false,
      averageRate: json['averageRate']?.toDouble(),
      totalRates: json['totalRates']?.toInt(),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'description': description,
      'category': category,
      'workingHours': workingHours.toJson(),
      'owner': owner,
      'logoPath': logoPath,
      'isActive': isActive,
      'averageRate': averageRate,
      'totalRates': totalRates,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}

class CreateVendorProfileRequest {
  final String name;
  final String description;
  final String categoryId;
  final String openHour;
  final String closeHour;
  final List<String> days;

  CreateVendorProfileRequest({
    required this.name,
    required this.description,
    required this.categoryId,
    required this.openHour,
    required this.closeHour,
    required this.days,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'categoryId': categoryId,
      'openHour': openHour,
      'closeHour': closeHour,
      'days': days,
    };
  }
}