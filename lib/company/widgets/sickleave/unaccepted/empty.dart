import 'package:flutter/material.dart';

import 'package:my24_flutter_core/widgets/slivers/base_widgets.dart';
import 'package:my24_flutter_core/widgets/widgets.dart';
import 'package:my24_flutter_core/i18n.dart';

import '../mixins.dart';


class LeaveHoursUnacceptedListEmptyWidget extends BaseEmptyWidget with UserLeaveHoursMixin {
  final String? memberPicture;
  final CoreWidgets widgetsIn;
  final My24i18n i18nIn = My24i18n(basePath: "company.leavehours.unaccepted");

  LeaveHoursUnacceptedListEmptyWidget({
    Key? key,
    required this.memberPicture,
    required this.widgetsIn,
  }) : super(
    key: key,
    memberPicture: memberPicture,
    widgetsIn: widgetsIn,
    i18nIn: My24i18n(basePath: "company.leavehours.unaccepted")
  );

  Widget getBottomSection(BuildContext context) {
    return SizedBox(height: 1);
  }

  @override
  String getEmptyMessage() {
    return i18n.$trans('notice_no_results');
  }
}
