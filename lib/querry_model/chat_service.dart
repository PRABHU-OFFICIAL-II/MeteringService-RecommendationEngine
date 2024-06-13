import 'package:flutter/services.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'message.dart';

class ChatService {
  final GenerativeModel _model;
  late String feedContent = "";

  ChatService(String apiKey)
      : _model = GenerativeModel(
            model: 'gemini-1.5-flash',
            apiKey: apiKey,
            generationConfig: GenerationConfig(maxOutputTokens: 1000));

  Future<Message> sendMessage(String text) async {
    String textContent =
        await rootBundle.loadString('assets/CDI_build_data.txt');
    var chat = _model.startChat(history: [
      Content.model([
        TextPart(
            'Hello, My name is CDI Buddy, I am here to answer all your questions related to Cloud Data Integration for Informatica Intelligent cloud Services 😃, I will never talk anything different from IICS and CDI, please cooperate $textContent')
      ])
    ]);
    var content = Content.text(text);
    var response = await chat.sendMessage(content);
    return Message(response.text!);
  }
}
