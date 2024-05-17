import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class RecommendationScreen extends StatefulWidget {
  const RecommendationScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _RecommendationScreenState createState() => _RecommendationScreenState();
}

class _RecommendationScreenState extends State<RecommendationScreen> {
  String recommendation = '';
  late bool loading = false;

  Future<Map<String, dynamic>> fetchData() async {
    final response = await http.get(Uri.parse(
        'http://127.0.0.1:5000/masterEngine')); // Replace with your API endpoint
    if (response.statusCode == 200) {
      final Map<String, dynamic> organizations = json.decode(response.body);
      return organizations;
    } else {
      throw Exception('Failed to load data');
    }
  }

  Future<void> generateIPURecommendation(Map<String, dynamic> tasks) async {
    setState(() {
      loading = true;
    });
    try {
      final gemini = Gemini.instance;
      final prompt = _generatePrompt(tasks);

      final value = await gemini.text(prompt);
      setState(() {
        recommendation = value?.output ?? 'No recommendation available';
      });
    } catch (e) {
      setState(() {
        recommendation = 'Error: $e';
      });
    } finally {
      setState(() {
        loading = false;
      });
    }
  }

  String _generatePrompt(Map<String, dynamic> tasks) {
    return "Answer me in 5 lines, Which task has consumed the most IPU, what type of task it is, Whose task it is, What is the total current consumption of IPU in the Org and What might be the expected IPU consumption of the org in the next month get an average value for that: $tasks";
  }

  Future<void> fetchRecommendation() async {
    try {
      final tasks = await fetchData();
      generateIPURecommendation(tasks['Tasks']);
    } catch (e) {
      print('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                fetchRecommendation();
              },
              child: const Text('Generate IPU Recommendation'),
            ),
            const SizedBox(height: 20),
            loading
                ? const CircularProgressIndicator()
                : Expanded(
                    child: SingleChildScrollView(
                      child: Card(
                        elevation: 4,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text(
                            recommendation,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
