class Otp {
  String otp;
  DateTime otpExpires;
  String userId;

  // Constructor
  Otp({
    required this.otp,
    required this.otpExpires,
    required this.userId,
  });

  // Factory method to create an OTP object from JSON (for when you receive data from an API)
  factory Otp.fromJson(Map<String, dynamic> json) {
    return Otp(
      otp: json['otp'],
      otpExpires: DateTime.parse(json['otpExpires']),
      userId: json['userId'],
    );
  }

  // Method to convert OTP object to JSON (for when you need to send data to an API)
  Map<String, dynamic> toJson() {
    return {
      'otp': otp,
      'otpExpires': otpExpires.toIso8601String(),
      'userId': userId,
    };
  }
}
