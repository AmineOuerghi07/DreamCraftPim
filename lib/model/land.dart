class Land {
  final String id;
  final String name;
  final String cordonate;  // You might consider using a more specific type like a LatLng if working with maps.
  final bool forRent;
  final double surface;    
  final String image;      // URL or asset path for the image.

  Land({
    required this.id,
    required this.name,
    required this.cordonate,
    required this.forRent,
    required this.surface,
    required this.image,
  });
  }