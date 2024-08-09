import 'dart:io';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import 'flutter_flow/flutter_flow_theme.dart';
import 'flutter_flow/flutter_flow_util.dart';
import 'flutter_flow/nav/nav.dart';
import 'index.dart';

import 'common/globs.dart';
import 'common/location_manager.dart';
import 'common/my_http_overrides.dart';
import 'common/service_call.dart';
import 'common/socket_manager.dart';
import 'screen/map_screen.dart';

import 'package:flutter/services.dart';

SharedPreferences? prefs;

void main() async {
  HttpOverrides.global = MyHttpOverrides();
  WidgetsFlutterBinding.ensureInitialized();
  GoRouter.optionURLReflectsImperativeAPIs = true;
  usePathUrlStrategy();

  await FlutterFlowTheme.initialize();

  prefs = await SharedPreferences.getInstance();

  ServiceCall.userUUID = Globs.udValueString("uuid");

  if (ServiceCall.userUUID == "") {
    ServiceCall.userUUID = const Uuid().v6();
    Globs.udStringSet(ServiceCall.userUUID, "uuid");
  }

  SocketManager.shared.initSocket();
  LocationManager.shared.initLocation();

  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();

  static _MyAppState of(BuildContext context) =>
      context.findAncestorStateOfType<_MyAppState>()!;
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = FlutterFlowTheme.themeMode;

  late AppStateNotifier _appStateNotifier;
  late GoRouter _router;

  @override
  void initState() {
    super.initState();

    _appStateNotifier = AppStateNotifier.instance;
    _router = createRouter(_appStateNotifier);
  }

  void setThemeMode(ThemeMode mode) => setState(() {
        _themeMode = mode;
        FlutterFlowTheme.saveThemeMode(mode);
      });

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'findThebus',
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en', '')],
      theme: ThemeData(
        brightness: Brightness.light,
        useMaterial3: false,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        useMaterial3: false,
      ),
      themeMode: _themeMode,
      routerConfig: _router,
      builder: (context, child) {
        return ImagePreloader(child: child!);
      },
    );
  }
}

class ImagePreloader extends StatefulWidget {
  final Widget child;

  const ImagePreloader({Key? key, required this.child}) : super(key: key);

  @override
  _ImagePreloaderState createState() => _ImagePreloaderState();
}

class _ImagePreloaderState extends State<ImagePreloader> {
  late Future<void> _preloadFuture;

  @override
  void initState() {
    super.initState();
    _preloadFuture = _preloadImages();
  }

  Future<void> _preloadImages() async {
    await Future.wait([
      precacheImage(AssetImage("assets/me.png"), context),
      precacheImage(AssetImage("assets/car.png"), context),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _preloadFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return widget.child;
        }
        return CircularProgressIndicator(); // Or any loading indicator
      },
    );
  }
}