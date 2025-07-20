import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:matrimeds/pages/onboarding_screen.dart';
import 'package:matrimeds/pages/splash_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  runApp(
    EasyLocalization(
        supportedLocales: const [
          Locale('en', 'US'), // English
          Locale('hi', 'IN'), // Hindi
          Locale('te', 'IN'), // Telugu
        ],
        path: 'assets/translations',
        saveLocale: true,
         useOnlyLangCode: false, 
        fallbackLocale: const Locale('en', 'US'),
        child: const MyApp()),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool? isOnboardingCompleted; // null = loading, true = completed, false = not completed

  @override
  void initState() {
    super.initState();
    checkOnboardingStatus(); // Call this to initialize the state
  }

  void checkOnboardingStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool completed = prefs.getBool('onboardingCompleted') ?? false;
    setState(() {
      isOnboardingCompleted = completed;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Show loading screen while checking onboarding status
    if (isOnboardingCompleted == null) {
      return  const  MaterialApp(
        home: Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        ),
      );
    }

    return MaterialApp(
      title: 'Matrimeds',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      // Show OnboardingScreen if not completed, otherwise show SplashScreen
      home: isOnboardingCompleted! ? const SplashScreen() : const OnboardingScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}