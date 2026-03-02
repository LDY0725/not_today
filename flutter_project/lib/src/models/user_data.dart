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
  bool isPro;
  Map<String, dynamic>? extraData;
  DailyReasonData? dailyReasonData;

  UserData({
    String? userId,
    this.days = 0,
    this.city = '',
    this.industry = '',
    this.lastUpdated,
    List<String>? checkedInDates,
    List<IndustryResignationData>? industryResignationInfo,
    double? appRankingPercentile,
    this.isPro = false,
    this.extraData,
    this.dailyReasonData,
  })  : userId = userId ?? _generateUserId(),
        checkedInDates = checkedInDates ?? [],
        industryResignationInfo = industryResignationInfo ?? [],
        appRankingPercentile = appRankingPercentile ?? 100.0;

  static String _generateUserId() {
    final random = Random();
    const chars =
        'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
    return List.generate(16, (index) => chars[random.nextInt(chars.length)])
        .join();
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'days': days,
      'city': city,
      'industry': industry,
      'lastUpdated': lastUpdated?.toIso8601String(),
      'checkedInDates': checkedInDates,
      'industryResignationInfo':
          industryResignationInfo.map((e) => e.toJson()).toList(),
      'appRankingPercentile': appRankingPercentile,
      'isPro': isPro,
      'extraData': extraData,
      'dailyReasonData': dailyReasonData?.toJson(),
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
      isPro: (json['isPro'] as bool?) ?? false,
      appRankingPercentile:
          (json['appRankingPercentile'] as num?)?.toDouble() ?? 100.0,
      extraData: json['extraData'] as Map<String, dynamic>?,
      dailyReasonData: json['dailyReasonData'] != null
          ? DailyReasonData.fromJson(json['dailyReasonData'])
          : null,
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
    bool? isPro,
    Map<String, dynamic>? extraData,
    DailyReasonData? dailyReasonData,
  }) {
    return UserData(
      userId: userId ?? this.userId,
      days: days ?? this.days,
      city: city ?? this.city,
      industry: industry ?? this.industry,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      checkedInDates: checkedInDates ?? this.checkedInDates,
      industryResignationInfo:
          industryResignationInfo ?? this.industryResignationInfo,
      appRankingPercentile: appRankingPercentile ?? this.appRankingPercentile,
      isPro: isPro ?? this.isPro,
      extraData: extraData ?? this.extraData,
      dailyReasonData: dailyReasonData ?? this.dailyReasonData,
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
      resignationPercentage:
          (json['resignationPercentage'] as num?)?.toDouble() ?? 0.0,
    );
  }

  IndustryResignationData copyWith({
    String? industryName,
    double? resignationPercentage,
  }) {
    return IndustryResignationData(
      industryName: industryName ?? this.industryName,
      resignationPercentage:
          resignationPercentage ?? this.resignationPercentage,
    );
  }
}

class DailyReasonData {
  DateTime date;
  List<DailyReasonItem> reasons;

  DailyReasonData({
    required this.date,
    required this.reasons,
  });

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'reasons': reasons.map((e) => e.toJson()).toList(),
    };
  }

  factory DailyReasonData.fromJson(Map<String, dynamic> json) {
    return DailyReasonData(
      date:
          json['date'] != null ? DateTime.parse(json['date']) : DateTime.now(),
      reasons: (json['reasons'] as List?)
              ?.map((e) => DailyReasonItem.fromJson(e))
              .toList() ??
          [],
    );
  }

  DailyReasonData copyWith({
    DateTime? date,
    List<DailyReasonItem>? reasons,
  }) {
    return DailyReasonData(
      date: date ?? this.date,
      reasons: reasons ?? this.reasons,
    );
  }
}

class DailyReasonItem {
  String reasonName;
  double score;
  int tapCount;

  DailyReasonItem({
    required this.reasonName,
    required this.score,
    this.tapCount = 0,
  });

  Map<String, dynamic> toJson() {
    return {
      'reasonName': reasonName,
      'score': score,
      'tapCount': tapCount,
    };
  }

  factory DailyReasonItem.fromJson(Map<String, dynamic> json) {
    return DailyReasonItem(
      reasonName: json['reasonName'] ?? '',
      score: (json['score'] as num?)?.toDouble() ?? 0.0,
      tapCount: (json['tapCount'] as int?) ?? 0,
    );
  }

  DailyReasonItem copyWith({
    String? reasonName,
    double? score,
    int? tapCount,
  }) {
    return DailyReasonItem(
      reasonName: reasonName ?? this.reasonName,
      score: score ?? this.score,
      tapCount: tapCount ?? this.tapCount,
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
