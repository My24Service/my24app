import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:easy_localization/easy_localization.dart';

import 'models.dart';
import 'utils.dart';


Future<CustomerHistory> fetchCustomerHistory(http.Client client) async {
  SlidingToken newToken = await refreshSlidingToken(client);

  SharedPreferences prefs = await SharedPreferences.getInstance();
  final int customerId = prefs.getInt('customer_id');
  final String token = newToken.token;
  final url = await getUrl('/order/order/all_for_customer/?customer_id=$customerId&json');
  final response = await client.get(
      url,
      headers: getHeaders(token)
  );

  if (response.statusCode == 401) {
    Map<String, dynamic> reponseBody = json.decode(response.body);

    if (reponseBody['code'] == 'token_not_valid') {
      throw TokenExpiredException('token expired');
    }
  }

  if (response.statusCode == 200) {
    CustomerHistory results = CustomerHistory.fromJson(json.decode(response.body));
    return results;
  }

  throw Exception('customers.history.exception_fetch'.tr());
}


class CustomerHistoryPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _CustomerHistoryState();
  }
}

class _CustomerHistoryState extends State<CustomerHistoryPage> {
  CustomerHistory _customerHistory;
  List<CustomerHistoryOrder> _customerHistoryOrders = [];
  String _customer;
  bool _fetchDone = false;
  bool _error = false;

    @override
  void initState() {
    super.initState();
    _doAsync();
  }

  _doAsync() async {
    await _doFetchCustomerHistory();
  }

  Widget _createOrderLinesTable(List<Orderline> orderlines) {
    List<TableRow> rows = [];

    // header
    rows.add(TableRow(
      children: [
        Column(children: [
          createTableHeaderCell('generic.info_product'.tr())
        ]),
        Column(children: [
          createTableHeaderCell('generic.info_location'.tr())
        ]),
        Column(children: [
          createTableHeaderCell('generic.info_remarks'.tr())
        ]),
      ],
    ));

    // orderlines
    for (int i = 0; i < orderlines.length; ++i) {
      Orderline orderLine = orderlines[i];

      rows.add(TableRow(children: [
        Column(
            children: [
              createTableColumnCell('${orderLine.product}')
            ]
        ),
        Column(
            children: [
              createTableColumnCell('${orderLine.location}')
            ]
        ),
        Column(
            children: [
              createTableColumnCell('${orderLine.remarks}')
            ]
        ),
      ]));
    }

    return createTable(rows);
  }

  Widget _createOrderRow(CustomerHistoryOrder orderData) {
    return Table(
      children: [
        TableRow(
          children: [
            Table(
              children: [
                TableRow(
                  children: [
                    Text('customers.history.info_date'.tr(),
                      style: TextStyle(fontWeight: FontWeight.bold)
                    ),
                    Text('${orderData.orderDate}')
                  ]
                ),
                TableRow(
                  children: [
                    Text('customers.history.info_order_type'.tr(),
                      style: TextStyle(fontWeight: FontWeight.bold)
                    ),
                    Text('${orderData.orderType}'),
                  ]
                )
              ],
            ),
            Table(
              children: [
                TableRow(
                  children: [
                    Text('customers.history.info_reference'.tr(),
                      style: TextStyle(fontWeight: FontWeight.bold)
                    ),
                    Text(orderData.orderReference != null ? orderData.orderReference : '-')
                  ]
                ),
                TableRow(
                  children: [
                    Text('customers.history.info_customer_id'.tr(),
                      style: TextStyle(fontWeight: FontWeight.bold)
                    ),
                    Text(orderData.orderId != null ? orderData.orderId : '-')
                  ]
                ),
              ],
            )
            // _createOrderLinesTable(orderData.orderLines)
          ]
        ),
        TableRow(
          children: [
            SizedBox(height: 10),
            SizedBox(height: 10),
          ]
        ),
        TableRow(
          children: [
            SizedBox(width: 10),
            createBlueElevatedButton(
                orderData.workorderPdfUrl != null && orderData.workorderPdfUrl != '' ?
                  'customers.history.button_open_workorder'.tr() :
                  'customers.history.button_no_workorder'.tr(),
                () => launchURL(orderData.workorderPdfUrl)
            ),
          ]
        ),
        TableRow(
          children: [
            Divider(),
            Divider(),
          ]
        )
      ],
    );
  }

  _doFetchCustomerHistory() async {
    setState(() {
      _fetchDone = false;
      _error = false;
    });

    try {
        CustomerHistory result = await fetchCustomerHistory(http.Client());

        setState(() {
          _fetchDone = true;
          _customerHistoryOrders = result.orderData;
          _customer = result.customer;
        });
      } catch(e) {
        setState(() {
          _fetchDone = true;
          _error = true;
        });
      }
  }

  Widget _buildList() {
    if (_error) {
      return RefreshIndicator(
        child: Center(
            child: Column(
              children: [
                SizedBox(height: 30),
                Text('customers.history.exception_fetch'.tr())
              ],
            )
        ), onRefresh: () => _doFetchCustomerHistory(),
      );
    }

    if (_customerHistoryOrders.length == 0 && _fetchDone) {
      return RefreshIndicator(
          child: Center(
              child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: [
                    Center(
                        child: Column(
                          children: [
                            SizedBox(height: 30),
                            Text('customers.history.notice_no_history'.tr())
                          ],
                        )
                    )
                  ]
              )
          ),
          onRefresh: () => _doFetchCustomerHistory()
      );
    }

    if (_customerHistoryOrders.length == 0 && !_fetchDone) {
      return Center(child: CircularProgressIndicator());
    }

    return RefreshIndicator(
      child: ListView.builder(
          padding: EdgeInsets.all(8),
          itemCount: _customerHistoryOrders.length,
          itemBuilder: (BuildContext context, int index) {
            return Container(
              child: _createOrderRow(_customerHistoryOrders[index])
            );
          } // itemBuilder
      ),
      onRefresh: () => _doFetchCustomerHistory(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('customers.history.app_bar_title'.tr(namedArgs: {'customer': _customer})),
      ),
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
        child: _buildList(),
      ),
    );
  }
}
