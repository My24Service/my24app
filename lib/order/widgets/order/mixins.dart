import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:my24app/core/widgets/widgets.dart';
import 'package:my24app/core/widgets/slivers/app_bars.dart';
import 'package:my24app/order/models/order/models.dart';
import 'package:my24app/order/blocs/order_bloc.dart';
import 'package:my24app/core/models/models.dart';


mixin OrderListMixin {
  final OrderListData orderListData = null;
  final List<Order> orderList = null;
  final PaginationInfo paginationInfo = null;
  final dynamic fetchEvent = null;
  final String searchQuery = null;
  final TextEditingController searchController = TextEditingController();

  Widget getBottomSection(BuildContext context) {
    return showPaginationSearchNewSection(
        context,
        paginationInfo,
        searchController,
        _nextPage,
        _previousPage,
        _doSearch,
        _handleNew,
        'orders.list.button_add'.tr()
    );
  }

  _handleNew(BuildContext context) {
    final bloc = BlocProvider.of<OrderBloc>(context);

    bloc.add(OrderEvent(
        status: OrderEventStatus.NEW
    ));
  }

  void doRefresh(BuildContext context) {
    final bloc = BlocProvider.of<OrderBloc>(context);

    bloc.add(OrderEvent(status: OrderEventStatus.DO_REFRESH));
    bloc.add(OrderEvent(status: fetchEvent));
  }

  SliverAppBar getAppBar(BuildContext context) {
    OrdersAppBarFactory factory = OrdersAppBarFactory(
        context: context,
        orderListData: orderListData,
        orders: orderList,
        count: paginationInfo.count,
        onStretch: doRefresh
    );
    return factory.createAppBar();
  }

  _nextPage(BuildContext context) {
    final bloc = BlocProvider.of<OrderBloc>(context);

    bloc.add(OrderEvent(status: OrderEventStatus.DO_ASYNC));
    bloc.add(OrderEvent(
      status: fetchEvent,
      page: paginationInfo.currentPage + 1,
      query: searchController.text,
    ));
  }

  _previousPage(BuildContext context) {
    final bloc = BlocProvider.of<OrderBloc>(context);

    bloc.add(OrderEvent(status: OrderEventStatus.DO_ASYNC));
    bloc.add(OrderEvent(
      status: fetchEvent,
      page: paginationInfo.currentPage - 1,
      query: searchController.text,
    ));
  }

  _doSearch(BuildContext context) {
    final bloc = BlocProvider.of<OrderBloc>(context);

    bloc.add(OrderEvent(status: OrderEventStatus.DO_ASYNC));
    bloc.add(OrderEvent(status: OrderEventStatus.DO_SEARCH));
    bloc.add(OrderEvent(
        status: fetchEvent,
        query: searchController.text,
        page: 1
    ));
  }
}
