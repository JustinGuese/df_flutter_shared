# Testing df_whisper_speech

## Unit Tests

Mock the `whisperDioProvider` to test the notifier without a real backend:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:df_whisper_speech/df_whisper_speech.dart';

class MockDio extends Mock implements Dio {}

void main() {
  group('WhisperSpeechNotifier', () {
    test('start recording updates state', () async {
      final mockDio = MockDio();

      final container = ProviderContainer(
        overrides: [
          whisperDioProvider.overrideWithValue(mockDio),
        ],
      );

      final notifier = container.read(whisperSpeechProvider.notifier);
      expect(notifier.state.status, WhisperSpeechStatus.idle);

      // Note: actual recording requires platform permissions
      // This test demonstrates state transitions
    });

    test('transcription state updates on success', () async {
      final mockDio = MockDio();

      // Mock SSE response
      when(() => mockDio.post(
        any(),
        data: any(named: 'data'),
        options: any(named: 'options'),
        cancelToken: any(named: 'cancelToken'),
      )).thenAnswer((_) async {
        // Simulate SSE stream
        final stream = Stream.fromIterable([
          'event: token\ndata: hello\n\n',
          'event: token\ndata:  world\n\n',
          'event: end\ndata:\n\n',
        ]);

        return Response(
          requestOptions: RequestOptions(path: '/test'),
          statusCode: 200,
          data: ResponseBody(stream, 200),
        );
      });

      final container = ProviderContainer(
        overrides: [
          whisperDioProvider.overrideWithValue(mockDio),
        ],
      );

      final notifier = container.read(whisperSpeechProvider.notifier);

      // After successful transcription, state should return to idle
      // and transcribedText should be populated
    });

    test('service error blocks recording', () async {
      final mockDio = MockDio();

      when(() => mockDio.post(
        any(),
        data: any(named: 'data'),
        options: any(named: 'options'),
        cancelToken: any(named: 'cancelToken'),
      )).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: '/test'),
          type: DioExceptionType.receiveTimeout,
        ),
      );

      final container = ProviderContainer(
        overrides: [
          whisperDioProvider.overrideWithValue(mockDio),
        ],
      );

      final notifier = container.read(whisperSpeechProvider.notifier);

      // After service error, isBlocked should be true
      // and button should be disabled for errorBlockDuration
    });
  });
}
```

## Widget Tests

Test `WhisperRecordButton` in isolation:

```dart
void main() {
  group('WhisperRecordButton', () {
    testWidgets('shows mic icon in idle state', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            whisperSpeechProvider.overrideWithValue(
              const WhisperSpeechState(),
            ),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: WhisperRecordButton(),
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.mic_none), findsOneWidget);
    });

    testWidgets('shows recording time during recording', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            whisperSpeechProvider.overrideWithValue(
              const WhisperSpeechState(
                status: WhisperSpeechStatus.recording,
                recordingDuration: Duration(seconds: 5),
              ),
            ),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: WhisperRecordButton(),
            ),
          ),
        ),
      );

      expect(find.text('0:05'), findsOneWidget);
    });

    testWidgets('shows unavailable message when blocked', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            whisperSpeechProvider.overrideWithValue(
              const WhisperSpeechState(isBlocked: true),
            ),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: WhisperRecordButton(),
            ),
          ),
        ),
      );

      expect(find.text('Speech unavailable'), findsOneWidget);
    });
  });
}
```

## Integration Tests

Test the full flow in a real app context:

```dart
void main() {
  group('Speech-to-text integration', () {
    testWidgets('records and transcribes audio', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            whisperDioProvider.overrideWithValue(createTestDio()),
          ],
          child: const MyApp(),
        ),
      );

      // Tap mic button
      await tester.tap(find.byType(WhisperRecordButton));
      await tester.pumpAndSettle();

      // Verify recording state
      expect(find.text('Recording'), findsWidgets);

      // Wait and stop recording
      await Future.delayed(Duration(seconds: 2));
      await tester.tap(find.byType(WhisperRecordButton));
      await tester.pumpAndSettle();

      // Verify transcription completes
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    testWidgets('shows error on network failure', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            whisperDioProvider.overrideWithValue(createFailingDio()),
          ],
          child: const MyApp(),
        ),
      );

      await tester.tap(find.byType(WhisperRecordButton));
      await tester.pumpAndSettle();
      await Future.delayed(Duration(seconds: 1));
      await tester.tap(find.byType(WhisperRecordButton));
      await tester.pumpAndSettle();

      // Verify error message
      expect(find.byType(SnackBar), findsWidgets);
      expect(find.text('speech service is not available'), findsOneWidget);
    });
  });
}
```

## Manual Testing

1. **Build & run on device:**
   ```bash
   flutter run -d <device>
   ```

2. **Record audio:**
   - Tap the mic button
   - Speak clearly
   - Tap to stop

3. **Verify:**
   - ✅ Audio is recorded (duration shown)
   - ✅ Transcription appears in real-time
   - ✅ Text is inserted at cursor position
   - ✅ Button shows "Tap to speak" when done

4. **Test error handling:**
   - Disconnect from network
   - Tap mic and record
   - Verify friendly error message + 30s disable

5. **Test state persistence:**
   - Record and cancel mid-stream
   - Verify state resets cleanly
   - Recording button re-enabled

## Test Coverage

Current test suite (psychdiary):
- `constants_test.dart` — `WhisperSpeechConfig` defaults
- `speech_text_controller_test.dart` — Text insertion logic

For broader coverage, consider adding:
- Recording state machine tests
- SSE parsing tests
- Timeout & error recovery tests
- Platform-specific I/O tests
