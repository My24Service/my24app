import 'package:my24app/core/widgets/slivers/base_widgets.dart';

import 'package:my24app/order/blocs/order_bloc.dart';
import 'package:my24app/order/models/order/models.dart';
import 'package:my24app/core/models/models.dart';
import 'package:my24app/order/pages/page_meta_data_mixin.dart';
import 'package:my24app/order/widgets/order/past/empty.dart';
import 'package:my24app/order/widgets/order/sales/error.dart';
import 'package:my24app/order/widgets/order/sales/list.dart';
import 'base_order.dart';

class SalesPage extends BaseOrderListPage with PageMetaData {
  final OrderEventStatus fetchMode = OrderEventStatus.FETCH_SALES;
  final String basePath = "orders.sales";

  @override
  BaseEmptyWidget getEmptyWidget() {
    return PastListEmptyWidget();
  }

  @override
  BaseErrorWidget getErrorWidget(String error, OrderPageMetaData orderPageMetaData) {
    return SalesListErrorWidget(error: error, orderPageMetaData: orderPageMetaData);
  }

  @override
  BaseSliverListStatelessWidget getListWidget(List<Order> orderList, OrderPageMetaData orderPageMetaData, PaginationInfo paginationInfo, OrderEventStatus fetchEvent, String searchQuery) {
    return SalesListWidget(
        orderList: orderList,
        orderPageMetaData: orderPageMetaData,
        paginationInfo: paginationInfo,
        fetchEvent: fetchMode,
        searchQuery: searchQuery
    );
  }
}
