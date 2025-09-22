import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/course_provider.dart';
import 'providers/settings_provider.dart';
import 'screens/dashboard_screen.dart';

void main() {
  runApp(const StudyFlowApp());
}

class StudyFlowApp extends StatelessWidget {
  const StudyFlowApp({super.key});

  ThemeData _buildTheme(SettingsProvider settings, Brightness brightness) {
    final bool isDark = brightness == Brightness.dark;
    final baseColorScheme = ColorScheme.fromSeed(
      seedColor: Colors.blue,
      brightness: brightness,
    );

    final colorScheme = settings.highContrast
        ? _buildHighContrastColorScheme(baseColorScheme, isDark)
        : baseColorScheme;

    return ThemeData(
      colorScheme: colorScheme,
      brightness: brightness,
      useMaterial3: true,
      textTheme: _buildTextTheme(settings.textSizeScale, brightness),
      appBarTheme: AppBarTheme(
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 1,
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: TextStyle(
          color: colorScheme.onSurface,
          fontSize: 22,
          fontWeight: FontWeight.w600,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: colorScheme.outline,
            width: settings.highContrast ? 2 : 1,
          ),
        ),
        filled: true,
        fillColor: isDark ? colorScheme.surface : Colors.grey.shade50,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(48, 48), // Larger tap targets
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          minimumSize: const Size(48, 48), // Larger tap targets
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          minimumSize: const Size(48, 48), // Larger tap targets
        ),
      ),
      listTileTheme: ListTileThemeData(
        minVerticalPadding: 12, // Larger tap targets
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        tileColor: Colors.transparent,
        selectedTileColor: colorScheme.primaryContainer.withOpacity(0.3),
        textColor: colorScheme.onSurface,
        iconColor: colorScheme.onSurface.withOpacity(0.7),
      ),
      tabBarTheme: TabBarThemeData(
        indicatorSize: TabBarIndicatorSize.label,
        labelStyle: const TextStyle(fontWeight: FontWeight.w600),
        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: colorScheme.surface,
        labelStyle: TextStyle(
          color: colorScheme.onSurfaceVariant,
          fontWeight: FontWeight.w500,
        ),
        side: BorderSide(
          color: colorScheme.outline.withOpacity(0.3),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: colorScheme.primary,
        linearTrackColor: colorScheme.surfaceVariant,
      ),
      dividerTheme: DividerThemeData(
        color: colorScheme.outline.withOpacity(0.2),
        thickness: 1,
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: colorScheme.surface,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        textStyle: TextStyle(
          color: colorScheme.onSurface,
        ),
      ),
    );
  }

  ColorScheme _buildHighContrastColorScheme(ColorScheme base, bool isDark) {
    if (isDark) {
      return base.copyWith(
        surface: Colors.black,
        onSurface: Colors.white,
        primary: Colors.blue.shade300,
        secondary: Colors.green.shade300,
        outline: Colors.white,
      );
    } else {
      return base.copyWith(
        surface: Colors.white,
        onSurface: Colors.black,
        primary: Colors.blue.shade800,
        secondary: Colors.green.shade800,
        outline: Colors.black,
      );
    }
  }

  TextTheme _buildTextTheme(double scale, Brightness brightness) {
    final baseTheme = brightness == Brightness.dark
        ? Typography.whiteCupertino
        : Typography.blackCupertino;

    return baseTheme.copyWith(
      displayLarge: baseTheme.displayLarge?.copyWith(fontSize: 57 * scale),
      displayMedium: baseTheme.displayMedium?.copyWith(fontSize: 45 * scale),
      displaySmall: baseTheme.displaySmall?.copyWith(fontSize: 36 * scale),
      headlineLarge: baseTheme.headlineLarge?.copyWith(fontSize: 32 * scale),
      headlineMedium: baseTheme.headlineMedium?.copyWith(fontSize: 28 * scale),
      headlineSmall: baseTheme.headlineSmall?.copyWith(fontSize: 24 * scale),
      titleLarge: baseTheme.titleLarge?.copyWith(fontSize: 22 * scale),
      titleMedium: baseTheme.titleMedium?.copyWith(fontSize: 16 * scale),
      titleSmall: baseTheme.titleSmall?.copyWith(fontSize: 14 * scale),
      bodyLarge: baseTheme.bodyLarge?.copyWith(fontSize: 16 * scale),
      bodyMedium: baseTheme.bodyMedium?.copyWith(fontSize: 14 * scale),
      bodySmall: baseTheme.bodySmall?.copyWith(fontSize: 12 * scale),
      labelLarge: baseTheme.labelLarge?.copyWith(fontSize: 14 * scale),
      labelMedium: baseTheme.labelMedium?.copyWith(fontSize: 12 * scale),
      labelSmall: baseTheme.labelSmall?.copyWith(fontSize: 11 * scale),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => CourseProvider()),
        ChangeNotifierProvider(create: (context) => SettingsProvider()..loadSettings()),
      ],
      child: Consumer<SettingsProvider>(
        builder: (context, settings, child) {
          return MaterialApp(
        title: 'StudyFlow',
        debugShowCheckedModeBanner: false,
        theme: _buildTheme(settings, Brightness.light),
        darkTheme: _buildTheme(settings, Brightness.dark),
        themeMode: settings.isDarkMode ? ThemeMode.dark : ThemeMode.light,
            home: const DashboardScreen(),
          );
        },
      ),
    );
  }
}
