import 'package:flutter/material.dart';

import 'package:my24_flutter_core/widgets/slivers/base_widgets.dart';
import 'package:my24_flutter_core/widgets/widgets.dart';
import 'package:my24_flutter_core/i18n.dart';

import 'mixins.dart';


class TimeRegistrationListEmptyWidget extends BaseEmptyWidget with TimeRegistrationMixin{
  final String basePath = "company.time_registration";
  final String? memberPicture;
  final CoreWidgets widgetsIn;
  final My24i18n i18nIn;
  
  TimeRegistrationListEmptyWidget({
    Key? key,
    required this.memberPicture,
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
    return i18nIn.$trans('notice_no_results');
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
