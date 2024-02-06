import 'package:flutter/material.dart';

import 'package:my24_flutter_core/widgets/slivers/base_widgets.dart';
import 'package:my24_flutter_core/widgets/widgets.dart';
import 'package:my24_flutter_core/i18n.dart';
import 'package:my24_flutter_core/models/models.dart';

import 'package:my24app/order/blocs/order_bloc.dart';
import 'package:my24app/order/models/order/models.dart';
import 'package:my24app/order/widgets/order/unassigned/empty.dart';
import 'package:my24app/order/widgets/order/unassigned/error.dart';
import 'package:my24app/order/widgets/order/unassigned/list.dart';
import 'base_order.dart';

class OrdersUnAssignedPage extends BaseOrderListPage {
  final OrderEventStatus fetchMode = OrderEventStatus.FETCH_UNASSIGNED;
  final i18n = My24i18n(basePath: "orders.unassigned");
  final OrderBloc bloc;
  final CoreWidgets widgets = CoreWidgets();

  OrdersUnAssignedPage({
    Key? key,
    required this.bloc,
  }) : super(
    bloc: bloc,
  );

  @override
  BaseEmptyWidget getEmptyWidget(OrderPageMetaData? orderPageMetaData) {
    return OrdersUnAssignedEmptyWidget(
      memberPicture: orderPageMetaData!.memberPicture,
      fetchEvent: fetchMode,
      widgetsIn: widgets,
      i18nIn: i18n,
    );
  }

  @override
  BaseErrorWidget getErrorWidget(String? error, OrderPageMetaData? orderPageMetaData) {
    return OrdersUnAssignedErrorWidget(
      error: error,
      orderPageMetaData: orderPageMetaData!,
      widgetsIn: widgets,
      i18nIn: i18n,
    );
  }

  @override
  BaseSliverListStatelessWidget getListWidget(List<Order>? orderList, OrderPageMetaData orderPageMetaData, PaginationInfo paginationInfo, OrderEventStatus fetchEvent, String? searchQuery) {
    return OrdersUnAssignedWidget(
      orderList: orderList,
      orderPageMetaData: orderPageMetaData,
      paginationInfo: paginationInfo,
      fetchEvent: fetchMode,
      searchQuery: searchQuery,
      widgetsIn: widgets,
      i18nIn: i18n,
    );
  }
}
