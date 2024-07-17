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
    requestLocationPermission();
    getCurrentLocation();
  }

  void dispose() {
    unfocusNode.dispose();
  }

  /// Additional helper methods are added here.

  Future<void> requestLocationPermission() async {
    var status = await Permission.location.status;
    if (status.isDenied) {
      if (await Permission.location.request().isGranted) {
        // Permission granted
        print('Location permission granted');
      } else {
        // Permission denied
        print('Location permission denied');
      }
    } else if (status.isGranted) {
      // Permission already granted
      print('Location permission already granted');
    } else if (status.isPermanentlyDenied) {
      // Permission permanently denied
      print('Location permission permanently denied');
      openAppSettings();
    }
  }

  Future<void> getCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      googleMapsCenter = ff.LatLng(position.latitude, position.longitude);
    } catch (e) {
      print("Error getting location: $e");
      // ใช้ตำแหน่งเริ่มต้นถ้าไม่สามารถรับตำแหน่งปัจจุบันได้
      googleMapsCenter = ff.LatLng(13.736717, 100.523186); // กรุงเทพมหานคร
    }
  }
}