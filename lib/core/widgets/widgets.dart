import 'package:stream_chat_flutter/stream_chat_flutter.dart';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:my24app/core/models/models.dart';
import 'package:my24app/mobile/models/models.dart';
import 'package:my24app/order/models/order/models.dart';
import 'package:my24app/quotation/models/models.dart';
import 'package:my24app/customer/models/models.dart';

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
            title: Text('customers.info_email'.tr(), style: TextStyle(fontWeight: FontWeight.w500)),
            subtitle: Text('${customer.email}'),
          ),
        ListTile(
          title: Text('customers.info_contact'.tr(), style: TextStyle(fontWeight: FontWeight.w500)),
          subtitle: Text('${customer.contact}'),
        ),
        ListTile(
          title: Text('customers.info_customer_id'.tr(), style: TextStyle(fontWeight: FontWeight.w500)),
          subtitle: Text('${customer.customerId}'),
        ),
      ],
  )
);

Widget buildOrderInfoCard(BuildContext context, Order order, {String maintenanceContract}) {
  return Container(
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 60,
              child: ListTile(
                title: Text('${order.orderName} (${order.customerId})', style: TextStyle(fontWeight: FontWeight.w500)),
                subtitle: Text('${order.orderAddress}\n${order.orderCountryCode}-${order.orderPostal}\n${order.orderCity}'),
                leading: Icon(
                  Icons.home,
                  color: Colors.blue[500],
                ),
              ),
            ),
            if (order.orderTel != null && order.orderTel != '')
              SizedBox(
                  height: 30,
                  child: ListTile(
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
                    )
              ),
            if (order.orderMobile != null && order.orderMobile != '')
              SizedBox(
              height: 46,
              child: ListTile(
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
            ),
            SizedBox(height: 10),
            getMy24Divider(context),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ...buildItemListKeyValueList(
                    "${'orders.info_order_id'.tr()} / ${'orders.info_order_reference'.tr()}",
                    "${order.orderId} / ${order.orderReference?? '-'}"
                ),
                ...buildItemListKeyValueList(
                    "${'orders.info_order_type'.tr()} / ${'orders.info_order_date'.tr()}",
                    "${order.orderType} / ${order.orderDate}"
                ),
                ...buildItemListKeyValueList(
                    "${'customers.info_contact'.tr()}",
                    "${order.orderContact?? '-'}"
                ),
                if (order.orderEmail != null && order.orderEmail != '')
                  ...buildItemListKeyValueList(
                      "${'orders.info_order_email'.tr()}",
                      "${order.orderEmail}"
                  ),
                if (order.customerRemarks != null && order.customerRemarks != '')
                  ...buildItemListKeyValueList(
                      "${'orders.info_order_customer_remarks'.tr()}",
                      "${order.customerRemarks}"
                  ),
                if (maintenanceContract != null)
                  ...buildItemListKeyValueList(
                      "${'assigned_orders.detail.info_maintenance_contract'.tr()}",
                      "$maintenanceContract"
                  ),
                ...buildItemListKeyValueList(
                    "${'orders.info_last_status'.tr()}",
                    "${order.lastStatusFull}"
                ),
              ],
            ),
          ],
        )
      )
  );
}

Widget buildAssignedOrderInfoCard(BuildContext context, AssignedOrder assignedOrder) {
  String maintenanceContract = assignedOrder.customer.maintenanceContract != null && assignedOrder.customer.maintenanceContract != '' ? assignedOrder.customer.maintenanceContract : null;
  return buildOrderInfoCard(context, assignedOrder.order, maintenanceContract: maintenanceContract);
}

Widget buildQuotationInfoCard(BuildContext context, Quotation quotation, {bool onlyCustomer=false}) => Container(
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
          title: Text('quotations.info_quotation_id'.tr(), style: TextStyle(fontWeight: FontWeight.w500)),
          subtitle: Text('${quotation.quotationId}'),
        ),
        if (!onlyCustomer)
          ListTile(
            title: Text('quotations.info_description'.tr(), style: TextStyle(fontWeight: FontWeight.w500)),
            subtitle: Text('${quotation.description}'),
          ),
        if (!onlyCustomer)
          ListTile(
            title: Text('quotations.info_last_status'.tr(), style: TextStyle(fontWeight: FontWeight.w500)),
            subtitle: Text('${quotation.lastStatusFull}'),
          ),
        if (!onlyCustomer)
          ListTile(
            title: Text('quotations.info_reference'.tr(), style: TextStyle(fontWeight: FontWeight.w500)),
            subtitle: Text('${quotation.quotationReference}'),
          ),
        if (!onlyCustomer && quotation.quotationEmail != null && quotation.quotationEmail != '')
          ListTile(
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


showDeleteDialogWrapper(String title, String content, Function deleteFunction, BuildContext context) {
  // show the dialog
  showDialog(
    barrierDismissible: false,
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
              child: Text('utils.button_cancel'.tr()),
              onPressed: () => Navigator.of(context).pop(false)
          ),
          TextButton(
              child: Text('utils.button_delete'.tr()),
              onPressed: () => Navigator.of(context).pop(true)
          ),
        ],
      );
    },
  ).then((dialogResult) {
    if (dialogResult == null) return;

    if (dialogResult) {
      deleteFunction();
    }
  });
}

showDeleteDialogWrapperOldOld(String title, String content, Function deleteFunction, BuildContext context) {
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

showDeleteDialogWrapperOld(String title, String content, BuildContext context, Function deleteFunction) {
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

Widget getOrderHeaderKeyWidget(String text, double fontsize) {
  return Padding(
      padding: EdgeInsets.only(top: 4.0),
      child: Text(text,
          style: TextStyle(fontSize: fontsize, color: Colors.grey)
      )
  );
}

Widget getOrderHeaderValueWidget(String text, double fontsize) {
  return Padding(
      padding: EdgeInsets.only(left: 8.0, bottom: 4, top: 2),
      child: Text(text,
          style: TextStyle(
              fontSize: fontsize,
              fontWeight: FontWeight.bold,
              fontStyle: FontStyle.italic,
              color: Colors.black
          )
      )
  );
}

Widget getOrderSubHeaderKeyWidget(String text, double fontsize) {
  return Padding(
      padding: EdgeInsets.only(top: 1.0),
      child: Text(text,
          style: TextStyle(fontSize: fontsize)
      )
  );
}

Widget getOrderSubHeaderValueWidget(String text, double fontsize) {
  return Padding(
      padding: EdgeInsets.only(left: 8.0, bottom: 4, top: 2),
      child: Text(text,
          style: TextStyle(
            fontSize: fontsize,
            // fontWeight: FontWeight.bold,
            // fontStyle: FontStyle.italic
          )
      )
  );
}

Widget createOrderListHeader(Order order, String date) {
  double fontsizeKey = 14.0;
  double fontsizeValue = 20.0;

  return Table(
    columnWidths: {
      0: FlexColumnWidth(1),
      1: FlexColumnWidth(4),
    },
    children: [
      TableRow(
          children: [
            getOrderHeaderKeyWidget('orders.info_order_date'.tr(), fontsizeKey),
            getOrderHeaderValueWidget(date, fontsizeValue)
          ]
      ),
      TableRow(
          children: [
            getOrderHeaderKeyWidget('orders.info_customer'.tr(), fontsizeKey),
            getOrderHeaderValueWidget('${order.orderName}, ${order.orderCity}', fontsizeValue)
          ]
      ),
      TableRow(
          children: [
            SizedBox(height: 2),
            SizedBox(height: 2),
          ]
      )
    ],
  );
}

Widget createOrderListSubtitle(Order order) {
  double fontsizeKey = 12.0;
  double fontsizeValue = 16.0;

  return Table(
    columnWidths: {
      0: FlexColumnWidth(1),
      1: FlexColumnWidth(4),
    },
    children: [
      TableRow(
          children: [
            getOrderSubHeaderKeyWidget('orders.info_order_id'.tr(), fontsizeKey),
            getOrderSubHeaderValueWidget('${order.orderId}', fontsizeValue)
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
            getOrderSubHeaderKeyWidget('orders.info_address'.tr(), fontsizeKey),
            getOrderSubHeaderValueWidget('${order.orderAddress}', fontsizeValue)
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
            getOrderSubHeaderKeyWidget('orders.info_postal_city'.tr(), fontsizeKey),
            getOrderSubHeaderValueWidget('${order.orderCountryCode}-${order.orderPostal} ${order.orderCity}', fontsizeValue)
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
            getOrderSubHeaderKeyWidget('orders.info_order_type'.tr(), fontsizeKey),
            getOrderSubHeaderValueWidget('${order.orderType}', fontsizeValue)
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
            getOrderSubHeaderKeyWidget('orders.info_last_status'.tr(), fontsizeKey),
            getOrderSubHeaderValueWidget('${order.lastStatusFull}', fontsizeValue)
          ]
      )
    ],
  );
}

Widget createOrderListHeader2(Order order, String date) {
  double fontsizeKey = 14.0;
  double fontsizeValue = 20.0;

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      getOrderHeaderKeyWidget('orders.info_customer'.tr(), fontsizeKey),
      getOrderHeaderValueWidget('${order.orderName}, ${order.orderCity}', fontsizeValue),
      SizedBox(height: 2),
      getOrderHeaderKeyWidget('orders.info_order_date'.tr(), fontsizeKey),
      getOrderHeaderValueWidget(date, fontsizeValue),
    ],
  );
}

Widget createOrderListSubtitle2(Order order) {
  double fontsizeKey = 12.0;
  double fontsizeValue = 16.0;

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      getOrderSubHeaderKeyWidget('orders.info_order_id'.tr(), fontsizeKey),
      getOrderSubHeaderValueWidget('${order.orderId}', fontsizeValue),
      SizedBox(height: 3),
      getOrderSubHeaderKeyWidget('orders.info_address'.tr(), fontsizeKey),
      getOrderSubHeaderValueWidget('${order.orderAddress}', fontsizeValue),
      SizedBox(height: 3),
      getOrderSubHeaderKeyWidget('orders.info_postal_city'.tr(), fontsizeKey),
      getOrderSubHeaderValueWidget('${order.orderCountryCode}-${order.orderPostal} ${order.orderCity}', fontsizeValue),
      SizedBox(height: 3),
      getOrderSubHeaderKeyWidget('orders.info_order_type'.tr(), fontsizeKey),
      getOrderSubHeaderValueWidget('${order.orderType}', fontsizeValue),
      SizedBox(height: 3),
      getOrderSubHeaderKeyWidget('orders.info_last_status'.tr(), fontsizeKey),
      getOrderSubHeaderValueWidget('${order.lastStatusFull}', fontsizeValue)
    ],
  );
}


Widget buildItemsSection(
    BuildContext context,
    String header, List<dynamic> items,
    Function itemBuilder, Function getActions,
    {String noResultsString, bool withDivider: true, bool withLastDivider: true}) {
  if(items == null || items.length == 0) {
    return Container(
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (header != "" && header != null)
                createHeader(header),
              buildEmptyListFeedback(noResultsString: noResultsString),
              getMy24Divider(context, last: true)
            ]
        )
    );
  }

  List<Widget> resultItems = [];
  for (int i = 0; i < items.length; ++i) {
    var item = items[i];

    var newList = new List<Widget>.from(resultItems)..addAll(itemBuilder(item));
    newList = new List<Widget>.from(newList)..addAll(getActions(item));
    if (items.length == 1 && withDivider) {
      newList.add(getMy24Divider(context, last: true));
    } else {
      if (i < items.length-1 && withDivider) {
        newList.add(getMy24Divider(context, last: false));
      } else {
        if (withDivider && withLastDivider) {
          newList.add(getMy24Divider(context, last: true));
        }
      }
    }
    resultItems = newList;
  }

  return Container(
    // clipBehavior: Clip.antiAliasWithSaveLayer,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (header != "" && header != null)
          createHeader(header),
        ...resultItems
      ],
    ),
  );
}

Widget buildItemListTile(String title, dynamic subtitle) {
  String text = subtitle != null ? "$subtitle" : "";

  return ListTile(
      title: createTableHeaderCell(text),
      subtitle: createTableColumnCell(title)
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

Widget createCancelButton(Function onClick) {
  return createElevatedButtonColored(
      'generic.action_cancel'.tr(),
      onClick,
      backgroundColor: Colors.grey,
      foregroundColor: Colors.white
  );
}

Widget createViewButton(Function onClick) {
  return createElevatedButtonColored(
      'generic.action_view'.tr(),
      onClick,
      backgroundColor: Colors.green,
      foregroundColor: Colors.white
  );
}

Widget createButton(Function onClick, {String title}) {
  if (title == null) {
    title = 'generic.action_new'.tr();
  }
  return createElevatedButtonColored(
      title,
      onClick,
      backgroundColor: Colors.green,
      foregroundColor: Colors.white
  );
}

Widget createDeleteButton(String text, Function onClick) {
  return createElevatedButtonColored(
      text,
      onClick,
      foregroundColor: Colors.red,
      backgroundColor: Colors.white
  );
}

Widget createEditButton(Function onClick) {
  return createElevatedButtonColored(
      'generic.action_edit'.tr(),
      () => onClick()
  );
}

Widget createImagePart(String url, String text) {
  return Center(
      child: Column(
          children: [
            Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.network(url, cacheWidth: 100),
                  SizedBox(width: 10),
                  Text(text)
                ]
            )
          ]
      )
  );
}

Widget getTextDisabled(bool disabled, String text) {
  if (!disabled) {
    return Text(text);
  }

  return Text(text,
      style: TextStyle(
          color: Colors.grey
      )
  );
}

Widget getSearchContainer(
    BuildContext context,
    TextEditingController searchController,
    Function searchFunc) {
  final double height = 40.0;
  return Container(
    height: height,
    width: 240,
    margin: const EdgeInsets.all(1.0),
    padding: const EdgeInsets.all(1.0),
    decoration: BoxDecoration(
        border: Border.all(color: Colors.blueAccent)
    ),
    child: Row(
      children: [
        SizedBox(
            height: height-10,
            width: 160,
            child: Padding(
                padding: EdgeInsets.only(bottom: 4),
                child: TextField(
                  controller: searchController,
                )
            )),
        Spacer(),
        SizedBox(
          height: height-10,
          width: 70,
          child: Padding(
              padding: EdgeInsets.only(right: 8),
              child: TextButton(
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.grey,
                  ),
                  child: Text("Search", style: TextStyle(color: Colors.white)),
                  onPressed: () => {
                    searchFunc(context)
                  }
              )
          ),
        ),
      ],
    ),
  );
}

Widget wrapPaginationSearchRow(Widget child) {
  return Container(
    color: Colors.grey[200],
    child: Padding(
        padding: EdgeInsets.only(top: 8, bottom: 8),
        child: child,
    )
  );
}

Widget showPaginationSearchSection(
    BuildContext context, PaginationInfo paginationInfo,
    TextEditingController searchController,
    Function nextPageFunc, Function previousPageFunc, Function searchFunc
    ) {
  if (paginationInfo == null || paginationInfo.count <= paginationInfo.pageSize) {
    return wrapPaginationSearchRow(
        Row(
          children: [
            Spacer(),
            getSearchContainer(context, searchController, searchFunc),
            Spacer(),
          ],
        )
    );
  }

  final int numPages = (paginationInfo.count/paginationInfo.pageSize).round();
  return wrapPaginationSearchRow(
      Row(
        children: [
          TextButton(
              child: getTextDisabled(paginationInfo.currentPage <= 1, 'generic.button_back'.tr()),
              onPressed: () => {
                if (paginationInfo.currentPage > 1) {
                  previousPageFunc(context)
                }
              }
          ),
          Spacer(),
          getSearchContainer(context, searchController, searchFunc),
          Spacer(),
          TextButton(
              child: getTextDisabled(paginationInfo.currentPage >= numPages, 'generic.button_next'.tr()),
              onPressed: () => {
                if (paginationInfo.currentPage < numPages) {
                  nextPageFunc(context)
                }
              }
          )
        ],
      )
  );
}

// new items overview
Widget getGenericKeyWidget(String text) {
  double fontsize = 12.0;

  return Padding(
      padding: EdgeInsets.only(top: 1.0),
      child: Text(text,
          style: TextStyle(fontSize: fontsize)
      )
  );
}

Widget getGenericValueWidget(String text) {
  double fontsize = 16.0;

  return Padding(
      padding: EdgeInsets.only(left: 8.0, bottom: 4, top: 2),
      child: Text(text,
          style: TextStyle(
            fontSize: fontsize,
            fontWeight: FontWeight.bold,
            // fontStyle: FontStyle.italic
          )
      )
  );
}

List<Widget> buildItemListKeyValueList(String key, dynamic value) {
  String textValue = value != null ? "$value" : "";
  if (textValue == "") {
    textValue = "-";
  }

  return [
    getGenericKeyWidget(key),
    getGenericValueWidget(textValue),
    SizedBox(height: 3)
  ];
}

Widget getMy24Divider(BuildContext context, {bool last: true}) {
  if (last) {
    return Divider(
      color: Theme.of(context).primaryColor,
      thickness: 1.0,
    );
  }
  return Divider(
    color: Colors.grey,
    thickness: 1.0,
  );

}

// slivers
SliverPersistentHeader makeDefaultPaginationHeader(
    BuildContext context,
    PaginationInfo paginationInfo,
    String modelName) {
  String title = "";
  if (paginationInfo.count > paginationInfo.pageSize) {
    int start = ((paginationInfo.currentPage - 1) * paginationInfo.pageSize) + 1;
    int end = start + paginationInfo.pageSize <= paginationInfo.count ? start + paginationInfo.pageSize -1 : paginationInfo.count;
    title = "generic.pagination_more_pages".tr(
      namedArgs: {
        "start": "$start",
        "end": "$end",
        "total": "${paginationInfo.count}",
        "modelName": modelName
      }
    );
  } else {
    int start = paginationInfo.count > 0 ? 1 : 0;
    int end = paginationInfo.count;
    title = "generic.pagination_one_page".tr(
        namedArgs: {
          "start": "$start",
          "end": "$end",
          "pageSize": "${paginationInfo.pageSize}",
          "modelName": modelName
        }
    );
  }

  return SliverPersistentHeader(
    pinned: true,
    delegate: _SliverAppBarDelegate(
      minHeight: 26.0,
      maxHeight: 26.0,
      child: Container(
          color: Theme.of(context).primaryColor,
          child: Padding(
            child: Text(title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white
              ),
            ),
            padding: EdgeInsets.only(left: 4.0, top: 7.0, bottom: 4.0),
          )
      ),
    ),
  );
}

// NOT USED, here as an example
class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate({
    @required this.minHeight,
    @required this.maxHeight,
    @required this.child,
  });
  final double minHeight;
  final double maxHeight;
  final Widget child;
  @override
  double get minExtent => minHeight;
  @override
  double get maxExtent => max(maxHeight, minHeight);
  @override
  Widget build(
      BuildContext context,
      double shrinkOffset,
      bool overlapsContent)
  {
    return new SizedBox.expand(child: child);
  }
  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return maxHeight != oldDelegate.maxHeight ||
        minHeight != oldDelegate.minHeight ||
        child != oldDelegate.child;
  }
}

// NOT USED, here as an example
SliverPersistentHeader makeHeader(BuildContext context, String headerText) {
  return SliverPersistentHeader(
    pinned: true,
    delegate: _SliverAppBarDelegate(
      minHeight: 40.0,
      maxHeight: 40.0,
      child: Container(
          color: Theme.of(context).primaryColor, child: Center(child:
      Text(headerText))),
    ),
  );
}

// NOT USED, here as an example
SliverPersistentHeader makeAssignedOrderHeader(
    BuildContext context,
    String userName,
    List<AssignedOrder> assignedOrders) {
  String title = "${assignedOrders.length} orders for $userName";
  Set<String> customerNames = assignedOrders.map((assignedOrder) => {
    assignedOrder.order.orderName
  }).map((e) => e.first).toList().toSet();
  String subtitle = "Customers include ${customerNames.join(', ')}";

  ListTile listTitle = ListTile(
    title: Text(title),
    subtitle: Text(subtitle)
  );

  return SliverPersistentHeader(
    pinned: false,
    delegate: _SliverAppBarDelegate(
      minHeight: 60.0,
      maxHeight: 140.0,
      child: Container(
          color: Theme.of(context).primaryColor,
          child: listTitle
      ),
    ),
  );
}
