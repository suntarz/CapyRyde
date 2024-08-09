import 'dart:async';
import 'dart:math' as Math;

import 'package:fbroadcast/fbroadcast.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:find_thebus/common/globs.dart';
import 'package:find_thebus/common/service_call.dart';
import 'package:find_thebus/common/socket_manager.dart'; // Import SocketManager

class LocationManager {
  static final LocationManager singleton = LocationManager._internal();
  LocationManager._internal();
  static LocationManager get shared => singleton;

  Position? currentPosition; // Renamed from currentPos to currentPosition
  double carDegree = 0.0;
  StreamSubscription<Position>? positionStream;

  void initLocation() {
    SocketManager.shared.initSocket(); // Initialize the socket
    getLocationUpdates();
  }

  void getLocationUpdates() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      debugPrint("Location services are disabled.");
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        debugPrint("Location permissions are denied.");
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      debugPrint("Location permissions are permanently denied, we cannot request permissions.");
      return;
    }

    const LocationSettings locationSettings = LocationSettings(
        accuracy: LocationAccuracy.bestForNavigation, distanceFilter: 15);

    positionStream = Geolocator.getPositionStream(locationSettings: locationSettings)
        .listen((Position position) {
      carDegree = calculateDegrees(
          LatLng(currentPosition?.latitude ?? 0.0, currentPosition?.longitude ?? 0.0),
          LatLng(position.latitude, position.longitude));
      currentPosition = position; // Update currentPosition
      apiCarUpdateLocation(); // Call to update location
      FBroadcast.instance().broadcast("update_location", value: position);
      debugPrint(position.toString());
    });
  }

  void stopLocationUpdates() {
    positionStream?.cancel();
    positionStream = null;
  }

  static double calculateDegrees(LatLng startPoint, LatLng endPoint) {
    final double startLat = toRadians(startPoint.latitude);
    final double startLng = toRadians(startPoint.longitude);
    final double endLat = toRadians(endPoint.latitude);
    final double endLng = toRadians(endPoint.longitude);

    final double deltaLng = endLng - startLng;

    final double y = Math.sin(deltaLng) * Math.cos(endLat);
    final double x = Math.cos(startLat) * Math.sin(endLat) -
        Math.sin(startLat) * Math.cos(endLat) * Math.cos(deltaLng);

    final double bearing = Math.atan2(y, x);
    return (toDegrees(bearing) + 360) % 360;
  }

  static double toRadians(double degrees) {
    return degrees * (Math.pi / 180.0);
  }

  static double toDegrees(double radians) {
    return radians * (180.0 / Math.pi);
  }

  // Call API to update car location
  Future<void> apiCarUpdateLocation() async {
    if (currentPosition == null) return; // Check for currentPosition

    ServiceCall.post({
      "uuid": ServiceCall.userUUID,
      "lat": currentPosition!.latitude.toString(), // Use currentPosition
      "long": currentPosition!.longitude.toString(), // Use currentPosition
      "degree": carDegree.toString(), // Use carDegree
      "socket_id": SocketManager.shared.socket?.id ?? "", // Use socket
    }, SVKey.svCarUpdateLocation, (responseObj) async {
      if (responseObj[KKey.status] == "1") {
        debugPrint(responseObj[KKey.message] as String? ?? MSG.success);
        // Emit the driver's location to the socket for the user to receive
        SocketManager.shared.socket?.emit(SVKey.nvCarUpdateLocation, { // Use socket
          "uuid": ServiceCall.userUUID,
          "lat": currentPosition!.latitude,
          "long": currentPosition!.longitude,
          "degree": carDegree.toString(),
        });
        debugPrint("Emitted driver's location: ${currentPosition!.latitude}, ${currentPosition!.longitude}");
      } else {
        debugPrint(responseObj[KKey.message] as String? ?? MSG.fail);
      }
    }, (error) async {
      debugPrint(error.toString());
    });
}
}
