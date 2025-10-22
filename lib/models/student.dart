// lib/models/student.dart

// 1. Remove 'none' from the enum
enum AttendanceStatus { present, absent, late }

class Student {
  // 2. Rename 'id' to 'studentId' for consistency with backend/previous code
  final String studentId;
  final String name;
  AttendanceStatus status; // Keep mutable

  Student({
    required this.studentId,
    required this.name,
    // 3. Make status required or default to present (making it required is safer)
    required this.status,
  });

  // 4. Add fromJson factory (adjust keys 'student_id', 'student_name' if your backend differs)
  factory Student.fromJson(Map<String, dynamic> json) {
    AttendanceStatus currentStatus;
    switch (json['status']?.toLowerCase()) {
      case 'absent':
        currentStatus = AttendanceStatus.absent;
        break;
      case 'late':
        currentStatus = AttendanceStatus.late;
        break;
      case 'present':
      default: // Default to present if status is missing, null, or unknown
        currentStatus = AttendanceStatus.present;
        break;
    }

    return Student(
      // Ensure keys match your backend JSON response
      studentId: (json['student_id'] ?? 0).toString(), // Convert to String
      name: json['student_name'] ?? 'Unknown Student',
      status: currentStatus,
    );
  }

  // 5. Add statusString getter for sending data back to API
  String get statusString {
    switch (status) {
      case AttendanceStatus.absent: return 'absent';
      case AttendanceStatus.late: return 'late';
      case AttendanceStatus.present:
      default: return 'present';
    }
  }
}