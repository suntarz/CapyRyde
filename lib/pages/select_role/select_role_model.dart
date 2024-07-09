import '/flutter_flow/flutter_flow_util.dart';
import 'select_role_widget.dart' show SelectRoleWidget;
import 'package:flutter/material.dart';

class SelectRoleModel extends FlutterFlowModel<SelectRoleWidget> {
  ///  State fields for stateful widgets in this page.

  final unfocusNode = FocusNode();

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    unfocusNode.dispose();
  }
}
