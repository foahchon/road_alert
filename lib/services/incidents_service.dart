import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class IncidentsService {
  final String _functionUrl;

  IncidentsService({required String functionUrl}) : _functionUrl = functionUrl {
    if (!dotenv.env.containsKey('SUPABASE_URL') ||
        !dotenv.env.containsKey('SUPABASE_ANON_KEY')) {
      throw const AuthException(
          'Supabase URL and Supabase anon key must be present.');
    }

    Supabase.initialize(
      url: dotenv.env['SUPABASE_URL']!,
      anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
    );
  }

  Future<http.StreamedResponse> createIncident(
      String description,
      String address,
      double latitude,
      double longitude,
      String photoPath) async {
    var uri = Uri.parse(_functionUrl);
    var request = http.MultipartRequest('POST', uri)
      ..fields['description'] = description
      ..fields['address'] = address
      ..fields['latitude'] = latitude.toString()
      ..fields['longitude'] = longitude.toString()
      ..files.add(
        await http.MultipartFile.fromPath(
          'image',
          photoPath,
          filename: photoPath.substring(photoPath.lastIndexOf('/') + 1),
        ),
      );

    return await request.send();
  }
}
