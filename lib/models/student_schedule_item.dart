class StudentScheduleItem {
  final int id;
  final String timeRange;
  final String lessons;
  final String title;
  final String courseCode;
  final String location;
  final String status;
  final String teacherName; // Tên giáo viên

  StudentScheduleItem({
    required this.id,
    required this.timeRange,
    required this.lessons,
    required this.title,
    required this.courseCode,
    required this.location,
    required this.status,
    required this.teacherName,
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
    );
  }
}