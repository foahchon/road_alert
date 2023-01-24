class IncidentNote {
  final int id;
  final String user;
  final String text;

  IncidentNote({this.id = 0, required this.user, required this.text});

  IncidentNote.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        user = json['user'],
        text = json['text'];

  Map<String, dynamic> toJson() => {'id': id, 'user': user, 'text': text};
}
