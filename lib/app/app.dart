import 'package:flutter/material.dart';
import 'package:kajani/features/splash/presentation/pages/splash_page.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'KAJANI',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.system,
      home: SplashPage(),
    );
  }
}
