import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:my24app/order/models/order/models.dart';
import 'package:my24app/core/models/models.dart';
import 'package:my24app/core/widgets/slivers/base_widgets.dart';
import 'package:my24app/core/widgets/widgets.dart';
import 'package:my24app/order/pages/info.dart';
import 'package:my24app/order/pages/form.dart';
import 'package:my24app/order/pages/documents.dart';
import 'package:my24app/order/blocs/order_bloc.dart';
import 'package:my24app/core/i18n_mixin.dart';
import 'mixins.dart';


class OrderListWidget extends BaseSliverListStatelessWidget with OrderListMixin, i18nMixin {
  final String basePath = "orders.list";
  final OrderPageMetaData orderPageMetaData;
  final List<Order> orderList;
  final PaginationInfo paginationInfo;
  final dynamic fetchEvent;
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
  ) {
    searchController.text = searchQuery?? '';
    paginationInfo.debug();
  }

  bool isPlanning() {
    return orderPageMetaData.submodel == 'planning_user';
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
        $trans('delete_dialog_title'),
        $trans('delete_dialog_content'),
        () => doDelete(context, order),
        context
    );
  }

  Row getButtonRow(BuildContext context, Order order) {
    Row row;

    if(isPlanning()) {
      row = Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          createEditButton(() => navEditOrder(context, order.id)),
          SizedBox(width: 10),
          createElevatedButtonColored(
              $trans('button_documents'),
              () => navDocuments(context, order.id)),
          SizedBox(width: 10),
          createDeleteButton(
              $trans('action_delete', pathOverride: 'generic'),
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
    bloc.add(OrderEvent(status: OrderEventStatus.DO_REFRESH));
    bloc.add(OrderEvent(status: OrderEventStatus.FETCH_ALL));
  }
}
