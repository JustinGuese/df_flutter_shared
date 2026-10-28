import 'package:flutter_test/flutter_test.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:df_feedback_prompt/df_feedback_prompt.dart';

class FakeInAppReview implements InAppReview {
  bool available = true;
  int requestReviewCount = 0;

  @override
  Future<bool> isAvailable() async => available;

  @override
  Future<void> requestReview() async {
    requestReviewCount++;
  }

  @override
  Future<void> openStoreListing({
    String? appStoreId,
    String? microsoftStoreId,
  }) async {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('DfStoreReviewPrompt', () {
    const testKey = 'test_review_asked';
    late FakeInAppReview fakeReview;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      fakeReview = FakeInAppReview();
    });

    test('returns false when streak < minStreak', () async {
      final asked = await DfStoreReviewPrompt.maybeAsk(
        streak: 2,
        minStreak: 3,
        prefsKey: testKey,
        inAppReview: fakeReview,
      );
      expect(asked, isFalse);
      expect(fakeReview.requestReviewCount, 0);
    });

    test('requests review when streak >= minStreak and ready', () async {
      final asked = await DfStoreReviewPrompt.maybeAsk(
        streak: 3,
        minStreak: 3,
        prefsKey: testKey,
        inAppReview: fakeReview,
      );
      expect(asked, isTrue);
      expect(fakeReview.requestReviewCount, 1);
    });

    test('respects cooldown after first ask', () async {
      // First ask succeeds
      final first = await DfStoreReviewPrompt.maybeAsk(
        streak: 5,
        minStreak: 3,
        prefsKey: testKey,
        inAppReview: fakeReview,
      );
      expect(first, isTrue);
      expect(fakeReview.requestReviewCount, 1);

      // Immediate second ask is blocked by cooldown
      final second = await DfStoreReviewPrompt.maybeAsk(
        streak: 6,
        minStreak: 3,
        prefsKey: testKey,
        inAppReview: fakeReview,
      );
      expect(second, isFalse);
      expect(fakeReview.requestReviewCount, 1);
    });

    test('does not request review when review is not available', () async {
      fakeReview.available = false;
      final asked = await DfStoreReviewPrompt.maybeAsk(
        streak: 5,
        minStreak: 3,
        prefsKey: testKey,
        inAppReview: fakeReview,
      );
      expect(asked, isFalse);
      expect(fakeReview.requestReviewCount, 0);
    });
  });
}
