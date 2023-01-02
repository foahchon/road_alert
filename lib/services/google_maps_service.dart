import 'package:road_alert/services/api_base_service.dart';

class GoogleMapsService extends ApiBaseService {
  final String _apiKey;

  GoogleMapsService({required String googleMapsUrl, required String apiKey})
      : _apiKey = apiKey,
        super(baseUrl: googleMapsUrl);

  Future<String> getFormattedAddress(double lat, double lng) async {
    String parameters = '/json?latlng=$lat,$lng&key=$_apiKey';
    var result = await super.get(parameters);

    return result['results'][0]['formatted_address'];
  }
}
