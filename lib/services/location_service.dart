import 'package:geolocator/geolocator.dart';

class LocationService {
  Future<bool> isServiceEnabled() {
    return Geolocator.isLocationServiceEnabled();
  }

  Future<bool> hasPermission() async {
    return (await Geolocator.checkPermission() == LocationPermission.always ||
        await Geolocator.checkPermission() == LocationPermission.whileInUse);
  }

  Future<LocationPermission> obtainPermission() async {
    if (!await hasPermission()) {
      return Geolocator.requestPermission();
    }

    return Geolocator.checkPermission();
  }

  Future<Position> getLocation({bool obtainPermissionIfNeeded = true}) async {
    if (!await isServiceEnabled()) {
      throw Exception('Location is service is not enabled.');
    }

    if (!await hasPermission() && obtainPermissionIfNeeded) {
      await obtainPermission();
    }

    return Geolocator.getCurrentPosition();
  }
}
