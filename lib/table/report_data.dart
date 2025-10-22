// lib/models/report_data.dart

// Matches the 'details' array items from backend's formatSchedulesForReport
// Reusing TeachingSchedule might work if backend adjusts keys, but this is safer.
class ReportDetailItem {
  final int id;
  final String dateString; // e.g., "12/9"
  final String time; // e.g., "Tiết 1-3"
  final String lessons; // e.g., "Tiết 1-3"
  final String title; // Subject name
  final String courseCode; // Class code e.g., "(20CT1)"
  final String location;
  final String status;
  final String students; // e.g., "45/50" (Placeholder from backend)
  final String attendance; // e.g., "90%" (Placeholder from backend)

  ReportDetailItem({
    required this.id,
    required this.dateString,
    required this.time,
    required this.lessons,
    required this.title,
    required this.courseCode,
    required this.location,
    required this.status,
    required this.students,
    required this.attendance,
  });

  factory ReportDetailItem.fromJson(Map<String, dynamic> json) {
    return ReportDetailItem(
      id: json['id'] ?? 0,
      dateString: json['date_string'] ?? 'N/A',
      time: json['time'] ?? '', // Match backend key
      lessons: json['lessons'] ?? '',
      title: json['title'] ?? '',
      courseCode: json['course_code'] ?? '', // Match backend key
      location: json['location'] ?? '',
      status: json['status'] ?? '',
      students: json['students'] ?? 'N/A',
      attendance: json['attendance'] ?? 'N/A',
    );
  }
}

// Matches the 'summary' object
class ReportSummary {
  final int totalSessions; // Renamed from totalHours
  final int absencesCount;
  final int makeupsCount;
  final double attendanceRate;

  ReportSummary({
    required this.totalSessions,
    required this.absencesCount,
    required this.makeupsCount,
    required this.attendanceRate,
  });

  factory ReportSummary.fromJson(Map<String, dynamic> json) {
    return ReportSummary(
      totalSessions: json['total_sessions'] ?? 0,
      absencesCount: json['absences_count'] ?? 0,
      makeupsCount: json['makeups_count'] ?? 0,
      attendanceRate: (json['attendance_rate'] ?? 0.0).toDouble(),
    );
  }
}

// Matches the 'chart_data' array items
class ChartDataItem {
  final String label;
  final num value; // Use num to accept int or double

  ChartDataItem({required this.label, required this.value});

  factory ChartDataItem.fromJson(Map<String, dynamic> json) {
    return ChartDataItem(
      label: json['label'] ?? '',
      value: json['value'] ?? 0,
    );
  }
}

// Main class for the entire API response
class ReportData {
  final ReportSummary summary;
  final List<ChartDataItem> chartData;
  final List<ReportDetailItem> details;

  ReportData({
    required this.summary,
    required this.chartData,
    required this.details,
  });

  factory ReportData.fromJson(Map<String, dynamic> json) {
    final summaryData = ReportSummary.fromJson(json['summary'] ?? {});
    final chartList = (json['chart_data'] as List<dynamic>? ?? [])
        .map((item) => ChartDataItem.fromJson(item))
        .toList();
    final detailList = (json['details'] as List<dynamic>? ?? [])
        .map((item) => ReportDetailItem.fromJson(item))
        .toList();

    return ReportData(
      summary: summaryData,
      chartData: chartList,
      details: detailList,
    );
  }
}