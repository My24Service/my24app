import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'models.dart';
import 'utils.dart';


Future<CustomerHistory> fetchCustomerHistory(http.Client client) async {
  // refresh token
  SlidingToken newToken = await refreshSlidingToken(client);

  if (newToken == null) {
    throw TokenExpiredException('token expired');
  }

  // refresh last position
  // await storeLastPosition(http.Client());

  // make call
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
    refreshTokenBackground(client);
    CustomerHistory results = CustomerHistory.fromJson(json.decode(response.body));
    return results;
  }

  throw Exception('Failed to load customer history: ${response.statusCode}, ${response.body}');
}

class CustomerHistorytPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _CustomerHistoryState();
  }
}

class _CustomerHistoryState extends State<CustomerHistorytPage> {
  CustomerHistory _customerHistory;
  List<CustomerHistoryOrder> _customerHistoryOrders = [];
  String _customer;
  bool _fetchDone = false;

    @override
  void initState() {
    super.initState();
    _doAsync();
  }

  _doAsync() async {
    await _doFetchCustomerHistory();
  }

  _doFetchCustomerHistory() async {
    CustomerHistory result = await fetchCustomerHistory(http.Client());

    if (result == null) {
      displayDialog(context, 'Error', 'Error loading customer history');
      return;
    }

    setState(() {
      _fetchDone = true;
      _customerHistoryOrders = result.orderData;
      _customer = result.customer;
    });
  }

  Widget _createOrderLinesTable(List<Orderline> orderlines) {
    List<TableRow> rows = [];

    // header
    rows.add(TableRow(
      children: [
        Column(children: [
          createTableHeaderCell('Product')
        ]),
        Column(children: [
          createTableHeaderCell('Location')
        ]),
        Column(children: [
          createTableHeaderCell('Remarks')
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
                    Text('Date:', style: TextStyle(fontWeight: FontWeight.bold)),
                    Text('${orderData.orderDate}')
                  ]
                ),
                TableRow(
                  children: [
                    Text('Order type:', style: TextStyle(fontWeight: FontWeight.bold)),
                    Text('${orderData.orderType}'),
                  ]
                )
              ],
            ),
            Table(
              children: [
                TableRow(
                  children: [
                    Text('Reference:', style: TextStyle(fontWeight: FontWeight.bold)),
                    Text(orderData.orderReference != null ? orderData.orderReference : '-')
                  ]
                ),
                TableRow(
                  children: [
                    Text('Order ID:', style: TextStyle(fontWeight: FontWeight.bold)),
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
                orderData.workorderPdfUrl != null && orderData.workorderPdfUrl != '' ? 'Open workorder' : 'No workorder',
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

  Widget _buildList() {
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
                            Text('No customer history.')
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
        title: Text('History for $_customer'),
      ),
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
        child: _buildList(),
      ),
    );
  }
}
