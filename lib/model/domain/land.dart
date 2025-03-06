class Land {
  final String id;
  final String name;
  String? cordonate;  // You might consider using a more specific type like a LatLng if working with maps.
  bool? forRent;
  double? surface;    
  String? image; 
    String? user;
  Land({
    required this.id,
    required this.name,
    required this.user,
    this.cordonate,
    this.forRent,
    this.surface,
    this.image,
  });

   factory Land.fromJson(Map<String, dynamic> json) {
    return Land(
      id: json['_id'],
      name: json['name'],
      user: json['user']
      //cordonate: json['cordonate'],
      //forRent: json['forRent'],
      //surface: json['surface'].toDouble(),
      //image: json['image'],
    );
  }

Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'user': user,
      'cordonate': cordonate,
      'forRent': forRent,
      'surface': surface,
      'image': image,
    };
  }




  }