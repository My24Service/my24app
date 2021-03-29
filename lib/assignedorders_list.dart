import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:easy_localization/easy_localization.dart';

import 'models.dart';
import 'utils.dart';
import 'assigned_order.dart';
import 'login.dart';


Future<AssignedOrders> fetchAssignedOrders(http.Client client) async {
  // refresh token
  SlidingToken newToken = await refreshSlidingToken(client);

  if (newToken == null) {
    throw TokenExpiredException('token expired');
  }

  // refresh last position
  await storeLastPosition(http.Client());

  // send device token
  await postDeviceToken(http.Client());

  // make call
  SharedPreferences prefs = await SharedPreferences.getInstance();
  final int userId = prefs.getInt('user_id');
  final String token = newToken.token;
  final url = await getUrl('/mobile/assignedorder/list_app/?user_pk=$userId&json');
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
    AssignedOrders results = AssignedOrders.fromJson(json.decode(response.body));
    return results;
  }

  throw Exception('Failed to load assigned orders: ${response.statusCode}, ${response.body}');
}

class AssignedOrdersListPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _AssignedOrderState();
  }
}

class _AssignedOrderState extends State<AssignedOrdersListPage> {
  List<AssignedOrder> _assignedOrders = [];
  String firstName;
  bool _fetchDone = false;
  Widget _drawer;

  @override
  void initState() {
    super.initState();
    _doAsync();
  }

  _doAsync() async {
    await _getFirstName();
    await _doFetchAssignedOrders();
    await _getDrawerForUser();
  }

  _getDrawerForUser() async {
    Widget drawer = await getDrawerForUser(context);

    setState(() {
      _drawer = drawer;
    });
  }

  _doFetchAssignedOrders() async {
    AssignedOrders result;

    try {
      result = await fetchAssignedOrders(http.Client());
    } on TokenExpiredException {
      SlidingToken token = await refreshSlidingToken(http.Client());

      if (token == null) {
        // redirect to login page?
        displayDialog(context, 'Error', 'Error refershing token');
        Navigator.push(context,
            new MaterialPageRoute(
                builder: (context) => LoginPageWidget())
        );

        return;
      }

      // try again with new token
      result = await fetchAssignedOrders(http.Client());
    }

    setState(() {
      _fetchDone = true;
      _assignedOrders = result.results;
    });
  }

  _storeAssignedorderPk(int pk) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('assignedorder_pk', pk);
  }

  _storeOrderPk(int pk) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('order_pk', pk);
  }

  Widget _buildList() {
    if (_assignedOrders.length == 0 && _fetchDone) {
      return RefreshIndicator(
        child: Center(
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                Center(
                    child: Column(
                      children: [
                        SizedBox(height: 30),
                        Text('No orders assigned.')
                      ],
                    )
                )
              ]
          )
        ),
        onRefresh: () => _doFetchAssignedOrders()
      );
    }

    if (_assignedOrders.length == 0 && !_fetchDone) {
      return Center(child: CircularProgressIndicator());
    }

    return RefreshIndicator(
        child: ListView.builder(
            padding: EdgeInsets.all(8),
            itemCount: _assignedOrders.length,
            itemBuilder: (BuildContext context, int index) {
              return ListTile(
                title: createOrderListHeader(_assignedOrders[index].order),
                subtitle: createOrderListSubtitle(_assignedOrders[index].order),
                onTap: () {
                  // store assignedorder.id
                  _storeAssignedorderPk(_assignedOrders[index].id);

                  // store order.id
                  _storeOrderPk(_assignedOrders[index].order.id);

                  // navigate to next page
                  Navigator.push(context,
                      new MaterialPageRoute(builder: (context) =>
                          AssignedOrderPage()
                      )
                  );
                } // onTab
              );
            } // itemBuilder
        ),
        onRefresh: () => _doFetchAssignedOrders(),
    );
  }

  Future<void> _getFirstName() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    firstName = prefs.getString('first_name');

    setState(() {
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Orders for $firstName'),
      ),
      body: Container(
        child: _buildList(),
      ),
      drawer: _drawer,
    );
  }
}
