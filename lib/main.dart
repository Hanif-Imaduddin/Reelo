import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'screens/splash_screen.dart';

/// Injected by CI via --dart-define=APP_VERSION=vX.Y.Z (see release.yml).
const appVersion = String.fromEnvironment('APP_VERSION', defaultValue: 'dev');

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(const ReeloApp());
}

class ReeloApp extends StatelessWidget {
  const ReeloApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Reelo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: Colors.black,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.black,
          elevation: 0,
        ),
      ),
      home: const SplashScreen(),
    );
  }
}
