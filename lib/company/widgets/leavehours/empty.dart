import 'package:flutter/material.dart';

import 'package:my24app/core/widgets/slivers/base_widgets.dart';
import 'package:my24app/core/i18n_mixin.dart';
import 'mixins.dart';


class UserLeaveHoursListEmptyWidget extends BaseEmptyWidget with UserLeaveHoursMixin, i18nMixin {
  final String basePath = "company.leavehours";
  final String memberPicture;
  final bool isPlanning;

  UserLeaveHoursListEmptyWidget({
    Key key,
    @required this.memberPicture,
    @required this.isPlanning,
  }) : super(
      key: key,
      memberPicture: memberPicture
  );

  @override
  String getEmptyMessage() {
    return $trans('notice_no_results');
  }
}