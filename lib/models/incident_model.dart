class Incident {
  int id;
  String description;
  String address;
  String zipCode;
  double latitude;
  double longitude;
  String imagePath;
  String userId;
  String email;
  DateTime? createdAt;
  bool complete;

  Incident(
      {this.id = 0,
      required this.description,
      required this.address,
      required this.zipCode,
      required this.latitude,
      required this.longitude,
      required this.imagePath,
      this.userId = "",
      this.email = "",
      required this.complete});

  Incident.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        description = json['description'],
        address = json['address'],
        zipCode = json['zip_code'],
        latitude = json['latitude'],
        longitude = json['longitude'],
        imagePath = json['image_path'],
        userId = json['user_id'],
        email = json['email'],
        createdAt = DateTime.parse(json['created_at']),
        complete = json['complete'];

  Map<String, dynamic> toJson() => {
        'id': id,
        'description': description,
        'address': address,
        'zip_code': zipCode,
        'latitude': latitude,
        'longitude': longitude,
        'image_path': imagePath,
        'user_id': userId,
        'email': email,
        'created_at':
            createdAt != null ? createdAt!.toIso8601String() : DateTime.now(),
        'complete': complete
      };
}
