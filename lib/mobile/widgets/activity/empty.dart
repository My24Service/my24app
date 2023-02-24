import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import 'package:my24app/core/widgets/slivers/base_widgets.dart';
import 'mixins.dart';


class ActivityListEmptyWidget extends BaseEmptyWidget with ActivityMixin {
  ActivityListEmptyWidget({
    Key key,
  }) : super(
      key: key,
      emptyMessage: 'assigned_orders.activity.notice_no_results'.tr()
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
