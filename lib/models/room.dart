// file: lib/models/room.dart

class Room {
  final int id;
  final String name;
  final String? building; // Tòa nhà (ví dụ: 'K1') - Có thể null
  final int? floor; // Tầng (ví dụ: 2) - Có thể null
  final int? capacity; // Sức chứa - Có thể null
  final String? roomType; // Loại phòng (ví dụ: 'Lí thuyết') - Có thể null
  final String status; // Trạng thái (ví dụ: 'Hoạt động')

  Room({
    required this.id,
    required this.name,
    this.building,
    this.floor,
    this.capacity,
    this.roomType,
    required this.status,
  });

  /// Hàm factory để parse JSON từ API.
  /// Khớp với cấu trúc bảng 'rooms' trong file migration mới.
  factory Room.fromJson(Map<String, dynamic> json) {
    return Room(
      id: json['id'] ?? 0,
      name: json['name'] ?? 'Phòng không xác định',

      // Các trường nullable
      building: json['building'] as String?,
      floor: json['floor'] as int?,
      capacity: json['capacity'] as int?,
      roomType: json['room_type'] as String?, // Khớp với key 'room_type'

      // Trường status có giá trị mặc định (trong DB là 'Hoạt động')
      status: json['status'] ?? 'Hoạt động',
    );
  }
}