import 'package:df_ui_widgets/df_ui_widgets.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SpeechTextController', () {
    test(
      'insertion preserves surrounding text and cursor across streaming updates',
      () {
        final textController = TextEditingController(text: 'Hello world');
        textController.selection = const TextSelection.collapsed(offset: 5);

        final speechController = SpeechTextController(textController);
        speechController.captureBaseState();

        // First streaming hypothesis: " beautiful"
        speechController.updateWithSpeech(' beautiful');
        expect(textController.text, 'Hello beautiful world');
        expect(textController.selection.baseOffset, 15);
        expect(textController.selection.extentOffset, 15);

        // Second streaming hypothesis replaces the previous hypothesis, preserving surrounding text
        speechController.updateWithSpeech(' amazing');
        expect(textController.text, 'Hello amazing world');
        expect(textController.selection.baseOffset, 13);
        expect(textController.selection.extentOffset, 13);

        // Reset locks in text and updates base state
        speechController.reset();
        textController.selection = const TextSelection.collapsed(offset: 19);
        speechController.captureBaseState();
        speechController.updateWithSpeech('!');
        expect(textController.text, 'Hello amazing world!');
        expect(textController.selection.baseOffset, 20);
      },
    );

    test(
      'handles invalid selection, empty input, and implicit base capture',
      () {
        final textController = TextEditingController(text: 'Prefix');
        textController.selection = const TextSelection.collapsed(offset: -1);

        final speechController = SpeechTextController(textController);

        // Empty speech does not alter text
        speechController.updateWithSpeech('');
        expect(textController.text, 'Prefix');

        // Invalid selection falls back to appending at the end
        speechController.updateWithSpeech(' suffix');
        expect(textController.text, 'Prefix suffix');
        expect(textController.selection.baseOffset, 13);
      },
    );
  });
}
