import 'package:flutter/material.dart';

import 'package:my24_flutter_core/widgets/slivers/base_widgets.dart';
import 'package:my24_flutter_core/widgets/widgets.dart';
import 'package:my24_flutter_core/i18n.dart';

import 'package:my24app/order/blocs/order_bloc.dart';
import 'mixins.dart';

class OrderListEmptyWidget extends BaseEmptyWidget with OrderListMixin, i18nMixin {
  final String basePath = "orders.list";
  final String? memberPicture;
  final OrderEventStatus fetchEvent;
  final CoreWidgets widgetsIn;

  OrderListEmptyWidget({
    Key? key,
    required this.fetchEvent,
    required this.memberPicture,
    required this.widgetsIn,
  }) : super(
    key: key,
    memberPicture: memberPicture,
    widgetsIn: widgetsIn
  );

  @override
  String getEmptyMessage() {
    return $trans('notice_no_order');
  }
}
