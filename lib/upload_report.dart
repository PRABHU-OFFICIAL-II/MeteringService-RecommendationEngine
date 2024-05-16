import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:csv/csv.dart';
import 'package:recommendation_engine_ipu/display_data.dart';

class UploadReportScreen extends StatefulWidget {
  const UploadReportScreen({super.key});

  @override
  _UploadReportScreenState createState() => _UploadReportScreenState();
}

class _UploadReportScreenState extends State<UploadReportScreen> {
  late List<List<dynamic>> csvData = [
    ["Detailed CSV Report"]
  ];
  bool isLoading = false; // Track loading state

  Future<void> _loadCSV() async {
    setState(() {
      isLoading = true; // Set loading state to true
    });
    try {
      // Open file picker to select CSV file
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv'],
      );

      if (result != null && result.files.isNotEmpty) {
        File file = File(result.files.single.path as String);
        String csvString = await file.readAsString();
        List<List<dynamic>> data =
            const CsvToListConverter().convert(csvString);
        setState(() {
          csvData = data;
        });
        _validatedDialog();
      } else {
        // No file selected
        print('No file selected');
      }
    } catch (e) {
      print('Error loading CSV file: $e');
      _inValidatedDialog();
    } finally {
      setState(() {
        isLoading = false; // Set loading state to false after loading completes
      });
    }
  }

  Future<void> _validatedDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Data Validation'),
          content: const SingleChildScrollView(
              child: Text("Data Validated Successfully")),
          actions: <Widget>[
            TextButton(
              child: const Text('Done'),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const DisplayData()));
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _inValidatedDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Data Validation'),
          content: const SingleChildScrollView(
              child: Text("Data Validation Failed")),
          actions: <Widget>[
            TextButton(
              child: const Text('Retry'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('IPU Audit Report'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: _loadCSV,
              child: const Text('Upload Audit Report'),
            ),
            const SizedBox(height: 20),
            // Show circular loading indicator while loading
            if (isLoading)
              const CircularProgressIndicator()
            else
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      columns: csvData[0]
                          .map((header) =>
                              DataColumn(label: Text(header.toString())))
                          .toList(),
                      rows: csvData.sublist(1).map((row) {
                        return DataRow(
                            cells: row.map((cell) {
                          return DataCell(Text(cell.toString()));
                        }).toList());
                      }).toList(),
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
