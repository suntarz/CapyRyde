import '/flutter_flow/flutter_flow_util.dart';
import 'crew_member_widget.dart' show CrewMemberWidget;
import 'package:flutter/material.dart';

class CrewMemberModel extends FlutterFlowModel<CrewMemberWidget> {
  ///  State fields for stateful widgets in this page.

  final unfocusNode = FocusNode();

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    unfocusNode.dispose();
  }
}
