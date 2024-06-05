import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:recommendation_engine_ipu/Helpers/CustomWidgets.dart';
import 'package:recommendation_engine_ipu/Screens/LoginScreen.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return  Scaffold
      (
        appBar: CustomWidgets.CustomAppBar("IPU Insight"),



     body: LoginScreen(),
    );

  }
}
