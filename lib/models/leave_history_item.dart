class LeaveHistoryItem {
  // Tương tự PendingMakeupItem nhưng thêm status và reason
  final int leaveRequestId;
  final int scheduleId;
  final String dateString;
  final String timeRange;
  final String lessonPeriod;
  final String subjectName;
  final String courseCode;
  final String location;
  final String leaveStatus; // 'pending', 'approved', 'rejected'
  final String reason;

  LeaveHistoryItem({
    required this.leaveRequestId,
    required this.scheduleId,
    // ... các trường khác ...
    required this.leaveStatus,
    required this.reason,
  });

  factory LeaveHistoryItem.fromJson(Map<String, dynamic> json) {
    return LeaveHistoryItem(
      leaveRequestId: json['leave_request_id'] ?? 0,
      scheduleId: json['schedule_id'] ?? 0,
      // ... parse các trường khác ...
      leaveStatus: json['leave_status'] ?? 'N/A',
      reason: json['reason'] ?? '',
    );
  }
}