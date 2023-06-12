import 'package:flutter/material.dart';

import 'package:my24app/core/widgets/slivers/base_widgets.dart';
import 'package:my24app/core/i18n_mixin.dart';
import 'mixins.dart';


class TimeRegistrationListEmptyWidget extends BaseEmptyWidget with TimeRegistrationMixin, i18nMixin {
  final String basePath = "company.time_registration";
  final String? memberPicture;

  TimeRegistrationListEmptyWidget({
    Key? key,
    required this.memberPicture,
  }) : super(
      key: key,
      memberPicture: memberPicture
  );

  @override
  String getEmptyMessage() {
    return $trans('notice_no_results');
  }

  @override
  void doRefresh(BuildContext context) {
    // TODO: implement doRefresh
  }

  @override
  Widget getBottomSection(BuildContext context) {
    // TODO: implement getBottomSection
    throw UnimplementedError();
  }
}
