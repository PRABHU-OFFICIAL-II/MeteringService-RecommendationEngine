import 'package:flutter/material.dart';
import 'package:pie_chart/pie_chart.dart';
import 'package:recommendation_engine_ipu/data/top_ten_tasks.dart';

class ProjectLevelTasks extends StatefulWidget {
  final List<Task> tasks;

  const ProjectLevelTasks({super.key, required this.tasks});

  @override
  State<ProjectLevelTasks> createState() => _ProjectLevelTasks();
}

class _ProjectLevelTasks extends State<ProjectLevelTasks> {
  @override
  Widget build(BuildContext context) {
    Map<String, int> projectTaskCount = {};

    // Count tasks per project
    for (var task in widget.tasks) {
      if (projectTaskCount.containsKey(task.projectName)) {
        projectTaskCount[task.projectName] =
            projectTaskCount[task.projectName]! + 1;
      } else {
        projectTaskCount[task.projectName] = 1;
      }
    }

    // Sort projects by task count in descending order
    List<MapEntry<String, int>> sortedProjects = projectTaskCount.entries
        .toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    // Select top 10 projects by task count
    if (sortedProjects.length > 10) {
      sortedProjects = sortedProjects.sublist(0, 10);
    }

    // Prepare data for the pie chart
    Map<String, double> pieChartData = {};
    for (var entry in sortedProjects) {
      pieChartData[entry.key] = entry.value.toDouble();
    }

    return SizedBox(
      height: 200,
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
