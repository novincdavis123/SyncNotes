import 'dart:math';

class RetryPolicy {
  final int maxRetries;

  /// ⏱ initial delay before first retry
  final Duration baseDelay;

  /// 📈 exponential growth factor (e.g. 2.0 = double each retry)
  final double backoffMultiplier;

  /// 🧯 maximum allowed delay cap
  final Duration maxDelay;

  /// 🎲 randomness factor (0.0 - 1.0)
  final double jitterFactor;

  const RetryPolicy({
    this.maxRetries = 3,
    this.baseDelay = const Duration(seconds: 2),
    this.backoffMultiplier = 2.0,
    this.maxDelay = const Duration(seconds: 30),
    this.jitterFactor = 0.2,
  });

  // ============================================================
  // 🧠 PRODUCTION BACKOFF CALCULATION
  // ============================================================

  Duration calculateDelay(int retryCount) {
    if (retryCount <= 0) return baseDelay;

    // ✅ true exponential backoff
    final exponentialMillis =
        baseDelay.inMilliseconds * pow(backoffMultiplier, retryCount);

    var delay = Duration(milliseconds: exponentialMillis.toInt());

    // 🧯 clamp to max delay
    if (delay > maxDelay) {
      delay = maxDelay;
    }

    // 🎲 jitter (prevents retry storms)
    final jitterRange = (delay.inMilliseconds * jitterFactor).toInt();

    final random = Random().nextInt(jitterRange + 1);
    final jittered = delay.inMilliseconds - (jitterRange ~/ 2) + random;

    // 🚨 safety guard (never allow negative delay)
    return Duration(milliseconds: max(0, jittered));
  }

  // ============================================================
  // 🧠 RETRY ELIGIBILITY
  // ============================================================

  bool shouldRetry(int retryCount) {
    return retryCount < maxRetries;
  }
}
