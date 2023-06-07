import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:my24app/company/pages/salesuser_customer.dart';
import 'package:my24app/core/i18n_mixin.dart';
import 'package:my24app/interact/pages/preferences.dart';
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
// import 'package:my24app/chat/pages/chat.dart';
import 'package:my24app/company/pages/project.dart';
import 'package:my24app/company/pages/workhours.dart';
import 'package:my24app/interact/pages/map.dart';
import 'package:my24app/mobile/blocs/assignedorder_bloc.dart';
import 'package:my24app/quotation/pages/list_preliminary.dart';
import 'package:my24app/customer/blocs/customer_bloc.dart';
import 'package:my24app/inventory/blocs/location_inventory_bloc.dart';
import 'package:my24app/company/blocs/project_bloc.dart';
import 'package:my24app/company/blocs/workhours_bloc.dart';
import 'package:my24app/company/blocs/leave_type_bloc.dart';
import 'package:my24app/company/pages/leave_type.dart';
import 'package:my24app/company/pages/leavehours.dart';
import 'package:my24app/company/blocs/leavehours_bloc.dart';
import 'package:my24app/company/blocs/salesuser_customer_bloc.dart';
import 'package:my24app/interact/blocs/preferences/blocs.dart';

// Drawers
Widget createDrawerHeader() {
  return SizedBox(height: 50);
}

ListTile listTilePreferences(context) {
  return ListTile(
    title: Text(getTranslationTr('utils.drawer_preferences', null)),
    onTap: () {
      // close the drawer and navigate
      Navigator.pop(context);
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => PreferencesPage(
          bloc: PreferencesBloc()
      ))
      );
    }, // onTap
  );
}

ListTile listTileMapPage(context, String text) {
  return ListTile(
    title: Text(text),
    onTap: () {
      // close the drawer and navigate
      Navigator.pop(context);
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => MapPage())
      );
    }, // onTap
  );
}

ListTile listTileLogout(context) {
  return ListTile(
    title: Text(getTranslationTr('utils.drawer_logout', null)),
    onTap: () async {
      // close the drawer and navigate
      Navigator.pop(context);

      bool loggedOut = await utils.logout();
      if (loggedOut == true) {
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => My24App())
        );
      }
    }, // onTap
  );
}

ListTile listTileProjectList(BuildContext context, String text) {
  return ListTile(
    title: Text(text),
    onTap: () {
      // close the drawer and navigate
      Navigator.pop(context);
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => ProjectPage(
        bloc: ProjectBloc(),
      ))
      );
    },
  );
}

ListTile listTileLeaveTypeList(BuildContext context, String text) {
  return ListTile(
    title: Text(text),
    onTap: () {
      // close the drawer and navigate
      Navigator.pop(context);
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => LeaveTypePage(
            bloc: LeaveTypeBloc(),
          )
      )
      );
    },
  );
}

ListTile listTileUserLeaveHoursList(BuildContext context, String text) {
  return ListTile(
    title: Text(text),
    onTap: () {
      // close the drawer and navigate
      Navigator.pop(context);
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => UserLeaveHoursPage(
          bloc: UserLeaveHoursBloc(),
          initialMode: null
      ))
      );
    },
  );
}

ListTile listTileUserLeaveHoursUnacceptedList(BuildContext context, String text) {
  return ListTile(
    title: Text(text),
    onTap: () {
      // close the drawer and navigate
      Navigator.pop(context);
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => UserLeaveHoursPage(
          bloc: UserLeaveHoursBloc(),
          initialMode: "unaccepted"
      ))
      );
    },
  );
}

ListTile listTileUserWorkHoursList(BuildContext context, String text) {
  return ListTile(
    title: Text(text),
    onTap: () {
      // close the drawer and navigate
      Navigator.pop(context);
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => UserWorkHoursPage(
        bloc: UserWorkHoursBloc(),
      ))
      );
    },
  );
}

ListTile listTileOrderList(BuildContext context, String text) {
  return ListTile(
    title: Text(text),
    onTap: () {
      // close the drawer and navigate
      Navigator.pop(context);
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => OrderListPage(bloc: OrderBloc()))
      );
    },
  );
}

ListTile listTileOrdersUnacceptedPage(BuildContext context, String text) {
  return ListTile(
    title: Text(text),
    onTap: () {
      // close the drawer and navigate
      Navigator.pop(context);
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => UnacceptedPage(
        bloc: OrderBloc(),
      ))
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
          context, MaterialPageRoute(builder: (context) => PastPage(
          bloc: OrderBloc()
      ))
      );
    },
  );
}

ListTile listTileOrderSalesList(BuildContext context, String text) {
  return ListTile(
    title: Text(text),
    onTap: () {
      // close the drawer and navigate
      Navigator.pop(context);
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => SalesPage(
          bloc: OrderBloc()
      ))
      );
    },
  );
}

ListTile listTileQuotationNewPage(BuildContext context, String text) {
  return ListTile(
    title: Text(text),
    onTap: () {
      // close the drawer and navigate
      Navigator.pop(context);
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => PreliminaryNewPage())
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
          context, MaterialPageRoute(builder: (context) => QuotationListPage(mode: ListModes.ALL))
      );
    },
  );
}

ListTile listTileQuotationsListPreliminaryPage(BuildContext context, String text) {
  return ListTile(
    title: Text(text),
    onTap: () {
      // close the drawer and navigate
      Navigator.pop(context);
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => PreliminaryQuotationListPage())
      );
    },
  );
}

ListTile listTileQuotationUnacceptedPage(BuildContext context, String text) {
  return ListTile(
    title: Text(text),
    onTap: () {
      // close the drawer and navigate
      Navigator.pop(context);
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => QuotationListPage(mode: ListModes.UNACCEPTED))
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
          context, MaterialPageRoute(builder: (context) => AssignedOrdersPage(
          bloc: AssignedOrderBloc()))
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
          context, MaterialPageRoute(builder: (context) => LocationInventoryPage(
        bloc: LocationInventoryBloc(),
      ))
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
          context, MaterialPageRoute(builder: (context) => OrdersUnAssignedPage(
        bloc: OrderBloc(),
      ))
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
          context, MaterialPageRoute(builder: (context) => CustomerPage(
        bloc: CustomerBloc(),
      ))
      );
    },
  );
}

ListTile listTileSalesUserCustomerPage(BuildContext context, String text) {
  return ListTile(
    title: Text(text),
    onTap: () {
      // close the drawer and navigate
      Navigator.pop(context);
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => SalesUserCustomerPage(
        bloc: SalesUserCustomerBloc(),
      ))
      );
    },
  );
}

// Widget _getUnreadIndicator(int unreadCount) {
//   if (unreadCount == 0 || unreadCount == null) {
//     return SizedBox(width: 1);
//   }
//
//   return Container(
//     child: Text(
//       '($unreadCount)',
//         style: TextStyle(
//             color: Colors.red
//         )
//     ),
//   );
// }

// ListTile listTileChatPage(BuildContext context, String text, int unreadCount) {
//   final page = ChatPage();
//
//   return ListTile(
//     title: Text(text),
//     trailing: _getUnreadIndicator(unreadCount),
//     onTap: () {
//       // close the drawer and navigate
//       Navigator.pop(context);
//       Navigator.push(
//           context, MaterialPageRoute(builder: (context) => page)
//       );
//     },
//   );
// }

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
        listTilePreferences(context),
        listTileLogout(context),
      ],
    ),
  );
}

Widget createEngineerDrawer(BuildContext context, SharedPreferences sharedPrefs) {
  // final int unreadCount = sharedPrefs.getInt('chat_unread_count');

  return Drawer(

    child: ListView(
      // Important: Remove any padding from the ListView.
      padding: EdgeInsets.all(0),
      children: <Widget>[
        createDrawerHeader(),
        listTileAssignedOrdersListPage(context, getTranslationTr('utils.drawer_engineer_orders', null)),
        // listTileOrdersUnAssignedPage(context, getTranslationTr('utils.drawer_engineer_orders_unassigned', null)),
        listTileLocationInventoryPage(context, getTranslationTr('utils.drawer_engineer_location_inventory', null)),

        listTileUserWorkHoursList(context, getTranslationTr('utils.drawer_engineer_workhours', null)),
        listTileUserLeaveHoursList(context, getTranslationTr('utils.drawer_engineer_leavehours', null)),
        listTileMapPage(context, getTranslationTr('utils.drawer_map', null)),
        // listTileChatPage(context, getTranslationTr('utils.drawer_chat', null), unreadCount),
        Divider(),
        listTilePreferences(context),
        listTileLogout(context),
      ],
    ),
  );
}

Widget createPlanningDrawer(BuildContext context, SharedPreferences sharedPrefs, bool hasBranches) {
  // final int unreadCount = sharedPrefs.getInt('chat_unread_count');

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
          listTileLeaveTypeList(context, getTranslationTr('utils.drawer_planning_leave_types', null)),
          listTileUserLeaveHoursList(context, getTranslationTr('utils.drawer_planning_leavehours', null)),
          listTileUserLeaveHoursUnacceptedList(context, getTranslationTr('utils.drawer_planning_leavehours_unaccepted', null)),

          listTileMapPage(context, getTranslationTr('utils.drawer_map', null)),
          // listTileChatPage(context, getTranslationTr('utils.drawer_chat', null), unreadCount),
          Divider(),
          listTilePreferences(context),
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
        // listTileOrdersUnAssignedPage(context, getTranslationTr('utils.drawer_planning_orders_unassigned', null)),
        listTileOrderPastList(context, getTranslationTr('utils.drawer_planning_orders_past', null)),
        // listTileUserWorkHoursList(context, 'utils.drawer_planning_workhours'.tr()),
        Divider(),
        listTilePreferences(context),
        listTileLogout(context),
      ],
    ),
  );
}

Widget createSalesDrawer(BuildContext context, SharedPreferences sharedPrefs) {
  // final int unreadCount = sharedPrefs.getInt('chat_unread_count');

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
        listTileSalesUserCustomerPage(context, getTranslationTr('utils.drawer_sales_manage_your_customers', null)),
        listTileUserWorkHoursList(context, getTranslationTr('utils.drawer_sales_workhours', null)),
        listTileUserLeaveHoursList(context, getTranslationTr('utils.drawer_sales_leavehours', null)),
        listTileMapPage(context, getTranslationTr('utils.drawer_map', null)),
        // listTileChatPage(context, getTranslationTr('utils.drawer_chat', null), unreadCount),
        Divider(),
        listTilePreferences(context),
        listTileLogout(context),
      ],
    ),
  );
}

Widget createEmployeeDrawer(BuildContext context, SharedPreferences sharedPrefs, bool hasBranches) {
  // final int unreadCount = sharedPrefs.getInt('chat_unread_count');

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
          listTileUserLeaveHoursList(context, getTranslationTr('utils.drawer_employee_leavehours', null)),
          listTileMapPage(context, getTranslationTr('utils.drawer_map', null)),
          // listTileChatPage(context, getTranslationTr('utils.drawer_chat', null), unreadCount),
          Divider(),
          listTilePreferences(context),
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
        listTilePreferences(context),
        listTileLogout(context),
      ],
    ),
  );

}

Future<Widget?> getDrawerForUser(BuildContext context) async {
  String? submodel = await utils.getUserSubmodel();
  SharedPreferences sharedPrefs = await SharedPreferences.getInstance();

  if (submodel == 'engineer') {
    return createEngineerDrawer(context, sharedPrefs);
  }

  if (submodel == 'customer_user') {
    return createCustomerDrawer(context, sharedPrefs);
  }

  if (submodel == 'planning_user') {
    final bool hasBranches = sharedPrefs.getBool('member_has_branches')!;
    return createPlanningDrawer(context, sharedPrefs, hasBranches);
  }

  if (submodel == 'sales_user') {
    return createSalesDrawer(context, sharedPrefs);
  }

  if (submodel == 'employee_user' || submodel == 'branch_employee_user') {
    final bool hasBranches = sharedPrefs.getBool('member_has_branches')! && sharedPrefs.getInt('employee_branch')! > 0;
    return createEmployeeDrawer(context, sharedPrefs, hasBranches);
  }

  return null;
}

Future<Widget?> getDrawerForUserWithSubmodel(BuildContext context, String? submodel) async {
  SharedPreferences sharedPrefs = await SharedPreferences.getInstance();
  bool? hasBranchesMember = await utils.getHasBranches();

  if (submodel == 'engineer') {
    return createEngineerDrawer(context, sharedPrefs);
  }

  if (submodel == 'customer_user') {
    return createCustomerDrawer(context, sharedPrefs);
  }

  if (submodel == 'planning_user') {
    return createPlanningDrawer(context, sharedPrefs, hasBranchesMember!);
  }

  if (submodel == 'sales_user') {
    return createSalesDrawer(context, sharedPrefs);
  }

  if (submodel == 'employee_user' || submodel == 'branch_employee_user') {
    final int? employeeBranch = await utils.getEmployeeBranch();
    final bool hasBranches = hasBranchesMember! && employeeBranch! > 0;
    return createEmployeeDrawer(context, sharedPrefs, hasBranches);
  }

  return null;
}
