import 'package:flutter/material.dart';

import 'package:my24_flutter_core/widgets/slivers/base_widgets.dart';
import 'package:my24app/core/i18n_mixin.dart';
import 'mixins.dart';


class TimeRegistrationListErrorWidget extends BaseErrorWidget with TimeRegistrationMixin, i18nMixin {
  final String basePath = "company.time_registration";
  final String? memberPicture;
  final String? error;
  final Function transFunction;

  TimeRegistrationListErrorWidget({
    Key? key,
    required this.error,
    required this.memberPicture,
    required this.transFunction
  }) : super(
      key: key,
      error: error,
      memberPicture: memberPicture,
      transFunc: transFunction
  );
}
