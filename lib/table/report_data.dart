// lib/models/report_data.dart

// Matches the 'details' array items from backend's formatSchedulesForReport
// Reusing TeachingSchedule might work if backend adjusts keys, but this is safer.
class ReportDetailItem {
  final int id;
  final String dateString; // e.g., "12/9"
  // final String time; // <<< SỬA: Xóa trường "time" không dùng đến và không có trong JSON
  final String lessons; // e.g., "1-3"
  final String title; // Subject name
  final String courseCode; // Class code e.g., "(20CT1)"
  final String location;
  final String status;
  final String students; // e.g., "45/50" (Placeholder from backend)
  final String attendance; // e.g., "90%" (Placeholder from backend)

  ReportDetailItem({
    required this.id,
    required this.dateString,
    // required this.time, // <<< SỬA: Xóa khỏi constructor
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
      id: json['id'] ?? 0, // Backend (hiện tại) không gửi, sẽ là 0
      dateString: json['dateString'] ?? 'N/A', // <<< SỬA: Sửa key thành 'dateString'
      // time: json['time'] ?? '', // <<< SỬA: Xóa
      lessons: json['lessons'] ?? '', // Backend gửi 'lessons' (đã đúng)
      title: json['title'] ?? '',
      courseCode: json['courseCode'] ?? '', // <<< SỬA: Sửa key thành 'courseCode'
      location: json['location'] ?? '',
      status: json['status'] ?? '', // Backend (hiện tại) không gửi, sẽ là ''
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
      // <<< SỬA: Đảm bảo khớp với key JSON từ backend (đã đúng) >>>
      totalSessions: json['totalSessions'] ?? 0,
      absencesCount: json['absencesCount'] ?? 0,
      makeupsCount: json['makeupsCount'] ?? 0,
      attendanceRate: (json['attendanceRate'] ?? 0.0).toDouble(),
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
    final chartList = (json['chartData'] as List<dynamic>? ?? []) // <<< SỬA: 'chartData'
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