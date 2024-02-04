import 'package:flutter/material.dart';

import 'package:my24_flutter_core/widgets/slivers/base_widgets.dart';
import 'package:my24_flutter_core/widgets/widgets.dart';

import 'package:my24app/core/i18n_mixin.dart';
import 'mixins.dart';

class UserLeaveHoursListEmptyWidget extends BaseEmptyWidget with UserLeaveHoursMixin, i18nMixin {
  final String basePath = "company.leavehours";
  final String? memberPicture;
  final bool isPlanning;
  final CoreWidgets widgetsIn;

  UserLeaveHoursListEmptyWidget({
    Key? key,
    required this.memberPicture,
    required this.isPlanning,
    required this.widgetsIn,
  }) : super(
      key: key,
      memberPicture: memberPicture,
      widgetsIn: widgetsIn,
  );

  @override
  String getEmptyMessage() {
    return $trans('notice_no_results');
  }
}
