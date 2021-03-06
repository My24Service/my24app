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

  void _doFetch() async {
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
            Column(
              children: [
                Row(
                  children: [
                    Text('Date:', style: TextStyle(fontWeight: FontWeight.bold)),
                    Text('${orderData.orderDate}')
                  ],
                ),
                Row(
                  children: [
                    Text('Order type:', style: TextStyle(fontWeight: FontWeight.bold)),
                    Text('${orderData.orderType}'),
                  ],
                ),
              ],
            ),
            _createOrderLinesTable(orderData.orderLines)
          ]
        ),
        TableRow(
          children: [
            RaisedButton(
              onPressed: () => launchURL(orderData.workorderPdfUrl),
              child: Text(orderData.workorderPdfUrl != null && orderData.workorderPdfUrl != '' ? 'Open workorder' : 'No workorder'),
            ),
            SizedBox(width: 10,)
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
                    Center(child: Text('\n\n\nNo customer history.'))
                  ]
              )
          ),
          onRefresh: _getData
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
      onRefresh: _getData,
    );
  }

  Future<void> _getData() async {
    setState(() {
      _doFetch();
    });
  }

  @override
  void initState() {
    super.initState();
    _getData();
    _doFetch();
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
