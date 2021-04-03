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
import 'package:easy_localization/easy_localization.dart';

import 'main.dart';
import 'order_list.dart';
import 'order_form.dart';
import 'order_past_list.dart';
import 'order_not_accepted_list.dart';
import 'quotation_not_accepted_list.dart';
import 'quotation_form.dart';
import 'quotations_list.dart';
import 'salesuser_customers.dart';
import 'customer_form.dart';
import 'order_unassigned_list.dart';
import 'location_inventory.dart';
import 'customer_list.dart';
import 'settings.dart';


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
    return null;
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

Future<bool> isLoggedInSlidingToken() async {
  http.Client client = http.Client();

  // refresh token
  SlidingToken newToken = await refreshSlidingToken(http.Client());

  if(newToken == null) {
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
    'speed': position.speed,
    'heading': position.heading,
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
Future <List> materialTypeAhead(http.Client client, String query) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  final String token = prefs.getString('token');

  final url = await getUrl('/inventory/material/autocomplete/' + '?q=' + query);
  final response = await client.get(
      url,
      headers: getHeaders(token)
  );

  if (response.statusCode == 200) {
    var parsedJson = json.decode(response.body);
    var list = parsedJson as List;
    List<InventoryMaterialTypeAheadModel> results = list.map((i) => InventoryMaterialTypeAheadModel.fromJson(i)).toList();

    return results;
  }

  return [];
}

Future <List> quotationProductTypeAhead(http.Client client, String query) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  final String token = prefs.getString('token');

  final url = await getUrl('/inventory/product/autocomplete/?q=' + query);
  final response = await client.get(
      url,
      headers: getHeaders(token)
  );

  if (response.statusCode == 200) {
    var parsedJson = json.decode(response.body);
    var list = parsedJson as List;
    List<QuotationProduct> results = list.map((i) => QuotationProduct.fromJson(i)).toList();

    return results;
  }

  return [];
}

Future <List> customerTypeAhead(http.Client client, String query) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  final String token = prefs.getString('token');

  final url = await getUrl('/customer/customer/autocomplete/?q=' + query);
  final response = await client.get(
      url,
      headers: getHeaders(token)
  );

  if (response.statusCode == 200) {
    var parsedJson = json.decode(response.body);
    var list = parsedJson as List;
    List<CustomerTypeAheadModel> results = list.map((i) => CustomerTypeAheadModel.fromJson(i)).toList();

    return results;
  }

  return [];
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

Widget createCustomerListHeader(Customer customer) {
  return Table(
    children: [
      TableRow(
          children: [
            Text('orders.info_customer_id'.tr(), style: TextStyle(fontWeight: FontWeight.bold)),
            Text('${customer.customerId}')
          ]
      ),
      TableRow(
          children: [
            Text('orders.info_name'.tr(), style: TextStyle(fontWeight: FontWeight.bold)),
            Text('${customer.name}')
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

Widget createCustomerListSubtitle(Customer customer) {
  return Table(
    children: [
      TableRow(
          children: [
            Text('orders.info_address', style: TextStyle(fontWeight: FontWeight.bold)),
            Text('${customer.address}'),
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
            Text('${customer.countryCode}-${customer.postal} ${customer.city}'),
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
            Text('orders.info_tel'.tr(), style: TextStyle(fontWeight: FontWeight.bold)),
            Text('${customer.tel}'),
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
            Text('orders.info_mobile'.tr(), style: TextStyle(fontWeight: FontWeight.bold)),
            Text('${customer.mobile}')
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
            Text('orders.info_order_email'.tr(), style: TextStyle(fontWeight: FontWeight.bold)),
            Text('${customer.email}')
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
            Text('orders.info_order_email'.tr(), style: TextStyle(fontWeight: FontWeight.bold)),
            Text('${quotation.quotationEmail}')
          ]
      ),
      TableRow(
          children: [
            Text('orders.info_tel'.tr(), style: TextStyle(fontWeight: FontWeight.bold)),
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
            Text('orders.info_name'.tr(), style: TextStyle(fontWeight: FontWeight.bold)),
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
            Text('generic.info_city'.tr(), style: TextStyle(fontWeight: FontWeight.bold)),
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
        child: Text('utils.drawer_options'.tr(), style: TextStyle(color: Colors.white)),
        decoration: BoxDecoration(
            color: Colors.grey
        ),
        margin: EdgeInsets.all(0),
        padding: EdgeInsets.all(6.35)
    ),
  );
}

ListTile listTileSettings(context) {
  return ListTile(
    title: Text('utils.drawer_settings'.tr()),
    onTap: () {
      // close the drawer and navigate
      Navigator.pop(context);
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => SettingsPage())
      );
    }, // onTap
  );
}

ListTile listTileLogout(context) {
  return ListTile(
    title: Text('utils.drawer_logout'.tr()),
    onTap: () async {
      // close the drawer and navigate
      Navigator.pop(context);

      bool loggedOut = await logout();
      if (loggedOut == true) {
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => My24App())
        );
      }
    }, // onTap
  );
}

ListTile listTileOrderList(BuildContext context, String text) {
  return ListTile(
    title: Text(text),
    onTap: () {
      // close the drawer and navigate
      Navigator.pop(context);
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => OrderListPage())
      );
    },
  );
}

ListTile listTileOrderNotAcceptedList(BuildContext context, String text) {
  return ListTile(
    title: Text(text),
    onTap: () {
      // close the drawer and navigate
      Navigator.pop(context);
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => OrderNotAcceptedListPage())
      );
    },
  );
}

ListTile listTileOrderPastList(BuildContext context, String text) {
  return ListTile(
    title: Text(text),
    onTap: () {
      // close the drawer and navigate
      Navigator.pop(context);
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => OrderPastListPage())
      );
    },
  );
}

ListTile listTileOrderFormPage(BuildContext context, String text) {
  return ListTile(
    title: Text(text),
    onTap: () {
      // close the drawer and navigate
      Navigator.pop(context);
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => OrderFormPage())
      );
    },
  );
}

ListTile listTileQuotationFormPage(BuildContext context, String text) {
  return ListTile(
    title: Text(text),
    onTap: () {
      // close the drawer and navigate
      Navigator.pop(context);
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => QuotationFormPage())
      );
    },
  );
}

ListTile listTileQuotationsListPage(BuildContext context, String text) {
  return ListTile(
    title: Text(text),
    onTap: () {
      // close the drawer and navigate
      Navigator.pop(context);
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => QuotationsListPage())
      );
    },
  );
}

ListTile listTileQuotationNotAcceptedListPage(BuildContext context, String text) {
  return ListTile(
    title: Text(text),
    onTap: () {
      // close the drawer and navigate
      Navigator.pop(context);
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => QuotationNotAcceptedListPage())
      );
    },
  );
}

ListTile listTileAssignedOrdersListPage(BuildContext context, String text) {
  return ListTile(
    title: Text(text),
    onTap: () {
      // close the drawer and navigate
      Navigator.pop(context);
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => AssignedOrdersListPage())
      );
    },
  );
}

ListTile listTileLocationInventoryPage(BuildContext context, String text) {
  return ListTile(
    title: Text(text),
    onTap: () {
      // close the drawer and navigate
      Navigator.pop(context);
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => LocationInventoryPage())
      );
    },
  );
}

ListTile listTileOrdersUnAssignedPage(BuildContext context, String text) {
  return ListTile(
    title: Text(text),
    onTap: () {
      // close the drawer and navigate
      Navigator.pop(context);
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => OrdersUnAssignedPage())
      );
    },
  );
}

ListTile listTileCustomerListPage(BuildContext context, String text) {
  return ListTile(
    title: Text(text),
    onTap: () {
      // close the drawer and navigate
      Navigator.pop(context);
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => CustomerListPage())
      );
    },
  );
}

ListTile listTileCustomerFormPage(BuildContext context, String text) {
  return ListTile(
    title: Text(text),
    onTap: () {
      // close the drawer and navigate
      Navigator.pop(context);
      // navigate to quotation list
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => CustomerFormPage())
      );
    },
  );
}

ListTile listTileSalesUserCustomersPage(BuildContext context, String text) {
  return ListTile(
    title: Text(text),
    onTap: () {
      // close the drawer and navigate
      Navigator.pop(context);
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => SalesUserCustomersPage())
      );
    },
  );
}

Widget createCustomerDrawer(BuildContext context) {
  return Drawer(
    child: ListView(
      // Important: Remove any padding from the ListView.
      padding: EdgeInsets.zero,
      children: <Widget>[
        createDrawerHeader(),
        listTileOrderList(context, 'utils.drawer_customer_orders'.tr()),
        listTileOrderNotAcceptedList(context, 'utils.drawer_customer_orders_processing'.tr()),
        listTileOrderPastList(context, 'utils.drawer_customer_orders_past'.tr()),
        listTileOrderFormPage(context, 'utils.drawer_customer_order_new'.tr()),
        listTileQuotationsListPage(context, 'utils.drawer_customer_quotations'.tr()),
        Divider(),
        listTileSettings(context),
        listTileLogout(context),
      ],
    ),
  );
}

Widget createEngineerDrawer(BuildContext context) {
  return Drawer(
    child: ListView(
      // Important: Remove any padding from the ListView.
      padding: EdgeInsets.all(0),
      children: <Widget>[
        createDrawerHeader(),
        listTileAssignedOrdersListPage(context, 'utils.drawer_engineer_orders'.tr()),
        listTileQuotationFormPage(context, 'utils.drawer_engineer_new_quotation'.tr()),
        listTileQuotationNotAcceptedListPage(context, 'utils.drawer_engineer_quotations_not_yet_accepted'.tr()),
        listTileLocationInventoryPage(context, 'utils.drawer_engineer_location_inventory'.tr()),
        Divider(),
        listTileSettings(context),
        listTileLogout(context),
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
        listTileOrderList(context, 'utils.drawer_planning_orders'.tr()),
        listTileOrderNotAcceptedList(context, 'utils.drawer_planning_orders_not_yet_accepted'.tr()),
        listTileOrdersUnAssignedPage(context, 'utils.drawer_planning_orders_unassigned'.tr()),
        listTileOrderFormPage(context, 'utils.drawer_planning_order_new'.tr()),
        listTileCustomerListPage(context, 'utils.drawer_planning_customers'.tr()),
        listTileQuotationsListPage(context, 'utils.drawer_planning_quotations'.tr()),
        listTileQuotationNotAcceptedListPage(context, 'utils.drawer_planning_quotations_not_yet_accepted'.tr()),
        listTileCustomerFormPage(context, 'utils.drawer_planning_new_customer'.tr()),
        Divider(),
        listTileSettings(context),
        listTileLogout(context),
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
        listTileOrderList(context, 'utils.drawer_sales_orders'.tr()),
        listTileQuotationsListPage(context, 'utils.drawer_sales_quotations'.tr()),
        listTileQuotationNotAcceptedListPage(context, 'utils.drawer_sales_quotations_not_yet_accepted'.tr()),
        listTileCustomerListPage(context, 'utils.drawer_sales_customers'.tr()),
        listTileSalesUserCustomersPage(context, 'utils.drawer_sales_manage_your_customers'.tr()),
        listTileCustomerFormPage(context, 'utils.drawer_sales_new_customer'.tr()),
        Divider(),
        listTileSettings(context),
        listTileLogout(context),
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
    child: Text('utils.button_cancel'.tr()),
    onPressed: () => Navigator.of(context).pop(false)
  );
  Widget deleteButton = TextButton(
    child: Text('utils.button_delete'.tr()),
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
  try {
    Scaffold.of(context).showSnackBar(snackBar);
  } catch(e) {
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}



Locale lang2locale(String lang) {
  if (lang == 'nl') {
    return Locale('nl', 'NL');
  }

  if (lang == 'en') {
    return Locale('en', 'US');
  }

  return null;
}



Future<MemberPublic> fetchMember(http.Client client) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  final int memberPk = prefs.getInt('member_pk');

  var url = await getUrl('/member/detail-public/$memberPk/');
  final response = await client.get(url);

  if (response.statusCode == 200) {
    return MemberPublic.fromJson(json.decode(response.body));
  }

  throw Exception('member_detail.exception_fetch'.tr());
}



Widget buildMemberInfoCard(member) => SizedBox(
  height: 150,
  width: 1000,
  child: Center(
    child: Column(
      mainAxisSize: MainAxisSize.max,
      children: [
        ListTile(
          title: Text('${member.name}',
              style: TextStyle(fontWeight: FontWeight.w500)),
          subtitle: Text(
              '${member.address}\n${member.countryCode}-${member.postal}\n${member.city}'),
          leading: Icon(
            Icons.home,
            color: Colors.blue[500],
          ),
        ),
        ListTile(
          title: Text('${member.tel}',
              style: TextStyle(fontWeight: FontWeight.w500)),
          leading: Icon(
            Icons.contact_phone,
            color: Colors.blue[500],
          ),
        ),
      ],
    ),
  ),
);

