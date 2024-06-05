import 'package:flutter/material.dart';
import 'package:recommendation_engine_ipu/Helpers/ExportSummaryIpuUsageHelper.dart';
import 'package:recommendation_engine_ipu/Model/JobResponse.dart';

import '../Model/User.dart';

class ExportSummaryIPUUsage extends StatefulWidget {

  final User currentSessiion;
  const ExportSummaryIPUUsage({super.key, required this.currentSessiion});

  @override
  State<ExportSummaryIPUUsage> createState() => _ExportSummaryIPUUsageState();
}

class _ExportSummaryIPUUsageState extends State<ExportSummaryIPUUsage> {
  String startDate = "";
  String endDate = "";
  final TextEditingController startDateController = TextEditingController();
  final TextEditingController endDateController = TextEditingController();
  late JobResponse jobResponse;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: startDateController,
          decoration: InputDecoration(
            border: UnderlineInputBorder(),
            hintText: "YYYY-MM-DD",
            labelText: "Enter the Start Date",
            // helperText: "Password must contain special character",

            alignLabelWithHint: false,
            filled: true,
          ),
          textInputAction: TextInputAction.done,
        ),
        SizedBox(
          height: 10,
        ),
        TextField(
          controller: endDateController,
          decoration: InputDecoration(
            border: UnderlineInputBorder(),
            hintText: "YYYY-MM-DD",
            labelText: "Enter the End Date",
            alignLabelWithHint: false,
            filled: true,
          ),
          textInputAction: TextInputAction.done,
        ),
        SizedBox(
          height: 15,
        ),
        Center(
            child: TextButton(
              onPressed: () async {
                startDate = startDateController.text;
                endDate = endDateController.text;

                 jobResponse= await ExportSummaryIpuUsageHelper.triggerExportJob(widget.currentSessiion, startDate, endDate);


                   ExportSummaryIpuUsageHelper.checkJobStatus(widget.currentSessiion, jobResponse);




              },
              child: Text("Submit"),
            ))
      ],
    );
  }
}
