import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'models/grocery_list_model.dart';
import 'screens/main_tabs.dart';

void main() => runApp(const MyApp());

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final GroceryListModel model = GroceryListModel();
  ThemeMode _themeMode = ThemeMode.light;

  static const _themePrefKey = 'app_theme_mode_v1';

  @override
  void initState() {
    super.initState();
    model.addListener(() => setState(() {}));
    model.loadFromPrefs();
    _loadTheme();
  }

  @override
  void dispose() {
    model.dispose();
    super.dispose();
  }

  Future<void> _loadTheme() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final v = prefs.getString(_themePrefKey);
      setState(() {
        _themeMode = switch (v) {
          'dark' => ThemeMode.dark,
          'light' => ThemeMode.light,
          'system' => ThemeMode.system,
          _ => ThemeMode.light,
        };
      });
    } catch (_) {
      // ignore
    }
  }

  Future<void> _setThemeMode(ThemeMode mode) async {
    setState(() => _themeMode = mode);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_themePrefKey, switch (mode) {
        ThemeMode.dark => 'dark',
        ThemeMode.system => 'system',
        _ => 'light',
      });
    } catch (_) {
      // ignore
    }
  }

  ThemeData _buildLightTheme() {
    const primary = Color(0xFF5A7D6C);
    const surface = Color(0xFFF5EDE3);
    const surface2 = Color(0xFFEDE3D6);
    final scheme = ColorScheme.fromSeed(
      seedColor: primary,
      brightness: Brightness.light,
      surface: surface,
    );
    return ThemeData(
      colorScheme: scheme,
      scaffoldBackgroundColor: surface,
      appBarTheme: const AppBarTheme(
        backgroundColor: surface,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      chipTheme: const ChipThemeData(backgroundColor: surface2),
      useMaterial3: true,
    );
  }

  ThemeData _buildDarkTheme() {
    final scheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF7FB8A8),
      brightness: Brightness.dark,
    );
    return ThemeData(
      colorScheme: scheme,
      scaffoldBackgroundColor: const Color(0xFF111315),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF111315),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      useMaterial3: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: _buildLightTheme(),
      darkTheme: _buildDarkTheme(),
      themeMode: _themeMode,
      home: MainTabs(
        model: model,
        themeMode: _themeMode,
        onThemeModeChanged: _setThemeMode,
      ),
    );
  }
}
