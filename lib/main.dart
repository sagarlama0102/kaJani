import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:kajani/app/app.dart';
import 'package:kajani/core/services/hive/hive_service.dart';
import 'package:kajani/core/services/storage/user_session_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );
  await Firebase.initializeApp();
  await GoogleSignIn.instance.initialize(
    serverClientId: '387828142161-425pd0emp6tr17qpq6osqo8pj2rf834t.apps.googleusercontent.com'
  );
  await HiveService().init();

    final sharedPrefs = await SharedPreferences.getInstance();
  runApp( ProviderScope(
    overrides: [
      sharedPreferencesProvider.overrideWithValue(sharedPrefs)
    ],
    child: App()));
}
