class User {
  final String userId;
  final String email;
  final String fullname;
  final String phonenumber;
  final String password;
  final String address;
  final String role;
  final String phone;
  final String? image; // optional image

  User({
    required this.userId,
    required this.email,
    required this.fullname,
    required this.phonenumber,
    required this.address,
    required this.password,
    required this.role,
    required this.phone,
    this.image,
  });

  // Convert JSON response to User object
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      userId: json['_id']?.toString() ?? json['id']?.toString() ?? json['userId']?.toString() ?? '',
      fullname: json['fullname']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      phonenumber: json['phonenumber']?.toString() ?? '',
      address: json['address']?.toString() ?? '',
      password: json['password']?.toString() ?? '',
      role: json['role']?.toString() ?? '',
      phone: json['phonenumber']?.toString() ?? '',
      image: json['image']?.toString(),
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
      'phonenumber': phone,
      'image': image,
    };
  }
}