import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';

class MapController extends GetxController {
  final Rx<double> _latitud = 0.0.obs;
  double get latitud => _latitud.value;

  final Rx<double> _longitud = 0.0.obs;
  double get longitud => _longitud.value;

  Future<String> getCurrentLocation() async {
    final GeolocatorPlatform geolocator = GeolocatorPlatform.instance;

    try {
      Position position = await geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.best, // Adjust the accuracy setting here
      ));

      _latitud.value = position.latitude;
      _longitud.value = position.longitude;
      return "exito";
    } catch (e) {
      _latitud.value = 40.4168;
      _longitud.value = -3.7038;
      return "error";
    }
  }
}
