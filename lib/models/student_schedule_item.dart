// lib/models/student_schedule_item.dart

class StudentScheduleItem {
  final int id;
  final String timeRange;
  final String lessons;
  final String title;
  final String courseCode;
  final String location;
  final String status;
  final String teacherName; // Tên giáo viên

  // 👇 *** BẮT BUỘC THÊM TRƯỜNG NÀY ***
  // Backend phải trả về trường này, ví dụ: "2025-09-18T09:45:00"
  final DateTime scheduleDate;

  StudentScheduleItem({
    required this.id,
    required this.timeRange,
    required this.lessons,
    required this.title,
    required this.courseCode,
    required this.location,
    required this.status,
    required this.teacherName,
    // 👇 *** THÊM VÀO CONSTRUCTOR ***
    required this.scheduleDate,
  });

  factory StudentScheduleItem.fromJson(Map<String, dynamic> json) {
    return StudentScheduleItem(
      id: json['id'] ?? 0,
      timeRange: json['time_range'] ?? '',
      lessons: json['lessons'] ?? '',
      title: json['title'] ?? '',
      courseCode: json['course_code'] ?? '',
      location: json['location'] ?? '',
      status: json['status'] ?? 'Sắp diễn ra',
      teacherName: json['teacher_name'] ?? 'N/A',

      // 👇 *** PARSE TRƯỜNG DATE TỪ BACKEND ***
      // Đảm bảo backend trả về 'schedule_date'
      scheduleDate: json['schedule_date'] != null
          ? DateTime.parse(json['schedule_date'])
          : DateTime.now(), // Fallback (không nên xảy ra)
    );
  }
}