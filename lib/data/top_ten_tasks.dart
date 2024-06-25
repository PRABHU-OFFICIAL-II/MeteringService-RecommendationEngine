import 'package:flutter/material.dart';
import 'package:pie_chart/pie_chart.dart';

class TopTenTasks extends StatefulWidget {
  final List<Task> tasks;

  const TopTenTasks({super.key, required this.tasks});

  @override
  State<TopTenTasks> createState() => _TopTenTasksState();
}

class _TopTenTasksState extends State<TopTenTasks> {
  int? selectedTaskIndex;

  @override
  Widget build(BuildContext context) {
    Map<String, double> data = {};
    for (var task in widget.tasks) {
      String taskName = "${task.taskName} [${task.projectName}]";
      double duration =
          task.endTime.difference(task.startTime).inSeconds.toDouble();
      if (data.containsKey(taskName)) {
        data[taskName] = data[taskName]! + duration;
      } else {
        data[taskName] = duration;
      }
    }

    // Sort tasks by total time in descending order
    List<MapEntry<String, double>> sortedTasks = data.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    // Select top 10 time-consuming tasks
    if (sortedTasks.length > 10) {
      sortedTasks = sortedTasks.sublist(0, 10);
    }

    // Prepare data for the pie chart
    Map<String, double> pieChartData = {};
    for (var entry in sortedTasks) {
      pieChartData[entry.key] = entry.value;
    }

    return SizedBox(
      height: 280,
      child: PieChart(
        dataMap: pieChartData,
        animationDuration: const Duration(milliseconds: 800),
        chartLegendSpacing: 40,
        chartRadius: MediaQuery.of(context).size.width / 2.7,
        chartValuesOptions: const ChartValuesOptions(
          showChartValuesInPercentage: true,
          showChartValuesOutside: true,
        ),
        chartType: ChartType.ring,
      ),
    );
  }
}

class Task {
  final int taskId;
  final DateTime startTime;
  final DateTime endTime;
  final String taskName;
  final String projectName;

  Task(
      {required this.taskId,
      required this.startTime,
      required this.endTime,
      required this.taskName,
      required this.projectName});

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
        taskId: json['Task Run ID'],
        startTime: DateTime.parse(json['Start Time']),
        endTime: DateTime.parse(json['End Time']),
        taskName: json['Task Name'],
        projectName: json['Project Name']);
  }
}
