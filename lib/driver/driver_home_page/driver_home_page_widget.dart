import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:find_thebus/common/globs.dart';
import 'package:find_thebus/common/service_call.dart';
import 'package:find_thebus/common/socket_manager.dart';
import 'package:find_thebus/common/location_manager.dart';

class DriverHomePageWidget extends StatefulWidget {
  const DriverHomePageWidget({super.key});

  @override
  State<DriverHomePageWidget> createState() => _DriverHomePageWidgetState();
}

class _DriverHomePageWidgetState extends State<DriverHomePageWidget> {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  final Completer<GoogleMapController> _controller = Completer<GoogleMapController>();

  BitmapDescriptor? carIcon;
  LatLng? currentPosition;
  Map<String, Marker> markers = {};
  bool isRideActive = false;
  Timer? locationUpdateTimer;
  late IO.Socket socket;

  @override
  void initState() {
    super.initState();
    loadIcons();
    setCurrentPosition();
    _initSocket();
  }

  @override
  void dispose() {
    stopLocationUpdateTimer();
    socket.dispose();
    super.dispose();
  }

  void _initSocket() {
    socket = SocketManager.shared.socket!;

    socket.on(SVKey.nvDriverLocationUpdate, (data) {
      updateDriverLocation(data);
    });

    socket.on('disconnect', (data) {
      if (mounted) {
        debugPrint("Disconnected from socket");
      }
    });
  }

  Future<void> loadIcons() async {
    carIcon = await getBitmapDescriptorFromAssetBytes("assets/car.png", 100);
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> setCurrentPosition() async {
    try {
      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.best);
      if (mounted) {
        setState(() {
          currentPosition = LatLng(position.latitude, position.longitude);
        });
      }
    } catch (e) {
      debugPrint("Error getting current location: $e");
    }
  }

  Future<BitmapDescriptor> getBitmapDescriptorFromAssetBytes(String path, int width) async {
    try {
      final ByteData data = await rootBundle.load(path);
      final ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(), targetWidth: width);
      final ui.FrameInfo fi = await codec.getNextFrame();
      final ByteData? byteData = await fi.image.toByteData(format: ui.ImageByteFormat.png);
      final Uint8List resizedImageData = byteData!.buffer.asUint8List();
      return BitmapDescriptor.fromBytes(resizedImageData);
    } catch (e) {
      debugPrint("Error loading icon: $e");
      return BitmapDescriptor.defaultMarker;
    }
  }

  void startLocationUpdateTimer() {
    locationUpdateTimer = Timer.periodic(Duration(seconds: 15), (timer) {
      updateCurrentLocation();
    });
  }

  void stopLocationUpdateTimer() {
    locationUpdateTimer?.cancel();
  }

  Future<void> updateCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.best);
      LatLng newPosition = LatLng(position.latitude, position.longitude);

      if (mounted) {
        setState(() {
          currentPosition = newPosition;
          if (isRideActive) {
            markers["car"] = Marker(
              markerId: MarkerId("car"),
              position: currentPosition!,
              icon: carIcon!,
            );
          }
        });
      }

      if (isRideActive) {
        socket.emit(SVKey.nvCarUpdateLocation, {
          "uuid": ServiceCall.userUUID,
          "lat": currentPosition!.latitude,
          "long": currentPosition!.longitude,
          "degree": LocationManager.shared.carDegree.toString(),
          "socket_id": socket.id,
        });
        
        apiCarUpdateLocation();
      }
    } catch (e) {
      debugPrint("Error getting current location: $e");
    }
  }

  void updateDriverLocation(Map data) {
    debugPrint("Driver location received: $data");
    String uuid = data['uuid'] ?? "";
    double lat = double.tryParse(data['lat'].toString()) ?? 0.0;
    double long = double.tryParse(data['long'].toString()) ?? 0.0;

    if (mounted) {
      setState(() {
        markers[uuid] = Marker(
          markerId: MarkerId(uuid),
          position: LatLng(lat, long),
          icon: carIcon!,
          infoWindow: InfoWindow(title: 'Driver $uuid'),
        );
      });
    }
  }

  Future<void> apiCarStopSharingLocation() async {
    ServiceCall.post({
      "uuid": ServiceCall.userUUID,
      "stopSharing": true,
    }, SVKey.svCarStopSharingLocation, (responseObj) async {
      if (responseObj[KKey.status] == "1") {
        debugPrint(responseObj[KKey.message] as String? ?? MSG.success);
      } else {
        debugPrint(responseObj[KKey.message] as String? ?? MSG.fail);
      }
    }, (error) async {
      debugPrint(error.toString());
    });
  }

  Future<void> apiCarUpdateLocation() async {
    if (currentPosition == null) return;

    ServiceCall.post({
      "uuid": ServiceCall.userUUID,
      "lat": currentPosition!.latitude.toString(),
      "long": currentPosition!.longitude.toString(),
      "degree": LocationManager.shared.carDegree.toString(),
      "socket_id": socket.id ?? "",
    }, SVKey.svCarUpdateLocation, (responseObj) async {
      if (responseObj[KKey.status] == "1") {
        debugPrint(responseObj[KKey.message] as String? ?? MSG.success);
      } else {
        debugPrint(responseObj[KKey.message] as String? ?? MSG.fail);
      }
    }, (error) async {
      debugPrint(error.toString());
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        key: scaffoldKey,
        resizeToAvoidBottomInset: false,
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Color(0xFFF1F5F8),
          automaticallyImplyLeading: false,
          title: Padding(
            padding: EdgeInsetsDirectional.fromSTEB(0.0, 24.0, 0.0, 0.0),
            child: Text(
              'Driver Home Page',
              style: TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                color: Color(0xFF57636C),
                fontSize: 14.0,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          actions: [
            Padding(
              padding: EdgeInsetsDirectional.fromSTEB(0.0, 8.0, 16.0, 0.0),
              child: IconButton(
                icon: Icon(
                  Icons.notifications_none,
                  color: Color(0xFF57636C),
                  size: 24.0,
                ),
                onPressed: () async {
                  Navigator.pop(context);
                },
              ),
            ),
          ],
          centerTitle: false,
          elevation: 0.0,
        ),
        body: SafeArea(
          top: true,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(0.0, 10.0, 0.0, 0.0),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Padding(
                        padding: EdgeInsetsDirectional.fromSTEB(16.0, 12.0, 0.0, 0.0),
                        child: Text(
                          'Welcome Driver',
                          style: TextStyle(
                            fontFamily: 'Outfit',
                            color: Color(0xFF0F1113),
                            fontSize: 24.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsetsDirectional.fromSTEB(5.0, 12.0, 0.0, 0.0),
                        child: Text(
                          'Dominic.',
                          style: TextStyle(
                            fontFamily: 'Outfit',
                            color: Color(0xFFD89D12),
                            fontSize: 24.0,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      Flexible(
                        child: Align(
                          alignment: AlignmentDirectional(1.0, 0.0),
                          child: Padding(
                            padding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 28.0, 0.0),
                            child: Icon(
                              Icons.settings_outlined,
                              color: Color(0xFF57636C),
                              size: 24.0,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: double.infinity,
                  height: 420.0,
                  decoration: BoxDecoration(
                    color: Colors.white,
                  ),
                  child: Padding(
                    padding: EdgeInsetsDirectional.fromSTEB(0.0, 20.0, 0.0, 0.0),
                    child: currentPosition == null
                        ? Center(child: CircularProgressIndicator())
                        : GoogleMap(
                            mapType: MapType.normal,
                            initialCameraPosition: CameraPosition(
                              target: currentPosition!,
                              zoom: 14.0,
                            ),
                            onMapCreated: (GoogleMapController controller) {
                              _controller.complete(controller);
                            },
                            markers: markers.values.toSet(),
                          ),
                  ),
                ),
                Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(16.0, 20.0, 0.0, 8.0),
                  child: Text(
                    'Overview',
                    style: TextStyle(
                      fontFamily: 'Outfit',
                      color: Color(0xFF0F1113),
                      fontSize: 12.0,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ),
                Flexible(
                  fit: FlexFit.loose,
                  child: Padding(
                    padding: EdgeInsetsDirectional.fromSTEB(16.0, 0.0, 16.0, 16.0),
                    child: Text(
                      'Your fleet:  <FLEET YOUR REGISTER>',
                      style: TextStyle(
                        fontFamily: 'Outfit',
                        color: Color(0xFF57636C),
                        fontSize: 16.0,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(16.0, 0.0, 16.0, 12.0),
                  child: Container(
                    width: double.infinity,
                    height: 50.0,
                    decoration: BoxDecoration(
                      color: Color(0xFFF1F4F8),
                      boxShadow: [
                        BoxShadow(
                          blurRadius: 3.0,
                          color: Color(0x33000000),
                          offset: Offset(0.0, 1.0),
                        )
                      ],
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(12.0),
                      child: InkWell(
                        splashColor: Colors.transparent,
                        focusColor: Colors.transparent,
                        hoverColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                        onTap: () async {
                          Navigator.pushNamed(context, 'selectVehiclePage');
                        },
                        child: Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Select Vehicle',
                              style: TextStyle(
                                fontFamily: 'Outfit',
                                color: Color(0xFF57636C),
                                fontSize: 14.0,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Icon(
                              Icons.chevron_right_rounded,
                              color: Color(0xFF0F1113),
                              size: 24.0,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                Flexible(
                  fit: FlexFit.loose,
                  child: Padding(
                    padding: EdgeInsetsDirectional.fromSTEB(16.0, 0.0, 16.0, 16.0),
                    child: Text(
                      'license plate: 1ABC-123',
                      style: TextStyle(
                        fontFamily: 'Outfit',
                        color: Color(0xFF57636C),
                        fontSize: 16.0,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Expanded(
                      child: SwitchListTile.adaptive(
                        value: isRideActive,
                        onChanged: (newValue) {
                          setState(() {
                            isRideActive = newValue;
                            if (isRideActive) {
                              LocationManager.shared.getLocationUpdates();
                              if (currentPosition != null) {
                                markers["car"] = Marker(
                                  markerId: MarkerId("car"),
                                  position: currentPosition!,
                                  icon: carIcon!,
                                );
                              }
                              startLocationUpdateTimer();
                              socket.emit(SVKey.nvRideStatusChange, {
                                "uuid": ServiceCall.userUUID,
                                "isActive": true,
                              });
                              updateCurrentLocation();
                            } else {
                              LocationManager.shared.stopLocationUpdates();
                              markers.remove("car");
                              apiCarStopSharingLocation();
                              stopLocationUpdateTimer();
                              setState(() {
                                markers.clear();
                              });
                              socket.emit(SVKey.nvRideStatusChange, {
                                "uuid": ServiceCall.userUUID,
                                "isActive": false,
                              });
                              socket.emit(SVKey.nvCarStopSharing, {
                                "uuid": ServiceCall.userUUID,
                              });
                            }
                          });
                        },
                        title: Text(
                          'Ride',
                          style: TextStyle(
                            fontFamily: 'Outfit',
                            fontSize: 20.0,
                          ),
                        ),
                        subtitle: Text(
                          DateTime.now().toString(),
                          style: TextStyle(
                            fontFamily: 'Readex Pro',
                            fontSize: 14.0,
                          ),
                        ),
                        tileColor: Colors.white,
                        activeColor: Color(0xFFD89D12),
                        activeTrackColor: Color(0xFFD89D12),
                        dense: false,
                        controlAffinity: ListTileControlAffinity.trailing,
                      ),
                    ),
                  ],
                ),
                Container(
                  width: double.infinity,
                  height: 477.0,
                  decoration: BoxDecoration(
                    color: Colors.white,
                  ),
                  child: Center(
                    child: Text('TableWidget Placeholder'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}