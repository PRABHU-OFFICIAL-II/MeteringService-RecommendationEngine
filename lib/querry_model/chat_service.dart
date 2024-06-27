import 'package:flutter/services.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:recommendation_engine_ipu/data/constants.dart';
import 'message.dart';

class ChatService {
  final GenerativeModel _model;
  late String feedContent = "";

  ChatService(String apiKey)
      : _model = GenerativeModel(
            model: Constants.model, // Azure Open AI model
            apiKey: apiKey,
            generationConfig: GenerationConfig(maxOutputTokens: 2000));

  Future<Message> sendMessage(String text) async {
    String textContent =
        await rootBundle.loadString('assets/CDI_build_data.txt');
    var chat = _model.startChat(history: [
      Content.text(
          "Hey your name is Data Integration Assistant and use this data $textContent, to answer the user queries"),
      Content.model([
        TextPart(
            'Hello, My name is Data Integration Assistant, I am here to answer all your questions related to Cloud Data Integration for Informatica Intelligent cloud Services 😃')
      ])
    ]);
    var content = Content.text(text);
    var response = await chat.sendMessage(content);
    return Message(response.text!);
  }
}
