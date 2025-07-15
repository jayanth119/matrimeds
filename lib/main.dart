import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:matrimeds/pages/splash_screen.dart';

void main() async{
    WidgetsFlutterBinding.ensureInitialized();
    await EasyLocalization.ensureInitialized();
    runApp(
    EasyLocalization(
            supportedLocales: const  [
        Locale('en', 'US'),  // English
        Locale('hi', 'IN'),  // Hindi
        Locale('te', 'IN'),  // Telugu
      ], 
      path: 'assets/translations', 
      fallbackLocale: const  Locale('en', 'US'),
      child: const  MyApp()
    ),
  );
    
} 

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Matrimeds',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Roboto',
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      home: const SplashScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}