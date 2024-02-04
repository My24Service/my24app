import 'package:flutter/material.dart';

import 'package:my24_flutter_core/widgets/slivers/base_widgets.dart';
import 'package:my24_flutter_core/widgets/widgets.dart';
import 'package:my24_flutter_core/models/models.dart';

import 'package:my24app/core/i18n_mixin.dart';
import 'package:my24app/order/models/order/models.dart';
import 'mixins.dart';

class AssignedOrderListEmptyWidget extends BaseEmptyWidget with AssignedListMixin, i18nMixin {
  final String basePath = "assigned_orders.list";
  final String? memberPicture;
  final PaginationInfo paginationInfo;
  final OrderPageMetaData? orderListData;
  final CoreWidgets widgetsIn;

  AssignedOrderListEmptyWidget({
    Key? key,
    required this.orderListData,
    required this.memberPicture,
    required this.paginationInfo,
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
