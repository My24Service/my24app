class AppConfig {
  AppConfig({
    this.protocol = "http"
  });

  final String apiBaseUrl = 'my24service-dev.com:8000';
  final int pageSize = 20;
  String protocol;
}
