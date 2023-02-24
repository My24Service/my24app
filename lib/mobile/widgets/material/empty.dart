import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import 'package:my24app/core/widgets/slivers/base_widgets.dart';
import 'mixins.dart';


class MaterialListEmptyWidget extends BaseEmptyWidget with MaterialMixin {
  MaterialListEmptyWidget({
    Key key,
  }) : super(
    key: key,
    emptyMessage: 'assigned_orders.materials.notice_no_results'.tr()
  );

  @override
  String getAppBarSubtitle(BuildContext context) {
    return "";
  }

  @override
  String getAppBarTitle(BuildContext context) {
    return 'assigned_orders.materials.app_bar_title'.tr();
  }
}
