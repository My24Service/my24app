import 'package:flutter/material.dart';

import 'package:my24app/core/widgets/slivers/base_widgets.dart';
import 'package:my24app/core/i18n_mixin.dart';
import 'mixins.dart';


class AssignedOrderListEmptyWidget extends BaseEmptyWidget with AssignedListMixin, i18nMixin {
  final String basePath = "assigned_orders.list";
  AssignedOrderListEmptyWidget({
    Key key,
  }) : super(
      key: key,
  );

  @override
  String getEmptyMessage() {
    return $trans('notice_no_order');
  }
}
