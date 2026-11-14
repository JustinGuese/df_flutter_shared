/// Core error reporting contract for DataFortress apps.
///
/// Applications install a [DfErrorSink] via [DfErrorReporting.install], wiring
/// Flutter and platform errors to the destination sink.
library;

export 'src/df_error_reporting.dart';
export 'src/df_error_sink.dart';
export 'src/noop_error_sink.dart';
export 'src/recording_error_sink.dart';
