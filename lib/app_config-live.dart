class AppConfig {
  AppConfig({
    this.protocol = "https"
  });

  final String apiBaseUrl = 'my24service.com';
  final int pageSize = 20;
  String protocol;
}
