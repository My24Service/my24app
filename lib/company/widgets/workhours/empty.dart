import 'package:flutter/material.dart';

import 'package:my24app/core/widgets/slivers/base_widgets.dart';
import 'package:my24app/core/i18n_mixin.dart';
import 'mixins.dart';


class UserWorkHoursListEmptyWidget extends BaseEmptyWidget with UserWorkHoursMixin, i18nMixin {
  final String basePath = "company.workhours";
  final String memberPicture;

  UserWorkHoursListEmptyWidget({
    Key key,
    @required this.memberPicture,
  }) : super(
      key: key,
      memberPicture: memberPicture
  );

  @override
  String getEmptyMessage() {
    return $trans('notice_no_results');
  }
}
