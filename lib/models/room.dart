// file: lib/models/room.dart

class Room {
  final int id;
  final String name;

  Room({
    required this.id,
    required this.name,
  });

  /// Hàm factory để parse JSON từ API.
  /// Giả sử API trả về đối tượng có key là 'id' và 'name'.
  /// Ví dụ: { "id": 101, "name": "Phòng A1-101" }
  factory Room.fromJson(Map<String, dynamic> json) {
    return Room(
      id: json['id'],
      name: json['name'],
    );
  }
}