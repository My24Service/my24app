import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

import 'package:my24app/core/widgets/widgets.dart';
import 'package:my24app/core/utils.dart';
import 'package:my24app/order/pages/documents.dart';
import 'package:my24app/order/pages/form.dart';
import 'package:my24app/order/pages/info.dart';
import 'package:my24app/order/models/models.dart';
import 'package:my24app/order/blocs/order_bloc.dart';
import 'package:my24app/order/api/order_api.dart';

// ignore: must_be_immutable
class OrderListWidget extends StatelessWidget {
  final ScrollController controller;
  final List<Order> orderList;

  var _searchController = TextEditingController();

  bool isPlanning = false;
  bool _inAsyncCall = false;

  OrderListWidget({
    Key key,
    @required this.controller,
    @required this.orderList,
  }): super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: utils.getUserSubmodel(),
      builder: (context, snapshot) {
        if(snapshot.data == null) {
          return loadingNotice();
        }

        isPlanning = snapshot.data == 'planning_user';

        return ModalProgressHUD(
            child: Column(
              children: [
                _showSearchRow(context),
                SizedBox(height: 20),
                Expanded(child: _buildList(context)),
              ]
            ), inAsyncCall: _inAsyncCall
        );
      }
    );
	}

  navEditOrder(BuildContext context, int orderPk) {
    Navigator.push(context,
        MaterialPageRoute(
          builder: (context) => OrderFormPage(
            orderPk: orderPk
          )
        )
    );
  }

  navDocuments(BuildContext context, int orderPk) {
    Navigator.push(context,
        MaterialPageRoute(
            builder: (context) => OrderDocumentsPage(orderPk: orderPk)
        )
    );
  }

  doDelete(BuildContext context, Order order) async {
    final bloc = BlocProvider.of<OrderBloc>(context);

    bloc.add(OrderEvent(status: OrderEventStatus.DO_ASYNC));
    bloc.add(OrderEvent(
        status: OrderEventStatus.DELETE, value: order.id));
  }

  showDeleteDialog(BuildContext context, Order order) {
    showDeleteDialogWrapper(
      'orders.delete_dialog_title'.tr(),
      'orders.delete_dialog_content'.tr(),
      context, () => doDelete(context, order));
  }

  Row _showSearchRow(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(width: 220, child:
          TextField(
            controller: _searchController,
          ),
        ),
        createBlueElevatedButton(
            'generic.action_search'.tr(),
            () => _doSearch(context, _searchController.text)
        ),
      ],
    );
  }

  Row getButtonRow(BuildContext context, Order order) {
    Row row;

    if(isPlanning) {
      row = Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          createBlueElevatedButton(
              'generic.action_edit'.tr(),
              () => navEditOrder(context, order.id)
          ),
          SizedBox(width: 10),
          createBlueElevatedButton(
              'orders.unaccepted.button_documents'.tr(),
              () => navDocuments(context, order.id)),
          SizedBox(width: 10),
          createBlueElevatedButton(
              'generic.action_delete'.tr(),
              () => showDeleteDialog(context, order),
              primaryColor: Colors.red),
        ],
      );
    } else {
      row = Row();
    }

    return row;
  }

  _doSearch(BuildContext context, String query) {
    final bloc = BlocProvider.of<OrderBloc>(context);

    bloc.add(OrderEvent(status: OrderEventStatus.DO_ASYNC));
    bloc.add(OrderEvent(
        status: OrderEventStatus.FETCH_ALL, value: query));
  }

  Widget createOrderListHeader(Order order) {
    return Table(
      children: [
        TableRow(
            children: [
              Text('orders.info_order_date'.tr(), style: TextStyle(fontWeight: FontWeight.bold)),
              Text('${order.orderDate}')
            ]
        ),
        TableRow(
            children: [
              Text('orders.info_order_id'.tr(), style: TextStyle(fontWeight: FontWeight.bold)),
              Text('${order.orderId}')
            ]
        ),
        TableRow(
            children: [
              SizedBox(height: 10),
              Text(''),
            ]
        )
      ],
    );
  }

  Widget createOrderListSubtitle(Order order) {
    return Table(
      children: [
        TableRow(
            children: [
              Text('orders.info_customer'.tr(), style: TextStyle(fontWeight: FontWeight.bold)),
              Text('${order.orderName}'),
            ]
        ),
        TableRow(
            children: [
              SizedBox(height: 3),
              SizedBox(height: 3),
            ]
        ),
        TableRow(
            children: [
              Text('orders.info_address'.tr(), style: TextStyle(fontWeight: FontWeight.bold)),
              Text('${order.orderAddress}'),
            ]
        ),
        TableRow(
            children: [
              SizedBox(height: 3),
              SizedBox(height: 3),
            ]
        ),
        TableRow(
            children: [
              Text('orders.info_postal_city'.tr(), style: TextStyle(fontWeight: FontWeight.bold)),
              Text('${order.orderCountryCode}-${order.orderPostal} ${order.orderCity}'),
            ]
        ),
        TableRow(
            children: [
              SizedBox(height: 3),
              SizedBox(height: 3),
            ]
        ),
        TableRow(
            children: [
              Text('orders.info_order_type'.tr(), style: TextStyle(fontWeight: FontWeight.bold)),
              Text('${order.orderType}'),
            ]
        ),
        TableRow(
            children: [
              SizedBox(height: 3),
              SizedBox(height: 3),
            ]
        ),
        TableRow(
            children: [
              Text('orders.info_last_status'.tr(), style: TextStyle(fontWeight: FontWeight.bold)),
              Text('${order.lastStatusFull}')
            ]
        )
      ],
    );
  }

  doRefresh(BuildContext context) {
    final bloc = BlocProvider.of<OrderBloc>(context);

    bloc.add(OrderEvent(status: OrderEventStatus.DO_ASYNC));
    bloc.add(OrderEvent(
        status: OrderEventStatus.FETCH_ALL));
  }

  Widget _buildList(BuildContext context) {
    return RefreshIndicator(
        child: ListView.builder(
            controller: controller,
            key: PageStorageKey<String>('orderList'),
            scrollDirection: Axis.vertical,
            physics: AlwaysScrollableScrollPhysics(),
            shrinkWrap: true,
            padding: EdgeInsets.all(8),
            itemCount: orderList.length,
            itemBuilder: (BuildContext context, int index) {
              Order order = orderList[index];

              return Column(
                children: [
                  ListTile(
                      title: createOrderListHeader(order),
                      subtitle: createOrderListSubtitle(order),
                      onTap: () async {
                        // navigate to detail page
                        Navigator.push(context,
                            MaterialPageRoute(
                                builder: (context) => OrderInfoPage(
                                    orderPk: order.id))
                        );
                      } // onTab
                  ),
                  SizedBox(height: 10),
                  getButtonRow(context, order),
                  SizedBox(height: 10)
                ],
              );
            } // itemBuilder
        ),
        onRefresh: () async {
          Future.delayed(
              Duration(milliseconds: 5),
              () {
                doRefresh(context);
              });
        },
    );
  }
}
