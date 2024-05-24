import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_markdown/flutter_markdown.dart';

class RecommendationScreen extends StatefulWidget {
  const RecommendationScreen({super.key});

  @override
  _RecommendationScreenState createState() => _RecommendationScreenState();
}

class _RecommendationScreenState extends State<RecommendationScreen> {
  String recommendation = '';
  String displayedText = '';
  late bool loading = false;
  Timer? _timer;
  int _currentIndex = 0;

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
      displayedText = '';
      _currentIndex = 0;
      _timer?.cancel();
    });
    try {
      final gemini = Gemini.instance;
      final prompt = _generatePrompt(tasks);

      final value = await gemini.text(prompt);
      setState(() {
        recommendation = value?.output ?? 'No recommendation available';
        loading = false;
      });
      _startTextAnimation();
    } catch (e) {
      setState(() {
        recommendation = 'Error: $e';
        loading = false;
      });
    }
  }

  void _startTextAnimation() {
    _timer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
      if (_currentIndex < recommendation.length) {
        setState(() {
          displayedText += recommendation[_currentIndex];
          _currentIndex++;
        });
      } else {
        timer.cancel();
      }
    });
  }

  String _generatePrompt(Map<String, dynamic> tasks) {
    double maxVal = 0;
    String taskName = "";
    String projectName = "";
    String taskType = "";
    double totalIPUConsumed = 0;
    for (Map<String, dynamic> task in tasks.values) {
      if (task["Metered Value"] > maxVal) {
        maxVal = task["Metered Value"];
        taskName = task["Task Name"];
        projectName = task["Project Name"];
        taskType = task["Task Type"];
      }
      totalIPUConsumed += task["IPU Consumed"];
    }
    return "Here IPU means Informatica Processing Unit. Answer in a small paragraph of perfectly 5 lines : Task Specific Details - The task that consumed the most IPU: $taskName, The type of task: $taskType, It belongs to the project: $projectName. Org Specific Details - The total IPU consumption for the org in the next month is expected to be between x and y, where x and y are some values close to $totalIPUConsumed, based on the assumption that the IPU consumption pattern remains consistent.";
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
  void dispose() {
    _timer?.cancel();
    super.dispose();
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
                : Flexible(
                    child: Card(
                      elevation: 4,
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: MarkdownBody(
                          data: displayedText,
                          styleSheet: MarkdownStyleSheet(
                            p: const TextStyle(fontSize: 16),
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
