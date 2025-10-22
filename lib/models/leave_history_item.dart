class LeaveHistoryItem {
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
    // 👇 THÊM CÁC TRƯỜNG CÒN LẠI VÀO CONSTRUCTOR
    required this.dateString,
    required this.timeRange,
    required this.lessonPeriod,
    required this.subjectName,
    required this.courseCode,
    required this.location,
    // 👆 KẾT THÚC THÊM
    required this.leaveStatus,
    required this.reason,
  });

  factory LeaveHistoryItem.fromJson(Map<String, dynamic> json) {
    return LeaveHistoryItem(
      leaveRequestId: json['leave_request_id'] ?? 0,
      scheduleId: json['schedule_id'] ?? 0,
      // 👇 PARSE CÁC TRƯỜNG CÒN LẠI TỪ JSON
      dateString: json['date_string'] ?? 'N/A',
      timeRange: json['time_range'] ?? '',
      lessonPeriod: json['lesson_period'] ?? '',
      subjectName: json['subject_name'] ?? '',
      courseCode: json['course_code'] ?? '', // Đảm bảo key khớp với JSON backend
      location: json['location'] ?? '',
      // 👆 KẾT THÚC PARSE
      leaveStatus: json['leave_status'] ?? 'N/A',
      reason: json['reason'] ?? '',
    );
  }
}