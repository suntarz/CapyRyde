import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/lat_lng.dart' as ff;
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as gmaps;
import 'dart:async';
import 'package:permission_handler/permission_handler.dart';
import 'package:geolocator/geolocator.dart';


class CrewHomePageModel extends FlutterFlowModel {
  ///  State fields for stateful widgets in this page.

  final unfocusNode = FocusNode();
  // State field(s) for GoogleMap widget.
  ff.LatLng? googleMapsCenter;
  final googleMapsController = Completer<gmaps.GoogleMapController>();
  // State field(s) for CheckboxListTile widget.
  bool? checkboxListTileValue;

  /// Initialization and disposal methods.

  void initState(BuildContext context) {
    requestLocationPermission().then((_) => getCurrentLocation());
    // requestLocationPermission();
    // getCurrentLocation();
  }

  void dispose() {
    unfocusNode.dispose();
  }

  /// Additional helper methods are added here.

  Future<void> requestLocationPermission() async {
  var status = await Permission.location.status;
  if (status.isDenied) {
    status = await Permission.location.request();
    if (status.isGranted) {
      print('Location permission granted');
    } else {
      print('Location permission denied');
    }
  } else if (status.isGranted) {
    print('Location permission already granted');
  } else if (status.isPermanentlyDenied) {
    print('Location permission permanently denied');
    openAppSettings();
  }
}

  Future<void> getCurrentLocation() async {
  bool serviceEnabled;
  LocationPermission permission;

  // ตรวจสอบว่าบริการตำแหน่งเปิดใช้งานหรือไม่
  serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    print('Location services are disabled.');
    googleMapsCenter = ff.LatLng(13.7563, 100.4949); // สนามหลวง, กรุงเทพมหานคร
    return;
  }

  // ตรวจสอบการอนุญาต
  permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      print('Location permissions are denied');
      googleMapsCenter = ff.LatLng(13.7563, 100.4949); // สนามหลวง, กรุงเทพมหานคร
      return;
    }
  }
  
  if (permission == LocationPermission.deniedForever) {
    print('Location permissions are permanently denied');
    googleMapsCenter = ff.LatLng(13.7563, 100.4949); // สนามหลวง, กรุงเทพมหานคร
    return;
  }

  // เมื่อได้รับอนุญาตแล้ว พยายามรับตำแหน่ง
  try {
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
      timeLimit: Duration(seconds: 10),
    );
    googleMapsCenter = ff.LatLng(position.latitude, position.longitude);
    print('Current location: ${position.latitude}, ${position.longitude}');
  } catch (e) {
    print('Error getting location: $e');
    googleMapsCenter = ff.LatLng(13.7563, 100.4949); // สนามหลวง, กรุงเทพมหานคร
  }
}
}