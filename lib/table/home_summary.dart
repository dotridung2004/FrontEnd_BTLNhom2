import 'package:btl_nhom2/table/teaching_schedule.dart';

class HomeSummary {
  final int todayLessons;
  final int weekLessons;
  final double completionPercent;
  final List<TeachingSchedule> schedules;

  HomeSummary({
    required this.todayLessons,
    required this.weekLessons,
    required this.completionPercent,
    required this.schedules,
  });

  factory HomeSummary.fromJson(Map<String, dynamic> json) {
    // 1. Lấy dữ liệu summary
    final summaryData = json['summary'] as Map<String, dynamic>? ?? {};

    // 2. Lấy danh sách lịch dạy
    final scheduleListData = json['today_schedules'] as List<dynamic>? ?? [];
    final List<TeachingSchedule> scheduleList = scheduleListData
        .map((item) => TeachingSchedule.fromJson(item))
        .toList();

    return HomeSummary(
      todayLessons: summaryData['today_lessons'] ?? 0,
      weekLessons: summaryData['week_lessons'] ?? 0,
      completionPercent: (summaryData['completion_percent'] ?? 0.0).toDouble(),
      schedules: scheduleList,
    );
  }
}