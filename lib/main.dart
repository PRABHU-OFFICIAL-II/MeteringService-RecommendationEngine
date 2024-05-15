import 'package:flutter/material.dart';
// import 'package:recommendation_engine_ipu/display_data.dart';
import 'package:recommendation_engine_ipu/upload_report.dart';

void main() {
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
        home: const Scaffold(
          // body: DisplayData()),
          body: UploadReportScreen(),
        ));
  }
}
