class TeachingSchedule {
  final int id;
  final String time; // "7:00 - 9:40"
  final String lessons; // "Tiết 1-3"
  final String title;
  final String courseCode;
  final String location;
  final String status; // "Đang diễn ra", "Sắp diễn ra", "Đã kết thúc"

  TeachingSchedule({
    required this.id,
    required this.time,
    required this.lessons,
    required this.title,
    required this.courseCode,
    required this.location,
    required this.status,
  });

  factory TeachingSchedule.fromJson(Map<String, dynamic> json) {
    return TeachingSchedule(
      id: json['id'] ?? 0,
      time: json['time_range'] ?? '', // Khớp với key 'time_range' của API
      lessons: json['lessons'] ?? '',
      title: json['title'] ?? '',
      courseCode: json['course_code'] ?? '', // Khớp với 'course_code'
      location: json['location'] ?? '',
      status: json['status'] ?? 'Scheduled',
    );
  }
}