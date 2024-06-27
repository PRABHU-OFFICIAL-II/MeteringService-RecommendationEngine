import 'package:flutter/material.dart';
import 'package:recommendation_engine_ipu/data/constants.dart';
import 'package:recommendation_engine_ipu/screens/login.dart';
// import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() {
  // await dotenv.load(fileName: "api_key.env");
  Constants.azureInit;
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Flutter Demo',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        // home: const Scaffold(body: RecommendationScreen()),
        home: const Scaffold(body: Login()));
  }
}
