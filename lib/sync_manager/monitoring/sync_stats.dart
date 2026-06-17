import 'package:syncnotes/app/app_logger.dart';

class SyncStats {
  static int totalSynced = 0;
  static int totalFailed = 0;
  static int totalRetried = 0;

  static void reset() {
    totalSynced = 0;
    totalFailed = 0;
    totalRetried = 0;
  }

  static void printSummary() {
    AppLogger.log(
      "SYNC STATS | Synced=$totalSynced | Failed=$totalFailed | Retried=$totalRetried",
    );
  }
}
