import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:my24_flutter_core/models/models.dart';
import 'package:my24_flutter_core/widgets/slivers/base_widgets.dart';
import 'package:my24_flutter_core/widgets/widgets.dart';
import 'package:my24_flutter_core/i18n.dart';

import 'package:my24app/order/models/order/models.dart';
import 'package:my24app/order/pages/documents.dart';
import 'package:my24app/order/blocs/order_bloc.dart';
import 'package:my24app/order/blocs/document_bloc.dart';
import 'package:my24app/order/pages/detail.dart';
import 'package:my24app/common/widgets/widgets.dart';
import '../../../mobile/blocs/assign_bloc.dart';
import '../../../mobile/pages/assign.dart';
import 'mixins.dart';

class OrderListWidget extends BaseSliverListStatelessWidget with OrderListMixin {
  final OrderPageMetaData orderPageMetaData;
  final List<Order>? orderList;
  final PaginationInfo paginationInfo;
  final OrderEventStatus fetchEvent;
  final String? searchQuery;
  final CoreWidgets widgetsIn;
  final My24i18n i18nIn = My24i18n(basePath: "orders.list");

  OrderListWidget({
    Key? key,
    required this.orderList,
    required this.orderPageMetaData,
    required this.fetchEvent,
    required this.searchQuery,
    required this.paginationInfo,
    required this.widgetsIn,
  }) : super(
    key: key,
    paginationInfo: paginationInfo,
    memberPicture: orderPageMetaData.memberPicture,
    widgets: widgetsIn,
    i18n: My24i18n(basePath: "orders.list")
  ) {
    searchController.text = searchQuery ?? '';
  }

  bool isPlanning() {
    return orderPageMetaData.submodel == 'planning_user';
  }

  SliverAppBar getAppBar(BuildContext context) {
    OrdersAppBarFactory factory = OrdersAppBarFactory(
        context: context,
        orderPageMetaData: orderPageMetaData,
        orders: orderList != null ? orderList : [],
        count: paginationInfo.count,
        onStretch: doRefresh);
    return factory.createAppBar();
  }

  @override
  SliverList getSliverList(BuildContext context) {
    return SliverList(
        delegate: SliverChildBuilderDelegate((BuildContext context, int index) {
      Order order = orderList![index];

      return Column(
        children: [
          ListTile(
              title: createOrderListHeader2(order, order.orderDate!),
              subtitle: createOrderListSubtitle2(order),
              onTap: () {
                _navOrderDetail(context, order.id);
              } // onTab
              ),
          SizedBox(height: 4),
          getButtonRow(context, order),
          if (index < orderList!.length - 1) widgetsIn.getMy24Divider(context)
        ],
      );
    }, childCount: orderList!.length));
  }

  navDocuments(BuildContext context, int? orderPk) {
    final page = OrderDocumentsPage(
      orderId: orderPk,
      bloc: OrderDocumentBloc(),
    );

    Navigator.push(context, MaterialPageRoute(builder: (context) => page));
  }

  showDeleteDialog(BuildContext context, int? orderPk) {
    widgetsIn.showDeleteDialogWrapper(
        i18nIn.$trans('delete_dialog_title'),
        i18nIn.$trans('delete_dialog_content'),
        () => doDelete(context, orderPk),
        context);
  }

  Widget getEditButton(BuildContext context, int? orderPk) {
    return widgetsIn.createEditButton(() => doEdit(context, orderPk));
  }

  Widget getDeleteButton(BuildContext context, int? orderPk) {
    return widgetsIn.createDeleteButton(
        () => showDeleteDialog(context, orderPk)
    );
  }

  Widget getDocumentsButton(BuildContext context, int? orderPk) {
    return widgetsIn.createElevatedButtonColored(
        i18nIn.$trans('button_documents'), () => navDocuments(context, orderPk));
  }

  Row getButtonRow(BuildContext context, Order order) {
    Row row;

    if (!orderPageMetaData.hasBranches! && isPlanning()) {
      row = Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Column(
            children: [
              Row(
                children: [
                  getEditButton(context, order.id),
                  SizedBox(width: 10),
                  getDocumentsButton(context, order.id),
                  SizedBox(width: 10),
                  getDeleteButton(context, order.id),
                ],
              ),
              SizedBox(height: 10),
              widgetsIn.createDefaultElevatedButton(
                  context,
                  i18nIn.$trans('button_assign'),
                  () => _navAssignOrder(context, order.id)
              )
            ],
          ),
        ],
      );
    } else {
      row = Row();
    }

    return row;
  }

  doEdit(BuildContext context, int? orderPk) {
    final bloc = BlocProvider.of<OrderBloc>(context);

    bloc.add(OrderEvent(status: OrderEventStatus.DO_ASYNC));
    bloc.add(OrderEvent(status: OrderEventStatus.FETCH_DETAIL, pk: orderPk));
  }

  doDelete(BuildContext context, int? orderPk) async {
    final bloc = BlocProvider.of<OrderBloc>(context);

    bloc.add(OrderEvent(status: OrderEventStatus.DO_ASYNC));
    bloc.add(OrderEvent(status: OrderEventStatus.DELETE, pk: orderPk));
  }

  void _navOrderDetail(BuildContext context, int? orderPk) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => OrderDetailPage(
              orderId: orderPk,
              bloc: OrderBloc(),
            )
        )
    );
  }

  _navAssignOrder(BuildContext context, int? orderPk) async {
    Navigator.push(context,
        MaterialPageRoute(
            builder: (context) => OrderAssignPage(
                bloc: AssignBloc(),
                orderId: orderPk
            )
        )
    );
  }
}
