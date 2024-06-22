import 'package:flutter/material.dart';

import 'package:my24_flutter_core/widgets/slivers/base_widgets.dart';
import 'package:my24_flutter_core/widgets/widgets.dart';
import 'package:my24_flutter_core/i18n.dart';
import 'package:my24_flutter_orders/models/order/models.dart';

import '../../../common/widgets/widgets.dart';
import 'mixins.dart';

class AssignedOrderListErrorWidget extends BaseErrorWidget with AssignedListMixin {
  final String? error;
  final String? memberPicture;
  final CoreWidgets widgetsIn;
  final OrderPageMetaData orderListData;
  final My24i18n i18nIn = My24i18n(basePath: "assigned_orders.list");

  AssignedOrderListErrorWidget({
    Key? key,
    required this.error,
    required this.memberPicture,
    required this.widgetsIn,
    required this.orderListData
  }) : super(
      key: key,
      error: error,
      memberPicture: memberPicture,
      widgetsIn: widgetsIn,
      i18nIn: My24i18n(basePath: "assigned_orders.list")
  );

  SliverAppBar getAppBar(BuildContext context) {
    AssignedOrdersAppBarFactory factory = AssignedOrdersAppBarFactory(
        context: context,
        orderPageMetaData: orderListData,
        orders: orderList,
        count: 0,
        onStretch: doRefresh
    );
    return factory.createAppBar();
  }
}
