# df_app_shell

Adaptive navigation shell and preference-backed theme/locale controllers for [DataFortress.cloud](https://datafortress.cloud/) apps.

Part of Layer 3 (L3) in the `df_flutter_shared` architecture. Depends only on lower layers (`df_theme`).

---

## What's included

- **DfNavShell** — Responsive navigation shell switching between a bottom `NavigationBar` (compact screens) and `NavigationRail` (tablets / desktop) at a customizable breakpoint.
- **DfNavDestination** — Destination descriptor with icon, selected icon, badge, and tooltip support.
- **DfThemeModeController** & **dfThemeModeProvider** — Preference-backed `Notifier<ThemeMode>` persisting `ThemeMode.system`, `light`, or `dark` to `SharedPreferences`.
- **DfLocaleController** & **dfLocaleProvider** — Preference-backed `Notifier<Locale?>` persisting selected app language or `null` for system default.
- **sharedPreferencesProvider** — Riverpod provider for injecting `SharedPreferences`.
- **DfAppShellStrings** — Localizable strings with English defaults and `.de()` constructor.

---

## Usage

### 1. Initialize SharedPreferences

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
      ],
      child: const MainApp(),
    ),
  );
}
```

### 2. Theme & Locale Controller

```dart
class MainApp extends ConsumerWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(dfThemeModeProvider);
    final locale = ref.watch(dfLocaleProvider);

    return MaterialApp(
      theme: DfTheme.light(brand),
      darkTheme: DfTheme.dark(brand),
      themeMode: themeMode,
      locale: locale,
      home: const HomeScreen(),
    );
  }
}
```

### 3. Adaptive Navigation Shell

```dart
DfNavShell(
  currentIndex: selectedIndex,
  onDestinationSelected: (index) => setState(() => selectedIndex = index),
  destinations: const [
    DfNavDestination(
      icon: Icon(Icons.home_outlined),
      selectedIcon: Icon(Icons.home),
      label: 'Home',
    ),
    DfNavDestination(
      icon: Icon(Icons.settings_outlined),
      selectedIcon: Icon(Icons.settings),
      label: 'Settings',
    ),
  ],
  body: currentBodyWidget,
)
```
