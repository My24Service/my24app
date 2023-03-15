import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';

import 'package:my24app/core/models/models.dart';
import 'package:my24app/core/widgets/widgets.dart';
import 'package:my24app/core/widgets/slivers/base_widgets.dart';
import 'package:my24app/core/widgets/slivers/app_bars.dart';
import 'package:my24app/order/pages/documents.dart';
import 'package:my24app/order/pages/form.dart';
import 'package:my24app/order/pages/info.dart';
import 'package:my24app/order/models/order/models.dart';
import 'package:my24app/order/blocs/order_bloc.dart';

// ignore: must_be_immutable
class OrderListWidget extends BaseSliverListStatelessWidget {
  final OrderPageMetaData orderListData;
  final List<Order> orderList;
  final PaginationInfo paginationInfo;
  final dynamic fetchEvent;
  final String searchQuery;
  final String error;

  TextEditingController _searchController = TextEditingController();

  bool isPlanning = false;

  OrderListWidget({
    Key key,
    @required this.orderListData,
    @required this.orderList,
    @required this.paginationInfo,
    @required this.fetchEvent,
    @required this.searchQuery,
    @required this.error,
  }): super(
      key: key,
      paginationInfo: paginationInfo
  ) {
    _searchController.text = searchQuery?? '';
    isPlanning = orderListData.submodel == 'planning_user';
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

  @override
  SliverList getSliverList(BuildContext context) {
    return SliverList(
        delegate: SliverChildBuilderDelegate(
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
                            new MaterialPageRoute(builder: (context) => page)
                        );
                      } // onTab
                  ),
                  SizedBox(height: 4),
                  getButtonRow(context, order),
                  if (index < orderList.length-1)
                    getMy24Divider(context)
                ],
              );
            },
            childCount: orderList.length
        )
    );
  }

  SliverAppBar getAppBar(BuildContext context) {
    OrdersAppBarFactory factory = OrdersAppBarFactory(
        context: context,
        orderPageMetaData: orderListData,
        orders: orderList,
        count: paginationInfo.count,
        onStretch: doRefresh
    );
    return factory.createAppBar();
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
        context
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
    bloc.add(OrderEvent(status: OrderEventStatus.DELETE, pk: order.id));
  }

  doRefresh(BuildContext context) {
    final bloc = BlocProvider.of<OrderBloc>(context);

    bloc.add(OrderEvent(status: OrderEventStatus.DO_REFRESH));
    bloc.add(OrderEvent(status: fetchEvent));
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
}

class OrderListEmptyErrorWidget extends BaseSliverPlainStatelessWidget {
  final OrderPageMetaData orderListData;
  final List<Order> orderList;
  final String error;
  final dynamic fetchEvent;

  OrderListEmptyErrorWidget({
    Key key,
    @required this.orderList,
    @required this.orderListData,
    @required this.error,
    @required this.fetchEvent
  }): super(key: key);


  @override
  String getAppBarSubtitle(BuildContext context) {
    return "";
  }

  @override
  String getAppBarTitle(BuildContext context) {
    return "";
  }

  @override
  SliverAppBar getAppBar(BuildContext context) {
    OrdersAppBarFactory factory = OrdersAppBarFactory(
        context: context,
        orderPageMetaData: orderListData,
        orders: orderList,
        count: 0,
        onStretch: doRefresh
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
              Text('orders.list.notice_no_order'.tr())
            ],
          )
      );
    }

    return SizedBox(height: 0);
  }

  doRefresh(BuildContext context) {
    final bloc = BlocProvider.of<OrderBloc>(context);

    bloc.add(OrderEvent(status: OrderEventStatus.DO_REFRESH));
    bloc.add(OrderEvent(status: fetchEvent));
  }
}
