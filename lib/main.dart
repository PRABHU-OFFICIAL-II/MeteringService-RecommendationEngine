import 'package:flutter/material.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:recommendation_engine_ipu/display_data.dart';
import 'package:recommendation_engine_ipu/login.dart';
// import 'package:recommendation_engine_ipu/recommendation_screen.dart';

void main() {
  Gemini.init(apiKey: 'AIzaSyBeqN6UNeJxjSFt6yI56QQH8SdCxSSE0_c');
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const Scaffold(body: LoginPage()),
      // body: UploadReportScreen(),
    );
  }
}
