import 'package:flutter/material.dart';

import 'package:my24_flutter_core/widgets/widgets.dart';
import 'package:my24_flutter_core/i18n.dart';
import 'package:my24_flutter_core/widgets/slivers/base_widgets.dart';

import 'package:my24app/order/blocs/order_bloc.dart';
import 'package:my24app/order/widgets/order/past/list.dart';
import 'package:my24app/order/widgets/order/past/error.dart';
import 'package:my24app/order/widgets/order/past/empty.dart';
import 'package:my24app/order/models/order/models.dart';
import 'base_order.dart';

class PastPage extends BaseOrderListPage {
  final OrderEventStatus fetchMode = OrderEventStatus.FETCH_PAST;
  final i18n = My24i18n(basePath: "orders.past");
  final OrderBloc bloc;
  final CoreWidgets widgets = CoreWidgets();

  PastPage({
    Key? key,
    required this.bloc,
  }) : super(
      bloc: bloc,
  );

  BaseErrorWidget getErrorWidget(String? error, OrderPageMetaData? orderPageMetaData) {
    return PastListErrorWidget(
      error: error,
      orderPageMetaData: orderPageMetaData!,
      fetchEvent: fetchMode,
      widgetsIn: widgets,
      i18nIn: i18n,
    );
  }

  BaseEmptyWidget getEmptyWidget(OrderPageMetaData? orderPageMetaData) {
    return PastListEmptyWidget(
      memberPicture: orderPageMetaData!.memberPicture,
      fetchEvent: fetchMode,
      widgetsIn: widgets,
      i18nIn: i18n,
    );
  }

  BaseSliverListStatelessWidget getListWidget(orderList, orderPageMetaData, paginationInfo, fetchEvent, searchQuery) {
    return PastListWidget(
        orderList: orderList,
        orderPageMetaData: orderPageMetaData,
        paginationInfo: paginationInfo,
        fetchEvent: fetchMode,
        searchQuery: searchQuery,
        widgetsIn: widgets,
    );
  }
}
