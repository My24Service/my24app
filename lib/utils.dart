import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:my24app/assignedorders_list.dart';

import 'package:my24app/models.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_core/firebase_core.dart';

import 'main.dart';
import 'order_list.dart';
import 'order_form.dart';
import 'order_past_list.dart';
import 'order_not_accepted_list.dart';
import 'member_detail.dart';
import 'quotation_not_accepted_list.dart';
import 'quotation_form.dart';
import 'quotations_list.dart';
import 'salesuser_customers.dart';
import 'customer_form.dart';
import 'order_unassigned_list.dart';


dynamic getUrl(String path) async {
  final prefs = await SharedPreferences.getInstance();
  String companycode = prefs.getString('companycode');
  String apiBaseUrl = prefs.getString('apiBaseUrl');

  if (companycode == null || companycode == '' || companycode == 'jansenit') {
    companycode = 'demo';
  }

  if (apiBaseUrl == null || apiBaseUrl == '') {
    apiBaseUrl = 'my24service-dev.com';
  }

  return 'https://$companycode.$apiBaseUrl$path';
}

dynamic getBaseUrl() async {
  final prefs = await SharedPreferences.getInstance();
  String companycode = prefs.getString('companycode');
  String apiBaseUrl = prefs.getString('apiBaseUrl');

  if (companycode == null || companycode == '') {
    companycode = 'demo';
  }

  return 'https://$companycode.$apiBaseUrl';
}

dynamic getAccessToken() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString('tokenAccess');
}

dynamic getRefreshToken() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString('tokenRefresh');
}

dynamic getToken() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString('token');
}

Map<String, String> getHeaders(String token) {
  return {'Authorization': 'Bearer $token'};
}

class TokenExpiredException implements Exception {
  String cause;
  TokenExpiredException(this.cause);
}

Future<Token> refreshToken(http.Client client) async {
  final url = await getUrl('/jwt-token/refresh/');
  final refreshToken = await getRefreshToken();
  final Map<String, String> headers = {"Content-Type": "application/json; charset=UTF-8"};
  print('refreshToken: $refreshToken');
  final res = await client.post(
    url,
    body: json.encode(<String, String>{"refresh": refreshToken}),
    headers: headers,
  );

  if (res.statusCode == 200) {
    Token token = Token.fromJson(json.decode(res.body));

    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('tokenAccess', token.access);
    print('stored new access token: ${token.access}');

    return token;
  }

  return null;
}

Future<SlidingToken> refreshSlidingToken(http.Client client) async {
  final url = await getUrl('/jwt-token/refresh/');
  final token = await getToken();
  final authHeaders = getHeaders(token);
  final Map<String, String> headers = {"Content-Type": "application/json; charset=UTF-8"};
  Map<String, String> allHeaders = {};
  allHeaders.addAll(authHeaders);
  allHeaders.addAll(headers);

  final response = await client.post(
    url,
    body: json.encode(<String, String>{"token": token}),
    headers: allHeaders,
  );

  if (response.statusCode == 401) {
    Map<String, dynamic> reponseBody = json.decode(response.body);

    if (reponseBody['code'] == 'token_not_valid') {
      // go to login screen

    }
  }

  if (response.statusCode == 200) {
    SlidingToken token = SlidingToken.fromJson(json.decode(response.body));
    token.checkIsTokenExpired();

    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token.token);

    return token;
  }

  return null;
}

void displayDialog(context, title, text) => showDialog(
  context: context,
  builder: (context) =>
      AlertDialog(
          title: Text(title),
          content: Text(text)
      ),
);

Future<bool> isLoggedIn() async {
  // get and check token
  String accessToken = await getAccessToken();

  if(accessToken == null) {
    return false;
  }

  // create token object from prefs
  Token token = Token(access: accessToken);

  // check checkIsTokenExpired
  token.checkIsTokenExpired();

  // try to refresh?
  if (token.isExpired) {
    return false;
  }

  return true;
}

Future<bool> isLoggedInSlidingToken() async {
  http.Client client = http.Client();

  // refresh token
  SlidingToken newToken = await refreshSlidingToken(http.Client());

  if(newToken == null) {
    return false;
  }

  // create token object from prefs
  SlidingToken token = SlidingToken(token: newToken.token);

  // check checkIsTokenExpired
  token.checkIsTokenExpired();

  // try to refresh?
  if (token.isExpired) {
    return false;
  }

  // make call to member to check if it's the correct one
  SharedPreferences prefs = await SharedPreferences.getInstance();
  final int userId = prefs.getInt('user_id');
  final url = await getUrl('/mobile/assignedorder/list_app/?user_pk=$userId&json');
  final response = await client.get(
      url,
      headers: getHeaders(newToken.token)
  );

  if (response.statusCode == 401 || response.statusCode == 403) {
    return false;
  }

  return true;
}

Future<bool> logout() async {
  final prefs = await SharedPreferences.getInstance();
  prefs.remove('tokenAccess');
  prefs.remove('tokenRefresh');
  prefs.remove('token');

  return true;
}

Future<bool> refreshTokenBackground(http.Client client) async {
  // refresh token
  SlidingToken newToken = await refreshSlidingToken(client);

  if (newToken == null) {
    // do nothing
    return false;
  }

  return true;
}

Future<bool> storeLastPosition(http.Client client) async {
  // get best latest position
  Position position;

  bool serviceEnabled;
  LocationPermission permission;

  serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    return Future.error('Location services are disabled.');
  }

  permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.deniedForever) {
    return Future.error(
        'Location permissions are permantly denied, we cannot request permissions.');
  }

  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission != LocationPermission.whileInUse &&
        permission != LocationPermission.always) {
      return Future.error(
          'Location permissions are denied (actual value: $permission).');
    }
  }

  position = await Geolocator.getCurrentPosition();

  if (position == null) {
    return false;
  }

  // store it in the API
  SharedPreferences prefs = await SharedPreferences.getInstance();
  final int userId = prefs.getInt('user_id');
  final String token = prefs.getString('token');
  final url = await getUrl('/company/engineer/$userId/store_lon_lat/');
  final authHeaders = getHeaders(token);
  final Map<String, String> headers = {"Content-Type": "application/json; charset=UTF-8"};
  Map<String, String> allHeaders = {};
  allHeaders.addAll(authHeaders);
  allHeaders.addAll(headers);

  final Map body = {
    'lon': position.longitude,
    'lat': position.latitude,
    'heading': position.heading,
    'speed': position.speed,
  };

  final response = await client.post(
    url,
    body: json.encode(body),
    headers: allHeaders,
  );

  if (response.statusCode == 200) {
    return true;
  }

  return false;
}



// typeaheads
Future <List> productTypeAhead(http.Client client, String query) async {
  // refresh token
  SlidingToken newToken = await refreshSlidingToken(client);

  if (newToken == null) {
    throw TokenExpiredException('token expired');
  }

  final url = await getUrl('/inventory/product/autocomplete/' + '?q=' + query);
  final response = await client.get(
      url,
      headers: getHeaders(newToken.token)
  );

  List result = [];

  if (response.statusCode == 200) {
    var parsedJson = json.decode(response.body);
    var list = parsedJson as List;
    List<InventoryProductTypeAheadModel> results = list.map((i) => InventoryProductTypeAheadModel.fromJson(i)).toList();

    return results;
  }

  return result;
}

Future <List> quotationProductTypeAhead(http.Client client, String query) async {
  // refresh token
  SlidingToken newToken = await refreshSlidingToken(client);

  if (newToken == null) {
    throw TokenExpiredException('token expired');
  }

  final url = await getUrl('/inventory/product/autocomplete/?q=' + query);
  final response = await client.get(
      url,
      headers: getHeaders(newToken.token)
  );

  List result = [];

  if (response.statusCode == 200) {
    var parsedJson = json.decode(response.body);
    var list = parsedJson as List;
    List<QuotationProduct> results = list.map((i) => QuotationProduct.fromJson(i)).toList();

    return results;
  }

  return result;
}

Future <List> customerTypeAhead(http.Client client, String query) async {
  // refresh token
  SlidingToken newToken = await refreshSlidingToken(client);

  if (newToken == null) {
    throw TokenExpiredException('token expired');
  }

  final url = await getUrl('/customer/customer/autocomplete/?q=' + query);
  final response = await client.get(
      url,
      headers: getHeaders(newToken.token)
  );

  List result = [];

  if (response.statusCode == 200) {
    var parsedJson = json.decode(response.body);
    var list = parsedJson as List;
    List<CustomerTypeAheadModel> results = list.map((i) => CustomerTypeAheadModel.fromJson(i)).toList();

    return results;
  }

  return result;
}



// tables
Widget createTable(List<TableRow> rows) {
  return Table(
      border: TableBorder(horizontalInside: BorderSide(width: 1, color: Colors.grey, style: BorderStyle.solid)),
      children: rows
  );
}

Widget createTableHeaderCell(String content) {
  return Padding(
    padding: EdgeInsets.all(8.0),
    child: Text(content, style: TextStyle(fontWeight: FontWeight.bold)),
  );
}

Widget createTableColumnCell(String content) {
  return Padding(
    padding: EdgeInsets.all(4.0),
    child: Text(content != null ? content : ''),
  );
}



ElevatedButton createBlueElevatedButton(String text, Function callback, { primaryColor=Colors.blue, onPrimary=Colors.white}) {
  return ElevatedButton(
    style: ElevatedButton.styleFrom(
      primary: primaryColor, // background
      onPrimary: onPrimary, // foreground
    ),
    child: new Text(text),
    onPressed: callback,
  );
}



Widget createHeader(String text) {
  return Container(child: Column(
    children: [
      SizedBox(
        height: 10.0,
      ),
      Text(text, style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 20,
          color: Colors.grey
      )),
      SizedBox(
        height: 10.0,
      ),
    ],
  ));
}



launchURL(String url) async {
  if (url == null || url == '') {
    return;
  }

  if (await canLaunch(url)) {
    await launch(url);
  } else {
    throw 'Could not launch $url';
  }
}



// list functions
Widget createOrderListHeader(Order order) {
  return Table(
    children: [
      TableRow(
          children: [
            Text('Date: ', style: TextStyle(fontWeight: FontWeight.bold)),
            Text('${order.orderDate}')
          ]
      ),
      TableRow(
          children: [
            Text('Order ID: ', style: TextStyle(fontWeight: FontWeight.bold)),
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
            Text('Customer: ', style: TextStyle(fontWeight: FontWeight.bold)),
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
            Text('Address: ', style: TextStyle(fontWeight: FontWeight.bold)),
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
            Text('Postal/City: ', style: TextStyle(fontWeight: FontWeight.bold)),
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
            Text('Order type: ', style: TextStyle(fontWeight: FontWeight.bold)),
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
            Text('Last status: ', style: TextStyle(fontWeight: FontWeight.bold)),
            Text('${order.lastStatusFull}')
          ]
      )
    ],
  );
}

Widget createQuotationListHeader(Quotation quotation) {
  return Table(
    children: [
      TableRow(
          children: [
            Text('Email: ', style: TextStyle(fontWeight: FontWeight.bold)),
            Text('${quotation.quotationEmail}')
          ]
      ),
      TableRow(
          children: [
            Text('Tel: ', style: TextStyle(fontWeight: FontWeight.bold)),
            Text('${quotation.quotationTel}')
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

Widget createQuotationListSubtitle(Quotation quotation) {
  return Table(
    children: [
      TableRow(
          children: [
            Text('Name: ', style: TextStyle(fontWeight: FontWeight.bold)),
            Text('${quotation.quotationName}'),
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
            Text('City: ', style: TextStyle(fontWeight: FontWeight.bold)),
            Text('${quotation.quotationCity}')
          ]
      )
    ],
  );
}


// Drawers
Widget createDrawerHeader() {
  return Container(
    height: 80.0,
    child: DrawerHeader(
        child: Text('Options', style: TextStyle(color: Colors.white)),
        decoration: BoxDecoration(
            color: Colors.grey
        ),
        margin: EdgeInsets.all(0),
        padding: EdgeInsets.all(6.35)
    ),
  );
}

Widget createCustomerDrawer(BuildContext context) {
  return Drawer(
    // Add a ListView to the drawer. This ensures the user can scroll
    // through the options in the drawer if there isn't enough vertical
    // space to fit everything.
    child: ListView(
      // Important: Remove any padding from the ListView.
      padding: EdgeInsets.zero,
      children: <Widget>[
        createDrawerHeader(),
        ListTile(
          title: Text('Orders'),
          onTap: () {
            // close the drawer
            Navigator.pop(context);
            Navigator.push(
                context, MaterialPageRoute(builder: (context) => OrderListPage())
            );
          },
        ),
        ListTile(
          title: Text('Orders processing'),
          onTap: () {
            // close the drawer
            Navigator.pop(context);
            Navigator.push(
                context, MaterialPageRoute(builder: (context) => OrderNotAcceptedListPage())
            );
          },
        ),
        ListTile(
          title: Text('Past orders'),
          onTap: () {
            // close the drawer
            Navigator.pop(context);
            Navigator.push(
                context, MaterialPageRoute(builder: (context) => OrderPastListPage())
            );
          },
        ),
        ListTile(
          title: Text('New order'),
          onTap: () {
            // close the drawer
            Navigator.pop(context);
            Navigator.push(
                context, MaterialPageRoute(builder: (context) => OrderFormPage())
            );
          },
        ),
        ListTile(
          title: Text('Quotations'),
          onTap: () {
            // close the drawer
            Navigator.pop(context);

            // navigate to quotation list
            Navigator.push(
                context, MaterialPageRoute(builder: (context) => QuotationsListPage())
            );
          },
        ),
        Divider(),
        ListTile(
          title: Text('Logout'),
          onTap: () async {
            // close the drawer
            Navigator.pop(context);

            bool loggedOut = await logout();

            if (loggedOut == true) {
              Navigator.push(
                  context, MaterialPageRoute(builder: (context) => My24App())
              );
            }
          }, // onTap
        ),
      ],
    ),
  );
}

Widget createEngineerDrawer(BuildContext context) {
  return Drawer(
    // Add a ListView to the drawer. This ensures the user can scroll
    // through the options in the drawer if there isn't enough vertical
    // space to fit everything.
    child: ListView(
      // Important: Remove any padding from the ListView.
      padding: EdgeInsets.all(0),
      children: <Widget>[
        createDrawerHeader(),
        ListTile(
          title: Text('Orders'),
          onTap: () {
            // close the drawer
            Navigator.pop(context);

            // navigate to member
            Navigator.push(
                context, MaterialPageRoute(builder: (context) => AssignedOrdersListPage())
            );
          },
        ),
        ListTile(
          title: Text('New quotation'),
          onTap: () {
            // close the drawer
            Navigator.pop(context);

            Navigator.push(context,
                new MaterialPageRoute(
                    builder: (context) => QuotationFormPage())
            );
          }
        ),
        ListTile(
            title: Text('Quotations not yet accepted'),
          onTap: () {
            // close the drawer
            Navigator.pop(context);

            // navigate to quotation list
            Navigator.push(
                context, MaterialPageRoute(builder: (context) => QuotationNotAcceptedListPage())
            );
          },
        ),
        Divider(),
        ListTile(
          title: Text('Back to member'),
          onTap: () {
            // close the drawer
            Navigator.pop(context);

            // navigate to member
            Navigator.push(
                context, MaterialPageRoute(builder: (context) => MemberPage())
            );
          },
        ),
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
      ],
    ),
  );
}

Widget createPlanningDrawer(BuildContext context) {
  return Drawer(
    // Add a ListView to the drawer. This ensures the user can scroll
    // through the options in the drawer if there isn't enough vertical
    // space to fit everything.
    child: ListView(
      // Important: Remove any padding from the ListView.
      padding: EdgeInsets.all(0),
      children: <Widget>[
        createDrawerHeader(),
        ListTile(
          title: Text('Orders'),
          onTap: () {
            // close the drawer
            Navigator.pop(context);

            // navigate to member
            Navigator.push(
                context, MaterialPageRoute(builder: (context) => OrderListPage())
            );
          },
        ),
        ListTile(
          title: Text('Orders not yet accepted'),
          onTap: () {
            // close the drawer
            Navigator.pop(context);

            // navigate to member
            Navigator.push(
                context, MaterialPageRoute(builder: (context) => OrderNotAcceptedListPage())
            );
          },
        ), // //OrdersUnAssignedPage
        ListTile(
          title: Text('Orders unassigned'),
          onTap: () {
            // close the drawer
            Navigator.pop(context);

            // navigate to member
            Navigator.push(
                context, MaterialPageRoute(builder: (context) => OrdersUnAssignedPage())
            );
          },
        ), // //OrdersUnAssignedPage
        ListTile(
          title: Text('New order'),
          onTap: () {
            // close the drawer
            Navigator.pop(context);
            Navigator.push(
                context, MaterialPageRoute(builder: (context) => OrderFormPage())
            );
          },
        ),
        ListTile(
          title: Text('Quotations'),
          onTap: () {
            // close the drawer
            Navigator.pop(context);

            // navigate to quotation list
            Navigator.push(
                context, MaterialPageRoute(builder: (context) => QuotationsListPage())
            );
          },
        ),
        ListTile(
          title: Text('Quotations not yet accepted'),
          onTap: () {
            // close the drawer
            Navigator.pop(context);

            // navigate to quotation list
            Navigator.push(
                context, MaterialPageRoute(builder: (context) => QuotationNotAcceptedListPage())
            );
          },
        ),
        Divider(),
        ListTile(
          title: Text('Back to member'),
          onTap: () {
            // close the drawer
            Navigator.pop(context);

            // navigate to member
            Navigator.push(
                context, MaterialPageRoute(builder: (context) => MemberPage())
            );
          },
        ),
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
      ],
    ),
  );
}

Widget createSalesDrawer(BuildContext context) {
  return Drawer(
    // Add a ListView to the drawer. This ensures the user can scroll
    // through the options in the drawer if there isn't enough vertical
    // space to fit everything.
    child: ListView(
      // Important: Remove any padding from the ListView.
      padding: EdgeInsets.all(0),
      children: <Widget>[
        createDrawerHeader(),
        ListTile(
          title: Text('Orders'),
          onTap: () {
            // close the drawer
            Navigator.pop(context);

            // navigate to member
            Navigator.push(
                context, MaterialPageRoute(builder: (context) => OrderListPage())
            );
          },
        ),
        ListTile(
          title: Text('Quotations'),
          onTap: () {
            // close the drawer
            Navigator.pop(context);

            // navigate to quotation list
            Navigator.push(
                context, MaterialPageRoute(builder: (context) => QuotationsListPage())
            );
          },
        ),
        ListTile(
          title: Text('Quotations not yet accepted'),
          onTap: () {
            // close the drawer
            Navigator.pop(context);

            // navigate to quotation list
            Navigator.push(
                context, MaterialPageRoute(builder: (context) => QuotationNotAcceptedListPage())
            );
          },
        ),
        ListTile(
          title: Text('Your customers'),
          onTap: () {
            // close the drawer
            Navigator.pop(context);

            // navigate to quotation list
            Navigator.push(
                context, MaterialPageRoute(builder: (context) => SalesUserCustomersPage())
            );
          },
        ),
        ListTile(
          title: Text('New customer'),
          onTap: () {
            // close the drawer
            Navigator.pop(context);

            // navigate to quotation list
            Navigator.push(
                context, MaterialPageRoute(builder: (context) => CustomerFormPage())
            );
          },
        ),
        Divider(),
        ListTile(
          title: Text('Back to member'),
          onTap: () {
            // close the drawer
            Navigator.pop(context);

            // navigate to member
            Navigator.push(
                context, MaterialPageRoute(builder: (context) => MemberPage())
            );
          },
        ),
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
      ],
    ),
  );
}

Future<Widget> getDrawerForUser(BuildContext context) async {
  String submodel = await getUserSubmodel();

  if (submodel == 'engineer') {
    return createEngineerDrawer(context);
  }

  if (submodel == 'customer_user') {
    return createCustomerDrawer(context);
  }

  if (submodel == 'planning_user') {
    return createPlanningDrawer(context);
  }

  if (submodel == 'sales_user') {
    return createSalesDrawer(context);
  }

  return null;
}



Future<String> getUserSubmodel() async {
  final prefs = await SharedPreferences.getInstance();
  String submodel = prefs.getString('submodel');

  return submodel;
}



Future<String> getOrderListTitleForUser() async {
  String submodel = await getUserSubmodel();

  if (submodel == 'customer_user') {
    return 'Your orders';
  }

  if (submodel == 'planning_user') {
    return 'All orders';
  }

  if (submodel == 'sales_user') {
    return 'Your customers\' orders';
  }

  return null;
}



Future<bool> postDeviceToken(http.Client client) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  final String token = prefs.getString('token');
  final int userId = prefs.getInt('user_id');
  final bool isAllowed = prefs.getBool('fcm_allowed');

  if (isAllowed == false) {
    return false;
  }

  final url = await getUrl('/company/user-device-token/');

  final authHeaders = getHeaders(token);
  final Map<String, String> headers = {"Content-Type": "application/json; charset=UTF-8"};
  Map<String, String> allHeaders = {};
  allHeaders.addAll(authHeaders);
  allHeaders.addAll(headers);

  await Firebase.initializeApp();
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  String messageingToken = await messaging.getToken();

  final Map body = {
    "user": userId,
    "device_token": messageingToken
  };

  final response = await client.post(
    url,
    body: json.encode(body),
    headers: allHeaders,
  );

  if (response.statusCode == 200) {
    return true;
  }

  return false;
}



showDeleteDialog(String title, String content, BuildContext context, Function deleteFunction) {
  // set up the button
  Widget cancelButton = TextButton(
    child: Text("Cancel"),
    onPressed: () => Navigator.of(context).pop(false)
  );
  Widget deleteButton = TextButton(
    child: Text("Delete"),
    onPressed: () => Navigator.of(context).pop(true)
  );

  // set up the AlertDialog
  AlertDialog alert = AlertDialog(
    title: Text(title),
    content: Text(content),
    actions: [
      cancelButton,
      deleteButton,
    ],
  );

  // show the dialog
  showDialog(
    barrierDismissible: false,
    context: context,
    builder: (BuildContext context) {
      return alert;
    },
  ).then((dialogResult) {
    if (dialogResult == null) return;

    if (dialogResult) {
      deleteFunction();
    }
  });
}


createSnackBar(BuildContext context, String content) {
  const String isOld = String.fromEnvironment('OLD');

  final snackBar = SnackBar(
    content: Text(content),
    // action: SnackBarAction(
    //   label: 'Undo',
    //   onPressed: () {
    //     // Some code to undo the change.
    //   },
    // ),
  );

  // Find the ScaffoldMessenger in the widget tree
  // and use it to show a SnackBar.
  if (isOld.length > 0) {
    Scaffold.of(context).showSnackBar(snackBar);
  } else {
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
