import 'package:connectivity_plus/connectivity_plus.dart';

import 'connectivity_service.dart';

class ConnectivityServiceImpl implements ConnectivityService {
  final Connectivity _connectivity;

  ConnectivityServiceImpl(this._connectivity);

  // ------------------------------------------------------------
  // CURRENT CONNECTIVITY STATUS
  // ------------------------------------------------------------

  @override
  Future<bool> isConnected() async {
    final results = await _connectivity.checkConnectivity();

    return _hasConnection(results);
  }

  // ------------------------------------------------------------
  // CONNECTIVITY CHANGE STREAM
  // ------------------------------------------------------------

  @override
  Stream<bool> get connectivityStream {
    return _connectivity.onConnectivityChanged.map(_hasConnection);
  }

  // ------------------------------------------------------------
  // HELPER
  // ------------------------------------------------------------

  bool _hasConnection(List<ConnectivityResult> results) {
    return results.any((result) => result != ConnectivityResult.none);
  }
}
