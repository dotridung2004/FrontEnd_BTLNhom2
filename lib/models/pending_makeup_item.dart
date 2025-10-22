class PendingMakeupItem {
  final int leaveRequestId;
  final int scheduleId;
  final String dateString;
  final String timeRange;
  final String lessonPeriod;
  final String subjectName;
  final String courseCode;
  final String location;

  PendingMakeupItem({
    required this.leaveRequestId,
    required this.scheduleId,
    required this.dateString,
    required this.timeRange,
    required this.lessonPeriod,
    required this.subjectName,
    required this.courseCode,
    required this.location,
  });

  factory PendingMakeupItem.fromJson(Map<String, dynamic> json) {
    return PendingMakeupItem(
      leaveRequestId: json['leave_request_id'] ?? 0,
      scheduleId: json['schedule_id'] ?? 0,
      dateString: json['date_string'] ?? 'N/A',
      timeRange: json['time_range'] ?? '',
      lessonPeriod: json['lesson_period'] ?? '',
      subjectName: json['subject_name'] ?? '',
      courseCode: json['course_code'] ?? '',
      location: json['location'] ?? '',
    );
  }
}