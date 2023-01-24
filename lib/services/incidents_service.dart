import 'package:http/http.dart' as http;
import 'package:road_alert/services/auth_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/incident_model.dart';
import '../models/incident_note_model.dart';

class IncidentsService {
  final String _functionUrl;
  final AuthService _authService;
  final _supabase = Supabase.instance.client;

  IncidentsService(AuthService authService, {required String functionUrl})
      : _functionUrl = functionUrl,
        _authService = authService;

  Future<http.StreamedResponse> createIncident(
      String description,
      String address,
      double latitude,
      double longitude,
      String photoPath) async {
    if (!_authService.isSignedIn) {
      throw Exception("Not signed in!");
    }
    var uri = Uri.parse(_functionUrl);
    var request = http.MultipartRequest('POST', uri)
      ..fields['description'] = description
      ..fields['address'] = address
      ..fields['latitude'] = latitude.toString()
      ..fields['longitude'] = longitude.toString()
      ..headers['Authorization'] = 'Bearer ${_authService.userAccessToken}'
      ..files.add(
        await http.MultipartFile.fromPath(
          'image',
          photoPath,
          filename: photoPath.substring(photoPath.lastIndexOf('/') + 1),
        ),
      );

    return await request.send();
  }

  Future<List<Incident>> getIncidents() async {
    var data = await _supabase.from('incidents').select() as List<dynamic>;
    return List<Incident>.from(
        data.map((incident) => Incident.fromJson(incident)));
  }

  String getPublicUrlForPath(String path) {
    return _supabase.storage.from('incident-images').getPublicUrl(path);
  }

  void completeIncident(Incident incident) async {
    await _supabase
        .from('incidents')
        .update({'complete': true}).eq('id', incident.id);
  }

  Future<List<IncidentNote>> getNotesForIncident(Incident incident) async {
    var data = await _supabase
        .from('incident_notes_view')
        .select()
        .eq('incident_id', incident.id) as List<dynamic>;
    return List<IncidentNote>.from(
        data.map((note) => IncidentNote.fromJson(note)));
  }
}
