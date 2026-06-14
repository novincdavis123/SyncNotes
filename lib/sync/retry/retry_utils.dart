import 'retry_policy.dart';

Duration calculateDelay(RetryPolicy policy, int retryCount) {
  final seconds =
      policy.baseDelay.inSeconds * (policy.backoffMultiplier * retryCount);

  return Duration(seconds: seconds.toInt());
}

bool shouldRetry(int retryCount, RetryPolicy policy) {
  return retryCount < policy.maxRetries;
}
