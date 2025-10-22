class AvailableSchedule {
  final int scheduleId;
  final String displayName; // e.g., "dd/mm/yyyy - Tiết 1-3 - Môn học (Lớp)"

  AvailableSchedule({required this.scheduleId, required this.displayName});

  factory AvailableSchedule.fromJson(Map<String, dynamic> json) {
    return AvailableSchedule(
      scheduleId: json['schedule_id'] ?? 0,
      displayName: json['display_name'] ?? 'N/A',
    );
  }
}