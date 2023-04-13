import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:my24app/company/pages/salesuser_customers.dart';
import 'package:my24app/core/i18n_mixin.dart';
import 'package:my24app/core/pages/settings.dart';
import 'package:my24app/core/utils.dart';
import 'package:my24app/customer/pages/list_form.dart';
import 'package:my24app/home/pages/home.dart';
import 'package:my24app/mobile/pages/assigned.dart';
import 'package:my24app/order/blocs/order_bloc.dart';
import 'package:my24app/order/pages/list.dart';
import 'package:my24app/order/pages/past.dart';
import 'package:my24app/order/pages/unaccepted.dart';
import 'package:my24app/order/pages/unassigned.dart';
import 'package:my24app/order/pages/sales_list.dart';
import 'package:my24app/inventory/pages/location_inventory.dart';
import 'package:my24app/quotation/pages/list.dart';
import 'package:my24app/quotation/pages/preliminary_new.dart';
import 'package:my24app/chat/pages/chat.dart';
import 'package:my24app/company/pages/project_list.dart';
import 'package:my24app/company/pages/workhours_list.dart';
import 'package:my24app/interact/pages/map.dart';
import 'package:my24app/mobile/blocs/assignedorder_bloc.dart';
import 'package:my24app/quotation/pages/list_preliminary.dart';
import 'package:my24app/customer/blocs/customer_bloc.dart';
import 'package:my24app/inventory/blocs/location_inventory_bloc.dart';

// Drawers
Widget createDrawerHeader() {
  return SizedBox(height: 30);
}

ListTile listTileSettings(context) {
  final page = SettingsPage();

  return ListTile(
    title: Text(getTranslationTr('utils.drawer_settings', null)),
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
    title: Text(getTranslationTr('utils.drawer_logout', null)),
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
  final page = OrderListPage(bloc: OrderBloc());

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
  final page = UnacceptedPage(
    bloc: OrderBloc(),
  );

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
  final page = PastPage(
      bloc: OrderBloc()
  );

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
  final page = SalesPage(
      bloc: OrderBloc()
  );

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
  final page = AssignedOrdersPage(bloc: AssignedOrderBloc());

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
  final page = LocationInventoryPage(
    bloc: LocationInventoryBloc(),
  );

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
  final page = OrdersUnAssignedPage(
    bloc: OrderBloc(),
  );

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
  final page = CustomerPage(
    bloc: CustomerBloc(),
  );

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
        listTileOrderList(context, getTranslationTr('utils.drawer_customer_orders', null)),
        listTileOrdersUnacceptedPage(context, getTranslationTr('utils.drawer_customer_orders_unaccepted', null)),
        listTileOrderPastList(context, getTranslationTr('utils.drawer_customer_orders_past', null)),
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
        listTileAssignedOrdersListPage(context, getTranslationTr('utils.drawer_engineer_orders', null)),
        listTileOrdersUnAssignedPage(context, getTranslationTr('utils.drawer_engineer_orders_unassigned', null)),
        listTileLocationInventoryPage(context, getTranslationTr('utils.drawer_engineer_location_inventory', null)),

        listTileUserWorkHoursList(context, getTranslationTr('utils.drawer_engineer_workhours', null)),
        listTileMapPage(context, getTranslationTr('utils.drawer_map', null)),
        listTileChatPage(context, getTranslationTr('utils.drawer_chat', null), unreadCount),
        Divider(),
        listTileSettings(context),
        listTileLogout(context),
      ],
    ),
  );
}

Widget createPlanningDrawer(BuildContext context, SharedPreferences sharedPrefs, bool hasBranches) {
  final int unreadCount = sharedPrefs.getInt('chat_unread_count');

  if (!hasBranches) {
    return Drawer(
      // Add a ListView to the drawer. This ensures the user can scroll
      // through the options in the drawer if there isn't enough vertical
      // space to fit everything.
      child: ListView(
        // Important: Remove any padding from the ListView.
        padding: EdgeInsets.all(0),
        children: <Widget>[
          createDrawerHeader(),
          listTileOrderList(context, getTranslationTr('utils.drawer_planning_orders', null)),
          listTileOrdersUnacceptedPage(context, getTranslationTr('utils.drawer_planning_orders_unaccepted', null)),
          listTileOrdersUnAssignedPage(context, getTranslationTr('utils.drawer_planning_orders_unassigned', null)),
          listTileOrderPastList(context, getTranslationTr('utils.drawer_planning_orders_past', null)),
          listTileCustomerListPage(context, getTranslationTr('utils.drawer_planning_customers', null)),
          // listTileQuotationsListPage(context, 'utils.drawer_planning_quotations'.tr()),
          // listTileQuotationUnacceptedPage(context, 'utils.drawer_planning_quotations_unaccepted'.tr()),
          listTileProjectList(context, getTranslationTr('utils.drawer_planning_projects', null)),
          listTileUserWorkHoursList(context, getTranslationTr('utils.drawer_planning_workhours', null)),
          listTileMapPage(context, getTranslationTr('utils.drawer_map', null)),
          listTileChatPage(context, getTranslationTr('utils.drawer_chat', null), unreadCount),
          Divider(),
          listTileSettings(context),
          listTileLogout(context),
        ],
      ),
    );
  }

  return Drawer(
    // Add a ListView to the drawer. This ensures the user can scroll
    // through the options in the drawer if there isn't enough vertical
    // space to fit everything.
    child: ListView(
      // Important: Remove any padding from the ListView.
      padding: EdgeInsets.all(0),
      children: <Widget>[
        createDrawerHeader(),
        listTileOrderList(context, getTranslationTr('utils.drawer_planning_orders', null)),
        listTileOrdersUnAssignedPage(context, getTranslationTr('utils.drawer_planning_orders_unassigned', null)),
        listTileOrderPastList(context, getTranslationTr('utils.drawer_planning_orders_past', null)),
        // listTileUserWorkHoursList(context, 'utils.drawer_planning_workhours'.tr()),
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
        listTileOrderList(context, getTranslationTr('utils.drawer_sales_orders', null)),
        listTileOrderSalesList(context, getTranslationTr('utils.drawer_sales_order_list', null)),
        // listTileSalesOrderFormPage(context, 'utils.drawer_sales_order_form'.tr()),
        // listTileQuotationNewPage(context, 'utils.drawer_sales_quotation_new'.tr()),
        // listTileQuotationsListPreliminaryPage(context, 'utils.drawer_sales_quotations_preliminary'.tr()),
        // listTileQuotationsListPage(context, 'utils.drawer_sales_quotations'.tr()),
        // listTileQuotationUnacceptedPage(context, 'utils.drawer_sales_quotations_unaccepted'.tr()),
        listTileCustomerListPage(context, getTranslationTr('utils.drawer_sales_customers', null)),
        listTileSalesUserCustomersPage(context, getTranslationTr('utils.drawer_sales_manage_your_customers', null)),
        listTileUserWorkHoursList(context, getTranslationTr('utils.drawer_sales_workhours', null)),
        listTileMapPage(context, getTranslationTr('utils.drawer_map', null)),
        listTileChatPage(context, getTranslationTr('utils.drawer_chat', null), unreadCount),
        Divider(),
        listTileSettings(context),
        listTileLogout(context),
      ],
    ),
  );
}

Widget createEmployeeDrawer(BuildContext context, SharedPreferences sharedPrefs, bool hasBranches) {
  final int unreadCount = sharedPrefs.getInt('chat_unread_count');

  if (!hasBranches) {
    return Drawer(
      // Add a ListView to the drawer. This ensures the user can scroll
      // through the options in the drawer if there isn't enough vertical
      // space to fit everything.
      child: ListView(
        // Important: Remove any padding from the ListView.
        padding: EdgeInsets.all(0),
        children: <Widget>[
          createDrawerHeader(),
          listTileUserWorkHoursList(context, getTranslationTr('utils.drawer_employee_workhours', null)),
          listTileMapPage(context, getTranslationTr('utils.drawer_map', null)),
          listTileChatPage(context, getTranslationTr('utils.drawer_chat', null), unreadCount),
          Divider(),
          listTileSettings(context),
          listTileLogout(context),
        ],
      ),
    );
  }

  return Drawer(
    // Add a ListView to the drawer. This ensures the user can scroll
    // through the options in the drawer if there isn't enough vertical
    // space to fit everything.
    child: ListView(
      // Important: Remove any padding from the ListView.
      padding: EdgeInsets.all(0),
      children: <Widget>[
        createDrawerHeader(),
        listTileOrderList(context, getTranslationTr('utils.drawer_employee_orders', null)),
        listTileOrdersUnacceptedPage(context, getTranslationTr('utils.drawer_employee_orders_unaccepted', null)),
        listTileOrderPastList(context, getTranslationTr('utils.drawer_employee_orders_past', null)),
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
    final bool hasBranches = sharedPrefs.getBool('member_has_branches');
    return createPlanningDrawer(context, sharedPrefs, hasBranches);
  }

  if (submodel == 'sales_user') {
    return createSalesDrawer(context, sharedPrefs);
  }

  if (submodel == 'employee_user' || submodel == 'branch_employee_user') {
    final bool hasBranches = sharedPrefs.getBool('member_has_branches') && sharedPrefs.getInt('employee_branch') > 0;
    return createEmployeeDrawer(context, sharedPrefs, hasBranches);
  }

  return null;
}

Future<Widget> getDrawerForUserWithSubmodel(BuildContext context, String submodel) async {
  SharedPreferences sharedPrefs = await SharedPreferences.getInstance();

  if (submodel == 'engineer') {
    return createEngineerDrawer(context, sharedPrefs);
  }

  if (submodel == 'customer_user') {
    return createCustomerDrawer(context, sharedPrefs);
  }

  if (submodel == 'planning_user') {
    final bool hasBranches = sharedPrefs.getBool('member_has_branches');
    return createPlanningDrawer(context, sharedPrefs, hasBranches);
  }

  if (submodel == 'sales_user') {
    return createSalesDrawer(context, sharedPrefs);
  }

  if (submodel == 'employee_user' || submodel == 'branch_employee_user') {
    final bool hasBranches = sharedPrefs.getBool('member_has_branches') && sharedPrefs.getInt('employee_branch') > 0;
    return createEmployeeDrawer(context, sharedPrefs, hasBranches);
  }

  return null;
}
