import 'package:syncnotes/sync_manager/retry/retry_policy.dart';

Duration calculateDelay(RetryPolicy policy, int retryCount) {
  final baseDelay = policy.baseDelay.inSeconds;

  // exponential backoff
  final exponential = baseDelay * (1 << retryCount);

  // cap delay
  final capped = exponential.clamp(baseDelay, policy.maxDelay.inSeconds);

  return Duration(seconds: capped + _jitter());
}

int _jitter() {
  return DateTime.now().millisecond % 3; // small randomness (0–2 sec)
}
