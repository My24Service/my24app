import 'package:my24app/core/widgets/slivers/base_widgets.dart';
import 'package:my24app/order/blocs/order_bloc.dart';
import 'package:my24app/order/models/order/models.dart';
import 'package:my24app/core/models/models.dart';
import 'package:my24app/order/widgets/order/unassigned/empty.dart';
import 'package:my24app/order/widgets/order/unassigned/error.dart';
import 'package:my24app/order/widgets/order/unassigned/list.dart';
import 'base_order.dart';


class OrdersUnAssignedPage extends BaseOrderListPage {
  final OrderEventStatus fetchMode = OrderEventStatus.FETCH_UNASSIGNED;
  final String basePath = "orders.unassigned";

  @override
  BaseEmptyWidget getEmptyWidget() {
    return OrdersUnAssignedEmptyWidget();
  }

  @override
  BaseErrorWidget getErrorWidget(String error, OrderPageMetaData orderPageMetaData) {
    return OrdersUnAssignedErrorWidget(
      error: error,
      orderPageMetaData: orderPageMetaData,
    );
  }

  @override
  BaseSliverListStatelessWidget getListWidget(List<Order> orderList, OrderPageMetaData orderPageMetaData, PaginationInfo paginationInfo, OrderEventStatus fetchEvent, String searchQuery) {
    return OrdersUnAssignedWidget(
        orderList: orderList,
        orderPageMetaData: orderPageMetaData,
        paginationInfo: paginationInfo,
        fetchEvent: fetchMode,
        searchQuery: searchQuery
    );
  }
}
