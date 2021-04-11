import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:my24app/core/utils.dart';
import 'package:my24app/order/pages/list.dart';
import 'package:my24app/order/pages/form.dart';

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
  return ListTile(
    title: Text('utils.drawer_logout'.tr()),
    onTap: () async {
      // close the drawer and navigate
      Navigator.pop(context);

      bool loggedOut = await utils.logout();
      // if (loggedOut == true) {
      //   Navigator.push(
      //       context, MaterialPageRoute(builder: (context) => My24App())
      //   );
      // }
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
      // Navigator.push(
      //     context, MaterialPageRoute(builder: (context) => OrderNotAcceptedListPage())
      // );
    },
  );
}

ListTile listTileOrderPastList(BuildContext context, String text) {
  return ListTile(
    title: Text(text),
    onTap: () {
      // close the drawer and navigate
      Navigator.pop(context);
      // Navigator.push(
      //     context, MaterialPageRoute(builder: (context) => OrderPastListPage())
      // );
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
          context, MaterialPageRoute(builder: (context) => OrderFormPage(orderPk: null))
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
      // Navigator.push(
      //     context, MaterialPageRoute(builder: (context) => QuotationFormPage())
      // );
    },
  );
}

ListTile listTileQuotationsListPage(BuildContext context, String text) {
  return ListTile(
    title: Text(text),
    onTap: () {
      // close the drawer and navigate
      Navigator.pop(context);
      // Navigator.push(
      //     context, MaterialPageRoute(builder: (context) => QuotationsListPage())
      // );
    },
  );
}

ListTile listTileQuotationNotAcceptedListPage(BuildContext context, String text) {
  return ListTile(
    title: Text(text),
    onTap: () {
      // close the drawer and navigate
      Navigator.pop(context);
      // Navigator.push(
      //     context, MaterialPageRoute(builder: (context) => QuotationNotAcceptedListPage())
      // );
    },
  );
}

ListTile listTileAssignedOrdersListPage(BuildContext context, String text) {
  return ListTile(
    title: Text(text),
    onTap: () {
      // close the drawer and navigate
      Navigator.pop(context);
      // Navigator.push(
      //     context, MaterialPageRoute(builder: (context) => AssignedOrdersListPage())
      // );
    },
  );
}

ListTile listTileLocationInventoryPage(BuildContext context, String text) {
  return ListTile(
    title: Text(text),
    onTap: () {
      // close the drawer and navigate
      Navigator.pop(context);
      // Navigator.push(
      //     context, MaterialPageRoute(builder: (context) => LocationInventoryPage())
      // );
    },
  );
}

ListTile listTileOrdersUnAssignedPage(BuildContext context, String text) {
  return ListTile(
    title: Text(text),
    onTap: () {
      // close the drawer and navigate
      Navigator.pop(context);
      // Navigator.push(
      //     context, MaterialPageRoute(builder: (context) => OrdersUnAssignedPage())
      // );
    },
  );
}

ListTile listTileCustomerListPage(BuildContext context, String text) {
  return ListTile(
    title: Text(text),
    onTap: () {
      // close the drawer and navigate
      Navigator.pop(context);
      // Navigator.push(
      //     context, MaterialPageRoute(builder: (context) => CustomerListPage())
      // );
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
      // Navigator.push(
      //     context, MaterialPageRoute(builder: (context) => CustomerFormPage())
      // );
    },
  );
}

ListTile listTileSalesUserCustomersPage(BuildContext context, String text) {
  return ListTile(
    title: Text(text),
    onTap: () {
      // close the drawer and navigate
      Navigator.pop(context);
      // Navigator.push(
      //     context, MaterialPageRoute(builder: (context) => SalesUserCustomersPage())
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
