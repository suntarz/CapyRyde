import '/flutter_flow/flutter_flow_google_map.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/flutter_flow/lat_lng.dart' as ff;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'crew_home_page_model.dart';

class CrewHomePageWidget extends StatefulWidget {
  const CrewHomePageWidget({Key? key}) : super(key: key);

  @override
  _CrewHomePageWidgetState createState() => _CrewHomePageWidgetState();
}

class _CrewHomePageWidgetState extends State<CrewHomePageWidget> {
  late CrewHomePageModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => CrewHomePageModel());
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).requestFocus(_model.unfocusNode),
      child: Scaffold(
        key: scaffoldKey,
        resizeToAvoidBottomInset: false,
        backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
        appBar: AppBar(
          backgroundColor: Color(0xFFF1F5F8),
          automaticallyImplyLeading: false,
          title: Padding(
            padding: EdgeInsetsDirectional.fromSTEB(0.0, 24.0, 0.0, 0.0),
            child: Text(
              'Crew Home Page',
              style: FlutterFlowTheme.of(context).labelMedium.override(
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
              child: FlutterFlowIconButton(
                borderColor: Colors.transparent,
                borderRadius: 30.0,
                borderWidth: 1.0,
                buttonSize: 50.0,
                fillColor: Color(0xFFF1F5F8),
                icon: Icon(
                  Icons.notifications_none,
                  color: Color(0xFF57636C),
                  size: 24.0,
                ),
                onPressed: () async {
                  context.safePop();
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
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(16.0, 12.0, 16.0, 0.0),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Text(
                        'Welcome ',
                        style: FlutterFlowTheme.of(context).displaySmall.override(
                              fontFamily: 'Outfit',
                              color: Color(0xFF0F1113),
                              fontSize: 24.0,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      Text(
                        'Gibbs',
                        style: FlutterFlowTheme.of(context).displaySmall.override(
                              fontFamily: 'Outfit',
                              color: Color(0xFFD89D12),
                              fontSize: 24.0,
                              fontWeight: FontWeight.w500,
                            ),
                      ),
                      Expanded(
                        child: Align(
                          alignment: AlignmentDirectional(1.0, 0.0),
                          child: Icon(
                            Icons.settings_outlined,
                            color: FlutterFlowTheme.of(context).secondaryText,
                            size: 24.0,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(0.0, 20.0, 0.0, 0.0),
                  child: Container(
                          width: 402.0,
                          height: 591.0,
                          decoration: BoxDecoration(
                            color: FlutterFlowTheme.of(context).secondaryBackground,
                          ),
                          child: Padding(
                            padding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
                            child: FlutterFlowGoogleMap(
                              controller: _model.googleMapsController,
                              onCameraIdle: (latLng) => _model.googleMapsCenter = latLng,
                              initialLocation: _model.googleMapsCenter ??=
                                  LatLng(13.106061, -59.613158),
                              markerColor: GoogleMarkerColor.violet,
                              mapType: MapType.normal,
                              style: GoogleMapStyle.standard,
                              initialZoom: 14.0,
                              allowInteraction: true,
                              allowZoom: true,
                              showZoomControls: true,
                              showLocation: true,
                              showCompass: false,
                              showMapToolbar: false,
                              showTraffic: false,
                              centerMapOnMarkerTap: true,
                            ),
                          ),
                  )   
                ),
                Align(
                  alignment: AlignmentDirectional(0.0, 0.0),
                  child: Padding(
                    padding: EdgeInsetsDirectional.fromSTEB(0.0, 20.0, 0.0, 10.0),
                    child: Text(
                      'Your fleet : <FLEET NOW>',
                      style: FlutterFlowTheme.of(context).bodyMedium.override(
                            fontFamily: 'Readex Pro',
                            color: Colors.black,
                          ),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(16.0, 12.0, 16.0, 0.0),
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          blurRadius: 5.0,
                          color: Color(0x34111417),
                          offset: Offset(0.0, 2.0),
                        )
                      ],
                      borderRadius: BorderRadius.circular(8.0),
                    ),
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