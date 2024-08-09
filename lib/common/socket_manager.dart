import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:find_thebus/common/globs.dart';
import 'package:find_thebus/common/service_call.dart';

class SocketManager {
  static final SocketManager singleton = SocketManager._internal();
  SocketManager._internal();
  IO.Socket? socket;
  static SocketManager get shared => singleton;

  void initSocket() {
    socket = IO.io(SVKey.nodeUrl, {
      "transports": ['websocket'],
      "autoConnect": true,
      "reconnection": true, // Enable reconnection
      "reconnectionAttempts": 5, // Number of reconnection attempts
      "reconnectionDelay": 1000, // Delay between reconnection attempts
    });

    socket?.on("connect", (data) {
      if (kDebugMode) {
        print("Socket Connect Done");
      }
      updateSocketIdApi();
    });

    socket?.on("connect_error", (data) {
      if (kDebugMode) {
        print("Socket Connect Error");
        print(data);
      }
    });

    socket?.on("error", (data) {
      if (kDebugMode) {
        print("Socket Error");
        print(data);
      }
    });

    socket?.on("disconnect", (data) {
      if (kDebugMode) {
        print("Socket Disconnect");
        print(data);
      }
      // Handle disconnection logic here, e.g., notify user
    });

    socket?.on("UpdateSocket", (data) {
      print("UpdateSocket : -------------");
      print(data);
    });

    // Add more event listeners as needed
  }

  void connect() {
    socket?.connect();
  }

  void disconnect() {
    socket?.disconnect();
  }

  Future updateSocketIdApi() async {
    if (ServiceCall.userUUID == "") {
      return;
    }

    try {
      socket?.emit("UpdateSocket", jsonEncode({'uuid': ServiceCall.userUUID}));
    } catch (e) {
      if (kDebugMode) {
        print("Socket Emit Error");
        print(e.toString());
      }
    }
  }
}