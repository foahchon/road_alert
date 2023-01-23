class Incident {
  final int id;
  final String description;
  final String address;
  final String zipCode;
  final double latitude;
  final double longitude;
  final String imagePath;

  Incident(
      {this.id = 0,
      required this.description,
      required this.address,
      required this.zipCode,
      required this.latitude,
      required this.longitude,
      required this.imagePath});

  Incident.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        description = json['description'],
        address = json['address'],
        zipCode = json['zip_code'],
        latitude = json['latitude'],
        longitude = json['longitude'],
        imagePath = json['image_path'];

  Map<String, dynamic> toJson() => {
        'id': id,
        'description': description,
        'address': address,
        'zip_code': zipCode,
        'latitude': latitude,
        'longitude': longitude,
        'image_path': imagePath
      };
}
