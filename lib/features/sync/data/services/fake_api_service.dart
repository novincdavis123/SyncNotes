import 'dart:math';

import 'package:syncnotes/features/notes/data/models/sync_operation_model.dart';

class FakeApiService {
  final Random _random = Random();

  Future<bool> pushToServer(SyncOperationModel operation) async {
    await Future.delayed(const Duration(milliseconds: 400));

    // simulate 80% success rate
    return _random.nextInt(10) < 8;
  }
}
