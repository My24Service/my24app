import 'package:flutter/material.dart';

import 'package:my24_flutter_core/widgets/slivers/base_widgets.dart';
import 'package:my24_flutter_core/widgets/widgets.dart';
import 'package:my24_flutter_core/i18n.dart';

import 'package:my24app/order/models/order/models.dart';
import 'mixins.dart';

class OrderListErrorWidget extends BaseErrorWidget with OrderListMixin, i18nMixin {
  final String basePath = "orders.list";
  final String? error;
  final OrderPageMetaData orderPageMetaData;
  final CoreWidgets widgetsIn;

  OrderListErrorWidget({
    Key? key,
    required this.error,
    required this.orderPageMetaData,
    required this.widgetsIn,
  }) : super(
      key: key,
      error: error,
      memberPicture: orderPageMetaData.memberPicture,
      widgetsIn: widgetsIn
  );
}
