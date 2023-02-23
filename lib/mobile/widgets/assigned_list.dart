import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';

import 'package:my24app/core/widgets/widgets.dart';
import 'package:my24app/core/widgets/slivers/base_widgets.dart';
import 'package:my24app/core/widgets/slivers/app_bars.dart';
import 'package:my24app/mobile/blocs/assignedorder_bloc.dart';
import 'package:my24app/mobile/models/models.dart';
import 'package:my24app/mobile/pages/assigned.dart';
import 'package:my24app/core/models/models.dart';


// ignore: must_be_immutable
class AssignedOrderListErrorWidget extends BaseSliverListStatelessWidget {
  final List<AssignedOrder> orderList;
  final PaginationInfo paginationInfo;
  final OrderListData orderListData;
  final String searchQuery;
  var _searchController = TextEditingController();

  AssignedOrderListErrorWidget({
    Key key,
    @required this.orderList,
    @required this.orderListData,
    @required this.paginationInfo,
    @required this.searchQuery,
  }): super(
      key: key,
      modelName: 'orders.model_name'.tr(),
      paginationInfo: paginationInfo
  ){
    _searchController.text = searchQuery?? '';
  }

  SliverAppBar getAppBar(BuildContext context) {
    AssignedOrdersAppBarFactory factory = AssignedOrdersAppBarFactory(
        context: context,
        orderListData: orderListData,
        orders: orderList,
        count: paginationInfo.count,
        onStretch: _doRefresh
    );
    return factory.createAppBar();
  }

  SliverList getSliverList(BuildContext context) {
    return SliverList(
        delegate: SliverChildBuilderDelegate(
          (BuildContext context, int index) {
              AssignedOrder assignedOrder = orderList[index];

              return Column(
                children: [
                  ListTile(
                      title: createOrderListHeader2(assignedOrder.order, assignedOrder.assignedorderDate),
                      subtitle: createOrderListSubtitle2(assignedOrder.order),
                      onTap: () {
                        // navigate to next page
                        final page = AssignedOrderPage(assignedOrderPk: assignedOrder.id);
                        Navigator.push(context, new MaterialPageRoute(builder: (context) => page)
                        );
                      } // onTab
                  ),
                  if (index < orderList.length-1)
                    getMy24Divider(context)
                ],
              );
            },
            childCount: orderList.length
        )
    );
  }

  @override
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

  // private methods
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

  _doRefresh(BuildContext context) {
    final bloc = BlocProvider.of<AssignedOrderBloc>(context);

    bloc.add(AssignedOrderEvent(status: AssignedOrderEventStatus.DO_ASYNC));
    bloc.add(AssignedOrderEvent(
        status: AssignedOrderEventStatus.FETCH_ALL
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

// ignore: must_be_immutable
class AssignedOrderListEmptyErrorWidget extends BaseSliverPlainStatelessWidget {
  final List<AssignedOrder> orderList;
  final OrderListData orderListData;
  final String error;

  AssignedOrderListEmptyErrorWidget({
    Key key,
    @required this.orderList,
    @required this.orderListData,
    @required this.error,
  }): super(key: key);

  @override
  SliverAppBar getAppBar(BuildContext context) {
    AssignedOrdersAppBarFactory factory = AssignedOrdersAppBarFactory(
        context: context,
        orderListData: orderListData,
        orders: orderList,
        count: 0
    );
    return factory.createAppBar();
  }

  @override
  Widget getBottomSection(BuildContext context) {
    return SizedBox(height: 1);
  }

  @override
  Widget getContentWidget(BuildContext context) {
    if (error != null) {
      return errorNotice(error);
    }

    if (orderList.length == 0) {
      return Center(
          child: Column(
            children: [
              SizedBox(height: 30),
              Text('assigned_orders.list.notice_no_order'.tr())
            ],
          )
      );
    }

    return SizedBox(height: 0);
  }
}
