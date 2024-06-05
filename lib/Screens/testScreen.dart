// import 'package:flutter/material.dart';
//
// import '../Helpers/Constants.dart';
// import '../Helpers/CustomWidgets.dart';
// import 'ExportSumaryIpuUsage.dart';
//
// class testScreen extends StatefulWidget {
//   const testScreen({super.key});
//
//   @override
//   State<testScreen> createState() => _testScreenState();
// }
//
// class _testScreenState extends State<testScreen> {
//
//
//   IPUREPRORTVIEW ipureprortview = IPUREPRORTVIEW.NOTHING;
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: CustomWidgets.CustomAppBar("IPU Insight"),
//       body: Column(children: [
//         Container(
//           height: 15,
//         ),
//         CustomWidgets.UserTile("User Name", "Siddhant"),
//         CustomWidgets.UserTile("Org ID", "afadgfdaf54548fdfas"),
//         CustomWidgets.UserTile(
//             "Registered Email", "sidjaiswal@informatica.com"),
//         SizedBox(
//           height: 15,
//         ),
//         Row(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Spacer(),
//             TextButton(
//               style: TextButton.styleFrom(
//                   foregroundColor: Colors.orangeAccent,
//                   backgroundColor: Colors.blueGrey),
//               onPressed: () {
//
//                 ipureprortview = IPUREPRORTVIEW.EXPORT_SUMMARY_IPU_USAGE;
//                 print("CLICKED EXPORT SUMMARY USAGE");
//                 setState(() {
//
//
//
//                 });
//               },
//               child: Text("Export Summary IPU Usage"),
//             ),
//             Spacer(),
//             TextButton(
//               style: TextButton.styleFrom(
//                   foregroundColor: Colors.orangeAccent,
//                   backgroundColor: Colors.blueGrey),
//               onPressed: () {
//                 ipureprortview = IPUREPRORTVIEW.EXPORT_JOB_LEVEL_IPU_USAGE_FOR_PARTICULAR_SERVICE;
//                 setState(() {
//
//                 });
//
//               },
//               child:
//               Text("Export Job Level IPU Usage for a Particular Service"),
//             ),
//             Spacer(),
//
//
//
//           ],
//         ),
//         SizedBox(height: 15,),
//         ipureprortview ==  IPUREPRORTVIEW.EXPORT_JOB_LEVEL_IPU_USAGE_FOR_PARTICULAR_SERVICE ? Container():
//         ipureprortview == IPUREPRORTVIEW.EXPORT_SUMMARY_IPU_USAGE ? ExportSummaryIPUUsage():Container()
//
//       ]),
//     );
//   }
//
//
//
// }
