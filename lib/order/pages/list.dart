import 'package:my24app/order/blocs/order_bloc.dart';
import 'package:my24app/order/widgets/order/list.dart';
import 'package:my24app/order/widgets/order/error.dart';
import 'package:my24app/order/widgets/order/empty.dart';
import 'package:my24app/core/widgets/slivers/base_widgets.dart';
import 'package:my24app/order/models/order/models.dart';
import 'base_order.dart';


class OrderListPage extends BaseOrderListPage {
  final OrderEventStatus fetchMode = OrderEventStatus.FETCH_ALL;
  final String basePath = "orders.list";

  BaseErrorWidget getErrorWidget(String error, OrderPageMetaData orderPageMetaData) {
    return OrderListErrorWidget(
      error: error,
      orderPageMetaData: orderPageMetaData,
    );
  }

  BaseEmptyWidget getEmptyWidget() {
    return OrderListEmptyWidget();
  }

  BaseSliverListStatelessWidget getListWidget(orderList, orderPageMetaData, paginationInfo, fetchEvent, searchQuery) {
    return OrderListWidget(
        orderList: orderList,
        orderPageMetaData: orderPageMetaData,
        paginationInfo: paginationInfo,
        fetchEvent: fetchMode,
        searchQuery: searchQuery
    );
  }
}
