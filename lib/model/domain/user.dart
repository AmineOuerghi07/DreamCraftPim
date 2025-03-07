class User {
  final String userId;
  final String fullname;
  final String email;
  final String phonenumber;
  final String password;
  final String address;
  final String role;

  User({
    required this.userId,
    required this.fullname,
    required this.email,
    required this.phonenumber,
    required this.address,
    required this.password,
    required this.role,
  });

  // Convert JSON response to User object
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      userId: json['id'] ?? '', 
      fullname: json['fullname'] ?? '',
      email: json['email'] ?? '',
      phonenumber: json['phonenumber'] ?? '',
      address: json['address'] ?? '',
      password: json['password'] ?? '',
      role: json['role'] ?? '',
    );
  }

  get status => null;

  get message => null;

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'fullname': fullname,
      'email': email,
      'phonenumber': phonenumber,
      'address': address,
      'password': password,
      'role': role,
    };
  }

  
}
