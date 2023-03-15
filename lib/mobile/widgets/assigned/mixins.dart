import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:my24app/core/widgets/widgets.dart';
import 'package:my24app/core/widgets/slivers/app_bars.dart';
import 'package:my24app/mobile/blocs/assignedorder_bloc.dart';
import 'package:my24app/mobile/models/models.dart';
import 'package:my24app/core/models/models.dart';


mixin AssignedListMixin {
  final List<AssignedOrder> orderList = [];
  final PaginationInfo paginationInfo = null;
  final OrderPageMetaData orderListData = null;
  final String searchQuery = null;
  final _searchController = TextEditingController();

  Widget getBottomSection(BuildContext context) {
    return showPaginationSearchSection(
        context,
        paginationInfo,
        _searchController,
        _nextPage,
        _previousPage,
        _doSearch
    );
  }

  void doRefresh(BuildContext context) {
    final bloc = BlocProvider.of<AssignedOrderBloc>(context);

    bloc.add(AssignedOrderEvent(status: AssignedOrderEventStatus.DO_ASYNC));
    bloc.add(AssignedOrderEvent(
        status: AssignedOrderEventStatus.FETCH_ALL
    ));
  }

  SliverAppBar getAppBar(BuildContext context) {
    AssignedOrdersAppBarFactory factory = AssignedOrdersAppBarFactory(
        context: context,
        orderPageMetaData: orderListData,
        orders: orderList,
        count: paginationInfo.count,
        onStretch: doRefresh
    );
    return factory.createAppBar();
  }

  _nextPage(BuildContext context) {
    final bloc = BlocProvider.of<AssignedOrderBloc>(context);

    bloc.add(AssignedOrderEvent(status: AssignedOrderEventStatus.DO_ASYNC));
    bloc.add(AssignedOrderEvent(
      status: AssignedOrderEventStatus.FETCH_ALL,
      page: paginationInfo.currentPage + 1,
      query: _searchController.text,
    ));
  }

  _previousPage(BuildContext context) {
    final bloc = BlocProvider.of<AssignedOrderBloc>(context);

    bloc.add(AssignedOrderEvent(status: AssignedOrderEventStatus.DO_ASYNC));
    bloc.add(AssignedOrderEvent(
      status: AssignedOrderEventStatus.FETCH_ALL,
      page: paginationInfo.currentPage - 1,
      query: _searchController.text,
    ));
  }

  _doSearch(BuildContext context) {
    final bloc = BlocProvider.of<AssignedOrderBloc>(context);

    bloc.add(AssignedOrderEvent(status: AssignedOrderEventStatus.DO_ASYNC));
    bloc.add(AssignedOrderEvent(
        status: AssignedOrderEventStatus.FETCH_ALL,
        query: _searchController.text,
        page: 1
    ));
  }
}
