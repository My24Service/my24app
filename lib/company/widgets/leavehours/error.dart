import 'package:flutter/material.dart';

import 'package:my24_flutter_core/widgets/slivers/base_widgets.dart';
import 'package:my24_flutter_core/widgets/widgets.dart';

import 'package:my24app/core/i18n_mixin.dart';
import 'mixins.dart';


class UserLeaveHoursListErrorWidget extends BaseErrorWidget with UserLeaveHoursMixin, i18nMixin {
  final String basePath = "company.leavehours";
  final String? memberPicture;
  final String? error;
  final CoreWidgets widgetsIn;

  UserLeaveHoursListErrorWidget({
    Key? key,
    required this.error,
    required this.memberPicture,
    required this.widgetsIn,
  }) : super(
      key: key,
      error: error,
      memberPicture: memberPicture,
      widgetsIn: widgetsIn,
  );
}
