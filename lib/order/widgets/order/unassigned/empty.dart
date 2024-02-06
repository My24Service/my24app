import 'package:flutter/material.dart';

import 'package:my24_flutter_core/widgets/slivers/base_widgets.dart';
import 'package:my24_flutter_core/widgets/widgets.dart';
import 'package:my24_flutter_core/i18n.dart';

import 'package:my24app/order/blocs/order_bloc.dart';
import '../mixins.dart';

class OrdersUnAssignedEmptyWidget extends BaseEmptyWidget with OrderListMixin {
  final String? memberPicture;
  final OrderEventStatus fetchEvent;
  final CoreWidgets widgetsIn;
  final My24i18n i18nIn;

  OrdersUnAssignedEmptyWidget({
    Key? key,
    required this.fetchEvent,
    required this.memberPicture,
    required this.widgetsIn,
    required this.i18nIn,
  }) : super(
    key: key,
    memberPicture: memberPicture,
    widgetsIn: widgetsIn,
    i18nIn: i18nIn
  );

  @override
  String getEmptyMessage() {
    return i18nIn.$trans('notice_no_order');
  }
}
