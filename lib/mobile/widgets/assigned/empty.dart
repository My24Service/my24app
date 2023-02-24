import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import 'package:my24app/core/widgets/slivers/base_widgets.dart';
import 'mixins.dart';


class AssignedOrderListEmptyWidget extends BaseEmptyWidget with AssignedListMixin {
  AssignedOrderListEmptyWidget({
    Key key,
  }) : super(
      key: key,
      emptyMessage: 'assigned_orders.list.notice_no_order'.tr()
  );
}
