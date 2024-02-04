import 'package:flutter/material.dart';

import 'package:my24_flutter_core/widgets/slivers/base_widgets.dart';
import 'package:my24_flutter_core/widgets/widgets.dart';
import 'package:my24app/core/i18n_mixin.dart';
import 'package:my24app/order/blocs/order_bloc.dart';
import '../mixins.dart';

class SalesListEmptyWidget extends BaseEmptyWidget with OrderListMixin, i18nMixin {
  final String basePath = "orders.sales";
  final String? memberPicture;
  final OrderEventStatus fetchEvent;
  final CoreWidgets widgetsIn;

  SalesListEmptyWidget({
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
