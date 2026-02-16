import 'dart:convert';

class UserData {
  int days;
  String city;
  String industry;
  DateTime? lastUpdated;
  Map<String, dynamic>? extraData;

  UserData({
    this.days = 0,
    this.city = '',
    this.industry = '',
    this.lastUpdated,
    this.extraData,
  });

  Map<String, dynamic> toJson() {
    return {
      'days': days,
      'city': city,
      'industry': industry,
      'lastUpdated': lastUpdated?.toIso8601String(),
      'extraData': extraData,
    };
  }

  factory UserData.fromJson(Map<String, dynamic> json) {
    return UserData(
      days: json['days'] ?? 0,
      city: json['city'] ?? '',
      industry: json['industry'] ?? '',
      lastUpdated: json['lastUpdated'] != null
          ? DateTime.parse(json['lastUpdated'])
          : null,
      extraData: json['extraData'] as Map<String, dynamic>?,
    );
  }

  String toJsonString() => jsonEncode(toJson());

  factory UserData.fromJsonString(String jsonString) {
    return UserData.fromJson(jsonDecode(jsonString));
  }

  UserData copyWith({
    int? days,
    String? city,
    String? industry,
    DateTime? lastUpdated,
    Map<String, dynamic>? extraData,
  }) {
    return UserData(
      days: days ?? this.days,
      city: city ?? this.city,
      industry: industry ?? this.industry,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      extraData: extraData ?? this.extraData,
    );
  }
}

class CacheKeys {
  static const String userData = 'user_data';
  static const String days = 'days';
  static const String city = 'city';
  static const String industry = 'industry';
  static const String lastUpdated = 'last_updated';
}
