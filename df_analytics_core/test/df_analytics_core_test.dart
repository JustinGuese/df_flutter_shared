import 'dart:async';

import 'package:df_analytics_core/df_analytics_core.dart';
import 'package:df_analytics_core/testing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late RecordingAnalyticsSink analytics;

  setUp(() => analytics = RecordingAnalyticsSink.install());
  tearDown(DfAnalyticsCore.debugReset);

  group('track', () {
    test('forwards the event with normalised parameters', () {
      DfAnalyticsCore.track(DfEvents.signUp, {
        DfEventParams.method: 'google',
        DfEventParams.skipped: true,
        'count': 3,
        'missing': null,
      });

      expect(analytics.names, [DfEvents.signUp]);
      expect(analytics.events.single.parameters, {
        'method': 'google',
        'skipped': 1,
        'count': 3,
      });
    });

    test('cuts string values to 100 characters', () {
      DfAnalyticsCore.track('long_value', {'text': 'x' * 150});
      expect(analytics.events.single.parameters['text'], 'x' * 100);
    });

    test('keeps at most 25 parameters', () {
      DfAnalyticsCore.track('many', {for (var i = 0; i < 30; i++) 'p$i': i});
      expect(analytics.events.single.parameters, hasLength(25));
    });

    test('a throwing sink does not throw into the caller', () {
      DfAnalyticsCore.sink = _ThrowingSink();
      expect(() => DfAnalyticsCore.track('ok'), returnsNormally);
      expect(() => DfAnalyticsCore.screenView('home'), returnsNormally);
    });

    test('an unwired core drops events without throwing', () {
      DfAnalyticsCore.debugReset();
      expect(DfAnalyticsCore.isWired, isFalse);
      expect(() => DfAnalyticsCore.track('dropped'), returnsNormally);
    });
  });

  group('isValidEventName', () {
    test('accepts GA4-shaped names', () {
      expect(DfAnalyticsCore.isValidEventName('diary_entry_created'), isTrue);
      expect(DfAnalyticsCore.isValidEventName('a' * 40), isTrue);
    });

    test('rejects names GA4 would discard', () {
      expect(DfAnalyticsCore.isValidEventName(''), isFalse);
      expect(DfAnalyticsCore.isValidEventName('a' * 41), isFalse);
      expect(DfAnalyticsCore.isValidEventName('1st_open'), isFalse);
      expect(DfAnalyticsCore.isValidEventName('has-dash'), isFalse);
      expect(DfAnalyticsCore.isValidEventName('firebase_thing'), isFalse);
      expect(DfAnalyticsCore.isValidEventName('ga_thing'), isFalse);
    });
  });

  group('screenView', () {
    test('ignores an immediate repeat of the same screen', () {
      DfAnalyticsCore.screenView('home');
      DfAnalyticsCore.screenView('home');
      DfAnalyticsCore.screenView('login');
      DfAnalyticsCore.screenView('home');
      expect(analytics.screens, ['home', 'login', 'home']);
    });
  });

  test('identify forwards ids and sign-out', () {
    DfAnalyticsCore.identify('uid-1');
    DfAnalyticsCore.identify(null);
    expect(analytics.identities, ['uid-1', null]);
  });

  group('dfNormaliseScreenName', () {
    test('collapses ids and drops the query', () {
      expect(dfNormaliseScreenName('/profiles/42?tab=1'), '/profiles/:id');
      expect(
        dfNormaliseScreenName('/doc/0f8fad5b-d9cb-469f-a165-70867728950e'),
        '/doc/:id',
      );
      expect(dfNormaliseScreenName('/users/AbCdEfGhIjKlMnOp12'), '/users/:id');
      expect(dfNormaliseScreenName('/settings'), '/settings');
      expect(dfNormaliseScreenName('/'), '/');
    });

    test('keeps paths under keepPrefixes verbatim', () {
      expect(
        dfNormaliseScreenName('/learning/1234', keepPrefixes: ['learning']),
        '/learning/1234',
      );
    });

    test('route names are used as is', () {
      expect(
        dfDefaultScreenName(const RouteSettings(name: 'view-entry')),
        'view-entry',
      );
      expect(
        dfDefaultScreenName(const RouteSettings(name: '/entry/7')),
        '/entry/:id',
      );
      expect(dfDefaultScreenName(const RouteSettings()), isNull);
    });
  });

  group('DfScreenObserver', () {
    Future<NavigatorState> pumpApp(
      WidgetTester tester, {
      DfScreenNameExtractor? nameExtractor,
    }) async {
      final key = GlobalKey<NavigatorState>();
      await tester.pumpWidget(
        MaterialApp(
          navigatorKey: key,
          navigatorObservers: [DfScreenObserver(nameExtractor: nameExtractor)],
          initialRoute: 'home',
          onGenerateRoute: (settings) => MaterialPageRoute<void>(
            settings: settings,
            builder: (_) => Text(settings.name ?? ''),
          ),
        ),
      );
      return key.currentState!;
    }

    testWidgets('reports pushes, replaces and the page revealed by a pop', (
      tester,
    ) async {
      final navigator = await pumpApp(tester);

      unawaited(navigator.pushNamed('/entry/12'));
      await tester.pumpAndSettle();
      navigator.pop();
      await tester.pumpAndSettle();
      unawaited(navigator.pushReplacementNamed('login'));
      await tester.pumpAndSettle();

      expect(analytics.screens, ['home', '/entry/:id', 'home', 'login']);
    });

    testWidgets('a removed top route reports the screen underneath', (
      tester,
    ) async {
      // What context.go() does to a pushed page: removed, never popped.
      final navigator = await pumpApp(tester);
      unawaited(navigator.pushNamed('create-entry'));
      await tester.pumpAndSettle();

      navigator.removeRoute(
        ModalRoute.of(tester.element(find.text('create-entry')))!,
      );
      await tester.pumpAndSettle();

      expect(analytics.screens, ['home', 'create-entry', 'home']);
    });

    testWidgets('dialogs are not screens', (tester) async {
      final navigator = await pumpApp(tester);

      unawaited(
        showDialog<void>(
          context: navigator.context,
          builder: (_) => const Text('dialog'),
        ),
      );
      await tester.pumpAndSettle();
      navigator.pop();
      await tester.pumpAndSettle();

      expect(analytics.screens, ['home']);
    });

    testWidgets('a custom extractor can rename or skip routes', (tester) async {
      final navigator = await pumpApp(
        tester,
        nameExtractor: (s) => s.name == 'secret' ? null : 'app_${s.name}',
      );

      unawaited(navigator.pushNamed('secret'));
      await tester.pumpAndSettle();

      expect(analytics.screens, ['app_home']);
    });
  });
}

class _ThrowingSink implements DfAnalyticsSink {
  @override
  void track(String name, Map<String, Object> parameters) =>
      throw StateError('boom');

  @override
  void screenView(String screenName, {String? screenClass}) =>
      throw StateError('boom');

  @override
  void identify(String? userId) => throw StateError('boom');
}
