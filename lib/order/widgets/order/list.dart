import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:my24app/order/models/order/models.dart';
import 'package:my24app/core/models/models.dart';
import 'package:my24app/core/widgets/slivers/base_widgets.dart';
import 'package:my24app/core/widgets/widgets.dart';
import 'package:my24app/order/pages/documents.dart';
import 'package:my24app/core/widgets/slivers/app_bars.dart';
import 'package:my24app/order/blocs/order_bloc.dart';
import 'package:my24app/core/i18n_mixin.dart';
import 'package:my24app/order/blocs/document_bloc.dart';
import 'package:my24app/order/pages/detail.dart';
import 'mixins.dart';


class OrderListWidget extends BaseSliverListStatelessWidget with OrderListMixin, i18nMixin {
  final String basePath = "orders.list";
  final OrderPageMetaData orderPageMetaData;
  final List<Order> orderList;
  final PaginationInfo paginationInfo;
  final OrderEventStatus fetchEvent;
  final String searchQuery;

  OrderListWidget({
    Key key,
    @required this.orderList,
    @required this.orderPageMetaData,
    @required this.fetchEvent,
    @required this.searchQuery,
    @required this.paginationInfo,
  }): super(
    key: key,
    paginationInfo: paginationInfo,
    memberPicture: orderPageMetaData.memberPicture
  ) {
    searchController.text = searchQuery?? '';
  }

  bool isPlanning() {
    return orderPageMetaData.submodel == 'planning_user';
  }

  SliverAppBar getAppBar(BuildContext context) {
    OrdersAppBarFactory factory = OrdersAppBarFactory(
        context: context,
        orderPageMetaData: orderPageMetaData,
        orders: orderList != null ? orderList : [],
        count: paginationInfo != null ? paginationInfo.count : 0,
        onStretch: doRefresh
    );
    return factory.createAppBar();
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
                        print('onTap');
                        _navOrderDetail(context, order.id);
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

  navDocuments(BuildContext context, int orderPk) {
    final page = OrderDocumentsPage(
        orderId: orderPk,
        bloc: OrderDocumentBloc(),
    );

    Navigator.push(context,
        MaterialPageRoute(
            builder: (context) => page
        )
    );
  }

  showDeleteDialog(BuildContext context, int orderPk) {
    showDeleteDialogWrapper(
        $trans('delete_dialog_title'),
        $trans('delete_dialog_content'),
        () => doDelete(context, orderPk),
        context
    );
  }

  Widget getEditButton(BuildContext context, int orderPk) {
    return createEditButton(
      () => doEdit(context, orderPk)
    );
  }

  Widget getDeleteButton(BuildContext context, int orderPk) {
    return createDeleteButton(
      $trans('action_delete', pathOverride: 'generic'),
      () => showDeleteDialog(context, orderPk)
    );
  }

  Widget getDocumentsButton(BuildContext context, int orderPk) {
    return createElevatedButtonColored(
      $trans('button_documents'),
      () => navDocuments(context, orderPk)
    );
  }

  Row getButtonRow(BuildContext context, Order order) {
    Row row;

    if(!orderPageMetaData.hasBranches && isPlanning()) {
      row = Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          getEditButton(context, order.id),
          SizedBox(width: 10),
          getDocumentsButton(context, order.id),
          SizedBox(width: 10),
          getDeleteButton(context, order.id)
        ],
      );
    } else {
      row = Row();
    }

    return row;
  }

  doEdit(BuildContext context, int orderPk) {
    final bloc = BlocProvider.of<OrderBloc>(context);

    bloc.add(OrderEvent(status: OrderEventStatus.DO_ASYNC));
    bloc.add(OrderEvent(status: OrderEventStatus.FETCH_DETAIL, pk: orderPk));
  }

  doDelete(BuildContext context, int orderPk) async {
    final bloc = BlocProvider.of<OrderBloc>(context);

    bloc.add(OrderEvent(status: OrderEventStatus.DO_ASYNC));
    bloc.add(OrderEvent(status: OrderEventStatus.DELETE, pk: orderPk));
  }

  void _navOrderDetail(BuildContext context, int orderPk) {
    print('Navigator.push');
    Navigator.push(context, MaterialPageRoute(builder: (context) => OrderDetailPage(
      orderId: orderPk,
      bloc: OrderBloc(),
    )));
  }

}
