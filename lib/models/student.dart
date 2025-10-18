enum AttendanceStatus { none, present, absent, late }

class Student {
  final String id;
  final String name;
  AttendanceStatus status;

  Student({
    required this.id,
    required this.name,
    this.status = AttendanceStatus.none,
  });
}