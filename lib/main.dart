import 'package:flutter/material.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:recommendation_engine_ipu/recommendation_screen.dart';

Future main() async {
  await dotenv.load(fileName: "api_key.env");
  Gemini.init(apiKey: dotenv.env["API_KEY"] ?? "");
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
      home: const Scaffold(body: RecommendationScreen()),
      // body: UploadReportScreen(),
    );
  }
}
