/// Configuration for API repository (pagination, timeouts).
class ApiRepositoryConfig {
  const ApiRepositoryConfig({
    this.defaultPageSize = 20,
    this.connectTimeout,
    this.receiveTimeout,
  });

  final int defaultPageSize;
  final Duration? connectTimeout;
  final Duration? receiveTimeout;
}
