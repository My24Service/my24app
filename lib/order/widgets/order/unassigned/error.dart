import 'package:flutter/material.dart';

import 'package:my24app/core/widgets/slivers/base_widgets.dart';
import 'package:my24app/core/i18n_mixin.dart';
import 'package:my24app/order/models/order/models.dart';
import '../mixins.dart';


class OrdersUnAssignedErrorWidget extends BaseErrorWidget with OrderListMixin, i18nMixin {
  final String basePath = "orders.unassigned";
  final String? error;
  final OrderPageMetaData orderPageMetaData;

  OrdersUnAssignedErrorWidget({
    Key? key,
    required this.error,
    required this.orderPageMetaData,
  }) : super(
      key: key,
      error: error,
      memberPicture: orderPageMetaData.memberPicture
  );
}
