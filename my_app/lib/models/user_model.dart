class User {
  final String username;
  final String email;
  final String password;
  final String university;
  final String department;
  final String bloodGroup;
  final String phoneNumber;
  final String profilePicture;
  User({
    required this.username,
    required this.email,
    required this.password,
    this.university = '',
    this.department = '',
    this.bloodGroup = '',
    this.phoneNumber = '',
    this.profilePicture = '',
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      password: '', // Password not returned from backend
      university: json['university'] ?? '',
      department: json['department'] ?? '',
      bloodGroup: json['bloodGroup'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
      profilePicture: json['profilePicture'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'email': email,
      'password': password,
      'university': university,
      'department': department,
      'bloodGroup': bloodGroup,
      'phoneNumber': phoneNumber,
      'profilePicture': profilePicture,
    };
  }
}