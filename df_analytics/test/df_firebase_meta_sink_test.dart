import 'package:df_analytics/df_analytics.dart';
import 'package:df_analytics_core/df_analytics_core.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DfMetaEvent names', () {
    test('mobile uses the SDK standard names, not the Pixel names', () {
      expect(
        DfMetaEvent.completeRegistration.appEventName,
        'fb_mobile_complete_registration',
      );
      expect(DfMetaEvent.purchase.appEventName, 'fb_mobile_purchase');
      expect(DfMetaEvent.contact.appEventName, 'Contact');
      expect(DfMetaEvent.subscribe.appEventName, 'Subscribe');
    });

    test('the Pixel keeps its own names', () {
      expect(DfMetaEvent.completeRegistration.wireName, 'CompleteRegistration');
      expect(DfMetaEvent.lead.wireName, 'Lead');
    });
  });

  group('DfFirebaseMetaSink', () {
    late _FakeFirebase firebase;
    late List<String> meta;

    DfFirebaseMetaSink sink({
      Map<String, DfMetaConversion> conversions = const {},
      bool sendUserId = false,
    }) => DfFirebaseMetaSink(
      metaConversions: conversions,
      sendUserId: sendUserId,
      firebase: firebase,
      reportMeta: (event, {contentType, registrationMethod}) =>
          meta.add('${event.name}|$contentType|$registrationMethod'),
    );

    setUp(() {
      firebase = _FakeFirebase();
      meta = [];
    });

    test('every event reaches Firebase; unmapped ones never reach Meta', () {
      sink().track(DfEvents.tutorialComplete, {'skipped': 1});

      expect(firebase.events, ['tutorial_complete {skipped: 1}']);
      expect(meta, isEmpty);
    });

    test('sign_up is CompleteRegistration by default, with its method', () {
      sink().track(DfEvents.signUp, {DfEventParams.method: 'google'});

      expect(firebase.events, ['sign_up {method: google}']);
      expect(meta, ['completeRegistration|null|google']);
    });

    test('app conversions are added on top of the defaults', () {
      final s = sink(
        conversions: {
          'diary_entry_created': const DfMetaConversion(
            DfMetaEvent.lead,
            contentType: 'diary_entry',
          ),
        },
      );
      s.track('diary_entry_created', {DfEventParams.method: 'ignored'});
      s.track(DfEvents.signUp, {});

      expect(meta, ['lead|diary_entry|null', 'completeRegistration|null|null']);
    });

    test('screen views go to Firebase only', () {
      sink().screenView('home_today');
      expect(firebase.screens, ['home_today']);
      expect(meta, isEmpty);
    });

    test('the user id is only sent when enabled', () {
      sink().identify('uid-1');
      expect(firebase.userIds, isEmpty);

      sink(sendUserId: true)
        ..identify('uid-1')
        ..identify(null);
      expect(firebase.userIds, ['uid-1', null]);
    });

    test('a failing Firebase call does not throw', () async {
      firebase.fail = true;
      expect(() => sink().track('anything', {}), returnsNormally);
      await Future<void>.delayed(Duration.zero);
    });
  });
}

class _FakeFirebase implements DfFirebaseCalls {
  final events = <String>[];
  final screens = <String>[];
  final userIds = <String?>[];
  bool fail = false;

  Future<void> _result() =>
      fail ? Future.error(StateError('offline')) : Future.value();

  @override
  Future<void> logEvent(String name, Map<String, Object> parameters) {
    events.add('$name $parameters');
    return _result();
  }

  @override
  Future<void> logScreenView(String screenName, String? screenClass) {
    screens.add(screenName);
    return _result();
  }

  @override
  Future<void> setUserId(String? id) {
    userIds.add(id);
    return _result();
  }
}
