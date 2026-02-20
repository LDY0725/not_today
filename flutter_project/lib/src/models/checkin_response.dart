class CheckinRequest {
  final String userId;
  final String city;
  final String industry;

  CheckinRequest({
    required this.userId,
    required this.city,
    required this.industry,
  });

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'city': city,
      'industry': industry,
    };
  }
}

class ApiIndustryData {
  final String industryName;
  final double resignationPercentage;

  ApiIndustryData({
    required this.industryName,
    required this.resignationPercentage,
  });

  factory ApiIndustryData.fromJson(Map<String, dynamic> json) {
    return ApiIndustryData(
      industryName: json['industryName'] ?? '',
      resignationPercentage: (json['resignationPercentage'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'industryName': industryName,
      'resignationPercentage': resignationPercentage,
    };
  }
}

class CheckinResponse {
  final String userId;
  final int days;
  final String city;
  final String industry;
  final DateTime lastUpdated;
  final List<String> checkedInDates;
  final List<ApiIndustryData> industryResignationInfo;
  final double appRankingPercentile;

  CheckinResponse({
    required this.userId,
    required this.days,
    required this.city,
    required this.industry,
    required this.lastUpdated,
    required this.checkedInDates,
    required this.industryResignationInfo,
    required this.appRankingPercentile,
  });

  factory CheckinResponse.fromJson(Map<String, dynamic> json) {
    var checkedInDatesList = <String>[];
    if (json['checkedInDates'] != null) {
      checkedInDatesList = List<String>.from(json['checkedInDates']);
    }

    var industryResignationInfoList = <ApiIndustryData>[];
    if (json['industryResignationInfo'] != null) {
      industryResignationInfoList = (json['industryResignationInfo'] as List)
          .map((e) => ApiIndustryData.fromJson(e))
          .toList();
    }

    return CheckinResponse(
      userId: json['userId'] ?? '',
      days: json['days'] ?? 0,
      city: json['city'] ?? '',
      industry: json['industry'] ?? '',
      lastUpdated: json['lastUpdated'] != null
          ? DateTime.parse(json['lastUpdated'])
          : DateTime.now(),
      checkedInDates: checkedInDatesList,
      industryResignationInfo: industryResignationInfoList,
      appRankingPercentile: (json['appRankingPercentile'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'days': days,
      'city': city,
      'industry': industry,
      'lastUpdated': lastUpdated.toIso8601String(),
      'checkedInDates': checkedInDates,
      'industryResignationInfo':
          industryResignationInfo.map((e) => e.toJson()).toList(),
      'appRankingPercentile': appRankingPercentile,
    };
  }
}
