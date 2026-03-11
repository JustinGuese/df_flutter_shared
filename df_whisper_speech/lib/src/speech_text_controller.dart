import 'package:flutter/material.dart';

/// Helper that manages cursor-aware insertion of speech-recognized text
/// into a [TextEditingController].
///
/// The controller captures a "base" snapshot of the text and selection
/// right before speech input starts, then applies streaming updates
/// relative to that snapshot so that:
/// - existing user text is preserved
/// - the cursor position is maintained correctly
/// - repeated updates from the recognizer replace the previous hypothesis
class SpeechTextController {
  SpeechTextController(this._textController);

  final TextEditingController _textController;

  String _baseText = '';
  TextSelection _baseSelection = const TextSelection.collapsed(offset: -1);

  /// Capture the current text and selection state before starting speech.
  void captureBaseState() {
    _baseText = _textController.text;
    _baseSelection = _textController.selection;
  }

  /// Apply a new speech hypothesis to the text field.
  ///
  /// The `recognizedText` should be the full text recognized so far
  /// (not just the diff). It will be inserted starting at the base
  /// selection's base offset.
  void updateWithSpeech(String recognizedText) {
    if (recognizedText.isEmpty) {
      return;
    }

    // Fallback if base selection is not valid.
    final insertionOffset =
        _baseSelection.isValid ? _baseSelection.baseOffset : _baseText.length;

    final safeOffset = insertionOffset.clamp(0, _baseText.length);
    final before = _baseText.substring(0, safeOffset);
    final after = _baseText.substring(safeOffset);

    final newText = '$before$recognizedText$after';

    _textController
      ..text = newText
      ..selection = TextSelection.collapsed(
        offset: (before.length + recognizedText.length),
      );
  }

  /// Reset base state after speech has finished so subsequent edits
  /// behave like normal typing.
  void reset() {
    _baseText = _textController.text;
    _baseSelection = _textController.selection;
  }
}
