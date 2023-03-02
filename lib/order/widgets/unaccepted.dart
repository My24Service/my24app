import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:my24app/core/models/models.dart';
import 'package:my24app/order/models/order/models.dart';
import 'package:my24app/order/blocs/order_bloc.dart';
import 'package:my24app/core/widgets/widgets.dart';
import 'package:my24app/core/widgets/slivers/app_bars.dart';
import 'package:my24app/order/widgets/list.dart';
import '../pages/form.dart';


// ignore: must_be_immutable
class UnacceptedListWidget extends OrderListWidget {
  final List<Order> orderList;
  final OrderListData orderListData;
  final PaginationInfo paginationInfo;
  final dynamic fetchEvent;
  final String searchQuery;
  final String error;

  UnacceptedListWidget({
    Key key,
    @required this.orderList,
    @required this.orderListData,
    @required this.fetchEvent,
    @required this.searchQuery,
    @required this.paginationInfo,
    @required this.error,
  }): super(
      key: key,
      orderList: orderList,
      orderListData: orderListData,
      paginationInfo: paginationInfo,
      fetchEvent: fetchEvent,
      searchQuery: searchQuery,
      error: error
  );

  SliverAppBar getAppBar(BuildContext context) {
    UnacceptedOrdersAppBarFactory factory = UnacceptedOrdersAppBarFactory(
        context: context,
        orderListData: orderListData,
        orders: orderList,
        count: paginationInfo.count,
        onStretch: doRefresh
    );
    return factory.createAppBar();
  }

  showDeleteDialog(BuildContext context, Order order) {
    showDeleteDialogWrapper(
        'orders.delete_dialog_title'.tr(),
        'orders.delete_dialog_content'.tr(),
        () => doDelete(context, order),
      context
    );
  }

  doDelete(BuildContext context, Order order) async {
    final bloc = BlocProvider.of<OrderBloc>(context);

    bloc.add(OrderEvent(status: OrderEventStatus.DO_ASYNC));
    bloc.add(OrderEvent(
        status: OrderEventStatus.DELETE, value: order.id));
    bloc.add(OrderEvent(status: OrderEventStatus.DO_REFRESH));
    bloc.add(OrderEvent(status: OrderEventStatus.FETCH_ALL));
  }

  navEditOrder(BuildContext context, int orderPk) {
    final page = OrderFormPage(orderPk: orderPk);

    Navigator.push(context,
        MaterialPageRoute(
            builder: (context) => page
        )
    );
  }

  @override
  Row getButtonRow(BuildContext context, Order order) {
    Row row;
    Widget _editButton = createElevatedButtonColored(
        'generic.action_edit'.tr(),
          () => navEditOrder(context, order.id)
    );
    Widget _deleteButton = createElevatedButtonColored(
        'generic.action_delete'.tr(),
        () => showDeleteDialog(context, order),
        foregroundColor: Colors.red,
        backgroundColor: Colors.white
    );
    Widget _documentsButton = createElevatedButtonColored(
        'orders.unaccepted.button_documents'.tr(),
        () => navDocuments(context, order.id)
    );

    if (order.lastAcceptedStatus == 'rejected') {
      return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _deleteButton
          ]
      );
    }

    if (isPlanning) {
      row = Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _editButton,
          SizedBox(width: 10),
          _deleteButton,
        ],
      );
    } else {
      row = Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _editButton,
          SizedBox(width: 10),
          _documentsButton,
          SizedBox(width: 10),
          _deleteButton,
        ],
      );
    }

    return row;
  }
}

class UnacceptedListEmptyErrorWidget extends OrderListEmptyErrorWidget {
  final OrderListData orderListData;
  final List<Order> orderList;
  final String error;
  final dynamic fetchEvent;

  UnacceptedListEmptyErrorWidget({
    Key key,
    @required this.orderList,
    @required this.orderListData,
    @required this.error,
    @required this.fetchEvent
  }): super(
      key: key,
      error: error,
      orderList: orderList,
      fetchEvent: fetchEvent,
      orderListData: orderListData
  );
}
