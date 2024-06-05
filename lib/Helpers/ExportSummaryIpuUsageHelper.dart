
import 'dart:typed_data';
import 'dart:io';
import 'package:archive/archive.dart';
import 'package:dio/dio.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../Model/JobResponse.dart';

import '../Model/User.dart';
import 'Constants.dart';

class ExportSummaryIpuUsageHelper
{
    static Future<JobResponse> triggerExportJob(User currentSession, String startDate, String endDate) async{


    startDate =  startDate+"T00:00:00Z";
    endDate = endDate +"T00:00:00Z";

    print("Session id "+currentSession.icSessionId.toString());


    print(currentSession.name);
    print(startDate);
    print(endDate);


    String url = currentSession.serverUrl.toString()+"/"+Constants.Export_AllLinkedOrgReport.toString();


      print(url);
    var response = await http.post(
      Uri.parse(url),
      headers: {
        "Content-Type": "application/json",
        "Accept": "application/json",
        "INFA-SESSION-ID":"${currentSession.icSessionId}",
      },
      body: jsonEncode(
        {
          "startDate": "${startDate}",
          "endDate": "${endDate}",
          "callbackUrl": "https://MyExportJobStatus.com",
        },
      ),
    );
    print(response.body);
    Map<String, dynamic> jsonMap = json.decode(response.body);
    JobResponse job = JobResponse.fromJson(jsonMap);


    // Map<String, dynamic> jsonMap = json.decode(response.body);

      return job;
  }

  static Future<JobResponse> checkJobStatus(User currentSession, JobResponse jobResponse)async
  {
    JobResponse currentStatus = await checkStatus(currentSession, jobResponse);




      bool run = true;
      while(run )
      {

        Future.delayed(Duration(seconds: 5), () async {
          print("RECALL ");
          currentStatus = await checkJobStatus(currentSession, jobResponse);
          });

        if(currentStatus.status !="SUCCESS")
          run = false;
      }


    print("Final Status " + currentStatus.status);




          saveApiResponseAsZip(currentSession, jobResponse);
          return currentStatus;

  }

  //   print("Final Status " + currentStatus.status);
  //
  //
  //
  //
  //
  //
  //
  //
  //   saveApiResponseAsZip(currentSession, jobResponse);
  //
  //
  // }

  static Future<JobResponse> checkStatus (User currentSession, JobResponse jobResponse) async
  {

    String url = currentSession.serverUrl.toString()+"/"+Constants.Check_Job_Status+jobResponse.jobId;
    var response = await http.get(
      Uri.parse(url),
      headers: {
        "Content-Type": "application/json",
        "Accept": "application/json",
        "INFA-SESSION-ID":"${currentSession.icSessionId}",
      },
    );
    print(response.body);
    Map<String, dynamic> jsonMap = json.decode(response.body);
    JobResponse job = JobResponse.fromJson(jsonMap);


    print("JOB IS "+job.status);



    return job;
  }



  static  Future<void> saveApiResponseAsZip(User currentSession, JobResponse jobResponse) async {
      // Replace with your API endpoint
      String apiUrl = currentSession.serverUrl.toString()+"/"+Constants.Check_Job_Status+jobResponse.jobId+"/download";

      print("Download url : "+apiUrl);

      // Replace with your headers
      Map<String, dynamic> headers = {
        'INFA-SESSION-ID': '${currentSession.icSessionId}',
        'Content-Type': 'application/json',
        // Add any other headers as needed
      };

      // Create a Dio instance with headers
      Dio dio = Dio(BaseOptions(headers: headers));

      try {
        // Make the API request
        Response<List<int>> response = await dio.get<List<int>>(apiUrl,
            options: Options(responseType: ResponseType.bytes));

        // Check if the request was successful (status code 200)
        if (response.statusCode == 200) {
          // Convert the response bytes to Uint8List
          Uint8List responseBody = Uint8List.fromList(response.data!);

          // Create an Archive object and add a file entry
          Archive archive = Archive()
            ..addFile(ArchiveFile('response.csv', responseBody.length, responseBody));

          // Create a zip file
          File zipFile = File('response.zip');

          // Write the zip file
          zipFile.writeAsBytesSync( ZipEncoder().encode(archive)! );

          print('Zip file saved at: ${zipFile.path}');
        } else {
          print('Error: ${response.statusCode}');
        }
      } catch (e) {
        print('Error: $e');
      }
    }
}