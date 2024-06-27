import 'package:flutter_gemini/flutter_gemini.dart';

class Constants {
  static const String model = "gemini-1.5-flash";
  static Gemini azure = Gemini.instance;
  static Gemini azureInit = Gemini.init(apiKey: 'AIzaSyBeqN6UNeJxjSFt6yI56QQH8SdCxSSE0_c');
}
