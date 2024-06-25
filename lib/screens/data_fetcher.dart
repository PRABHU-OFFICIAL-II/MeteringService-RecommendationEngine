import 'dart:convert';
import 'dart:io';
import 'package:archive/archive.dart';
import 'package:path/path.dart' as path;
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:recommendation_engine_ipu/data/secondary_display_data.dart';

class DataFetcher extends StatefulWidget {
  final String icSessionId;
  final String serverUrl;

  const DataFetcher({
    super.key,
    required this.icSessionId,
    required this.serverUrl,
  });

  @override
  _DataFetcherState createState() => _DataFetcherState();
}

class _DataFetcherState extends State<DataFetcher> {
  final TextEditingController startDateController = TextEditingController();
  final TextEditingController endDateController = TextEditingController();
  String selectedService = "Data Integration";

  final Map<String, String> services = {
    "Data Integration": "a2nB20h1o0lc7k3P9xtWS8",
    "Data Integration with Advanced Serverless": "35m9fB23Tykj4Fb3rN5q2J",
    "Data Integration Elastic": "3TaYTMo6BFYeNIABfVmH0n",
    "Data Integration Elastic with Advanced Serverless":
        "8tXWie0ZQLWlG1cyxxLwQM",
    "Application Integration": "3uIRkIV5Rt9lBbAPzeR5Kj",
    "Application Integration with Advanced Serverless":
        "bN6mes5n4GGciiMkuoDlCz",
    "Mass Ingestion Streaming": "hr7GsCwFFmyfvfZQFn8v81",
    "Mass Ingestion Database": "24WXkCWzeSHjFlQvLPDegF",
    "Mass Ingestion Files": "lCwc4CfL7EEhv9773egFC8",
    "Mass Ingestion Application": "i3H6LcmMIYjhUKa9VCi7CI",
    "Advanced Pushdown Optimization": "dMN0VeTW4cThHyPovp4GEX",
    "Data Integration CDC": "0sDTANKFZBSbqjzKaXKlmB",
    "Mass Ingestion Database CDC": "aluxJ8jOKmzdXwD0JuHRS1",
    "Mass Ingestion Application CDC": "4cPkZ5cZxjzc4SK2RHoqgy",
    "Integration Hub": "fqttkiGnSaHeXW255z4IcD",
  };

  Future<void> showProgressDialog(String assetPath, String message) async {
    return showDialog(
      barrierDismissible: false,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(
                    assetPath,
                    height: 100,
                  ),
                  const SizedBox(height: 20),
                  Text(message),
                ],
              ),
            );
          },
        );
      },
      context: context,
    );
  }

  Future<void> showError(String message) async {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text("Error"),
                const SizedBox(height: 20),
                Text(message),
              ],
            ),
          );
        });
  }

  Future<void> unzipFile(String zipFilePath) async {
    final file = File(zipFilePath);
    final bytes = await file.readAsBytes();

    final archive = ZipDecoder().decodeBytes(bytes);

    for (final file in archive) {
      final fileName = file.name;
      final filePath = path.join(path.dirname(zipFilePath), fileName);

      if (file.isFile) {
        final data = file.content as List<int>;
        final outFile = File(filePath);
        await outFile.create(recursive: true);
        await outFile.writeAsBytes(data);
      } else {
        final dir = Directory(filePath);
        await dir.create(recursive: true);
      }
    }
  }

  Future<void> startMasterEngine() async {
    Process process = await Process.start('python', ['lib/models/main.py']);
    process.stdout.transform(utf8.decoder).listen((data) {
      if (data.contains('Serving Flask app')) {
        print("Master Engine Started");
      }
    });
  }

  Future<void> downloadExportData(
      String serverUrl, String icSessionId, String jobId) async {
    final url =
        '$serverUrl/public/core/v3/license/metering/ExportMeteringData/$jobId/download';
    final headers = {'INFA-SESSION-ID': icSessionId};

    try {
      final response = await http.get(Uri.parse(url), headers: headers);
      if (response.statusCode == 200) {
        final File file = File('resources/export_data.zip');
        file.writeAsBytes(response.bodyBytes).asStream();

        Navigator.of(context).pop();
        showProgressDialog(
            'assets/exportData.png', 'Export data downloaded successfully');
        await Future.delayed(const Duration(seconds: 2));
        Navigator.of(context).pop();
        unzipFile('resources/export_data.zip');
        showProgressDialog(
            'assets/contentExtraction.png', 'Content Extraction Finished');
        await Future.delayed(const Duration(seconds: 2));
        Navigator.of(context).pop();
        startMasterEngine();
        showProgressDialog(
            'assets/masterEngine.png', 'Master Engine Starting Up');
        await Future.delayed(const Duration(seconds: 10));
        Navigator.of(context).pop();
        showProgressDialog(
            'assets/masterEngine.png', 'Master Engine is Up and Running');
        await Future.delayed(const Duration(seconds: 2));
        Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => SecondaryDisplayData(
                  icSessionId: icSessionId,
                  serverUrl: serverUrl,
                )));
      } else {
        Navigator.of(context).pop();
        showError('Failed to download export data');
      }
    } catch (e) {
      Navigator.of(context).pop();
      showError('An error occurred: $e');
    }
  }

  Future<void> fetchExportData(String serverUrl, String icSessionId,
      String startDate, String endDate) async {
    startDate = '${startDate}T00:00:00Z';
    endDate = '${endDate}T00:00:00Z';
    String meterId = services[selectedService]!;

    final url = Uri.parse(
        '$serverUrl/public/core/v3/license/metering/ExportServiceJobLevelMeteringData');
    final headers = {
      'Content-Type': 'application/json',
      'INFA-SESSION-ID': icSessionId,
    };
    final body = jsonEncode({
      "startDate": startDate,
      "endDate": endDate,
      "allMeters": false,
      "meterId": meterId,
      "callbackUrl": "https://MyExportJobStatus.com"
    });

    try {
      final response = await http.post(url, headers: headers, body: body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        final jobId = await responseData['jobId'];
        await Future.delayed(const Duration(seconds: 2));
        Navigator.of(context).pop();
        showProgressDialog('assets/jobId.png', 'Job ID generated successfully');
        await Future.delayed(const Duration(seconds: 2));
        Navigator.of(context).pop();
        showProgressDialog(
            'assets/fetchData.png', 'Request to fetch data started');
        await Future.delayed(const Duration(seconds: 2));
        Navigator.of(context).pop();
        showProgressDialog(
            'assets/extractData.png', 'Data extraction in progress');
        await Future.delayed(const Duration(seconds: 2));
        Navigator.of(context).pop();
        showProgressDialog(
            'assets/downloadData.png', 'Downloading export data');
        await downloadExportData(serverUrl, icSessionId, jobId);
      } else {
        final errorData = jsonDecode(response.body);
        Navigator.of(context).pop();
        showError(errorData['error']['message']);
      }
    } catch (e) {
      Navigator.of(context).pop();
      showError('An error occurred: $e');
    }
  }

  Future<void> selectDate(
      BuildContext context, TextEditingController controller) async {
    DateTime firstDate =
        DateTime.now().subtract(const Duration(days: 180)); // Six months ago
    DateTime lastDate = DateTime.now(); // Current date
    DateTime initialDate = lastDate;

    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
    );

    if (pickedDate != null) {
      setState(() {
        controller.text = pickedDate.toString().split(' ')[0];
      });
    }
  }

  @override
  void dispose() {
    startDateController.dispose();
    endDateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 300,
      width: 500,
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: startDateController,
              readOnly: true,
              onTap: () => selectDate(context, startDateController),
              decoration: InputDecoration(
                labelText: 'Start Date',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                suffixIcon: const Icon(Icons.calendar_today),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: endDateController,
              readOnly: true,
              onTap: () => selectDate(context, endDateController),
              decoration: InputDecoration(
                labelText: 'End Date',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                suffixIcon: const Icon(Icons.calendar_today),
              ),
            ),
            const SizedBox(height: 20),
            DropdownButtonFormField<String>(
              value: selectedService,
              onChanged: (newValue) {
                setState(() {
                  selectedService = newValue!;
                });
              },
              decoration: InputDecoration(
                labelText: 'Select Service',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              items: services.keys.map((String service) {
                return DropdownMenuItem<String>(
                  value: service,
                  child: Text(service),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: () async {
                  if (startDateController.text.isEmpty ||
                      endDateController.text.isEmpty) {
                    showError("Please select both start and end dates.");
                  } else {
                    showProgressDialog('assets/fetchData.png', 'Fetching data');
                    await fetchExportData(
                      widget.serverUrl,
                      widget.icSessionId,
                      startDateController.text,
                      endDateController.text,
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                child: const Text("Fetch Data"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
