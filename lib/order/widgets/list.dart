import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:my24app/core/models/models.dart';

import 'package:my24app/core/widgets/widgets.dart';
import 'package:my24app/core/widgets/sliver_classes.dart';
import 'package:my24app/order/pages/documents.dart';
import 'package:my24app/order/pages/form.dart';
import 'package:my24app/order/pages/info.dart';
import 'package:my24app/order/models/models.dart';
import 'package:my24app/order/blocs/order_bloc.dart';

// ignore: must_be_immutable
class OrderListWidget extends StatelessWidget {
  final OrderListData orderListData;
  final List<Order> orderList;
  final PaginationInfo paginationInfo;
  final dynamic fetchEvent;
  final String searchQuery;
  final String error;
  BuildContext _context;

  var _searchController = TextEditingController();

  bool isPlanning = false;

  OrderListWidget({
    Key key,
    @required this.orderListData,
    @required this.orderList,
    @required this.paginationInfo,
    @required this.fetchEvent,
    @required this.searchQuery,
    @required this.error,
  }): super(key: key);

  @override
  Widget build(BuildContext context) {
    _context = context;
    _searchController.text = searchQuery?? '';
    isPlanning = orderListData.submodel == 'planning_user';

    return Column(
        children: [
          Expanded(child: _buildList(context)),
          if (paginationInfo.count > 1 || searchQuery != null)
            showPaginationSearchSection(
              context,
              paginationInfo,
              _searchController,
              _nextPage,
              _previousPage,
              _doSearch
          )
        ]
    );
	}

  navEditOrder(BuildContext context, int orderPk) {
    final page = OrderFormPage(orderPk: orderPk);

    Navigator.push(context,
        MaterialPageRoute(
          builder: (context) => page
        )
    );
  }

  navDocuments(BuildContext context, int orderPk) {
    final page = OrderDocumentsPage(orderPk: orderPk);

    Navigator.push(context,
        MaterialPageRoute(
            builder: (context) => page
        )
    );
  }

  showDeleteDialog(BuildContext context, Order order) {
    showDeleteDialogWrapper(
      'orders.delete_dialog_title'.tr(),
      'orders.delete_dialog_content'.tr(),
      () => doDelete(context, order),
        _context
    );
  }

  Row getButtonRow(BuildContext context, Order order) {
    Row row;

    if(isPlanning) {
      row = Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          createEditButton(() => navEditOrder(context, order.id)),
          SizedBox(width: 10),
          createElevatedButtonColored(
              'orders.unaccepted.button_documents'.tr(),
              () => navDocuments(context, order.id)),
          SizedBox(width: 10),
          createDeleteButton(
              'generic.action_delete'.tr(),
              () => showDeleteDialog(context, order)
          ),
        ],
      );
    } else {
      row = Row();
    }

    return row;
  }

  doDelete(BuildContext context, Order order) async {
    final bloc = BlocProvider.of<OrderBloc>(context);

    bloc.add(OrderEvent(status: OrderEventStatus.DO_ASYNC));
    bloc.add(OrderEvent(
        status: OrderEventStatus.DELETE, value: order.id));
    bloc.add(OrderEvent(status: OrderEventStatus.DO_REFRESH));
    bloc.add(OrderEvent(status: OrderEventStatus.FETCH_ALL));
  }

  doRefresh(BuildContext context) {
    final bloc = BlocProvider.of<OrderBloc>(context);

    bloc.add(OrderEvent(status: OrderEventStatus.DO_REFRESH));
    bloc.add(OrderEvent(status: fetchEvent));
  }

  SliverAppBar getAppBar(BuildContext context) {
    OrdersAppBarFactory factory = OrdersAppBarFactory(
        context: context,
        orderListData: orderListData,
        orders: orderList,
        count: paginationInfo.count
    );
    return factory.createAppBar();
  }

  // private methods
  _doSearch(BuildContext context) {
    final bloc = BlocProvider.of<OrderBloc>(context);

    bloc.add(OrderEvent(status: OrderEventStatus.DO_ASYNC));
    bloc.add(OrderEvent(status: OrderEventStatus.DO_SEARCH));
    bloc.add(OrderEvent(
        status: fetchEvent,
        query: _searchController.text,
        page: 1
    ));
  }

  _nextPage(BuildContext context) {
    final bloc = BlocProvider.of<OrderBloc>(context);

    bloc.add(OrderEvent(status: OrderEventStatus.DO_ASYNC));
    bloc.add(OrderEvent(
        status: fetchEvent,
        page: paginationInfo.currentPage + 1,
        query: _searchController.text,
    ));
  }

  _previousPage(BuildContext context) {
    final bloc = BlocProvider.of<OrderBloc>(context);

    bloc.add(OrderEvent(status: OrderEventStatus.DO_ASYNC));
    bloc.add(OrderEvent(
        status: fetchEvent,
        page: paginationInfo.currentPage - 1,
        query: _searchController.text,
    ));
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
          onRefresh: () => doRefresh(context)
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
                              Text('orders.list.notice_no_order'.tr())
                            ],
                          )
                      )
                    ])
                )
              ]
          ),
          onRefresh: () => doRefresh(context)
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
                      Order order = orderList[index];
                      return Column(
                          children: [
                            ListTile(
                              title: createOrderListHeader2(order, order.orderDate),
                              subtitle: createOrderListSubtitle2(order),
                              onTap: () {
                                // navigate to next page
                                final page = OrderInfoPage(orderPk: order.id);

                                Navigator.push(context,
                                  new MaterialPageRoute(builder: (context) => page
                                ));
                              } // onTab
                            ),
                            SizedBox(height: 4),
                            getButtonRow(context, order),
                            if (index < orderList.length-1)
                              getMy24Divider(context)
                          ]
                      );
                    },
                    childCount: orderList != null ? orderList.length : 0
                )
            )
          ]
      ),
      onRefresh: () => doRefresh(context),
    );
  }
}
