# Architecture

## Design Goals

1. **Deduplication** — Single source of truth for Whisper integration across multiple apps (psychdiary, openshrimp)
2. **Configurability** — Timeouts, endpoints, and behavior customizable per app via `WhisperSpeechConfig`
3. **Riverpod native** — Seamless integration with Riverpod state management; no external dependencies
4. **Platform agnostic** — Works on iOS, Android, Web via conditional compilation
5. **Friendly UX** — Clear error messages, visual feedback, service error recovery

## Core Components

### 1. **WhisperSpeechNotifier** (`whisper_speech_provider.dart`)

Manages the recording → transcription → state pipeline.

**Lifecycle:**
```
[idle] ──startRecording()──> [recording]
                                  ↓
                         stopAndTranscribe()
                                  ↓
                        [transcribing] ──SSE stream──> [idle]
                                  ↑
                                  └── error: [idle] + isBlocked for 30s
```

**State Management:**
- `status` — Current phase (idle/recording/transcribing)
- `recordingDuration` — Elapsed time during recording (1s tick via Timer)
- `transcribedText` — Accumulated text from SSE stream
- `error` — User-friendly error message
- `isBlocked` — Disables button after service error for N seconds

**Key Methods:**
- `startRecording()` — Check permission, initialize recorder, tick duration timer
- `stopRecording()` — Stop recorder, return file path
- `stopAndTranscribe()` — Stop + send to backend
- `_transcribeInternal()` — HTTP POST + SSE stream parsing
- `cancel()` — Clean abort (timers, file, HTTP token)
- `_cleanup()` — Dispose handler (timers, streams, files)

**Error Detection:**
- `DioExceptionType.receiveTimeout`, `connectionTimeout`, `connectionError`
- String contains `'timeout'`
- → Service error (HTTP 5xx, network issue)
- → Friendly message + auto-block for 30s

### 2. **WhisperSpeechConfig** (`whisper_speech_config.dart`)

Configuration provider for backend communication.

**Fields:**
- `transcribeEndpoint` — POST URL (default: `/speech/transcribe/stream`)
- `transcriptionTimeout` — Total stream timeout (default: 60s)
- `transcriptionReceiveTimeout` — Socket receive timeout (default: 30s)
- `errorBlockDuration` — Button disable after service error (default: 30s)

**Why two timeouts?**
- `receiveTimeout` — Short, catches hung connections fast
- `transcriptionTimeout` — Long, allows slow networks to complete streaming

### 3. **Recording I/O** (`recording_io/`)

Platform-specific file handling via conditional compilation.

```
recording_io.dart
├── if dart.library.io → recording_io_mobile.dart
├── if dart.library.js_interop → recording_io_web.dart
└── else → recording_io_stub.dart
```

**Mobile** (`recording_io_mobile.dart`):
- `getRecordingPath()` → temp dir + `.m4a` filename
- `readRecordingBytes()` → File I/O
- `deleteRecording()` → Safe file cleanup

**Web** (`recording_io_web.dart`):
- `getRecordingPath()` → empty string (not used)
- `readRecordingBytes()` → Fetch blob URL → ArrayBuffer → Uint8List
- `deleteRecording()` → `URL.revokeObjectURL()`

**Stub** (`recording_io_stub.dart`):
- All throw `UnsupportedError` (fallback for unknown platforms)

### 4. **WhisperRecordButton** (`widgets/whisper_record_button.dart`)

Compact UI component reflecting provider state.

**States:**
- **Idle (enabled):** Mic icon + "Tap to speak" → `startRecording()`
- **Idle (blocked):** Mic-off icon + "Speech unavailable" → disabled
- **Recording:** Red bg, white mic, duration timer → `stopAndTranscribe()`
- **Transcribing:** Spinner + "Transcribing…" → disabled

**Styling:**
- `primaryContainer` background (idle)
- `red` background (recording)
- `surfaceContainerHighest` background (blocked)

### 5. **SpeechTextController** (`speech_text_controller.dart`)

Helper for cursor-aware streaming text insertion.

**Flow:**
1. Call `captureBaseState()` before starting speech
2. Call `updateWithSpeech(text)` for each SSE token
3. Text is inserted at captured cursor position
4. Repeated updates append to live text
5. Call `reset()` after speech completes

**Example:**
```
Base text: "I like "
Cursor at: 7
Input: "apple"

New text: "I like apple"
Cursor at: 12

Next input: "apple pie"

New text: "I like apple pie"  (prev "apple" replaced)
Cursor at: 16
```

## Data Flow

```
┌──────────────────┐
│  WhisperRecordButton (UI)
│  - Watch whisperSpeechProvider
│  - Call notifier.startRecording(), stopAndTranscribe(), cancel()
└──────────────────┘
           ↓
┌──────────────────────────┐
│  WhisperSpeechNotifier   │
│  - Records audio via `record` pkg
│  - Reads bytes via platform-specific `recording_io`
│  - POSTs to backend with FormData (multipart)
│  - Listens to SSE stream
│  - Updates state: transcribedText, duration, status, error
└──────────────────────────┘
           ↓
┌──────────────────────────┐
│  whisperDioProvider      │
│  - Authenticated Dio client
│  - Injected from app's apiClientProvider
└──────────────────────────┘
           ↓
┌──────────────────────────┐
│  WhisperSpeechConfig     │
│  - Timeouts & endpoint
│  - Overridable per-app
└──────────────────────────┘
           ↓
┌──────────────────────────┐
│  Backend API             │
│  POST /speech/transcribe/stream
│  Response: Server-Sent Events (SSE)
│  event: token
│  data: <text_chunk>
└──────────────────────────┘
```

## Error Handling Strategy

**Transient Errors** (network timeouts, connection issues):
1. Detect: `DioExceptionType.receiveTimeout`, `connectionTimeout`, `connectionError`, or `'timeout'` in message
2. Set `isBlocked = true`
3. Disable button for `errorBlockDuration` (30s)
4. Show friendly message: "Sorry, our speech service is not available right now, please type your message."
5. Auto-unblock after timer

**User Errors** (permission denied):
1. Show: "Microphone permission denied. Please enable it in settings."
2. No blocking (user can retry immediately)

**Unexpected Errors** (I/O failures):
1. Show: "Transcription failed: <details>"
2. No blocking (likely recoverable)

## Testing Strategy

- **Unit tests** — Mock Dio, test state transitions, error handling
- **Widget tests** — Mock provider, test UI states
- **Integration tests** — Real recording flow on device
- **Manual testing** — Device-specific recording permissions, audio quality

## Dependency Graph

```
df_whisper_speech/
├── flutter_riverpod ^3.0.3
│   └── riverpod ^3.0.3
├── dio ^5.7.0
├── record ^6.2.0
│   └── record_platform_interface
├── path_provider ^2.1.0 (mobile only)
└── web ^1.0.0 (web only)
```

No transitive dependency on app's auth, networking, or state layers.

## Extensibility

**Future enhancements:**
- Language selection support
- Confidence scores per token
- Custom audio format support
- Batch transcription
- Prompt injection (for specialized domains)
- Alternative backends (other Whisper APIs)

**Breaking changes would require:**
- New major version bump
- Update docs and CHANGELOG
- Notify consuming apps (psychdiary, openshrimp)

## Canonical Source

**Psychdiary** is the canonical implementation. This package extracts its Whisper integration, including:
- Service error detection
- Friendly error messages
- `isBlocked` state for UX
- Per-request `receiveTimeout` override

**OpenShrimp** will automatically receive these improvements when it upgrades to this package.

## Maintenance Notes

- Keep `recording_io/` exports synchronized with compilation targets
- Update `WhisperSpeechConfig` defaults if backend API changes
- Coordinate SSE format expectations with backend team
- Monitor Riverpod & Dio for major version changes
