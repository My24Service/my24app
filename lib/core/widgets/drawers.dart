import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:my24app/core/utils.dart';
import 'package:my24app/home/pages/home.dart';
import 'package:my24app/mobile/pages/assigned_list.dart';
import 'package:my24app/order/pages/list.dart';
import 'package:my24app/order/pages/form.dart';
import 'package:my24app/order/pages/past.dart';
import 'package:my24app/order/pages/unaccepted.dart';
import 'package:my24app/order/pages/unassigned.dart';
import 'package:my24app/mobile/pages/assigned.dart';
import 'package:my24app/quotation/pages/list.dart';
import 'package:my24app/quotation/pages/form.dart';

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
      // Navigator.push(
      //     context, MaterialPageRoute(builder: (context) => SettingsPage())
      // );
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
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => page)
        );
      }
    }, // onTap
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

ListTile listTileQuotationFormPage(BuildContext context, String text) {
  final page = QuotationFormPage();

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
  // final page = LocationInventoryPage();

  return ListTile(
    title: Text(text),
    onTap: () {
      // close the drawer and navigate
      Navigator.pop(context);
      // Navigator.push(
      //     context, MaterialPageRoute(builder: (context) => page)
      // );
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
  // final page = CustomerListPage();

  return ListTile(
    title: Text(text),
    onTap: () {
      // close the drawer and navigate
      Navigator.pop(context);
      // Navigator.push(
      //     context, MaterialPageRoute(builder: (context) => page)
      // );
    },
  );
}

ListTile listTileCustomerFormPage(BuildContext context, String text) {
  // final page = CustomerFormPage();

  return ListTile(
    title: Text(text),
    onTap: () {
      // close the drawer and navigate
      Navigator.pop(context);
      // navigate to quotation list
      // Navigator.push(
      //     context, MaterialPageRoute(builder: (context) => page)
      // );
    },
  );
}

ListTile listTileSalesUserCustomersPage(BuildContext context, String text) {
  // final page = SalesUserCustomersPage();

  return ListTile(
    title: Text(text),
    onTap: () {
      // close the drawer and navigate
      Navigator.pop(context);
      // Navigator.push(
      //     context, MaterialPageRoute(builder: (context) => page)
      // );
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
        listTileOrdersUnacceptedPage(context, 'utils.drawer_customer_orders_unaccepted'.tr()),
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
        listTileQuotationUnacceptedPage(context, 'utils.drawer_engineer_quotations_unaccepted'.tr()),
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
        listTileOrdersUnacceptedPage(context, 'utils.drawer_planning_orders_unaccepted'.tr()),
        listTileOrdersUnAssignedPage(context, 'utils.drawer_planning_orders_unassigned'.tr()),
        listTileOrderPastList(context, 'utils.drawer_planning_orders_past'.tr()),
        listTileOrderFormPage(context, 'utils.drawer_planning_order_new'.tr()),
        listTileCustomerListPage(context, 'utils.drawer_planning_customers'.tr()),
        listTileQuotationsListPage(context, 'utils.drawer_planning_quotations'.tr()),
        listTileQuotationUnacceptedPage(context, 'utils.drawer_planning_quotations_unaccepted'.tr()),
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
        listTileQuotationUnacceptedPage(context, 'utils.drawer_sales_quotations_unaccepted'.tr()),
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
  String submodel = await utils.getUserSubmodel();

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
