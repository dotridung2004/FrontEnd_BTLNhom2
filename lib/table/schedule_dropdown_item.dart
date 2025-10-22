// lib/models/schedule_dropdown_item.dart
class ScheduleDropdownItem {
  final int scheduleId;
  final String displayName;

  ScheduleDropdownItem({required this.scheduleId, required this.displayName});

  factory ScheduleDropdownItem.fromJson(Map<String, dynamic> json) {
    return ScheduleDropdownItem(
      scheduleId: json['schedule_id'] ?? 0,
      displayName: json['display_name'] ?? 'N/A',
    );
  }
}