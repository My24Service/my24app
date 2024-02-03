import 'package:flutter/material.dart';

import 'package:my24_flutter_core/widgets/slivers/base_widgets.dart';
import 'package:my24app/core/i18n_mixin.dart';
import '../mixins.dart';


class LeaveHoursUnacceptedListEmptyWidget extends BaseEmptyWidget with UserLeaveHoursMixin, i18nMixin {
  final String basePath = "company.leavehours.unaccepted";
  final String? memberPicture;
  final Function transFunction;

  LeaveHoursUnacceptedListEmptyWidget({
    Key? key,
    required this.memberPicture,
    required this.transFunction
  }) : super(
    key: key,
    memberPicture: memberPicture,
    transFunc: transFunction
  );

  Widget getBottomSection(BuildContext context) {
    return SizedBox(height: 1);
  }

  @override
  String getEmptyMessage() {
    return $trans('notice_no_results');
  }
}
