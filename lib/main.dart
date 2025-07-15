import 'package:flutter/material.dart';
import 'package:matrimeds/pages/login_screen.dart';
// import 'package:matrimeds/pages/onboarding_screen.dart' ;
import 'package:matrimeds/pages/medi_screen.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const   MedicalAssistantApp() ;
  }
}