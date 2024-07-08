import '/compo/bottom_sheet/bottom_sheet_widget.dart';
import '/compo/moni_stat_compo/moni_stat_compo_widget.dart';
import '/flutter_flow/flutter_flow_animations.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:math';
import 'cap_home_page_widget.dart' show CapHomePageWidget;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';

class CapHomePageModel extends FlutterFlowModel<CapHomePageWidget> {
  ///  State fields for stateful widgets in this page.

  final unfocusNode = FocusNode();
  // Model for moniStatCompo component.
  late MoniStatCompoModel moniStatCompoModel;

  @override
  void initState(BuildContext context) {
    moniStatCompoModel = createModel(context, () => MoniStatCompoModel());
  }

  @override
  void dispose() {
    unfocusNode.dispose();
    moniStatCompoModel.dispose();
  }

  /// Action blocks.
  Future bottomSheet(BuildContext context) async {
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
            child: BottomSheetWidget(),
          ),
        );
      },
    );
  }
}
