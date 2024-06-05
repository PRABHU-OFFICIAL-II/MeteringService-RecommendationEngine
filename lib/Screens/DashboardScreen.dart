import 'package:flutter/material.dart';
import 'package:recommendation_engine_ipu/Helpers/Constants.dart';
import 'package:recommendation_engine_ipu/Helpers/CustomWidgets.dart';
import 'package:recommendation_engine_ipu/Helpers/ServiceReportIpuHelper.dart';
import 'package:recommendation_engine_ipu/Model/User.dart';
import 'package:recommendation_engine_ipu/Screens/ExportSumaryIpuUsage.dart';

class DashBoardScreen extends StatefulWidget {
  const DashBoardScreen({super.key, required this.currentUser});

  final User currentUser;

  @override
  State<DashBoardScreen> createState() => _DashBoardScreenState();
}

class _DashBoardScreenState extends State<DashBoardScreen> {
  IPUREPRORTVIEW ipureprortview = IPUREPRORTVIEW.NOTHING;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomWidgets.CustomAppBar("IPU Insight"),
      body: Column(children: [
        Container(
          height: 15,
        ),
        CustomWidgets.UserTile("User Name", widget.currentUser.name.toString()),
        CustomWidgets.UserTile("Org ID", widget.currentUser.orgUuid.toString()),
        CustomWidgets.UserTile(
            "Registered Email", widget.currentUser.emails.toString()),
        SizedBox(
          height: 15,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Spacer(),
            TextButton(
              style: TextButton.styleFrom(
                  foregroundColor: Colors.orangeAccent,
                  backgroundColor: Colors.blueGrey),
              onPressed: () {
                ipureprortview = IPUREPRORTVIEW.EXPORT_SUMMARY_IPU_USAGE;
                print("CLICKED EXPORT SUMMARY USAGE");
                setState(() {});
              },
              child: Text("Export Summary IPU Usage"),
            ),
            Spacer(),
            TextButton(
              style: TextButton.styleFrom(
                  foregroundColor: Colors.orangeAccent,
                  backgroundColor: Colors.blueGrey),
              onPressed: () {
                ipureprortview = IPUREPRORTVIEW
                    .EXPORT_JOB_LEVEL_IPU_USAGE_FOR_PARTICULAR_SERVICE;

                ServiceRepportIpuHelper.invokeJob(widget.currentUser);
                setState(() {});
              },
              child:
                  Text("Export Job Level IPU Usage for a Particular Service"),
            ),
            Spacer(),
          ],
        ),
        ipureprortview ==
                IPUREPRORTVIEW.EXPORT_JOB_LEVEL_IPU_USAGE_FOR_PARTICULAR_SERVICE
            ? Container()
            : ipureprortview == IPUREPRORTVIEW.EXPORT_SUMMARY_IPU_USAGE
                ? ExportSummaryIPUUsage(
                    currentSessiion: widget.currentUser,
                  )
                : Container()
      ]),
    );
  }
}
