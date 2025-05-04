// model/domain/user.dart
class User {
  final String userId;
  final String email;
  final String fullname;
  final String phonenumber;
  final String password;
  final String address;
  final String role;
  final String phone;
  final String? image;
  final String? token;

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
    this.token,
  });

  // Convert JSON response to User object
  factory User.fromJson(Map<String, dynamic> json) {
    print('👤 [User] Conversion des données JSON:');
    print('   - Données reçues: $json');
    
    final userId = json['_id']?.toString() ?? json['id']?.toString() ?? json['userId']?.toString() ?? '';
    final image = json['image']?.toString();
    final token = json['token']?.toString();
    
    // Extract phone number from either 'phonenumber' or 'phone' field
    final phone = json['phone']?.toString() ?? json['phonenumber']?.toString() ?? '';
    
    print('   - ID extrait: $userId');
    print('   - Phone extrait: $phone');
    print('   - Image extraite: $image');
    print('   - Token extrait: $token');
    
    return User(
      userId: userId,
      fullname: json['fullname']?.toString() ?? json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      phonenumber: phone,
      address: json['address']?.toString() ?? '',
      password: json['password']?.toString() ?? '',
      role: json['role']?.toString() ?? '',
      phone: phone,
      image: image,
      token: token,
    );
  }

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
      'token': token,
    };
  }
}