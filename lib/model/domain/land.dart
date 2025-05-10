// model/domain/land.dart
import 'package:pim_project/main.dart';
import 'package:pim_project/model/domain/user.dart';

class Land {
  final String id;
  final String name;
  final String cordonate;
  final bool forRent;
  final double surface;
  final String image;
  final List<String> regions;
  final double rentPrice;
  final String ownerPhone;
  final String userId; // ID of the user who owns this land
  final User? owner; // Optional full user object

  Land({
    required this.id,
    required this.name,
    required this.cordonate,
    required this.forRent,
    required this.surface,
    required this.image,
    required this.regions,
    required this.rentPrice,
    this.ownerPhone = '',
    required this.userId,
    this.owner,
  });

  factory Land.fromJson(Map<String, dynamic> json) {
    try {
      // Handle user field - it could be a string ID or a full user object
      String userId = '';
      String phoneNumber = '';
      User? owner;

      if (json['user'] != null) {
        if (json['user'] is String) {
          // If user is just an ID string
          userId = json['user'];
        } else if (json['user'] is Map) {
          // If user is a full object
          final userJson = json['user'] as Map<String, dynamic>;
          userId = userJson['_id'] ?? '';
          owner = User.fromJson(userJson);
          phoneNumber = owner.phonenumber;
        }
      }

      return Land(
        id: json['_id'] ?? '',
        name: json['name'] ?? '',
        cordonate: json['cordonate'] ?? '',
        forRent: json['forRent'] ?? false,
        surface: (json['surface'] as num?)?.toDouble() ?? 0.0,
        image: json['image'] ?? '',
        regions: (json['regions'] as List<dynamic>? ?? [])
            .map((r) => r.toString())
            .toList(),
        rentPrice: (json['rentPrice'] as num?)?.toDouble() ?? 0.0,
        ownerPhone: phoneNumber,
        userId: userId,
        owner: owner,
      );
    } catch (e, stack) {
      print('Error parsing Land: $e\n$stack');
      throw FormatException('Invalid land data');
    }
  }

  Map<String, String> toMap() {
    return {
      'name': name,
      'cordonate': cordonate,
      'surface': surface.toString(),
      'forRent': forRent.toString(),
      'user': userId.isNotEmpty ? userId : MyApp.userId,
      'rentPrice': rentPrice.toString(),
      'ownerPhone': ownerPhone,
    };
  }

  Land copyWith({
    String? id,
    String? name,
    String? cordonate,
    bool? forRent,
    double? surface,
    String? image,
    List<String>? regions,
    double? rentPrice,
    String? ownerPhone,
    String? userId,
    User? owner,
  }) {
    return Land(
      id: id ?? this.id,
      name: name ?? this.name,
      cordonate: cordonate ?? this.cordonate,
      forRent: forRent ?? this.forRent,
      surface: surface ?? this.surface,
      image: image ?? this.image,
      regions: regions ?? this.regions,
      rentPrice: rentPrice ?? this.rentPrice,
      ownerPhone: ownerPhone ?? this.ownerPhone,
      userId: userId ?? this.userId,
      owner: owner ?? this.owner,
    );
  }

  Map<String, dynamic> toJson() => {
    '_id': id,
    'name': name,
    'cordonate': cordonate,
    'forRent': forRent,
    'surface': surface,
    'image': image,
    'regions': regions,
    'rentPrice': rentPrice,
    'ownerPhone': ownerPhone,
    'user': userId,
  };

  // Get the phone number, either directly or from the owner object
  String getPhoneNumber() {
    if (ownerPhone.isNotEmpty) {
      return ownerPhone;
    } else if (owner != null) {
      // Try the phonenumber field first
      if (owner!.phonenumber.isNotEmpty) {
        return owner!.phonenumber;
      }
      // Fallback to the phone field if needed
      if (owner!.phone.isNotEmpty) {
        return owner!.phone;
      }
    }
    return '';
  }
}