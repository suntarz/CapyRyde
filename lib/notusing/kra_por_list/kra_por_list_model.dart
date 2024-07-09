import '/compo/kraporcompo/kraporcompo_widget.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'kra_por_list_widget.dart' show KraPorListWidget;
import 'package:flutter/material.dart';

class KraPorListModel extends FlutterFlowModel<KraPorListWidget> {
  ///  State fields for stateful widgets in this page.

  final unfocusNode = FocusNode();
  // State field(s) for TextField widget.
  FocusNode? textFieldFocusNode;
  TextEditingController? textController;
  String? Function(BuildContext, String?)? textControllerValidator;
  // Model for kraporcompo component.
  late KraporcompoModel kraporcompoModel;

  @override
  void initState(BuildContext context) {
    kraporcompoModel = createModel(context, () => KraporcompoModel());
  }

  @override
  void dispose() {
    unfocusNode.dispose();
    textFieldFocusNode?.dispose();
    textController?.dispose();

    kraporcompoModel.dispose();
  }
}
