import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:my24app/customer/models/models.dart';

import 'package:my24app/core/widgets/widgets.dart';
import 'package:my24app/core/utils.dart';
import 'package:my24app/order/models/models.dart';
import 'package:my24app/order/api/order_api.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

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
        child: _showMainView(),
        inAsyncCall: _inAsyncCall
    );
  }

  Widget _showMainView() {
    return Align(
        alignment: Alignment.topRight,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            createHeader('customers.detail.header_customer'.tr()),
            buildCustomerInfoCard(context, widget.customer),
            getMy24Divider(context),
            _createHistorySection(context),
          ]
        )
    );
  }

  Widget _createWorkorderText(Order order) {
    if (order.workorderPdfUrl != null && order.workorderPdfUrl != '') {
      return createElevatedButtonColored(
          'customers.detail.button_open_workorder'.tr(),
              () => utils.launchURL(order.workorderPdfUrl.replaceAll('/api', ''))
      );
    }

    return Text('-');
  }

  Widget _createOrderDetailButton(Order order) {
    return createElevatedButtonColored(
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
  Widget _createHistorySection(BuildContext context) {
    return buildItemsSection(
        context,
        'customers.detail.header_order_history'.tr(),
        _orderHistory,
        (Order item) {
          String key = "${'orders.info_order_id'.tr()} / ${'orders.info_order_date'.tr()} / ${'orders.info_order_type'.tr()}";
          String value = "${item.orderId} / ${item.orderDate} / ${item.orderType}";
          return buildItemListKeyValueList(key, value);
        },
        (item) {
          return <Widget>[
            buildItemListCustomWidget(
                'customers.detail.info_workorder'.tr(),
                _createWorkorderText(item)
            ),
            buildItemListCustomWidget(
                'customers.detail.info_view_order'.tr(),
                _createOrderDetailButton(item)
            )
          ];
        }
    );
  }
}
