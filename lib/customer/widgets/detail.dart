import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:my24app/customer/models/models.dart';

import 'package:my24app/core/widgets/widgets.dart';
import 'package:my24app/core/utils.dart';
import 'package:my24app/order/models/models.dart';
import 'package:my24app/order/api/order_api.dart';

import '../../order/pages/info.dart';

class CustomerDetailWidget extends StatefulWidget {
  final Customer customer;

  CustomerDetailWidget({
    Key key,
    @required this.customer,
  }) : super(key: key);

  @override
  _CustomerDetailWidgetState createState() => _CustomerDetailWidgetState();
}

class _CustomerDetailWidgetState extends State<CustomerDetailWidget> {
  List<Order> _orderHistory = [];
  bool _inAsyncCall = false;

  @override
  void initState() {
    super.initState();
    _doAsync();
  }

  _doAsync() async {
    await _doFetchOrderHistory();
  }

  _doFetchOrderHistory() async {
    setState(() {
      _inAsyncCall = true;
    });

    try {
      Orders result = await orderApi.fetchOrderHistory(widget.customer.id);

      setState(() {
        _orderHistory = result.results;
        _inAsyncCall = false;
      });
    } catch(e) {
      setState(() {
        _inAsyncCall = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ModalProgressHUD(
        child: Center(
              child: _showMainView()
          ),
        inAsyncCall: _inAsyncCall);
  }

  Widget _showMainView() {
    return Align(
        alignment: Alignment.topRight,
        child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              createHeader('customers.detail.header_customer'.tr()),
              Table(
                children: [
                  TableRow(
                      children: [
                        Text('customers.info_customer_id'.tr(),
                            style: TextStyle(fontWeight: FontWeight.bold)
                        ),
                        Text(widget.customer.customerId),
                      ]
                  ),
                  TableRow(
                      children: [
                        Text('customers.info_name'.tr(),
                            style: TextStyle(fontWeight: FontWeight.bold)
                        ),
                        Text(widget.customer.name),
                      ]
                  ),
                  TableRow(
                      children: [
                        Text('customers.info_address'.tr(),
                            style: TextStyle(fontWeight: FontWeight.bold)
                        ),
                        Text(widget.customer.address),
                      ]
                  ),
                  TableRow(
                      children: [
                        Text('customers.info_postal'.tr(), style: TextStyle(fontWeight: FontWeight.bold)),
                        Text(widget.customer.postal),
                      ]
                  ),
                  TableRow(
                      children: [
                        Text('customers.info_country_city'.tr(),
                            style: TextStyle(fontWeight: FontWeight.bold)
                        ),
                        Text(widget.customer.countryCode + '/' + widget.customer.city),
                      ]
                  ),
                  TableRow(
                      children: [
                        Text('customers.info_contact'.tr(),
                            style: TextStyle(fontWeight: FontWeight.bold)
                        ),
                        Text(widget.customer.contact),
                      ]
                  ),
                  TableRow(
                      children: [
                        Text('customers.info_tel'.tr(),
                            style: TextStyle(fontWeight: FontWeight.bold)
                        ),
                        Text(widget.customer.tel),
                      ]
                  ),
                  TableRow(
                      children: [
                        Text('customers.info_mobile'.tr(),
                            style: TextStyle(fontWeight: FontWeight.bold)
                        ),
                        Text(widget.customer.mobile),
                      ]
                  ),
                  TableRow(
                      children: [
                        Divider(),
                        SizedBox(height: 10),
                      ]
                  ),
                ],
              ),
              Divider(),
              createHeader('customers.detail.header_order_history'.tr()),
              _createHistoryTable(),
            ]
        )
    );
  }

  Widget _createWorkorderText(Order order) {
    if (order.workorderPdfUrl != null && order.workorderPdfUrl != '') {
      return createBlueElevatedButton(
          'customers.detail.button_open_workorder'.tr(),
              () => utils.launchURL(order.workorderPdfUrl.replaceAll('/api', ''))
      );
    }

    return Text('-');
  }

  Widget _createOrderDetailButton(Order order) {
    return createBlueElevatedButton(
        'customers.history.button_view_order'.tr(),
        () => _navOrderDetail(order.id)
    );
  }

  void _navOrderDetail(int orderPk) {
    // navigate to detail page
    final page = OrderInfoPage(orderPk: orderPk);

    Navigator.push(context,
        MaterialPageRoute(
            builder: (context) => page)
    );
  }

  // order history
  Widget _createHistoryTable() {
    List<TableRow> rows = [];

    // header
    rows.add(TableRow(
      children: [
        Column(
            children:[
              createTableHeaderCell('orders.info_order_id'.tr())
            ]
        ),
        Column(
            children:[
              createTableHeaderCell('orders.info_order_date'.tr())
            ]
        ),
        Column(
            children:[
              createTableHeaderCell('orders.info_order_type'.tr())
            ]
        ),
        Column(
            children:[
              createTableHeaderCell('customers.detail.info_workorder'.tr())
            ]
        ),
        Column(
            children:[
              createTableHeaderCell('customers.detail.info_view_order'.tr())
            ]
        )
      ],
    ));

    for (int i = 0; i < _orderHistory.length; ++i) {
      Order order = _orderHistory[i];

      rows.add(
          TableRow(
              children: [
                Column(
                    children:[
                      createTableColumnCell(order.orderId)
                    ]
                ),
                Column(
                    children:[
                      createTableColumnCell(order.orderDate)
                    ]
                ),
                Column(
                    children:[
                      createTableColumnCell(order.orderType)
                    ]
                ),
                Column(
                    children:[
                      _createWorkorderText(order)
                    ]
                ),
                Column(
                    children:[
                      _createOrderDetailButton(order)
                    ]
                ),
              ]
          )
      );
    }
    return createTable(rows);
  }
}
