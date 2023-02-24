import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import 'package:my24app/core/widgets/slivers/base_widgets.dart';
import 'mixins.dart';


class ActivityListErrorWidget extends BaseErrorWidget with ActivityMixin {
  final String error;

  ActivityListErrorWidget({
    Key key,
    @required this.error
  }) : super(
      key: key,
      error: error
  );

  @override
  String getAppBarSubtitle(BuildContext context) {
    return "";
  }

  @override
  String getAppBarTitle(BuildContext context) {
    return 'assigned_orders.activity.app_bar_title'.tr();
  }
}
