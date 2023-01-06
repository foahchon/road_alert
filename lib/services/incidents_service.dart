import 'package:http/http.dart' as http;
import 'package:road_alert/services/auth_service.dart';

class IncidentsService {
  final String _functionUrl;
  final AuthService _authService;

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
}
