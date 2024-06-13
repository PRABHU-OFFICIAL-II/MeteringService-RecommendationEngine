// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
// import 'dart:html' as html; // Web-specific import for downloading files
import 'dart:io';
import 'package:archive/archive.dart';
import 'package:path/path.dart' as path;
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:recommendation_engine_ipu/data/display_data.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController startDateController = TextEditingController();
  final TextEditingController endDateController = TextEditingController();
  String jobId = "";
  String serverUrl = "";

  // List of services and their corresponding meter IDs
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
    "Integration Hub": "fqttkiGnSaHeXW255z4IcD"
  };

  // List of PODs and their corresponding meter IDs
  final Map<String, String> pods = {
    // US AWS PODs
    "USW1_AWS_POD1": "https://dm-us.informaticacloud.com",
    "USE2_AWS_POD2": "https://dm-us.informaticacloud.com",
    "USW3_AWS_POD3": "https://dm-us.informaticacloud.com",
    "USE4_AWS_POD4": "https://dm-us.informaticacloud.com",
    "USW5_AWS_POD5": "https://dm-us.informaticacloud.com",
    "USE6_AWS_POD6": "https://dm-us.informaticacloud.com",

    // US AZURE PODs
    "USW1_1_Azure_POD7": "https://dm1-us.informaticacloud.com",
    "USW3_1_Azure_POD8": "https://dm1-us.informaticacloud.com",

    // US GCP PODs
    "USW1_2_GCP_POD9": "https://dm2-us.informaticacloud.com",
    "CAC1_AWS_POD10": "https://dm-na.informaticacloud.com",
    "CAC2_AZURE_POD21": "https://dm1-ca.informaticacloud.com",
    "USE1_ORACLE_POD22": "https://dm3-us.informaticacloud.com",

    // APJ PODs
    "APSE1_AWS_POD14": "https://dm-ap.informaticacloud.com",
    "AP_SOUTHEAST_AZURE": "https://dm1-apse.informaticacloud.com",
    "AP_NORTHEAST_1_AZURE": "https://dm1-ap.informaticacloud.com",
    "AP_NORTHEAST_2": "https://dm-apne.informaticacloud.com",
    "AUSTRALIA": "https://dm1-apau.informaticacloud.com",

    // EMEA PODs
    "EM_WEST_1": "https://dm-em.informaticacloud.com",
    "EM_CENTRAL_1_AZURE": "https://dm1-em.informaticacloud.com",
    "UK": "https://dm-uk.informaticacloud.com",
    "EM_SOUTHEAST_1_AZURE": "https://dm1-em.informaticacloud.com",
    "EM_WEST_2_GCP": "https://dm2-em.informaticacloud.com"
  };

  String selectedService = "Data Integration";
  String selectedPOD = "USW1_AWS_POD1";

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

    // Listen for any errors from the Python process
    // process.stderr.transform(utf8.decoder).listen((data) {
    //   print('Python stderr: $data');
    // });
  }

  Future<void> downloadExportData(
      String serverUrl, String icSessionId, String jobId) async {
    final url =
        '$serverUrl/public/core/v3/license/metering/ExportMeteringData/$jobId/download';
    final headers = {'INFA-SESSION-ID': icSessionId};

    try {
      final response = await http.get(Uri.parse(url), headers: headers);
      if (response.statusCode == 200) {
        // Specific for the dart:io package.
        final File file = File('resources/export_data.zip');
        file.writeAsBytes(response.bodyBytes).asStream();

        // Use html package to create a download link for web
        // final blob = html.Blob([response.bodyBytes]);
        // final url = html.Url.createObjectUrlFromBlob(blob);
        // final anchor = html.AnchorElement(href: url)
        //   ..setAttribute("download", "export_data.zip")
        //   ..click();
        // html.Url.revokeObjectUrl(url);
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
        Navigator.of(context)
            .push(MaterialPageRoute(builder: (context) => const DisplayData()));
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
        jobId = await responseData['jobId'];
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

  Future<void> validateLogin() async {
    final String username = usernameController.text;
    final String password = passwordController.text;
    final String startDate = startDateController.text;
    final String endDate = endDateController.text;

    if (username.isEmpty ||
        password.isEmpty ||
        startDate.isEmpty ||
        endDate.isEmpty) {
      showError(
          'Username or Password or Start Date or end Date cannot be empty');
      return;
    }
    final String loginUrl = pods[selectedPOD]!;
    final url = Uri.parse('$loginUrl/ma/api/v2/user/login');
    final headers = {'Content-Type': 'application/json'};
    final body = jsonEncode({
      "@type": "login",
      "username": username,
      "password": password,
    });

    try {
      showProgressDialog('assets/signUp.png', 'Logging in...');
      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final icSessionId = await responseData['icSessionId'];
        Navigator.of(context).pop();
        showProgressDialog('assets/signUp.png', 'Login successful');
        await Future.delayed(const Duration(seconds: 2));
        serverUrl = responseData['serverUrl'];
        fetchExportData(serverUrl, icSessionId, startDate, endDate);
      } else {
        final errorData = jsonDecode(response.body);
        Navigator.of(context).pop();
        showError(errorData['description'] +
            ' Please contact Informatica Global Customer Support');
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
        controller.text = pickedDate.toLocal().toString().split(' ')[0];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage(
                    'assets/infa_bg.png'), // Ensure you have this image in the assets folder
                fit: BoxFit.cover,
              ),
            ),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.3), // Translucent overlay
              ),
            ),
          ),
          SizedBox(
            height: 700,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: SingleChildScrollView(
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    elevation: 8.0,
                    child: SizedBox(
                      width: 500,
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Image.asset(
                              'assets/informatica.png', // Ensure you have this image in the assets folder
                              height: 100,
                            ),
                            const SizedBox(height: 20),
                            const Text(
                              'Welcome to Informatica',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 20),
                            TextField(
                              controller: usernameController,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12.0),
                                ),
                                labelText: 'Username',
                              ),
                            ),
                            const SizedBox(height: 20),
                            TextField(
                              controller: passwordController,
                              obscureText: true,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12.0),
                                ),
                                labelText: 'Password',
                              ),
                            ),
                            const SizedBox(height: 20),
                            TextFormField(
                              controller: startDateController,
                              readOnly: true,
                              onTap: () =>
                                  selectDate(context, startDateController),
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12.0),
                                ),
                                labelText: 'Start Date (YYYY-MM-DD)',
                              ),
                            ),
                            const SizedBox(height: 20),
                            TextFormField(
                              controller: endDateController,
                              readOnly: true,
                              onTap: () =>
                                  selectDate(context, endDateController),
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12.0),
                                ),
                                labelText: 'End Date (YYYY-MM-DD)',
                              ),
                            ),
                            const SizedBox(height: 20),
                            DropdownButtonFormField<String>(
                              value: selectedService,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12.0),
                                ),
                                labelText: 'Select Service',
                              ),
                              items: services.keys.map((String service) {
                                return DropdownMenuItem<String>(
                                  value: service,
                                  child: Text(service),
                                );
                              }).toList(),
                              onChanged: (String? newValue) {
                                setState(() {
                                  selectedService = newValue!;
                                });
                              },
                            ),
                            const SizedBox(height: 20),
                            DropdownButtonFormField<String>(
                              value: selectedPOD,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12.0),
                                ),
                                labelText: 'Select Pod',
                              ),
                              items: pods.keys.map((String pod) {
                                return DropdownMenuItem<String>(
                                  value: pod,
                                  child: Text(pod),
                                );
                              }).toList(),
                              onChanged: (String? newValue) {
                                setState(() {
                                  selectedPOD = newValue!;
                                });
                              },
                            ),
                            const SizedBox(height: 20),
                            ElevatedButton(
                              onPressed: () {
                                validateLogin();
                              },
                              style: ElevatedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12.0),
                                ),
                                minimumSize: const Size(double.infinity,
                                    50), // Stretch to full width
                              ),
                              child: const Text('Login'),
                            ),
                            const SizedBox(height: 20),
                            const Text(
                              '** This Login is available for Users with Specific Access **',
                              style: TextStyle(
                                  color: Colors.red,
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
