import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:go_router/go_router.dart';
import '../common/globs.dart';
import '../common/location_manager.dart';
import '../common/service_call.dart';
import '../common/socket_manager.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:math';

class GPSPoint {
  final LatLng position;
  final DateTime timestamp;

  GPSPoint(this.position, this.timestamp);
}

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final Completer<GoogleMapController> _controller = Completer<GoogleMapController>();

  LatLng? currentPosition;
  Map<String, Marker> usersCarArr = {};
  Set<String> activeCars = {};
  Map<String, List<GPSPoint>> carGPSHistory = {};
  static const int MAX_GPS_HISTORY = 5;
  static const double EARTH_RADIUS = 6371; // in kilometers

  BitmapDescriptor userIcon = BitmapDescriptor.defaultMarker;
  BitmapDescriptor carIcon = BitmapDescriptor.defaultMarker;
  Timer? locationUpdateTimer;
  bool isActiveRide = false;
  bool isCameraToUser = true; // Track the button state

  // Track the current map type
  MapType _currentMapType = MapType.normal; // Start with roadmap

  @override
  void initState() {
    super.initState();

    usersCarArr.clear();
    activeCars.clear();

    loadIcons();
    setCurrentPosition();

    SocketManager.shared.initSocket();
    SocketManager.shared.connect();

    SocketManager.shared.socket?.on(SVKey.nvCarUpdateLocation, (data) {
      debugPrint("Received car update location: $data");
      updateOtherCarLocation(data);
    });

    SocketManager.shared.socket?.on(SVKey.nvRideStatusChange, (data) {
      String uuid = data["uuid"];
      bool isActive = data["isActive"];
      debugPrint("Received ride status change for UUID: $uuid, isActive: $isActive");
      if (isActive) {
        activeCars.add(uuid);
      } else {
        activeCars.remove(uuid);
        usersCarArr.remove(uuid);
      }
      setState(() {});
    });

    SocketManager.shared.socket?.on(SVKey.nvCarStopSharing, (data) {
      String uuid = data["uuid"]?.toString() ?? "";
      debugPrint("Received car stop sharing for UUID: $uuid");
      if (uuid.isNotEmpty) {
        setState(() {
          activeCars.remove(uuid);
          usersCarArr.remove(uuid);
        });
      }
    });

    apiCarJoin();
    startLocationUpdateTimer();
  }

  @override
  void dispose() {
    locationUpdateTimer?.cancel();
    SocketManager.shared.disconnect();
    super.dispose();
  }

  Future<void> loadIcons() async {
    final Uint8List userIconData = await getBytesFromAsset('assets/me.png', 100);
    final Uint8List carIconData = await getBytesFromAsset('assets/car.png', 100);
    
    setState(() {
      userIcon = BitmapDescriptor.fromBytes(userIconData);
      carIcon = BitmapDescriptor.fromBytes(carIconData);
    });

    if (usersCarArr.containsKey("user") && currentPosition != null) {
      setState(() {
        usersCarArr["user"] = Marker(
          markerId: MarkerId("user"),
          position: currentPosition!,
          icon: userIcon,
        );
      });
    }
  }

  Future<Uint8List> getBytesFromAsset(String path, int width) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(), targetWidth: width);
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png))!.buffer.asUint8List();
  }

  Future<void> setCurrentPosition() async {
    try {
      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.best);
      if (mounted) {
        setState(() {
          currentPosition = LatLng(position.latitude, position.longitude);
          usersCarArr["user"] = Marker(
            markerId: MarkerId("user"),
            position: currentPosition!,
            icon: userIcon,
          );
        });
      }
    } catch (e) {
      debugPrint("Error getting current location: $e");
    }
  }

  void startLocationUpdateTimer() {
    locationUpdateTimer = Timer.periodic(Duration(seconds:7), (timer) {
      updateCurrentLocation();
    });
  }

  Future<void> updateCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.best);
      LatLng newPosition = LatLng(position.latitude, position.longitude);

      if (mounted) {
        setState(() {
          currentPosition = newPosition;
          usersCarArr["user"] = Marker(
            markerId: MarkerId("user"),
            position: currentPosition!,
            icon: userIcon,
          );
        });
      }
    } catch (e) {
      debugPrint("Error getting current location: $e");
    }
  }

  void updateOtherCarLocation(Map data) {
    if (data['status'] == '1' && data['payload'] is Map) {
      Map payload = data['payload'];
      String uuid = payload["uuid"]?.toString() ?? "";
      debugPrint("Updating location for car UUID: $uuid");

      if (uuid.isNotEmpty && uuid != ServiceCall.userUUID) {
        LatLng carPosition = LatLng(
          double.tryParse(payload["lat"]?.toString() ?? "") ?? 0.0,
          double.tryParse(payload["long"]?.toString() ?? "") ?? 0.0
        );

        // Add new GPS point to history
        if (!carGPSHistory.containsKey(uuid)) {
          carGPSHistory[uuid] = [];
        }
        carGPSHistory[uuid]!.add(GPSPoint(carPosition, DateTime.now()));
        if (carGPSHistory[uuid]!.length > MAX_GPS_HISTORY) {
          carGPSHistory[uuid]!.removeAt(0);
        }

        debugPrint("Adding marker for UUID: $uuid at position: ${carPosition.latitude}, ${carPosition.longitude}");

        usersCarArr[uuid] = Marker(
          markerId: MarkerId(uuid),
          position: carPosition,
          icon: carIcon,
          rotation: double.tryParse(payload["degree"]?.toString() ?? "") ?? 0.0,
          anchor: const Offset(0.5, 0.5),
          onTap: () => _showCarInfo(uuid, payload),
        );

        activeCars.add(uuid);

        if (mounted) {
          setState(() {});
        }
      }
    } else {
      debugPrint("Invalid data format received: $data");
    }
  }

  double calculateSpeed(List<GPSPoint> gpsHistory) {
    if (gpsHistory.length < 2) return 0;

    double totalDistance = 0;
    for (int i = 1; i < gpsHistory.length; i++) {
      totalDistance += _calculateDistance(gpsHistory[i-1].position, gpsHistory[i].position);
    }

    double timeInHours = (gpsHistory.last.timestamp.difference(gpsHistory.first.timestamp).inSeconds) / 3600;
    return totalDistance / timeInHours; // km/h
  }

  double _calculateDistance(LatLng start, LatLng end) {
    double lat1 = start.latitude * pi / 180;
    double lon1 = start.longitude * pi / 180;
    double lat2 = end.latitude * pi / 180;
    double lon2 = end.longitude * pi / 180;

    double dlon = lon2 - lon1;
    double dlat = lat2 - lat1;

    double a = pow(sin(dlat/2), 2) + cos(lat1) * cos(lat2) * pow(sin(dlon/2), 2);
    double c = 2 * atan2(sqrt(a), sqrt(1-a));

    // dlat: ความแตกต่างของละติจูด (latitude) ระหว่างสองจุด (lat2 - lat1)
    // dlon: ความแตกต่างของลองจิจูด (longitude) ระหว่างสองจุด (lon2 - lon1)
    // sin(dlat/2): คำนวณค่า sine ของครึ่งหนึ่งของความแตกต่างของละติจูด
    // pow(sin(dlat/2), 2): ยกกำลังสองของค่า sine ที่ได้
    // cos(lat1) และ cos(lat2): คำนวณค่า cosine ของละติจูดของทั้งสองจุด
    // pow(sin(dlon/2), 2): ยกกำลังสองของค่า sine ของครึ่งหนึ่งของความแตกต่างของลองจิจูด
    // a: ค่าที่ได้จะถูกใช้ในขั้นตอนถัดไปเพื่อคำนวณระยะทาง

    return EARTH_RADIUS * c; // Distance in km
  }

  String estimateArrivalTime(String uuid) {
    if (!carGPSHistory.containsKey(uuid) || carGPSHistory[uuid]!.length < 2) {
      return "Not enough data";
    }

    double speed = calculateSpeed(carGPSHistory[uuid]!);
    if (speed == 0) return "Cannot estimate (speed is 0)";

    LatLng carPosition = carGPSHistory[uuid]!.last.position;
    double distance = _calculateDistance(carPosition, currentPosition!);

    double timeInHours = distance / speed;
    int minutes = (timeInHours * 60).ceil();

    return "$minutes minutes";
  }

  void _showCarInfo(String uuid, Map payload) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Car Information', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              SizedBox(height: 16),
              Text('UUID: $uuid'),
              Text('Latitude: ${payload["lat"]}'),
              Text('Longitude: ${payload["long"]}'),
              Text('Degree: ${payload["degree"]}'),
              Text('Active Ride: ${activeCars.contains(uuid) ? "Yes" : "No"}'),
              Text('Estimated Arrival Time: ${estimateArrivalTime(uuid)}'),
            ],
          ),
        );
      },
    );
  }

  void apiCarJoin() {
    if (currentPosition == null) return;

    ServiceCall.post({
      "uuid": ServiceCall.userUUID,
      "lat": currentPosition!.latitude.toString(),
      "long": currentPosition!.longitude.toString(),
    }, SVKey.svCarJoin, (responseObj) async {
      if (responseObj[KKey.status] == "1") {
        (responseObj[KKey.payload] as Map? ?? {}).forEach((key, value) {
          String uuid = key.toString();
          if (uuid != ServiceCall.userUUID) {
            LatLng carPosition = LatLng(
              double.tryParse(value["lat"].toString()) ?? 0.0,
              double.tryParse(value["long"].toString()) ?? 0.0,
            );

            usersCarArr[uuid] = Marker(
              markerId: MarkerId(uuid),
              position: carPosition,
              icon: carIcon,
              rotation: double.tryParse(value["degree"].toString()) ?? 0.0,
              onTap: () => _showCarInfo(uuid, value),
            );
          }
        });

        if (mounted) {
          setState(() {});
        }
      } else {
        debugPrint(responseObj[KKey.message] as String? ?? MSG.fail);
      }
    }, (error) async {
      debugPrint(error.toString());
    });
  }

  LatLng? findNearestCar() {
    if (currentPosition == null || usersCarArr.isEmpty) return null;

    LatLng? nearestCarPosition; // Change to nullable
    double nearestDistance = double.infinity;

    usersCarArr.forEach((uuid, marker) {
      double distance = _calculateDistance(currentPosition!, marker.position);
      if (distance < nearestDistance) {
        nearestDistance = distance;
        nearestCarPosition = marker.position; // Assign the nearest car position
      }
    });

    return nearestCarPosition; // Return nullable
  }

  void _goToNearestCar() async {
    LatLng? nearestCarPosition = findNearestCar();
    if (nearestCarPosition != null) {
      final GoogleMapController controller = await _controller.future;
      await controller.animateCamera(CameraUpdate.newCameraPosition(
        CameraPosition(target: nearestCarPosition, zoom: 14.0),
      ));
    } else {
      debugPrint("No cars available nearby.");
    }
  }

  void _toggleMapType() {
    setState(() {
      // Toggle between roadmap and hybrid
      _currentMapType = _currentMapType == MapType.normal ? MapType.hybrid : MapType.normal;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: Icon(Icons.arrow_back_rounded, color: Color(0xFF14181B)),
            onPressed: () {
              context.pop();
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          currentPosition == null
              ? Center(child: CircularProgressIndicator())
              : GoogleMap(
                  mapType: _currentMapType, // Use the current map type
                  initialCameraPosition: CameraPosition(
                    target: currentPosition!,
                    zoom: 14.4746,
                  ),
                  onMapCreated: (GoogleMapController controller) {
                    _controller.complete(controller);
                  },
                  markers: {
                    ...usersCarArr.values.where((marker) => marker.markerId.value == "user" || activeCars.contains(marker.markerId.value)).toSet(),
                  },
                ),
          Positioned(
            top: 16.0, // Distance from the top
            left: 16.0, // Distance from the left
            child: FloatingActionButton(
              onPressed: _toggleMapType,
              tooltip: 'Switch Map Type',
              child: Icon(Icons.map), // Icon for the map type switch button
            ),
          ),
          Positioned(
            bottom: 16.0, // Distance from the bottom
            left: 16.0,   // Distance from the left
            child: FloatingActionButton(
              onPressed: () {
                if (isCameraToUser) {
                  // Move camera to current position
                  _goToCurrentPosition();
                } else {
                  // Move camera to nearest car
                  _goToNearestCar();
                }
                // Toggle button state
                setState(() {
                  isCameraToUser = !isCameraToUser;
                });
              },
              tooltip: isCameraToUser ? 'Come Back to Me' : 'Go to Nearest Car',
              child: Icon(isCameraToUser ? Icons.my_location : Icons.directions_car),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _goToCurrentPosition() async {
    if (currentPosition == null) return;

    final GoogleMapController controller = await _controller.future;
    await controller.animateCamera(CameraUpdate.newCameraPosition(
      CameraPosition(target: currentPosition!, zoom: 16.0),
    ));
  }
}