class IncidentNote {
  final int id;
  final String user;
  final String text;
  DateTime? createdAt;

  IncidentNote({this.id = 0, required this.user, required this.text});

  IncidentNote.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        user = json['user'],
        text = json['text'],
        createdAt = DateTime.parse(json['created_at']);

  Map<String, dynamic> toJson() => {
        'id': id,
        'user': user,
        'text': text,
        'created_at':
            createdAt != null ? createdAt!.toIso8601String() : DateTime.now(),
      };
}
