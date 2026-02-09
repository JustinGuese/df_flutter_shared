import 'package:flutter/widgets.dart';

/// Helper that manages inserting speech-recognized text into a
/// [TextEditingController] at the original cursor position.
class SpeechTextController {
  SpeechTextController(this._textController);

  final TextEditingController _textController;

  String? _baseText;
  TextSelection? _baseSelection;

  /// Capture the current text and selection as the base state.
  void captureBaseState() {
    _baseText = _textController.text;
    _baseSelection = _textController.selection;
  }

  /// Insert the given [words] at the original cursor position captured
  /// in [captureBaseState].
  void updateWithSpeech(String words) {
    _baseText ??= _textController.text;
    _baseSelection ??= _textController.selection;

    final baseText = _baseText!;
    final selection = _baseSelection!;

    final insertOffset =
        selection.isValid ? selection.baseOffset : baseText.length;

    final newText =
        baseText.substring(0, insertOffset) + words + baseText.substring(insertOffset);

    _textController.value = _textController.value.copyWith(
      text: newText,
      selection: TextSelection.collapsed(offset: insertOffset + words.length),
      composing: TextRange.empty,
    );
  }

  /// Clear any captured base state.
  void reset() {
    _baseText = null;
    _baseSelection = null;
  }
}
