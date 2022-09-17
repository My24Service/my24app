import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:my24app/mobile/models/models.dart';
import 'package:my24app/order/models/models.dart';
import 'package:my24app/quotation/models/models.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';

import '../../customer/models/models.dart';

Widget errorNotice(String message) {
  return Center(
          child: Column(
          children: [
            SizedBox(height: 30),
            Text(message),
            SizedBox(height: 30),
          ],
        )
      );
}

Widget errorNoticeWithReload(String message, dynamic reloadBloc, dynamic reloadEvent) {
  return RefreshIndicator(
    child: ListView(
      children: [
        errorNotice(message),
      ],
    ),
    onRefresh: () {
      return Future.delayed(
          Duration(milliseconds: 5),
              () {
                reloadBloc.add(reloadEvent);
              }
      );
    }
  );
}

Widget loadingNotice() {
  return Center(child: CircularProgressIndicator());
  return Center(
      child: Column(
        children: [
          SizedBox(height: 30),
          Text('generic.loading'.tr())
        ],
      )
  );
}

Widget buildMemberInfoCard(BuildContext context, member) => SizedBox(
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
          title: Text('${member.tel}', style: TextStyle(fontWeight: FontWeight.w500)),
          leading: Icon(
            Icons.contact_phone,
            color: Colors.blue[500],
          ),
          onTap: () {
            if (member.tel != '' && member.tel != null) {
              launchURL(context, "tel://${member.tel}");
            }
          },
        ),
      ],
    ),
  ),
);

Widget buildCustomerInfoCard(BuildContext context, Customer customer) => Container(
  child: Column(
      // mainAxisSize: MainAxisSize.max,
      children: [
        ListTile(
          title: Text('${customer.name}', style: TextStyle(fontWeight: FontWeight.w500)),
          subtitle: Text('${customer.address}\n${customer.countryCode}-${customer.postal}\n${customer.city}'),
          leading: Icon(
            Icons.home,
            color: Colors.blue[500],
          ),
        ),
        if (customer.tel != null && customer.tel != '')
          ListTile(
            title: Text('${customer.tel}', style: TextStyle(fontWeight: FontWeight.w500)),
            leading: Icon(
              Icons.contact_phone,
              color: Colors.blue[500],
            ),
            onTap: () {
              if (customer.tel != '' && customer.tel != null) {
                launchURL(context, "tel://${customer.tel}");
              }
            },
          ),
        if (customer.mobile != null && customer.mobile != '')
          ListTile(
            title: Text('${customer.mobile}', style: TextStyle(fontWeight: FontWeight.w500)),
            leading: Icon(
              Icons.send_to_mobile,
              color: Colors.blue[500],
            ),
            onTap: () {
              if (customer.mobile != '' && customer.mobile != null) {
                launchURL(context, "tel://${customer.mobile}");
              }
            },
          ),
        if (customer.email != null && customer.email != '')
          ListTile(
            dense: true,
            title: Text('customers.info_email'.tr(), style: TextStyle(fontWeight: FontWeight.w500)),
            subtitle: Text('${customer.email}'),
          ),
        ListTile(
          dense: true,
          title: Text('customers.info_contact'.tr(), style: TextStyle(fontWeight: FontWeight.w500)),
          subtitle: Text('${customer.contact}'),
        ),
        ListTile(
          dense: true,
          title: Text('customers.info_customer_id'.tr(), style: TextStyle(fontWeight: FontWeight.w500)),
          subtitle: Text('${customer.customerId}'),
        ),
      ],
  )
);

Widget buildOrderInfoCard(BuildContext context, Order order) => Container(
    child: Column(
      // mainAxisSize: MainAxisSize.max,
      children: [
        ListTile(
          title: Text('${order.orderName}', style: TextStyle(fontWeight: FontWeight.w500)),
          subtitle: Text('${order.orderAddress}\n${order.orderCountryCode}-${order.orderPostal}\n${order.orderCity}'),
          leading: Icon(
            Icons.home,
            color: Colors.blue[500],
          ),
        ),
        if (order.orderTel != null && order.orderTel != '')
          ListTile(
            title: Text('${order.orderTel}', style: TextStyle(fontWeight: FontWeight.w500)),
            leading: Icon(
              Icons.contact_phone,
              color: Colors.blue[500],
            ),
            onTap: () {
              if (order.orderTel != '' && order.orderTel != null) {
                launchURL(context, "tel://${order.orderTel}");
              }
            },
          ),
        if (order.orderMobile != null && order.orderMobile != '')
          ListTile(
            title: Text('${order.orderMobile}', style: TextStyle(fontWeight: FontWeight.w500)),
            leading: Icon(
              Icons.send_to_mobile,
              color: Colors.blue[500],
            ),
            onTap: () {
              if (order.orderMobile != '' && order.orderMobile != null) {
                launchURL(context, "tel://${order.orderMobile}");
              }
            },
          ),
        ListTile(
          dense: true,
          title: Text('orders.info_order_id'.tr(), style: TextStyle(fontWeight: FontWeight.w500)),
          subtitle: Text('${order.orderId}'),
        ),
        ListTile(
          dense: true,
          title: Text('orders.info_last_status'.tr(), style: TextStyle(fontWeight: FontWeight.w500)),
          subtitle: Text('${order.lastStatusFull}'),
        ),
        ListTile(
          dense: true,
          title: Text('orders.info_order_type'.tr(), style: TextStyle(fontWeight: FontWeight.w500)),
          subtitle: Text('${order.orderType}'),
        ),
        ListTile(
          dense: true,
          title: Text('orders.info_order_date'.tr(), style: TextStyle(fontWeight: FontWeight.w500)),
          subtitle: Text('${order.orderDate}'),
        ),
        ListTile(
          dense: true,
          title: Text('orders.info_order_reference'.tr(), style: TextStyle(fontWeight: FontWeight.w500)),
          subtitle: Text('${order.orderReference}'),
        ),
        ListTile(
          dense: true,
          title: Text('orders.info_customer_id'.tr(), style: TextStyle(fontWeight: FontWeight.w500)),
          subtitle: Text('${order.customerId}'),
        ),
        ListTile(
          dense: true,
          title: Text('customers.info_contact'.tr(), style: TextStyle(fontWeight: FontWeight.w500)),
          subtitle: Text('${order.orderContact}'),
        ),
        if (order.orderEmail != null && order.orderEmail != '')
          ListTile(
            dense: true,
            title: Text('customers.info_email'.tr(), style: TextStyle(fontWeight: FontWeight.w500)),
            subtitle: Text('${order.orderEmail}'),
          ),
        if (order.customerRemarks != null && order.customerRemarks != '')
          ListTile(
            dense: true,
            title: Text('orders.info_order_customer_remarks'.tr(), style: TextStyle(fontWeight: FontWeight.w500)),
            subtitle: Text('${order.customerRemarks}'),
          ),
      ],
    )
);

Widget buildAssignedOrderInfoCard(BuildContext context, AssignedOrder assignedOrder) => Container(
    child: Column(
      // mainAxisSize: MainAxisSize.max,
      children: [
        ListTile(
          title: Text('${assignedOrder.order.orderName}', style: TextStyle(fontWeight: FontWeight.w500)),
          subtitle: Text('${assignedOrder.order.orderAddress}\n${assignedOrder.order.orderCountryCode}-${assignedOrder.order.orderPostal}\n${assignedOrder.order.orderCity}'),
          leading: Icon(
            Icons.home,
            color: Colors.blue[500],
          ),
        ),
        if (assignedOrder.order.orderTel != null && assignedOrder.order.orderTel != '')
          ListTile(
            title: Text('${assignedOrder.order.orderTel}', style: TextStyle(fontWeight: FontWeight.w500)),
            leading: Icon(
              Icons.contact_phone,
              color: Colors.blue[500],
            ),
            onTap: () {
              if (assignedOrder.order.orderTel != '' && assignedOrder.order.orderTel != null) {
                launchURL(context, "tel://${assignedOrder.order.orderTel}");
              }
            },
          ),
        if (assignedOrder.order.orderMobile != null && assignedOrder.order.orderMobile != '')
          ListTile(
            title: Text('${assignedOrder.order.orderMobile}', style: TextStyle(fontWeight: FontWeight.w500)),
            leading: Icon(
              Icons.send_to_mobile,
              color: Colors.blue[500],
            ),
            onTap: () {
              if (assignedOrder.order.orderMobile != '' && assignedOrder.order.orderMobile != null) {
                launchURL(context, "tel://${assignedOrder.order.orderMobile}");
              }
            },
          ),
        ListTile(
          dense: true,
          title: Text('orders.info_order_id'.tr(), style: TextStyle(fontWeight: FontWeight.w500)),
          subtitle: Text('${assignedOrder.order.orderId}'),
        ),
        ListTile(
          dense: true,
          title: Text('orders.info_order_type'.tr(), style: TextStyle(fontWeight: FontWeight.w500)),
          subtitle: Text('${assignedOrder.order.orderType}'),
        ),
        ListTile(
          dense: true,
          title: Text('orders.info_order_date'.tr(), style: TextStyle(fontWeight: FontWeight.w500)),
          subtitle: Text('${assignedOrder.order.orderDate}'),
        ),
        ListTile(
          dense: true,
          title: Text('orders.info_order_reference'.tr(), style: TextStyle(fontWeight: FontWeight.w500)),
          subtitle: Text('${assignedOrder.order.orderReference}'),
        ),
        ListTile(
          dense: true,
          title: Text('orders.info_customer_id'.tr(), style: TextStyle(fontWeight: FontWeight.w500)),
          subtitle: Text('${assignedOrder.order.customerId}'),
        ),
        ListTile(
          dense: true,
          title: Text('orders.info_contact'.tr(), style: TextStyle(fontWeight: FontWeight.w500)),
          subtitle: Text('${assignedOrder.order.orderContact}'),
        ),
        if (assignedOrder.order.orderEmail != null && assignedOrder.order.orderEmail != '')
          ListTile(
            dense: true,
            title: Text('orders.info_order_email'.tr(), style: TextStyle(fontWeight: FontWeight.w500)),
            subtitle: Text('${assignedOrder.order.orderEmail}'),
          ),
        if (assignedOrder.order.customerRemarks != null && assignedOrder.order.customerRemarks != '')
          ListTile(
            dense: true,
            title: Text('orders.info_order_customer_remarks'.tr(), style: TextStyle(fontWeight: FontWeight.w500)),
            subtitle: Text('${assignedOrder.order.customerRemarks}'),
          ),
        if (assignedOrder.customer.maintenanceContract != null && assignedOrder.customer.maintenanceContract != '')
          ListTile(
            dense: true,
            title: Text('assigned_orders.detail.info_maintenance_contract'.tr(), style: TextStyle(fontWeight: FontWeight.w500)),
            subtitle: Text('${assignedOrder.customer.maintenanceContract}'),
          ),
      ],
    )
);

Widget buildQuotationInfoCard(BuildContext context, Quotation quotation) => Container(
    child: Column(
      // mainAxisSize: MainAxisSize.max,
      children: [
        ListTile(
          title: Text('${quotation.quotationName}', style: TextStyle(fontWeight: FontWeight.w500)),
          subtitle: Text('${quotation.quotationAddress}\n${quotation.quotationCountryCode}-${quotation.quotationPostal}\n${quotation.quotationCity}'),
          leading: Icon(
            Icons.home,
            color: Colors.blue[500],
          ),
        ),
        if (quotation.quotationTel != null && quotation.quotationTel != '')
          ListTile(
            title: Text('${quotation.quotationTel}', style: TextStyle(fontWeight: FontWeight.w500)),
            leading: Icon(
              Icons.contact_phone,
              color: Colors.blue[500],
            ),
            onTap: () {
              if (quotation.quotationTel != '' && quotation.quotationTel != null) {
                launchURL(context, "tel://${quotation.quotationTel}");
              }
            },
          ),
        if (quotation.quotationMobile != null && quotation.quotationMobile != '')
          ListTile(
            title: Text('${quotation.quotationMobile}', style: TextStyle(fontWeight: FontWeight.w500)),
            leading: Icon(
              Icons.send_to_mobile,
              color: Colors.blue[500],
            ),
            onTap: () {
              if (quotation.quotationMobile != '' && quotation.quotationMobile != null) {
                launchURL(context, "tel://${quotation.quotationMobile}");
              }
            },
          ),
        ListTile(
          dense: true,
          title: Text('quotations.info_quotation_id'.tr(), style: TextStyle(fontWeight: FontWeight.w500)),
          subtitle: Text('${quotation.quotationId}'),
        ),
        ListTile(
          dense: true,
          title: Text('quotations.info_description'.tr(), style: TextStyle(fontWeight: FontWeight.w500)),
          subtitle: Text('${quotation.description}'),
        ),
        ListTile(
          dense: true,
          title: Text('quotations.info_last_status'.tr(), style: TextStyle(fontWeight: FontWeight.w500)),
          subtitle: Text('${quotation.lastStatusFull}'),
        ),
        ListTile(
          dense: true,
          title: Text('quotations.info_reference'.tr(), style: TextStyle(fontWeight: FontWeight.w500)),
          subtitle: Text('${quotation.quotationReference}'),
        ),
        if (quotation.quotationEmail != null && quotation.quotationEmail != '')
          ListTile(
            dense: true,
            title: Text('quotations.info_email'.tr(), style: TextStyle(fontWeight: FontWeight.w500)),
            subtitle: Text('${quotation.quotationEmail}'),
          ),
      ],
    )
);


Widget buildEmptyListFeedback({String noResultsString}) {
  if (noResultsString == null) {
    noResultsString = 'generic.empty_table'.tr();
  }

  return Column(
    children: [
      SizedBox(height: 1),
      Text(noResultsString, style: TextStyle(fontStyle: FontStyle.italic))
    ],
  );
}

ElevatedButton createElevatedButtonColored(
    String text,
    Function callback,
    { foregroundColor=Colors.white, backgroundColor=Colors.blue}
    ) {
  return ElevatedButton(
    style: ElevatedButton.styleFrom(
      foregroundColor: foregroundColor,
      backgroundColor: backgroundColor,
    ),
    child: new Text(text),
    onPressed: callback,
  );
}

ElevatedButton createDefaultElevatedButton(String text, Function callback) {
  return ElevatedButton(
    style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white
    ),
    child: new Text(text),
    onPressed: callback,
  );
}

Widget createPhoneSection(BuildContext context, String number) {
  if (number == '' || number == null) {
    return SizedBox(height: 1);
  }

  return ElevatedButton(
    style: ElevatedButton.styleFrom(
        foregroundColor: Colors.black,
        backgroundColor: Colors.white,
        padding: EdgeInsets.all(1)
    ),
    child: new Text(number),
    onPressed: () => launchURL(context, "tel://$number"),
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

Widget createSubHeader(String text) {
  return Container(child: Column(
    children: [
      SizedBox(
        height: 10.0,
      ),
      Text(text, style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16,
          color: Colors.grey
      )),
      SizedBox(
        height: 10.0,
      ),
    ],
  ));
}

Future<dynamic> displayDialog(context, title, text) {
  return showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
          title: Text(title),
          content: Text(text)
      );
    }
  );
}

showDeleteDialogWrapper(String title, String content, BuildContext context, Function deleteFunction) {
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
    duration: Duration(seconds: 1),
  );

  // Find the ScaffoldMessenger in the widget tree
  // and use it to show a SnackBar.
  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}

Widget createTable(List<TableRow> rows) {
  return Table(
      border: TableBorder(horizontalInside: BorderSide(width: 1, color: Colors.grey, style: BorderStyle.solid)),
      children: rows
  );
}

Widget createTableWidths(List<TableRow> rows, Map<int, TableColumnWidth> columnWidths) {
  return Table(
      columnWidths: columnWidths,
      border: TableBorder(horizontalInside: BorderSide(width: 1, color: Colors.grey, style: BorderStyle.solid)),
      children: rows
  );
}

Widget createTableHeaderCell(String content, [double padding=8.0]) {
  return Padding(
    padding: EdgeInsets.all(padding),
    child: Text(content, style: TextStyle(fontWeight: FontWeight.bold)),
  );
}

Widget createTableColumnCell(String content, [double padding=4.0]) {
  return Padding(
    padding: EdgeInsets.all(padding),
    child: Text(content != null ? content : ''),
  );
}

Widget createOrderListHeader(Order order, String date) {
  return Table(
    children: [
      TableRow(
          children: [
            Text('orders.info_order_date'.tr(), style: TextStyle(fontWeight: FontWeight.bold)),
            Text(date)
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


Widget buildItemsSection(String header, List<dynamic> items, Function itemBuilder, Function getActions, {String noResultsString}) {
    if(items == null || items.length == 0) {
      return Container(
          child: Column(
              children: [
                createHeader(header),
                buildEmptyListFeedback(noResultsString: noResultsString)
              ]
          )
      );
    }

    List<Widget> resultItems = [];
    for (int i = 0; i < items.length; ++i) {
      var item = items[i];

      var newList = new List<Widget>.from(resultItems)..addAll(itemBuilder(item));
      newList = new List<Widget>.from(newList)..addAll(getActions(item));
      newList.add(Divider());
      resultItems = newList;
    }

    return Container(
      child: Column(
        children: [
          createHeader(header),
          ...resultItems
        ],
      ),
    );
}

Widget buildItemListTile(String title, dynamic subtitle) {
  String text = subtitle != null ? "$subtitle" : "";

  return ListTile(
      dense: true,
      title: createTableHeaderCell(title),
      subtitle: createTableColumnCell(text)
  );
}

Widget buildItemListDeleteButton(dynamic item, Function deleteFunction, BuildContext context) {
  return Padding(
      padding: EdgeInsets.only(left: 16),
      child: Row(
          children: [
            createTableHeaderCell('generic.action_delete'.tr()),
            IconButton(
              icon: Icon(Icons.delete, color: Colors.red),
              onPressed: () {
                deleteFunction(item, context);
              },
            )
          ]
      )
  );
}

Widget buildItemListViewDocumentButton(dynamic item, Function onPressedFunction) {
  return Padding(
      padding: EdgeInsets.only(left: 16),
      child: Row(
          children: [
            createTableHeaderCell('generic.action_view'.tr()),
            IconButton(
              icon: Icon(Icons.view_agenda, color: Colors.green),
              onPressed: () async {
                await onPressedFunction(item);
              },
            )
          ]
      )
  );
}

Widget buildItemListEditButton(dynamic item, Function editFunction, BuildContext context) {
  return Padding(
      padding: EdgeInsets.only(left: 16),
      child: Row(
          children: [
            createTableHeaderCell('generic.action_edit'.tr()),
            IconButton(
              icon: Icon(Icons.edit, color: Colors.green),
              onPressed: () {
                editFunction(item, context);
              },
            )
          ]
      )
  );
}

Widget buildItemListCustomWidget(String title, Widget content) {
  return Padding(
      padding: EdgeInsets.only(left: 16),
      child: Row(
          children: [
            createTableHeaderCell(title),
            content
          ]
      )
  );
}
