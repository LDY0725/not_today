class AppConfig {
  final String appName;
  final String version;
  final int buildNumber;

  AppConfig({
    required this.appName,
    required this.version,
    required this.buildNumber,
  });

  static AppConfig get instance =>
      AppConfig(appName: 'Not Today', version: '1.0.0', buildNumber: 1);

  String get fullVersion => '$version ($buildNumber)';
}
