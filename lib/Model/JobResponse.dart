class JobResponse {
  String jobId;
  String status;
  String orgId;
  String userId;
  String selectedOrgId;
  String? meterId; // Nullable type
  DateTime startDate;
  DateTime endDate;
  String callbackUrl;
  DateTime createTime;
  DateTime updateTime;

  JobResponse({
    required this.jobId,
    required this.status,
    required this.orgId,
    required this.userId,
    required this.selectedOrgId,
    required this.meterId,
    required this.startDate,
    required this.endDate,
    required this.callbackUrl,
    required this.createTime,
    required this.updateTime,
  });

  factory JobResponse.fromJson(Map<String, dynamic> json) {
    return JobResponse(
      jobId: json['jobId'] ?? "",
      status: json['status'] ?? "",
      orgId: json['orgId'] ?? "",
      userId: json['userId'] ?? "",
      selectedOrgId: json['selectedOrgId'] ?? "",
      meterId: json['meterId'],
      startDate: DateTime.parse(json['startDate'] ?? ""),
      endDate: DateTime.parse(json['endDate'] ?? ""),
      callbackUrl: json['callbackUrl'] ?? "",
      createTime: DateTime.parse(json['createTime'] ?? ""),
      updateTime: DateTime.parse(json['updateTime'] ?? ""),
    );
  }
}
