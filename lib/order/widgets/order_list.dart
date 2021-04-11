import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:my24app/order/models/models.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:my24app/order/blocs/order_bloc.dart';
import 'package:my24app/core/widgets/widgets.dart';
import 'package:my24app/core/utils.dart';
import 'package:my24app/order/pages/edit.dart';

// ignore: must_be_immutable
class OrderListWidget extends StatelessWidget {
  final Orders orders;
  var _searchController = TextEditingController();
  bool _isPlanning = false;

  OrderListWidget({
    Key key,
    @required this.orders,
  }): super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: utils.getUserSubmodel(),
      builder: (ctx, snapshot) {
        _isPlanning = snapshot.data == 'planning_user';

        return Column(
                children: [
                  _showSearchRow(context),
                  SizedBox(height: 20),
                  Expanded(child: _buildList(context)),
                ]
              );
        }
    );
	}

  _storeOrderPk(int pk) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('order_pk', pk);
  }

  _navEditOrder(BuildContext context, int orderPk) {
    _storeOrderPk(orderPk);

    Navigator.push(context,
        MaterialPageRoute(
          builder: (context) => OrderEditPage(
            orderPk: orderPk,
            isPlanning: _isPlanning,
          )
        )
    );
  }

  _doDelete(BuildContext context, Order order) async {
    final bloc = BlocProvider.of<OrderBloc>(context);

    bloc.add(OrderEvent(
        status: OrderEventStatus.DELETE, value: order.id));
  }

  _showDeleteDialog(BuildContext context, Order order) {
    showDeleteDialog(
      'orders.delete_dialog_title'.tr(),
      'orders.delete_dialog_content'.tr(),
      context, () => _doDelete(context, order));
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

  Row _getListButtons(BuildContext context, Order order) {
    Row row;

    if(_isPlanning) {
      row = Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          createBlueElevatedButton(
              'generic.action_edit'.tr(),
              () => _navEditOrder(context, order.id)
          ),
          SizedBox(width: 10),
          createBlueElevatedButton(
              'generic.action_delete'.tr(),
              () => _showDeleteDialog(context, order),
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

  Widget _buildList(BuildContext context) {
    return RefreshIndicator(
        child: ListView.builder(
            scrollDirection: Axis.vertical,
            shrinkWrap: true,
            padding: EdgeInsets.all(8),
            itemCount: orders.results.length,
            itemBuilder: (BuildContext context, int index) {
              Order order = orders.results[index];

              return Column(
                children: [
                  ListTile(
                      title: createOrderListHeader(order),
                      subtitle: createOrderListSubtitle(order),
                      onTap: () async {
                        // store order_pk
                        await _storeOrderPk(order.id);

                        // navigate to detail page
                        // Navigator.push(context,
                        //     new MaterialPageRoute(builder: (context) => OrderDetailPage())
                        // );
                      } // onTab
                  ),
                  SizedBox(height: 10),
                  _getListButtons(context, order),
                  SizedBox(height: 10)
                ],
              );
            } // itemBuilder
        ),
        onRefresh: () async {
          Future.delayed(
              Duration(milliseconds: 5),
              () {
                final bloc = BlocProvider.of<OrderBloc>(context);

                bloc.add(OrderEvent(
                    status: OrderEventStatus.FETCH_ALL));
              });
        },
    );
  }
}
