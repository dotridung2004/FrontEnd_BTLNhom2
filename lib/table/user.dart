class User {
  final int id;
  final String name;
  final String firstName;
  final String lastName;
  final String email;
  final DateTime? emailVerifiedAt;
  final String? password; // Cho phép password là null
  final String? phoneNumber; // Cho phép null
  final String? avatarUrl; // Cho phép null
  final String? gender; // Cho phép null
  final DateTime? dateOfBirth;
  final String role;
  final String status;

  User({
    required this.id,
    required this.name,
    required this.firstName,
    required this.lastName,
    required this.email,
    this.emailVerifiedAt,
    this.password, // không còn 'required'
    this.phoneNumber, // không còn 'required'
    this.avatarUrl, // không còn 'required'
    this.gender, // không còn 'required'
    this.dateOfBirth,
    required this.role,
    required this.status,
  });

  /// 🧭 Chuyển từ JSON → Object (dùng khi gọi API)
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      email: json['email'] ?? '',
      emailVerifiedAt: json['email_verified_at'] != null
          ? DateTime.tryParse(json['email_verified_at'])
          : null,
      password: json['password'], // Chấp nhận giá trị null từ API
      phoneNumber: json['phone_number'], // Chấp nhận giá trị null từ API
      avatarUrl: json['avatar_url'], // Chấp nhận giá trị null từ API
      gender: json['gender'], // Chấp nhận giá trị null từ API
      dateOfBirth: json['date_of_birth'] != null
          ? DateTime.tryParse(json['date_of_birth'])
          : null,
      role: json['role'] ?? '',
      status: json['status'] ?? '',
    );
  }

  /// 🔁 Chuyển từ Object → JSON (dùng khi gửi dữ liệu lên API)
  Map<String, dynamic> toJson() {
    return {
      // ❌ Không gửi 'id'
      'name': name,
      'first_name': firstName,
      'last_name': lastName,
      'email': email,
      // ❌ Không gửi 'email_verified_at'
      // Chỉ gửi password nếu nó được cung cấp (ví dụ: khi tạo/đổi mật khẩu)
      if (password != null) 'password': password,
      'phone_number': phoneNumber,
      'avatar_url': avatarUrl,
      'gender': gender,
      'date_of_birth': dateOfBirth != null
          ? dateOfBirth!.toIso8601String().split('T')[0]
          : null,
      'role': role,
      'status': status,
    };
  }

  /// 🧑‍💻 Factory khởi tạo user rỗng
  factory User.empty() {
    return User(
      id: 0,
      name: '',
      firstName: '',
      lastName: '',
      email: '',
      emailVerifiedAt: null,
      password: null,
      phoneNumber: null,
      avatarUrl: null,
      gender: null,
      dateOfBirth: null,
      role: '',
      status: '',
    );
  }
}