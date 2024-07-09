import '/compo/kraporcompo/kraporcompo_widget.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'feet_list_widget.dart' show FeetListWidget;
import 'package:flutter/material.dart';

class FeetListModel extends FlutterFlowModel<FeetListWidget> {
  ///  State fields for stateful widgets in this page.

  final unfocusNode = FocusNode();
  // State field(s) for TextField widget.
  FocusNode? textFieldFocusNode;
  TextEditingController? textController;
  String? Function(BuildContext, String?)? textControllerValidator;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    unfocusNode.dispose();
    textFieldFocusNode?.dispose();
    textController?.dispose();
  }

  /// Action blocks.
  Future krapoExtend(BuildContext context) async {
    await showModalBottomSheet(
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      enableDrag: false,
      context: context,
      builder: (context) {
        return GestureDetector(
          onTap: () => unfocusNode.canRequestFocus
              ? FocusScope.of(context).requestFocus(unfocusNode)
              : FocusScope.of(context).unfocus(),
          child: Padding(
            padding: MediaQuery.viewInsetsOf(context),
            child: const KraporcompoWidget(),
          ),
        );
      },
    );
  }
}
