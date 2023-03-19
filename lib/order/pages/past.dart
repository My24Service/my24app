import 'package:my24app/order/blocs/order_bloc.dart';
import 'package:my24app/core/models/models.dart';
import 'package:my24app/core/widgets/slivers/base_widgets.dart';
import 'package:my24app/order/widgets/order/past/list.dart';
import 'package:my24app/order/widgets/order/past/error.dart';
import 'package:my24app/order/widgets/order/past/empty.dart';
import 'base_order.dart';


class PastPage extends BaseOrderListPage {
  final OrderEventStatus fetchMode = OrderEventStatus.FETCH_PAST;
  final String basePath = "orders.unaccepted";

  BaseErrorWidget getErrorWidget(String error, OrderPageMetaData orderPageMetaData) {
    return PastListErrorWidget(
      error: error,
      orderPageMetaData: orderPageMetaData,
    );
  }

  BaseEmptyWidget getEmptyWidget() {
    return PastListEmptyWidget();
  }

  BaseSliverListStatelessWidget getListWidget(orderList, orderPageMetaData, paginationInfo, fetchEvent, searchQuery) {
    return PastListWidget(
        orderList: orderList,
        orderPageMetaData: orderPageMetaData,
        paginationInfo: paginationInfo,
        fetchEvent: fetchMode,
        searchQuery: searchQuery
    );
  }
}
