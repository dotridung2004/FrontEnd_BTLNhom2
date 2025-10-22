class LeaveMakeupSummary {
  final int leaveCount;
  final int pendingMakeupCount;

  LeaveMakeupSummary({required this.leaveCount, required this.pendingMakeupCount});

  factory LeaveMakeupSummary.fromJson(Map<String, dynamic> json) {
    return LeaveMakeupSummary(
      leaveCount: json['leave_count'] ?? 0,
      pendingMakeupCount: json['pending_makeup_count'] ?? 0,
    );
  }
}