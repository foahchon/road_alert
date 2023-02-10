import 'package:road_alert/services/api_base_service.dart';

class GoogleMapsService extends ApiBaseService {
  final String _apiKey;

  GoogleMapsService({required String googleMapsUrl, required String apiKey})
      : _apiKey = apiKey,
        super(baseUrl: googleMapsUrl);

  Future<GoogleMapServiceResult> getAddress(double lat, double lng) async {
    String parameters = '/json?latlng=$lat,$lng&key=$_apiKey';
    var result = await super.get(parameters);
    var addressComponents = result['results'][0]['address_components'];

    return GoogleMapServiceResult(
      streetAddress:
          "${addressComponents[0]['short_name']} ${addressComponents[1]['short_name']}, ${addressComponents[2]['short_name']}, ${addressComponents[4]['short_name']} ${addressComponents[6]['short_name']}",
      zipCode: addressComponents[6]['short_name'],
    );
  }
}

class GoogleMapServiceResult {
  final String streetAddress;
  final String zipCode;

  const GoogleMapServiceResult(
      {required this.streetAddress, required this.zipCode});
}
