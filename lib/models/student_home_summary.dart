import 'student_schedule_item.dart';

class StudentHomeSummary {
  final int todaySessions;
  final int weekSessions;
  final double attendanceRate;
  final List<StudentScheduleItem> schedules;

  StudentHomeSummary({
    required this.todaySessions,
    required this.weekSessions,
    required this.attendanceRate,
    required this.schedules,
  });

  factory StudentHomeSummary.fromJson(Map<String, dynamic> json) {
    final summaryData = json['summary'] as Map<String, dynamic>? ?? {};
    final scheduleListData = json['today_schedules'] as List<dynamic>? ?? [];

    final scheduleList = scheduleListData
        .map((item) => StudentScheduleItem.fromJson(item))
        .toList();

    return StudentHomeSummary(
      todaySessions: summaryData['today_sessions'] ?? 0,
      weekSessions: summaryData['week_sessions'] ?? 0,
      attendanceRate: (summaryData['attendance_rate'] ?? 0.0).toDouble(),
      schedules: scheduleList,
    );
  }
}