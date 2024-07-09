import '/compo/bus_compo/bus_compo_widget.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'buslist_widget.dart' show BuslistWidget;
import 'package:flutter/material.dart';

class BuslistModel extends FlutterFlowModel<BuslistWidget> {
  ///  State fields for stateful widgets in this page.

  final unfocusNode = FocusNode();
  // State field(s) for TextField widget.
  FocusNode? textFieldFocusNode;
  TextEditingController? textController;
  String? Function(BuildContext, String?)? textControllerValidator;
  // Model for busCompo component.
  late BusCompoModel busCompoModel;

  @override
  void initState(BuildContext context) {
    busCompoModel = createModel(context, () => BusCompoModel());
  }

  @override
  void dispose() {
    unfocusNode.dispose();
    textFieldFocusNode?.dispose();
    textController?.dispose();

    busCompoModel.dispose();
  }
}
