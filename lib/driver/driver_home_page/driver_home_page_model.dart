import '/compo/table/table_widget.dart';
import '/flutter_flow/flutter_flow_google_map.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'driver_home_page_widget.dart' show DriverHomePageWidget;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class DriverHomePageModel extends FlutterFlowModel<DriverHomePageWidget> {
  ///  State fields for stateful widgets in this page.

  final unfocusNode = FocusNode();
  // State field(s) for GoogleMap widget.
  LatLng? googleMapsCenter;
  final googleMapsController = Completer<GoogleMapController>();
  // State field(s) for SwitchListTile widget.
  bool? switchListTileValue;
  // Model for table component.
  late TableModel tableModel;

  @override
  void initState(BuildContext context) {
    tableModel = createModel(context, () => TableModel());
  }

  @override
  void dispose() {
    unfocusNode.dispose();
    tableModel.dispose();
  }
}
