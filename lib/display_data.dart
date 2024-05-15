import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

// class Task {
//   late final String taskId;
//   late final String taskName;
//   late final String taskType;
//   late final int taskRunId;
//   late final String projectName;
//   late final String folderName;
//   late final String environmentId;
//   late final String environment;
//   late final double coresUsed;
//   late final String startTime;
//   late final String endTime;
//   late final String status;
//   late final double meteredValue;
//   late final double ipuConsumed;

//   Task({
//     required this.taskId,
//     required this.taskName,
//     required this.taskType,
//     required this.taskRunId,
//     required this.projectName,
//     required this.folderName,
//     required this.environmentId,
//     required this.environment,
//     required this.coresUsed,
//     required this.startTime,
//     required this.endTime,
//     required this.status,
//     required this.meteredValue,
//     required this.ipuConsumed,
//   });

//   factory Task.fromJson(Map<String, dynamic> json) {
//     return Task(
//         taskId: json['taskId'],
//         taskName: json['taskName'],
//         taskType: json['taskType'],
//         taskRunId: json['taskRunId'],
//         projectName: json['projectName'],
//         folderName: json['folderName'],
//         environmentId: json['environmentId'],
//         environment: json['environment'],
//         coresUsed: json['coresUsed'],
//         startTime: json['startTime'],
//         endTime: json['endTime'],
//         status: json['status'],
//         meteredValue: json['meteredValue'],
//         ipuConsumed: json['ipuConsumed']);
//   }
// }

// class Organization {
//   late final String orgId;
//   late final Map<String, Task> tasks;

//   Organization({
//     required this.orgId,
//     required this.tasks,
//   });

//   factory Organization.fromJson(Map<String, dynamic> json) {
//     var tasksMap = json['Tasks'] as Map<String, dynamic>;
//     var tasks = tasksMap
//         .map((taskId, taskJson) => MapEntry(taskId, Task.fromJson(taskJson)));
//     return Organization(orgId: json['Org ID'], tasks: tasks);
//   }
// }

class DisplayData extends StatelessWidget {
  const DisplayData({super.key});

  Future<Map<String, dynamic>> fetchData() async {
    final response = await http.get(Uri.parse(
        'http://127.0.0.1:5000/masterEngine')); // Replace with your API endpoint
    if (response.statusCode == 200) {
      final Map<String, dynamic> organizations = json.decode(response.body);
      //print(organizations);
      return organizations;
    } else {
      throw Exception('Failed to load data');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Underdeveloped Application'),
      ),
      body: Center(
        child: FutureBuilder<Map<String, dynamic>>(
          future: fetchData(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            } else if (snapshot.hasError) {
              return Column(children: [
                const CircularProgressIndicator(),
                Text("Error: ${snapshot.error}")
              ]);
            } else {
              return ListView.builder(
                itemCount: 1,
                itemBuilder: (context, index) {
                  final organization = snapshot.data!;
                  return ExpansionTile(
                    title: Text('Organization ID: ${organization["Org ID"]}'),
                    children: [
                      for (var task in organization['Tasks'].keys)
                        ExpansionTile(
                          title: Text('Task ID: $task'),
                          children: [
                            ListTile(
                              title: Text(
                                  'Task Name: ${organization['Tasks'][task]['Task Name']}'),
                            ),
                            ListTile(
                              title: Text(
                                  'Cores Used: ${organization['Tasks'][task]['Cores Used']}'),
                            ),
                            ListTile(
                              title: Text(
                                  'End Time: ${organization['Tasks'][task]['End Time']}'),
                            ),
                            ListTile(
                              title: Text(
                                  'Environment: ${organization['Tasks'][task]['Environment']}'),
                            ),
                            ListTile(
                              title: Text(
                                  'Environment ID: ${organization['Tasks'][task]['Environment ID']}'),
                            ),
                            ListTile(
                              title: Text(
                                  'Folder Name: ${organization['Tasks'][task]['Folder Name']}'),
                            ),
                            ListTile(
                              title: Text(
                                  'IPU Consumed: ${organization['Tasks'][task]['IPU Consumed']}'),
                            ),
                            ListTile(
                              title: Text(
                                  'Metered Value: ${organization['Tasks'][task]['Metered Value']}'),
                            ),
                            ListTile(
                              title: Text(
                                  'Project Name: ${organization['Tasks'][task]['Project Name']}'),
                            ),
                            ListTile(
                              title: Text(
                                  'Start Time: ${organization['Tasks'][task]['Start Time']}'),
                            ),
                            ListTile(
                              title: Text(
                                  'Status: ${organization['Tasks'][task]['Status']}'),
                            ),
                            ListTile(
                              title: Text(
                                  'Task Run ID: ${organization['Tasks'][task]['Task Run ID']}'),
                            ),
                            ListTile(
                              title: Text(
                                  'Task Type: ${organization['Tasks'][task]['Task Type']}'),
                            ),
                          ],
                        ),
                    ],
                  );
                },
              );
            }
          },
        ),
      ),
    );
  }
}
