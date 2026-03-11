# Changelog

## [0.1.0] - 2026-03-11

### Added
- Initial release of `df_whisper_speech`
- `WhisperSpeechNotifier` & `WhisperSpeechState` for state management
- `WhisperRecordButton` widget for recording UI
- `SpeechTextController` helper for cursor-aware text insertion
- `WhisperSpeechConfig` for configurable timeouts and endpoints
- `whisperDioProvider` for injecting authenticated Dio client
- Platform-specific recording I/O (mobile via `path_provider`, web via Web API)
- SSE streaming transcription with real-time token updates
- Service error detection and auto-blocking behavior
- Comprehensive error messages and state tracking

### Context
Extracted from psychdiary's local implementation to eliminate duplication with openshrimp. Canonical source is now the psychdiary version, which includes:
- Per-request `receiveTimeout` override
- Service error detection (timeouts, connection errors)
- Friendly error messages
- `isBlocked` state for temporary button disable after service errors
