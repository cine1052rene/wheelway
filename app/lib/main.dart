import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'theme/app_scroll_behavior.dart';
import 'screens/home_shell.dart';

void main() {
  runApp(const WheelwayApp());
}

class WheelwayApp extends StatelessWidget {
  const WheelwayApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WheelWay',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: ThemeMode.system,
      scrollBehavior: AppScrollBehavior(),
      home: const HomeShell(),
    );
  }
}
