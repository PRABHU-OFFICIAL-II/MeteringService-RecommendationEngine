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
      String taskName = task.taskName;
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

    return GestureDetector(
      onTapDown: (TapDownDetails details) {
        // Calculate the tapped index based on the angle
        double tappedAngle = (details.localPosition.dx -
                (MediaQuery.of(context).size.width / 2.7)) /
            (MediaQuery.of(context).size.width / 2.7);
        if (tappedAngle >= -1 && tappedAngle <= 1) {
          selectedTaskIndex =
              ((tappedAngle + 1) / (2 / sortedTasks.length)).floor();
          setState(() {});
        }
      },
      child: PieChart(
        dataMap: pieChartData,
        animationDuration: const Duration(milliseconds: 800),
        chartLegendSpacing: 32,
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

  Task({
    required this.taskId,
    required this.startTime,
    required this.endTime,
    required this.taskName,
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      taskId: json['Task Run ID'],
      startTime: DateTime.parse(json['Start Time']),
      endTime: DateTime.parse(json['End Time']),
      taskName: json['Task Name'],
    );
  }
}
