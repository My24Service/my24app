import 'package:flutter/material.dart';

import 'package:my24app/core/widgets/slivers/base_widgets.dart';
import 'package:my24app/core/i18n_mixin.dart';
import 'package:my24app/order/blocs/order_bloc.dart';
import '../mixins.dart';


class OrdersUnAssignedEmptyWidget extends BaseEmptyWidget with OrderListMixin, i18nMixin {
  final String basePath = "orders.unassigned";
  final String memberPicture;
  final OrderEventStatus fetchEvent;

  OrdersUnAssignedEmptyWidget({
    Key key,
    @required this.fetchEvent,
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
