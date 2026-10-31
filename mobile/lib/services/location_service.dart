import 'dart:async';

import 'package:geolocator/geolocator.dart';

import '../repositories/order_repository.dart';

class LocationService {
  final OrderRepository _repository;
  StreamSubscription<Position>? _subscription;

  LocationService({OrderRepository? repository})
      : _repository = repository ?? OrderRepository();

  Future<bool> ensurePermission() async {
    if (!await Geolocator.isLocationServiceEnabled()) return false;
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    return permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse;
  }

  /// Fetch a single position without starting the continuous stream.
  Future<Position?> currentPosition() async {
    if (!await ensurePermission()) return null;
    try {
      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );
    } catch (_) {
      return null;
    }
  }

  Future<void> start({void Function(Position position)? onPosition}) async {
    if (!await ensurePermission()) return;
    await stop();
    _subscription = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 25,
      ),
    ).listen((position) {
      onPosition?.call(position);
      _repository.updateTechnicianLocation(
        position.latitude,
        position.longitude,
      );
    });
  }

  Future<void> stop() async {
    await _subscription?.cancel();
    _subscription = null;
  }
}
