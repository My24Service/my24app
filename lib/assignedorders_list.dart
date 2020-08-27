import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'models.dart';
import 'utils.dart';
import 'assigned_order.dart';
import 'main_dev.dart';
import 'login.dart';


Future<AssignedOrders> fetchAssignedOrders(http.Client client) async {
  // refresh token
  SlidingToken newToken = await refreshSlidingToken(client);

  if (newToken == null) {
    throw TokenExpiredException('token expired');
  }

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
    storeLatestLocation(client);
    AssignedOrders results = AssignedOrders.fromJson(json.decode(response.body));
    return results;
  }

  throw Exception('Failed to load assigned orders: ${response.statusCode}, ${response.body}');
}

class AssignedOrdersListWidget extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _AssignedOrderState();
  }
}

class _AssignedOrderState extends State<AssignedOrdersListWidget> {
  List<AssignedOrder> _assignedOrders = [];
  String firstName;
  bool _fetchDone = false;

  void _doFetch() async {
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

    if (result == null) {
      // redirect to login page?
      displayDialog(context, 'Error', 'Error loading assigned orders');
      return;
    }

    setState(() {
      _fetchDone = true;
      _assignedOrders = result.results;
    });
  }

  String _createHeader(Order order) {
    return '${order.orderDate} - ${order.orderName}';
  }

  String _createSubtitle(Order order) {
    return '${order.orderAddress}, ${order.orderCountryCode}-${order.orderPostal} ${order.orderCity}';
  }

  _storeAssignedorderPk(int pk) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('assignedorder_pk', pk);
    print('stored assignedorder_pk: $pk');
  }

  _storeOrderPk(int pk) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('order_pk', pk);
    print('stored order_pk: $pk');
  }

  Widget _buildList() {
    if (_assignedOrders.length == 0 && _fetchDone) {
      return RefreshIndicator(
        child: Center(
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                Center(child: Text('\n\n\nNo orders assigned.'))
              ]
          )
        ),
        onRefresh: _getData
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
                title: Text(_createHeader(_assignedOrders[index].order)),
                subtitle: Text(_createSubtitle(_assignedOrders[index].order)),
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
        onRefresh: _getData,
    );
  }

  Future<void> _getData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    firstName = prefs.getString('first_name');

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

  Widget _createDrawerHeader() {
    return Container(
      height: 60.0,
      child: DrawerHeader(
          child: Text('Options', style: TextStyle(color: Colors.white)),
          decoration: BoxDecoration(
              color: Colors.blue
          ),
          margin: EdgeInsets.all(0.0),
          padding: EdgeInsets.all(10.10)
      ),
    );
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
      drawer: Drawer(
        // Add a ListView to the drawer. This ensures the user can scroll
        // through the options in the drawer if there isn't enough vertical
        // space to fit everything.
        child: ListView(
          // Important: Remove any padding from the ListView.
          padding: EdgeInsets.zero,
          children: <Widget>[
            _createDrawerHeader(),
            ListTile(
              title: Text('Logout'),
              onTap: () async {
                // close the drawer
                Navigator.pop(context);

                bool loggedOut = await logout();

                if (loggedOut == true) {
                  // navigate to home
                  Navigator.push(
                      context, MaterialPageRoute(builder: (context) => My24App())
                  );
                }
              }, // onTap
            ),
            ListTile(
              title: Text('Profile'),
              onTap: () {
                // Update the state of the app
                // ...
                // Then close the drawer
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}

//class AssignedOrdersListWidget extends StatelessWidget {
//  final EngineerUser engineer;
//
//  AssignedOrdersListWidget(this.engineer);
//
//  Widget assignedOrderList() {
//    return FutureBuilder<AssignedOrders>(
//        future: fetchAssignedOrders(http.Client()),
//        builder: (context, snapshot) {
//          print(snapshot.data);
//          if (snapshot.data == null) {
//            return Container(
//                child: Center(
//                    child: Text("Loading...")
//                )
//            );
//          } else {
//            return ListView.builder(
//                itemCount: snapshot.data.results.length,
//                itemBuilder: (BuildContext context, int index) {
//                  return ListTile(
//                      title: Text(snapshot.data.results[index].order.orderName),
//                      subtitle: Text(snapshot.data.results[index].order.orderAddress),
//                      onTap: () {
//                        print(snapshot.data.results[index]);
////                        Navigator.push(context,
////                            new MaterialPageRoute(builder: (context) =>
////                                MemberPage()
////                            )
////                        );
//                      } // onTab
//                  );
//                } // itemBuilder
//            );
//          } // else
//        } // builder
//    );
//  }
//
//  @override
//  Widget build(BuildContext context) {
//    return Scaffold(
//      appBar: AppBar(title: Text('Orders for ${engineer.firstName}')),
//      body: Center(child: assignedOrderList()),
//      drawer: Drawer(
//        // Add a ListView to the drawer. This ensures the user can scroll
//        // through the options in the drawer if there isn't enough vertical
//        // space to fit everything.
//        child: ListView(
//          // Important: Remove any padding from the ListView.
//          padding: EdgeInsets.zero,
//          children: <Widget>[
//            DrawerHeader(
//              child: Text('Drawer Header'),
//              decoration: BoxDecoration(
//                color: Colors.blue,
//              ),
//            ),
//            ListTile(
//              title: Text('Item 1'),
//              onTap: () {
//                // Update the state of the app
//                // ...
//                // Then close the drawer
//                Navigator.pop(context);
//              },
//            ),
//            ListTile(
//              title: Text('Item 2'),
//              onTap: () {
//                // Update the state of the app
//                // ...
//                // Then close the drawer
//                Navigator.pop(context);
//              },
//            ),
//          ],
//        ),
//      ),
//    );
//  }
//}
