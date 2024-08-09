import 'package:find_thebus/main.dart';

class Globs {
  static const appName = "Car Tracking";

  static void udStringSet(String data, String key) {
    prefs?.setString(key, data);
  }

  static String udValueString(String key) {
    return prefs?.getString(key) ?? "";
  }
}

// class SVKey {
//   // static const mainUrl = "http://10.31.27.231:3001";
//   static const mainUrl = "http://13.251.7.176:3001";
//   // static const mainUrl = "127.0.0.1:3001";
//   static const baseUrl = "$mainUrl/api/";
//   static const nodeUrl = mainUrl;

//   static const nvCarJoin = "car_join";
//   static const nvCarUpdateLocation = "car_update_location";
//   // static const nvCarStopSharing = "car_stop_sharing";

//   static const svCarJoin = "${baseUrl}car_join";
//   static const svCarUpdateLocation = "${baseUrl}car_update_location";
//   // static const svCarStopSharingLocation = "${baseUrl}car_stop_sharing";


//   static const String nvDriverLocationUpdate = 'nvDriverLocationUpdate';
//   static const String nvCarStopSharing = 'nvCarStopSharing';
//   static const String svCarStopSharingLocation = 'svCarStopSharingLocation';

  

//   static const carUpdateLocation = "car/updateLocation";

class SVKey {
  static const mainUrl = "http://13.251.7.176:3001";
  static const baseUrl = "$mainUrl/api/";
  static const nodeUrl = mainUrl;

  static const nvCarJoin = "car_join";
  static const nvCarUpdateLocation = "car_update_location";
  static const nvRideStatusChange = 'nvRideStatusChange'; // New constant added

  static const svCarJoin = "${baseUrl}car_join";
  static const svCarUpdateLocation = "${baseUrl}car_update_location";
  static const svCarStopSharingLocation = 'svCarStopSharingLocation';
  static const String nvDriverLocationUpdate = 'nvDriverLocationUpdate';
  static const String nvCarStopSharing = 'nvCarStopSharing';
}

class KKey {
  static const String status = "status";
  static const String message = "message";
  static const String payload = "payload";
}

class MSG {
  static const String success = "Success";
  static const String fail = "Fail";
}