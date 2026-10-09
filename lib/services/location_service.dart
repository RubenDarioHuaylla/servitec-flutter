import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

class LocationResult {
  final double latitude;
  final double longitude;
  final String address;

  const LocationResult({
    required this.latitude,
    required this.longitude,
    required this.address,
  });
}

class LocationService {
  Future<LocationResult> getCurrentLocation() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) {
      throw Exception('Activa la ubicación de tu dispositivo');
    }

    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied) {
      throw Exception('Permiso de ubicación denegado');
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception('El permiso de ubicación fue denegado permanentemente');
    }

    final position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
    );

    final geocoding = Geocoding();

    final placemarks = await geocoding.placemarkFromCoordinates(
      position.latitude,
      position.longitude,
    );

    String address = 'Ubicación actual';

    if (placemarks.isNotEmpty) {
      final place = placemarks.first;

      final parts = <String>[
        if (place.subLocality?.isNotEmpty == true) place.subLocality!,
        if (place.locality?.isNotEmpty == true) place.locality!,
        if (place.administrativeArea?.isNotEmpty == true)
          place.administrativeArea!,
      ];

      if (parts.isNotEmpty) {
        address = parts.toSet().join(', ');
      }
    }

    return LocationResult(
      latitude: position.latitude,
      longitude: position.longitude,
      address: address,
    );
  }
}
