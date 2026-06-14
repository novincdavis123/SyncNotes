class RetryPolicy {
  final int maxRetries;
  final Duration baseDelay;
  final double backoffMultiplier;

  const RetryPolicy({
    this.maxRetries = 3,
    this.baseDelay = const Duration(seconds: 2),
    this.backoffMultiplier = 2.0,
  });
}
