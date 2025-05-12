class LandRequest {
  final String requestId;
  final String userId;
  final String landId;
  final String userName;
  final String landName;
  final String landLocation;
  final String userImg;
  final String price;

  const LandRequest({
    required this.requestId,
    required this.userId,
    required this.landId,
    required this.userName,
    required this.landName,
    required this.landLocation,
    required this.userImg,
    required this.price,
  });

  factory LandRequest.fromJson(Map<String, dynamic> json) {
    return LandRequest(
      requestId: json['requestId']?.toString() ?? '',
      userId: json['userId']?.toString() ?? '',
      landId: json['landId']?.toString() ?? '',
      userName: json['userName']?.toString() ?? '',
      landName: json['landName']?.toString() ?? '',
      landLocation: json['landLocation']?.toString() ?? '',
      userImg: json['userImg']?.toString() ?? '',
      price: json['price']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'requestId': requestId,
      'userId': userId,
      'landId': landId,
      'userName': userName,
      'landName': landName,
      'landLocation': landLocation,
      'userImg': userImg,
      'price': price,
    };
  }
}
