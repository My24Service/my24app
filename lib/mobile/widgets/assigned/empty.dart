import 'package:flutter/material.dart';

import 'package:my24app/core/widgets/slivers/base_widgets.dart';
import 'package:my24app/core/i18n_mixin.dart';
import 'mixins.dart';


class AssignedOrderListEmptyWidget extends BaseEmptyWidget with AssignedListMixin, i18nMixin {
  final String basePath = "assigned_orders.list";
  final String memberPicture;

  AssignedOrderListEmptyWidget({
    Key key,
    @required this.memberPicture,
  }) : super(
      key: key,
      memberPicture: memberPicture
  );

  @override
  String getEmptyMessage() {
    return $trans('notice_no_order');
  }
}
