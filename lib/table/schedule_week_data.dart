import 'package:btl_nhom2/table/teaching_schedule.dart';

// 1. Model cho một ngày trong thanh chọn tuần
class WeekDate {
  final String dayName;   // "T2"
  final String dayNumber; // "20"
  final String fullDate;  // "2025-10-20" (dùng làm key)
  final String fullDateString; // "Thứ 2, Ngày 20/10/2025"

  WeekDate({
    required this.dayName,
    required this.dayNumber,
    required this.fullDate,
    required this.fullDateString,
  });

  factory WeekDate.fromJson(Map<String, dynamic> json) {
    return WeekDate(
      dayName: json['day_name'] ?? '',
      dayNumber: json['day_number'] ?? '',
      fullDate: json['full_date'] ?? '',
      fullDateString: json['full_date_string'] ?? '',
    );
  }
}

// 2. Model cho dữ liệu view "Hôm nay"
class ScheduleToday {
  final String dayNumber;
  final String fullDateString;
  final List<TeachingSchedule> schedules;

  ScheduleToday({
    required this.dayNumber,
    required this.fullDateString,
    required this.schedules,
  });

  factory ScheduleToday.fromJson(Map<String, dynamic> json) {
    final scheduleList = (json['schedules'] as List<dynamic>? ?? [])
        .map((item) => TeachingSchedule.fromJson(item))
        .toList();

    return ScheduleToday(
      dayNumber: json['day_number'] ?? '',
      fullDateString: json['full_date_string'] ?? '',
      schedules: scheduleList,
    );
  }
}

// 3. Model cho dữ liệu view "Tuần này"
class ScheduleWeek {
  final List<WeekDate> dates; // List 7 ngày
  final int todayIndex; // Index của ngày hôm nay
  // Map<String, List<TeachingSchedule>>
  // Ví dụ: { "2025-10-20": [ ... ], "2025-10-21": [ ... ] }
  final Map<String, List<TeachingSchedule>> schedulesByDate;

  ScheduleWeek({
    required this.dates,
    required this.todayIndex,
    required this.schedulesByDate,
  });

  factory ScheduleWeek.fromJson(Map<String, dynamic> json) {
    final dateList = (json['dates'] as List<dynamic>? ?? [])
        .map((item) => WeekDate.fromJson(item))
        .toList();

    // Parse map schedules
    final schedulesMapRaw = json['schedules_by_date'] as Map<String, dynamic>? ?? {};
    final Map<String, List<TeachingSchedule>> schedulesMap = {};
    schedulesMapRaw.forEach((dateKey, scheduleListRaw) {
      final scheduleList = (scheduleListRaw as List<dynamic>? ?? [])
          .map((item) => TeachingSchedule.fromJson(item))
          .toList();
      schedulesMap[dateKey] = scheduleList;
    });

    return ScheduleWeek(
      dates: dateList,
      todayIndex: json['today_index'] ?? 0,
      schedulesByDate: schedulesMap,
    );
  }
}

// 4. Model tổng hợp cho toàn bộ API response
class ScheduleWeekData {
  final ScheduleToday todayData;
  final ScheduleWeek weekData;

  ScheduleWeekData({required this.todayData, required this.weekData});

  factory ScheduleWeekData.fromJson(Map<String, dynamic> json) {
    return ScheduleWeekData(
      todayData: ScheduleToday.fromJson(json['today'] ?? {}),
      weekData: ScheduleWeek.fromJson(json['week'] ?? {}),
    );
  }
}