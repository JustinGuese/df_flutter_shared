// Guarded on dart.library.js_interop rather than dart.library.html so the web
// implementation is also selected under Wasm.
export 'audio_capture_service_io.dart'
    if (dart.library.js_interop) 'audio_capture_service_web.dart';
