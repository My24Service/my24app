import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

import 'package:my24app/company/pages/salesuser_customers.dart';
import 'package:my24app/core/pages/settings.dart';
import 'package:my24app/core/utils.dart';
import 'package:my24app/customer/pages/form.dart';
import 'package:my24app/customer/pages/list.dart';
import 'package:my24app/home/pages/home.dart';
import 'package:my24app/mobile/pages/assigned_list.dart';
import 'package:my24app/order/pages/list.dart';
import 'package:my24app/order/pages/form.dart';
import 'package:my24app/order/pages/past.dart';
import 'package:my24app/order/pages/sales_form.dart';
import 'package:my24app/order/pages/unaccepted.dart';
import 'package:my24app/order/pages/unassigned.dart';
import 'package:my24app/order/pages/sales_list.dart';
import 'package:my24app/inventory/pages/location_inventory.dart';
import 'package:my24app/quotation/pages/list.dart';
import 'package:my24app/quotation/pages/preliminary_new.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../chat/pages/chat.dart';
import '../../company/pages/project_list.dart';
import '../../company/pages/workhours_list.dart';
import '../../interact/pages/map.dart';
import '../../navigator_key.dart';
import '../../quotation/pages/list_preliminary.dart';

// Drawers
Widget createDrawerHeader() {
  return SizedBox(height: 30);
}

ListTile listTileSettings(context) {
  final page = SettingsPage();

  return ListTile(
    title: Text('utils.drawer_settings'.tr()),
    onTap: () {
      // close the drawer and navigate
      Navigator.pop(context);
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => page)
      );
    }, // onTap
  );
}

ListTile listTileMapPage(context, String text) {
  final page = MapPage();

  return ListTile(
    title: Text(text),
    onTap: () {
      // close the drawer and navigate
      Navigator.pop(context);
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => page)
      );
    }, // onTap
  );
}

ListTile listTileLogout(context) {
  final page = My24App();

  return ListTile(
    title: Text('utils.drawer_logout'.tr()),
    onTap: () async {
      // close the drawer and navigate
      Navigator.pop(context);

      bool loggedOut = await utils.logout();
      if (loggedOut == true) {
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => page)
        );
      }
    }, // onTap
  );
}

ListTile listTileProjectList(BuildContext context, String text) {
  final page = ProjectListPage();

  return ListTile(
    title: Text(text),
    onTap: () {
      // close the drawer and navigate
      Navigator.pop(context);
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => page)
      );
    },
  );
}

ListTile listTileUserWorkHoursList(BuildContext context, String text) {
  final page = UserWorkHoursListPage();

  return ListTile(
    title: Text(text),
    onTap: () {
      // close the drawer and navigate
      Navigator.pop(context);
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => page)
      );
    },
  );
}

ListTile listTileOrderList(BuildContext context, String text) {
  final page = OrderListPage();

  return ListTile(
    title: Text(text),
    onTap: () {
      // close the drawer and navigate
      Navigator.pop(context);
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => page)
      );
    },
  );
}

ListTile listTileOrdersUnacceptedPage(BuildContext context, String text) {
  final page = UnacceptedPage();

  return ListTile(
    title: Text(text),
    onTap: () {
      // close the drawer and navigate
      Navigator.pop(context);
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => page)
      );
    },
  );
}

ListTile listTileOrderPastList(BuildContext context, String text) {
  final page = PastPage();

  return ListTile(
    title: Text(text),
    onTap: () {
      // close the drawer and navigate
      Navigator.pop(context);
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => page)
      );
    },
  );
}

ListTile listTileOrderSalesList(BuildContext context, String text) {
  final page = SalesPage();

  return ListTile(
    title: Text(text),
    onTap: () {
      // close the drawer and navigate
      Navigator.pop(context);
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => page)
      );
    },
  );
}

ListTile listTileOrderFormPage(BuildContext context, String text) {
  final page = OrderFormPage(orderPk: null);

  return ListTile(
    title: Text(text),
    onTap: () {
      // close the drawer and navigate
      Navigator.pop(context);
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => page)
      );
    },
  );
}

ListTile listTileSalesOrderFormPage(BuildContext context, String text) {
  final page = SalesOrderFormPage(orderPk: null);

  return ListTile(
    title: Text(text),
    onTap: () {
      // close the drawer and navigate
      Navigator.pop(context);
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => page)
      );
    },
  );
}

ListTile listTileQuotationNewPage(BuildContext context, String text) {
  final page = PreliminaryNewPage();

  return ListTile(
    title: Text(text),
    onTap: () {
      // close the drawer and navigate
      Navigator.pop(context);
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => page)
      );
    },
  );
}

ListTile listTileQuotationsListPage(BuildContext context, String text) {
  final page = QuotationListPage(mode: listModes.ALL);

  return ListTile(
    title: Text(text),
    onTap: () {
      // close the drawer and navigate
      Navigator.pop(context);
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => page)
      );
    },
  );
}

ListTile listTileQuotationsListPreliminaryPage(BuildContext context, String text) {
  final page = PreliminaryQuotationListPage();

  return ListTile(
    title: Text(text),
    onTap: () {
      // close the drawer and navigate
      Navigator.pop(context);
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => page)
      );
    },
  );
}

ListTile listTileQuotationUnacceptedPage(BuildContext context, String text) {
  final page = QuotationListPage(mode: listModes.UNACCEPTED);

  return ListTile(
    title: Text(text),
    onTap: () {
      // close the drawer and navigate
      Navigator.pop(context);
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => page)
      );
    },
  );
}

ListTile listTileAssignedOrdersListPage(BuildContext context, String text) {
  final page = AssignedOrderListPage();

  return ListTile(
    title: Text(text),
    onTap: () {
      // close the drawer and navigate
      Navigator.pop(context);
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => page)
      );
    },
  );
}

ListTile listTileLocationInventoryPage(BuildContext context, String text) {
  final page = LocationInventoryPage();

  return ListTile(
    title: Text(text),
    onTap: () {
      // close the drawer and navigate
      Navigator.pop(context);
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => page)
      );
    },
  );
}

ListTile listTileOrdersUnAssignedPage(BuildContext context, String text) {
  final page = OrdersUnAssignedPage();

  return ListTile(
    title: Text(text),
    onTap: () {
      // close the drawer and navigate
      Navigator.pop(context);
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => page)
      );
    },
  );
}

ListTile listTileCustomerListPage(BuildContext context, String text) {
  final page = CustomerListPage();

  return ListTile(
    title: Text(text),
    onTap: () {
      // close the drawer and navigate
      Navigator.pop(context);
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => page)
      );
    },
  );
}

ListTile listTileCustomerFormPage(BuildContext context, String text) {
  final page = CustomerFormPage();

  return ListTile(
    title: Text(text),
    onTap: () {
      // close the drawer and navigate
      Navigator.pop(context);
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => page)
      );
    },
  );
}

ListTile listTileSalesUserCustomersPage(BuildContext context, String text) {
  final page = SalesUserCustomersPage();

  return ListTile(
    title: Text(text),
    onTap: () {
      // close the drawer and navigate
      Navigator.pop(context);
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => page)
      );
    },
  );
}

Widget _getUnreadIndicator(int unreadCount) {
  if (unreadCount == 0 || unreadCount == null) {
    return SizedBox(width: 1);
  }

  return Container(
    child: Text(
      '($unreadCount)',
        style: TextStyle(
            color: Colors.red
        )
    ),
  );
}

ListTile listTileChatPage(BuildContext context, String text, int unreadCount) {
  final page = ChatPage();

  return ListTile(
    title: Text(text),
    trailing: _getUnreadIndicator(unreadCount),
    onTap: () {
      // close the drawer and navigate
      Navigator.pop(context);
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => page)
      );
    },
  );
}

Widget createCustomerDrawer(BuildContext context, SharedPreferences sharedPrefs) {
  return Drawer(
    child: ListView(
      // Important: Remove any padding from the ListView.
      padding: EdgeInsets.zero,
      children: <Widget>[
        createDrawerHeader(),
        listTileOrderList(context, 'utils.drawer_customer_orders'.tr()),
        listTileOrdersUnacceptedPage(context, 'utils.drawer_customer_orders_unaccepted'.tr()),
        listTileOrderPastList(context, 'utils.drawer_customer_orders_past'.tr()),
        listTileOrderFormPage(context, 'utils.drawer_customer_order_new'.tr()),
        // listTileQuotationsListPage(context, 'utils.drawer_customer_quotations'.tr()),
        Divider(),
        listTileSettings(context),
        listTileLogout(context),
      ],
    ),
  );
}

Widget createEngineerDrawer(BuildContext context, SharedPreferences sharedPrefs) {
  final int unreadCount = sharedPrefs.getInt('chat_unread_count');

  return Drawer(

    child: ListView(
      // Important: Remove any padding from the ListView.
      padding: EdgeInsets.all(0),
      children: <Widget>[
        createDrawerHeader(),
        listTileAssignedOrdersListPage(context, 'utils.drawer_engineer_orders'.tr()),
        listTileOrdersUnAssignedPage(context, 'utils.drawer_engineer_orders_unassigned'.tr()),
//        listTileQuotationFormPage(context, 'utils.drawer_engineer_new_quotation'.tr()),
//        listTileQuotationUnacceptedPage(context, 'utils.drawer_engineer_quotations_unaccepted'.tr()),
        listTileLocationInventoryPage(context, 'utils.drawer_engineer_location_inventory'.tr()),

        listTileUserWorkHoursList(context, 'utils.drawer_engineer_workhours'.tr()),
        listTileMapPage(context, 'utils.drawer_map'.tr()),
        listTileChatPage(context, 'utils.drawer_chat'.tr(), unreadCount),
        Divider(),
        listTileSettings(context),
        listTileLogout(context),
      ],
    ),
  );
}

Widget createPlanningDrawer(BuildContext context, SharedPreferences sharedPrefs) {
  final int unreadCount = sharedPrefs.getInt('chat_unread_count');

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
        listTileOrdersUnacceptedPage(context, 'utils.drawer_planning_orders_unaccepted'.tr()),
        listTileOrdersUnAssignedPage(context, 'utils.drawer_planning_orders_unassigned'.tr()),
        listTileOrderPastList(context, 'utils.drawer_planning_orders_past'.tr()),
        listTileOrderFormPage(context, 'utils.drawer_planning_order_new'.tr()),
        listTileCustomerListPage(context, 'utils.drawer_planning_customers'.tr()),
        // listTileQuotationsListPage(context, 'utils.drawer_planning_quotations'.tr()),
        // listTileQuotationUnacceptedPage(context, 'utils.drawer_planning_quotations_unaccepted'.tr()),
        listTileCustomerFormPage(context, 'utils.drawer_planning_new_customer'.tr()),
        listTileProjectList(context, 'utils.drawer_planning_projects'.tr()),
        listTileUserWorkHoursList(context, 'utils.drawer_planning_workhours'.tr()),
        listTileMapPage(context, 'utils.drawer_map'.tr()),
        listTileChatPage(context, 'utils.drawer_chat'.tr(), unreadCount),
        Divider(),
        listTileSettings(context),
        listTileLogout(context),
      ],
    ),
  );
}

Widget createSalesDrawer(BuildContext context, SharedPreferences sharedPrefs) {
  final int unreadCount = sharedPrefs.getInt('chat_unread_count');

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
        listTileOrderSalesList(context, 'utils.drawer_sales_order_list'.tr()),
        // listTileSalesOrderFormPage(context, 'utils.drawer_sales_order_form'.tr()),
        listTileQuotationNewPage(context, 'utils.drawer_sales_quotation_new'.tr()),
        listTileQuotationsListPreliminaryPage(context, 'utils.drawer_sales_quotations_preliminary'.tr()),
        // listTileQuotationsListPage(context, 'utils.drawer_sales_quotations'.tr()),
        // listTileQuotationUnacceptedPage(context, 'utils.drawer_sales_quotations_unaccepted'.tr()),
        listTileCustomerListPage(context, 'utils.drawer_sales_customers'.tr()),
        listTileSalesUserCustomersPage(context, 'utils.drawer_sales_manage_your_customers'.tr()),
        listTileCustomerFormPage(context, 'utils.drawer_sales_new_customer'.tr()),
        listTileUserWorkHoursList(context, 'utils.drawer_sales_workhours'.tr()),
        listTileMapPage(context, 'utils.drawer_map'.tr()),
        listTileChatPage(context, 'utils.drawer_chat'.tr(), unreadCount),
        Divider(),
        listTileSettings(context),
        listTileLogout(context),
      ],
    ),
  );
}

Widget createEmployeeDrawer(BuildContext context, SharedPreferences sharedPrefs) {
  final int unreadCount = sharedPrefs.getInt('chat_unread_count');

  return Drawer(
    // Add a ListView to the drawer. This ensures the user can scroll
    // through the options in the drawer if there isn't enough vertical
    // space to fit everything.
    child: ListView(
      // Important: Remove any padding from the ListView.
      padding: EdgeInsets.all(0),
      children: <Widget>[
        createDrawerHeader(),
        listTileUserWorkHoursList(context, 'utils.drawer_employee_workhours'.tr()),
        listTileMapPage(context, 'utils.drawer_map'.tr()),
        listTileChatPage(context, 'utils.drawer_chat'.tr(), unreadCount),
        Divider(),
        listTileSettings(context),
        listTileLogout(context),
      ],
    ),
  );
}

Future<Widget> getDrawerForUser(BuildContext context) async {
  String submodel = await utils.getUserSubmodel();
  SharedPreferences sharedPrefs = await SharedPreferences.getInstance();

  if (submodel == 'engineer') {
    return createEngineerDrawer(context, sharedPrefs);
  }

  if (submodel == 'customer_user') {
    return createCustomerDrawer(context, sharedPrefs);
  }

  if (submodel == 'planning_user') {
    return createPlanningDrawer(context, sharedPrefs);
  }

  if (submodel == 'sales_user') {
    return createSalesDrawer(context, sharedPrefs);
  }

  if (submodel == 'employee_user') {
    return createEmployeeDrawer(context, sharedPrefs);
  }

  return null;
}
