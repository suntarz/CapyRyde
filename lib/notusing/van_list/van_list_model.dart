import '/compo/van_compo/van_compo_widget.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'van_list_widget.dart' show VanListWidget;
import 'package:flutter/material.dart';

class VanListModel extends FlutterFlowModel<VanListWidget> {
  ///  State fields for stateful widgets in this page.

  final unfocusNode = FocusNode();
  // State field(s) for TextField widget.
  FocusNode? textFieldFocusNode;
  TextEditingController? textController;
  String? Function(BuildContext, String?)? textControllerValidator;
  // Model for VanCompo component.
  late VanCompoModel vanCompoModel;

  @override
  void initState(BuildContext context) {
    vanCompoModel = createModel(context, () => VanCompoModel());
  }

  @override
  void dispose() {
    unfocusNode.dispose();
    textFieldFocusNode?.dispose();
    textController?.dispose();

    vanCompoModel.dispose();
  }
}
