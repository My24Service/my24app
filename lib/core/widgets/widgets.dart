import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:my24app/order/models/models.dart';
import 'package:url_launcher/url_launcher.dart';

import '../utils.dart';

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

ElevatedButton createBlueElevatedButton(
    String text,
    Function callback,
    { primaryColor=Colors.blue, onPrimary=Colors.white}
    ) {
  return ElevatedButton(
    style: ElevatedButton.styleFrom(
      foregroundColor: primaryColor,
      backgroundColor: onPrimary
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
    if(items.length == 0) {
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

Widget buildItemListTile(String title, String subtitle) {
  return ListTile(
      title: createTableHeaderCell(title),
      subtitle: createTableColumnCell(subtitle)
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
