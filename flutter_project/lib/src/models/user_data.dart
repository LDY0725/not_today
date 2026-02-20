import 'dart:convert';
import 'dart:math';

class UserData {
  String userId;
  int days;
  String city;
  String industry;
  DateTime? lastUpdated;
  List<String> checkedInDates;
  List<IndustryResignationData> industryResignationInfo;
  double appRankingPercentile;
  Map<String, dynamic>? extraData;

  UserData({
    String? userId,
    this.days = 0,
    this.city = '',
    this.industry = '',
    this.lastUpdated,
    List<String>? checkedInDates,
    List<IndustryResignationData>? industryResignationInfo,
    double? appRankingPercentile,
    this.extraData,
  })  : userId = userId ?? _generateUserId(),
        checkedInDates = checkedInDates ?? [],
        industryResignationInfo = industryResignationInfo ?? [],
        appRankingPercentile = appRankingPercentile ?? 100.0;

  static String _generateUserId() {
    final random = Random();
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
    return List.generate(16, (index) => chars[random.nextInt(chars.length)]).join();
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'days': days,
      'city': city,
      'industry': industry,
      'lastUpdated': lastUpdated?.toIso8601String(),
      'checkedInDates': checkedInDates,
      'industryResignationInfo': industryResignationInfo.map((e) => e.toJson()).toList(),
      'appRankingPercentile': appRankingPercentile,
      'extraData': extraData,
    };
  }

  factory UserData.fromJson(Map<String, dynamic> json) {
    return UserData(
      userId: json['userId'] ?? '',
      days: json['days'] ?? 0,
      city: json['city'] ?? '',
      industry: json['industry'] ?? '',
      lastUpdated: json['lastUpdated'] != null
          ? DateTime.parse(json['lastUpdated'])
          : null,
      checkedInDates: (json['checkedInDates'] as List?)?.cast<String>() ?? [],
      industryResignationInfo: (json['industryResignationInfo'] as List?)
          ?.map((e) => IndustryResignationData.fromJson(e))
          .toList() ??
          [],
      appRankingPercentile: (json['appRankingPercentile'] as num?)?.toDouble() ?? 100.0,
      extraData: json['extraData'] as Map<String, dynamic>?,
    );
  }

  String toJsonString() => jsonEncode(toJson());

  factory UserData.fromJsonString(String jsonString) {
    return UserData.fromJson(jsonDecode(jsonString));
  }

  UserData copyWith({
    String? userId,
    int? days,
    String? city,
    String? industry,
    DateTime? lastUpdated,
    List<String>? checkedInDates,
    List<IndustryResignationData>? industryResignationInfo,
    double? appRankingPercentile,
    Map<String, dynamic>? extraData,
  }) {
    return UserData(
      userId: userId ?? this.userId,
      days: days ?? this.days,
      city: city ?? this.city,
      industry: industry ?? this.industry,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      checkedInDates: checkedInDates ?? this.checkedInDates,
      industryResignationInfo: industryResignationInfo ?? this.industryResignationInfo,
      appRankingPercentile: appRankingPercentile ?? this.appRankingPercentile,
      extraData: extraData ?? this.extraData,
    );
  }

  bool get isFirstTimeUser => userId.isEmpty;
}

class IndustryResignationData {
  String industryName;
  double resignationPercentage;

  IndustryResignationData({
    required this.industryName,
    required this.resignationPercentage,
  });

  Map<String, dynamic> toJson() {
    return {
      'industryName': industryName,
      'resignationPercentage': resignationPercentage,
    };
  }

  factory IndustryResignationData.fromJson(Map<String, dynamic> json) {
    return IndustryResignationData(
      industryName: json['industryName'] ?? '',
      resignationPercentage: (json['resignationPercentage'] as num?)?.toDouble() ?? 0.0,
    );
  }

  IndustryResignationData copyWith({
    String? industryName,
    double? resignationPercentage,
  }) {
    return IndustryResignationData(
      industryName: industryName ?? this.industryName,
      resignationPercentage: resignationPercentage ?? this.resignationPercentage,
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
