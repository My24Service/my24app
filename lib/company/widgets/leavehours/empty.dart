import 'package:flutter/material.dart';

import 'package:my24_flutter_core/widgets/slivers/base_widgets.dart';
import 'package:my24_flutter_core/widgets/widgets.dart';
import 'package:my24_flutter_core/i18n.dart';

import 'mixins.dart';

class UserLeaveHoursListEmptyWidget extends BaseEmptyWidget with UserLeaveHoursMixin {
  final String? memberPicture;
  final bool isPlanning;
  final CoreWidgets widgetsIn;
  final My24i18n i18nIn;
  UserLeaveHoursListEmptyWidget({
    Key? key,
    required this.memberPicture,
    required this.isPlanning,
    required this.widgetsIn,
    required this.i18nIn,
  }) : super(
      key: key,
      memberPicture: memberPicture,
      widgetsIn: widgetsIn,
      i18nIn: i18nIn,
  );

  @override
  String getEmptyMessage() {
    return i18n.$trans('notice_no_results');
  }
}
