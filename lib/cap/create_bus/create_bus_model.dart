import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/form_field_controller.dart';
import 'create_bus_widget.dart' show CreateBusWidget;
import 'package:flutter/material.dart';

class CreateBusModel extends FlutterFlowModel<CreateBusWidget> {
  ///  State fields for stateful widgets in this page.

  final unfocusNode = FocusNode();
  final formKey = GlobalKey<FormState>();
  // State field(s) for task widget.
  FocusNode? taskFocusNode1;
  TextEditingController? taskTextController1;
  String? Function(BuildContext, String?)? taskTextController1Validator;
  // State field(s) for task widget.
  FocusNode? taskFocusNode2;
  TextEditingController? taskTextController2;
  String? Function(BuildContext, String?)? taskTextController2Validator;
  // State field(s) for description widget.
  FocusNode? descriptionFocusNode;
  TextEditingController? descriptionTextController;
  String? Function(BuildContext, String?)? descriptionTextControllerValidator;
  // State field(s) for task widget.
  FocusNode? taskFocusNode3;
  TextEditingController? taskTextController3;
  String? Function(BuildContext, String?)? taskTextController3Validator;
  // State field(s) for ChoiceChips widget.
  FormFieldController<List<String>>? choiceChipsValueController;
  String? get choiceChipsValue =>
      choiceChipsValueController?.value?.firstOrNull;
  set choiceChipsValue(String? val) =>
      choiceChipsValueController?.value = val != null ? [val] : [];

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    unfocusNode.dispose();
    taskFocusNode1?.dispose();
    taskTextController1?.dispose();

    taskFocusNode2?.dispose();
    taskTextController2?.dispose();

    descriptionFocusNode?.dispose();
    descriptionTextController?.dispose();

    taskFocusNode3?.dispose();
    taskTextController3?.dispose();
  }
}
