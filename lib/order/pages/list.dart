import 'package:flutter/material.dart';

import 'package:my24_flutter_core/widgets/widgets.dart';
import 'package:my24_flutter_core/widgets/slivers/base_widgets.dart';

import 'package:my24app/order/blocs/order_bloc.dart';
import 'package:my24app/order/widgets/order/list.dart';
import 'package:my24app/order/widgets/order/error.dart';
import 'package:my24app/order/widgets/order/empty.dart';
import 'package:my24app/order/models/order/models.dart';
import 'base_order.dart';

class OrderListPage extends BaseOrderListPage {
  final OrderEventStatus fetchMode = OrderEventStatus.FETCH_ALL;
  final OrderBloc bloc;
  final CoreWidgets widgets = CoreWidgets();

  OrderListPage({
    Key? key,
    required this.bloc,
    String? initialMode,
    int? pk
  }) : super(
    bloc: bloc,
    initialMode: initialMode,
    pk: pk
  );

  BaseErrorWidget getErrorWidget(String? error, OrderPageMetaData? orderPageMetaData) {
    return OrderListErrorWidget(
      error: error,
      orderPageMetaData: orderPageMetaData!,
      widgetsIn: widgets,
    );
  }

  BaseEmptyWidget getEmptyWidget(OrderPageMetaData? orderPageMetaData) {
    return OrderListEmptyWidget(
      memberPicture: orderPageMetaData!.memberPicture,
      fetchEvent: fetchMode,
      widgetsIn: widgets,
    );
  }

  BaseSliverListStatelessWidget getListWidget(orderList, orderPageMetaData, paginationInfo, fetchEvent, searchQuery) {
    return OrderListWidget(
        orderList: orderList,
        orderPageMetaData: orderPageMetaData,
        paginationInfo: paginationInfo,
        fetchEvent: fetchMode,
        searchQuery: searchQuery,
      widgetsIn: widgets,
    );
  }
}
