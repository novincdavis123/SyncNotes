import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:syncnotes/app/app_logger.dart';

class AppBlocObserver extends BlocObserver {
  @override
  void onChange(BlocBase bloc, Change change) {
    super.onChange(bloc, change);
    AppLogger.log('${bloc.runtimeType} -> $change');
  }

  @override
  void onEvent(Bloc bloc, Object? event) {
    super.onEvent(bloc, event);
    AppLogger.log('${bloc.runtimeType} -> $event');
  }
}
