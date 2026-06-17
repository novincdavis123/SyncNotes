import 'package:syncnotes/sync_manager/retry/retry_policy.dart';

const RetryPolicy defaultRetryPolicy = RetryPolicy(
  maxRetries: 3,
  baseDelay: Duration(seconds: 2),
  maxDelay: Duration(seconds: 30),
  backoffMultiplier: 2.0,
);
