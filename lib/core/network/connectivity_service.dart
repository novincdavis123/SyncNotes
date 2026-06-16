import 'dart:async';

abstract class ConnectivityService {
  /// Returns the current network connectivity status.
  Future<bool> isConnected();

  /// Emits connectivity changes in real time.
  ///
  /// true  -> Internet/network available
  /// false -> No network available
  Stream<bool> get connectivityStream;
}
