import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';

import 'package:my24app/core/widgets/widgets.dart';
import 'package:my24app/mobile/blocs/assignedorder_bloc.dart';
import 'package:my24app/mobile/models/models.dart';
import 'package:my24app/mobile/pages/assigned.dart';

import '../../core/models/models.dart';

class AssignedListWidget extends StatelessWidget {
  final List<AssignedOrder> orderList;
  final PaginationInfo paginationInfo;
  final OrderListData orderListData;
  final String error;

  AssignedListWidget({
    Key key,
    @required this.orderList,
    @required this.orderListData,
    @required this.paginationInfo,
    @required this.error,
  }): super(key: key);

  SliverAppBar getAppBar(BuildContext context) {
    AssignedOrdersAppBarFactory factory = AssignedOrdersAppBarFactory(
        context: context,
        orderListData: orderListData,
        orders: orderList
    );
    return factory.createAppBar();
  }

  @override
  Widget build(BuildContext context) {
    // _searchController.text = searchQuery?? '';

    return Column(
        children: [
          // _showSearchRow(context),
          // SizedBox(height: 20),
          Expanded(child: _buildList(context)),
          showPaginationSearchSection(context, paginationInfo, _nextPage, _previousPage)
        ]
    );
  }

  Widget _buildList(BuildContext context) {
    if (error != null) {
      return RefreshIndicator(
          child: CustomScrollView(
              slivers: [
                getAppBar(context),
                SliverToBoxAdapter(
                    child: errorNotice(error)
                )
              ]
          ),
          onRefresh: () => _doRefresh(context)
      );
    }

    if (orderList.length == 0) {
      return RefreshIndicator(
          child: CustomScrollView(
              slivers: [
                getAppBar(context),
                SliverFixedExtentList(
                  itemExtent: 50,
                  delegate: SliverChildListDelegate([
                      Center(
                          child: Column(
                            children: [
                              SizedBox(height: 30),
                              Text('assigned_orders.list.notice_no_order'.tr())
                            ],
                          )
                      )
                    ])
                  )
              ]
          ),
          onRefresh: () => _doRefresh(context)
      );
    }

    return RefreshIndicator(
        child: CustomScrollView(
            slivers: [
              getAppBar(context),
              makePaginationHeader(context, paginationInfo),
              SliverList(
                delegate: new SliverChildBuilderDelegate(
                  (BuildContext context, int index) {
                    AssignedOrder assignedOrder = orderList[index];

                    return ListTile(
                        title: createOrderListHeader2(assignedOrder.order, assignedOrder.assignedorderDate),
                        subtitle: createOrderListSubtitle2(assignedOrder.order),
                        onTap: () {
                          // navigate to next page
                          final page = AssignedOrderPage(assignedOrderPk: assignedOrder.id);

                          Navigator.push(context,
                              new MaterialPageRoute(builder: (context) => page
                              )
                          );
                        } // onTab
                    );

                  },
                  childCount: orderList.length
                )
              )
            ]
        ),
        onRefresh: () => _doRefresh(context),
    );
  }

  _nextPage(BuildContext context) async {
    final bloc = BlocProvider.of<AssignedOrderBloc>(context);

    bloc.add(AssignedOrderEvent(status: AssignedOrderEventStatus.DO_ASYNC));
    bloc.add(AssignedOrderEvent(
        status: AssignedOrderEventStatus.FETCH_ALL,
        page: paginationInfo.currentPage + 1));
  }

  _previousPage(BuildContext context) async {
    final bloc = BlocProvider.of<AssignedOrderBloc>(context);

    bloc.add(AssignedOrderEvent(status: AssignedOrderEventStatus.DO_ASYNC));
    bloc.add(AssignedOrderEvent(
        status: AssignedOrderEventStatus.FETCH_ALL,
        page: paginationInfo.currentPage - 1));
  }

  _doRefresh(BuildContext context) {
    final bloc = BlocProvider.of<AssignedOrderBloc>(context);

    bloc.add(AssignedOrderEvent(status: AssignedOrderEventStatus.DO_ASYNC));
    bloc.add(AssignedOrderEvent(
        status: AssignedOrderEventStatus.FETCH_ALL
    ));

    return Future.delayed(Duration(milliseconds: 100));
  }

  _doSearch(BuildContext context) {
    final bloc = BlocProvider.of<AssignedOrderBloc>(context);

    bloc.add(AssignedOrderEvent(status: AssignedOrderEventStatus.DO_ASYNC));
    bloc.add(AssignedOrderEvent(
        status: AssignedOrderEventStatus.FETCH_ALL
    ));

    return Future.delayed(Duration(milliseconds: 100));
  }
}
