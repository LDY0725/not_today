enum Environment { dev, prod }

class EnvConfig {
  final Environment environment;
  final String baseUrl;
  final bool logEnabled;
  final int timeout;

  EnvConfig({
    required this.environment,
    required this.baseUrl,
    required this.logEnabled,
    required this.timeout,
  });

  static EnvConfig get dev => EnvConfig(
    environment: Environment.dev,
    baseUrl: 'https://api.dev.example.com',
    logEnabled: true,
    timeout: 30000,
  );

  static EnvConfig get prod => EnvConfig(
    environment: Environment.prod,
    baseUrl: 'https://api.example.com',
    logEnabled: false,
    timeout: 15000,
  );

  static EnvConfig fromEnvironment() {
    const envString = String.fromEnvironment('ENV', defaultValue: 'dev');
    return envString == 'prod' ? prod : dev;
  }

  String get environmentName => environment.toString().split('.').last;
}
