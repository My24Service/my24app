import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:my24_flutter_core/i18n.dart';
import 'package:my24_flutter_core/utils.dart';
import 'package:my24_flutter_orders/blocs/order_bloc.dart';

import 'package:my24app/company/pages/salesuser_customer.dart';
import 'package:my24app/interact/pages/preferences.dart';
import 'package:my24app/common/utils.dart';
import 'package:my24app/customer/pages/list_form.dart';
import 'package:my24app/home/pages/home.dart';
import 'package:my24app/mobile/pages/assigned.dart';
import 'package:my24app/order/pages/list.dart';
import 'package:my24app/inventory/pages/location_inventory.dart';
import 'package:my24app/quotation/pages/list.dart';
// import 'package:my24app/chat/pages/chat.dart';
import 'package:my24app/company/pages/project.dart';
import 'package:my24app/company/pages/workhours.dart';
import 'package:my24app/interact/pages/map.dart';
import 'package:my24app/mobile/blocs/assignedorder_bloc.dart';
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
import 'package:my24app/company/blocs/time_registration_bloc.dart';
import 'package:my24app/company/pages/time_registration.dart';


// Drawers
Widget createDrawerHeader() {
  return SizedBox(height: 50);
}

Future<bool> hasQuotations() async {
  final Map<String, dynamic>? initialData = await coreUtils.getInitialDataPrefs();
  if (initialData != null && initialData.containsKey('memberInfo')) {
    final List<String> modules = initialData['memberInfo']['contract']['member_contract'].split('|');
    for (int i=0; i<modules.length; i++) {
      final List<String> parts = modules[i].split(':');
      if (parts[0] == 'quotations') {
        return true;
      }
    }
  }
  return false;
}

ListTile listTilePreferences(context) {
  return ListTile(
    title: Text(My24i18n.tr('utils.drawer_preferences')),
    onTap: () {
      // close the drawer and navigate
      Navigator.pop(context);
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => PreferencesPage(bloc: PreferencesBloc())));
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
          context, MaterialPageRoute(builder: (context) => MapPage()));
    }, // onTap
  );
}

ListTile listTileLogout(context) {
  return ListTile(
    title: Text(My24i18n.tr('utils.drawer_logout')),
    onTap: () async {
      // close the drawer and navigate
      Navigator.pop(context);

      bool loggedOut = await utils.logout();
      if (loggedOut == true) {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => My24App()));
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
          context,
          MaterialPageRoute(
              builder: (context) => ProjectPage(
                    bloc: ProjectBloc(),
                  )));
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
          context,
          MaterialPageRoute(
              builder: (context) => LeaveTypePage(
                    bloc: LeaveTypeBloc(),
                  )));
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
          context,
          MaterialPageRoute(
              builder: (context) => UserLeaveHoursPage(
                  bloc: UserLeaveHoursBloc(), initialMode: null)));
    },
  );
}

ListTile listTileUserLeaveHoursUnacceptedList(
    BuildContext context, String text) {
  return ListTile(
    title: Text(text),
    onTap: () {
      // close the drawer and navigate
      Navigator.pop(context);
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => UserLeaveHoursPage(
                  bloc: UserLeaveHoursBloc(), initialMode: "unaccepted")));
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
          context,
          MaterialPageRoute(
              builder: (context) => UserWorkHoursPage(
                    bloc: UserWorkHoursBloc(),
                  )));
    },
  );
}

ListTile listTileTimeRegistration(BuildContext context, String text) {
  return ListTile(
    title: Text(text),
    onTap: () {
      // close the drawer and navigate
      Navigator.pop(context);
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  TimeRegistrationPage(bloc: TimeRegistrationBloc())));
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
          context,
          MaterialPageRoute(
              builder: (context) => OrderListPage(
                bloc: OrderBloc(),
                fetchMode: OrderEventStatus.fetchAll,
              )
          )
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
          context,
          MaterialPageRoute(
              builder: (context) => OrderListPage(
                bloc: OrderBloc(),
                fetchMode: OrderEventStatus.fetchUnaccepted,
              )
          )
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
      Navigator.push(context,
          MaterialPageRoute(builder: (context) => OrderListPage(
            bloc: OrderBloc(),
            fetchMode: OrderEventStatus.fetchPast,
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
          context,
          MaterialPageRoute(
              builder: (context) => OrderListPage(
                bloc: OrderBloc(),
                fetchMode: OrderEventStatus.fetchSales,
              )
          )
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
          context,
          MaterialPageRoute(
              builder: (context) => QuotationListPage(mode: ListModes.ALL)
          )
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
          context,
          MaterialPageRoute(
              builder: (context) =>
                  QuotationListPage(mode: ListModes.UNACCEPTED)
          )
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
          context,
          MaterialPageRoute(
              builder: (context) =>
                  AssignedOrdersPage(bloc: AssignedOrderBloc())
          )
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
          context,
          MaterialPageRoute(
              builder: (context) => LocationInventoryPage(
                    bloc: LocationInventoryBloc(),
                  )));
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
          context,
          MaterialPageRoute(
              builder: (context) => OrderListPage(
                bloc: OrderBloc(),
                fetchMode: OrderEventStatus.fetchUnassigned,
              )
          )
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
          context,
          MaterialPageRoute(
              builder: (context) => CustomerPage(
                    bloc: CustomerBloc(),
                  )));
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
          context,
          MaterialPageRoute(
              builder: (context) => SalesUserCustomerPage(
                    bloc: SalesUserCustomerBloc(),
                  )));
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

Widget createCustomerDrawer(
    BuildContext context, SharedPreferences sharedPrefs) {
  return Drawer(
    child: ListView(
      // Important: Remove any padding from the ListView.
      padding: EdgeInsets.zero,
      children: <Widget>[
        createDrawerHeader(),
        listTileOrderList(
            context, My24i18n.tr('utils.drawer_customer_orders')),
        listTileOrdersUnacceptedPage(context,
            My24i18n.tr('utils.drawer_customer_orders_unaccepted')),
        listTileOrderPastList(context,
            My24i18n.tr('utils.drawer_customer_orders_past')),
        // listTileQuotationsListPage(context, 'utils.drawer_customer_quotations'.tr()),
        Divider(),
        listTilePreferences(context),
        listTileLogout(context),
      ],
    ),
  );
}

Widget createEngineerDrawer(
    BuildContext context, SharedPreferences sharedPrefs) {
  // final int unreadCount = sharedPrefs.getInt('chat_unread_count');

  return Drawer(
    child: ListView(
      // Important: Remove any padding from the ListView.
      padding: EdgeInsets.all(0),
      children: <Widget>[
        createDrawerHeader(),
        listTileAssignedOrdersListPage(
            context, My24i18n.tr('utils.drawer_engineer_orders')),
        // listTileOrdersUnAssignedPage(context, My24i18n.tr('utils.drawer_engineer_orders_unassigned')),
        listTileLocationInventoryPage(context,
            My24i18n.tr('utils.drawer_engineer_location_inventory')),

        listTileTimeRegistration(
            context, My24i18n.tr('utils.drawer_time_registration')),
        listTileUserWorkHoursList(
            context, My24i18n.tr('utils.drawer_engineer_workhours')),
        listTileUserLeaveHoursList(context,
            My24i18n.tr('utils.drawer_engineer_leavehours')),
        listTileMapPage(context, My24i18n.tr('utils.drawer_map')),
        // listTileChatPage(context, My24i18n.tr('utils.drawer_chat'), unreadCount),
        Divider(),
        listTilePreferences(context),
        listTileLogout(context),
      ],
    ),
  );
}

Widget createPlanningDrawer(
    BuildContext context, SharedPreferences sharedPrefs, bool hasBranches,
    bool companyHasQuotations) {
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
          listTileOrderList(
              context, My24i18n.tr('utils.drawer_planning_orders')),
          listTileOrdersUnacceptedPage(
              context,
              My24i18n.tr(
                  'utils.drawer_planning_orders_unaccepted')),
          listTileOrdersUnAssignedPage(
              context,
              My24i18n.tr(
                  'utils.drawer_planning_orders_unassigned')),
          listTileOrderPastList(context,
              My24i18n.tr('utils.drawer_planning_orders_past')),
          listTileCustomerListPage(context,
              My24i18n.tr('utils.drawer_planning_customers')),
          // if (companyHasQuotations)
          //   listTileQuotationsListPage(context,
          //       My24i18n.tr('utils.drawer_planning_quotations')),
          // listTileQuotationUnacceptedPage(context, 'utils.drawer_planning_quotations_unaccepted'.tr()),
          listTileProjectList(context,
              My24i18n.tr('utils.drawer_planning_projects')),
          listTileTimeRegistration(context,
              My24i18n.tr('utils.drawer_time_registration')),
          listTileUserWorkHoursList(context,
              My24i18n.tr('utils.drawer_planning_workhours')),
          listTileLeaveTypeList(context,
              My24i18n.tr('utils.drawer_planning_leave_types')),
          listTileUserLeaveHoursList(context,
              My24i18n.tr('utils.drawer_planning_leavehours')),
          listTileUserLeaveHoursUnacceptedList(
              context,
              My24i18n.tr(
                  'utils.drawer_planning_leavehours_unaccepted')),

          listTileMapPage(context, My24i18n.tr('utils.drawer_map')),
          // listTileChatPage(context, My24i18n.tr('utils.drawer_chat'), unreadCount),
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
        listTileOrderList(
            context, My24i18n.tr('utils.drawer_planning_orders')),
        // listTileOrdersUnAssignedPage(context, My24i18n.tr('utils.drawer_planning_orders_unassigned')),
        listTileOrderPastList(context,
            My24i18n.tr('utils.drawer_planning_orders_past')),
        // listTileUserWorkHoursList(context, 'utils.drawer_planning_workhours'.tr()),
        Divider(),
        listTilePreferences(context),
        listTileLogout(context),
      ],
    ),
  );
}

Widget createSalesDrawer(BuildContext context, SharedPreferences sharedPrefs,
    bool companyHasQuotations) {
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
        listTileOrderList(
            context, My24i18n.tr('utils.drawer_sales_orders')),
        listTileOrderSalesList(
            context, My24i18n.tr('utils.drawer_sales_order_list')),
        // listTileSalesOrderFormPage(context, 'utils.drawer_sales_order_form'.tr()),
        // listTileQuotationNewPage(context, 'utils.drawer_sales_quotation_new'.tr()),
        // listTileQuotationsListPreliminaryPage(context, 'utils.drawer_sales_quotations_preliminary'.tr()),
        // listTileQuotationsListPage(context, 'utils.drawer_sales_quotations'.tr()),
        // listTileQuotationUnacceptedPage(context, 'utils.drawer_sales_quotations_unaccepted'.tr()),
        // if (companyHasQuotations)
        //   listTileQuotationsListPage(context,
        //       My24i18n.tr('utils.drawer_planning_quotations')),
        listTileCustomerListPage(
            context, My24i18n.tr('utils.drawer_sales_customers')),
        listTileSalesUserCustomerPage(context,
            My24i18n.tr('utils.drawer_sales_manage_your_customers')),
        listTileUserWorkHoursList(
            context, My24i18n.tr('utils.drawer_sales_workhours')),
        listTileUserLeaveHoursList(
            context, My24i18n.tr('utils.drawer_sales_leavehours')),
        listTileTimeRegistration(
            context, My24i18n.tr('utils.drawer_time_registration')),
        listTileMapPage(context, My24i18n.tr('utils.drawer_map')),
        // listTileChatPage(context, My24i18n.tr('utils.drawer_chat'), unreadCount),
        Divider(),
        listTilePreferences(context),
        listTileLogout(context),
      ],
    ),
  );
}

Widget createEmployeeDrawer(
    BuildContext context, SharedPreferences sharedPrefs, bool hasBranches) {
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
          listTileUserWorkHoursList(context,
              My24i18n.tr('utils.drawer_employee_workhours')),
          listTileUserLeaveHoursList(context,
              My24i18n.tr('utils.drawer_employee_leavehours')),
          listTileTimeRegistration(context,
              My24i18n.tr('utils.drawer_time_registration')),
          listTileMapPage(context, My24i18n.tr('utils.drawer_map')),
          // listTileChatPage(context, My24i18n.tr('utils.drawer_chat'), unreadCount),
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
        listTileOrderList(
            context, My24i18n.tr('utils.drawer_employee_orders')),
        listTileOrdersUnacceptedPage(context,
            My24i18n.tr('utils.drawer_employee_orders_unaccepted')),
        listTileOrderPastList(context,
            My24i18n.tr('utils.drawer_employee_orders_past')),
        Divider(),
        listTilePreferences(context),
        listTileLogout(context),
      ],
    ),
  );
}

Future<Widget?> getDrawerForUser(BuildContext context) async {
  String? submodel = await coreUtils.getUserSubmodel();
  SharedPreferences sharedPrefs = await SharedPreferences.getInstance();
  final bool companyHasQuotations = await hasQuotations();

  if (submodel == 'engineer') {
    return createEngineerDrawer(context, sharedPrefs);
  }

  if (submodel == 'customer_user') {
    return createCustomerDrawer(context, sharedPrefs);
  }

  if (submodel == 'planning_user') {
    final bool hasBranches = sharedPrefs.getBool('member_has_branches')!;
    return createPlanningDrawer(context, sharedPrefs, hasBranches, companyHasQuotations);
  }

  if (submodel == 'sales_user') {
    return createSalesDrawer(context, sharedPrefs, companyHasQuotations);
  }

  if (submodel == 'employee_user' || submodel == 'branch_employee_user') {
    final bool hasBranches = sharedPrefs.getBool('member_has_branches')! &&
        sharedPrefs.getInt('employee_branch')! > 0;
    return createEmployeeDrawer(context, sharedPrefs, hasBranches);
  }

  return null;
}

Future<Widget?> getDrawerForUserWithSubmodel(
    BuildContext context, String? submodel) async {
  SharedPreferences sharedPrefs = await SharedPreferences.getInstance();
  bool? hasBranchesMember = await utils.getHasBranches();
  final bool companyHasQuotations = await hasQuotations();

  if (submodel == 'engineer') {
    return createEngineerDrawer(context, sharedPrefs);
  }

  if (submodel == 'customer_user') {
    return createCustomerDrawer(context, sharedPrefs);
  }

  if (submodel == 'planning_user') {
    return createPlanningDrawer(context, sharedPrefs, hasBranchesMember!, companyHasQuotations);
  }

  if (submodel == 'sales_user') {
    return createSalesDrawer(context, sharedPrefs, companyHasQuotations);
  }

  if (submodel == 'employee_user' || submodel == 'branch_employee_user') {
    final int? employeeBranch = await utils.getEmployeeBranch();
    final bool hasBranches = hasBranchesMember! && employeeBranch! > 0;
    return createEmployeeDrawer(context, sharedPrefs, hasBranches);
  }

  return null;
}
