import 'package:flutter/material.dart';

import 'package:my24_flutter_core/widgets/slivers/base_widgets.dart';
import 'package:my24_flutter_core/widgets/widgets.dart';
import 'package:my24_flutter_core/i18n.dart';
import 'package:my24_flutter_core/models/models.dart';

import 'package:my24app/order/models/order/models.dart';
import 'mixins.dart';

class AssignedOrderListEmptyWidget extends BaseEmptyWidget with AssignedListMixin {
  final String? memberPicture;
  final PaginationInfo paginationInfo;
  final OrderPageMetaData? orderListData;
  final CoreWidgets widgetsIn;
  final My24i18n i18nIn = My24i18n(basePath: "assigned_orders.list");

  AssignedOrderListEmptyWidget({
    Key? key,
    required this.orderListData,
    required this.memberPicture,
    required this.paginationInfo,
    required this.widgetsIn,
  }) : super(
      key: key,
      memberPicture: memberPicture,
      widgetsIn: widgetsIn,
      i18nIn: My24i18n(basePath: "assigned_orders.list")
  );

  @override
  String getEmptyMessage() {
    return i18nIn.$trans('notice_no_order');
  }
}
