class AssetRequest {
  final String requestId;
  final String assetId;
  final String requesterName;
  final String reason;
  final String dateTime;
  String status; // Pending, Approved, Declined

  AssetRequest({
    required this.requestId,
    required this.assetId,
    required this.requesterName,
    required this.reason,
    required this.dateTime,
    this.status = "Pending",
  });

  Map<String, dynamic> toMap() {
    return {
      "requestId": requestId,
      "assetId": assetId,
      "requesterName": requesterName,
      "reason": reason,
      "dateTime": dateTime,
      "status": status,
    };
  }

  factory AssetRequest.fromMap(Map<String, dynamic> map) {
    return AssetRequest(
      requestId: map["requestId"] ?? "",
      assetId: map["assetId"] ?? "",
      requesterName: map["requesterName"] ?? "",
      reason: map["reason"] ?? "",
      dateTime: map["dateTime"] ?? "",
      status: map["status"] ?? "Pending",
    );
  }
}
