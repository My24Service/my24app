import 'package:flutter/material.dart';
// import 'package:stream_chat_flutter/stream_chat_flutter.dart';

import 'package:my24_flutter_core/utils.dart';
import 'package:my24_flutter_core/widgets/slivers/app_bars.dart';
import 'package:my24_flutter_core/widgets/widgets.dart';
import 'package:my24_flutter_core/i18n.dart';
import 'package:my24_flutter_member_models/public/models.dart';
import 'package:my24_flutter_orders/models/order/models.dart';

import 'package:my24app/customer/models/models.dart';
import 'package:my24app/mobile/models/assignedorder/models.dart';


// Widget errorNotice(String message) {
//   return Center(
//       child: Column(
//     children: [
//       SizedBox(height: 30),
//       Text(message),
//       SizedBox(height: 30),
//     ],
//   ));
// }
//
// Widget errorNoticeWithReload(
//     String message, dynamic reloadBloc, dynamic reloadEvent) {
//   return RefreshIndicator(
//       child: ListView(
//         children: [
//           errorNotice(message),
//         ],
//       ),
//       onRefresh: () {
//         return Future.delayed(Duration(milliseconds: 5), () {
//           reloadBloc.add(reloadEvent);
//         });
//       });
// }
//
// Widget loadingNotice() {
//   return Center(child: CircularProgressIndicator());
// }
//
// Widget buildMemberInfoCard(BuildContext context, member) => SizedBox(
//       height: 200,
//       width: 1000,
//       child: Center(
//         child: Column(
//           mainAxisSize: MainAxisSize.max,
//           children: [
//             ListTile(
//               title: Text('${member.name}',
//                   style: TextStyle(fontWeight: FontWeight.w500)),
//               subtitle: Text(
//                   '${member.address}\n${member.countryCode}-${member.postal}\n${member.city}'),
//               leading: Icon(
//                 Icons.home,
//                 color: Colors.blue[500],
//               ),
//             ),
//             ListTile(
//               title: Text('${member.tel}',
//                   style: TextStyle(fontWeight: FontWeight.w500)),
//               leading: Icon(
//                 Icons.contact_phone,
//                 color: Colors.blue[500],
//               ),
//               onTap: () {
//                 if (member.tel != '' && member.tel != null) {
//                   utils.launchURL("tel://${member.tel}");
//                 }
//               },
//             ),
//           ],
//         ),
//       ),
//     );
//
Widget buildCustomerInfoCard(BuildContext context, Customer customer) =>
    Container(
        child: Column(
      // mainAxisSize: MainAxisSize.max,
      children: [
        ListTile(
          title: Text('${customer.name}',
              style: TextStyle(fontWeight: FontWeight.w500)),
          subtitle: Text(
              '${customer.address}\n${customer.countryCode}-${customer.postal}\n${customer.city}'),
          leading: Icon(
            Icons.home,
            color: Colors.blue[500],
          ),
        ),
        if (customer.tel != null && customer.tel != '')
          ListTile(
            title: Text('${customer.tel}',
                style: TextStyle(fontWeight: FontWeight.w500)),
            leading: Icon(
              Icons.contact_phone,
              color: Colors.blue[500],
            ),
            onTap: () {
              if (customer.tel != '' && customer.tel != null) {
                coreUtils.launchURL("tel://${customer.tel}");
              }
            },
          ),
        if (customer.mobile != null && customer.mobile != '')
          ListTile(
            title: Text('${customer.mobile}',
                style: TextStyle(fontWeight: FontWeight.w500)),
            leading: Icon(
              Icons.send_to_mobile,
              color: Colors.blue[500],
            ),
            onTap: () {
              if (customer.mobile != '' && customer.mobile != null) {
                coreUtils.launchURL("tel://${customer.mobile}");
              }
            },
          ),
        if (customer.email != null && customer.email != '')
          ListTile(
            title: Text(My24i18n.tr('customers.info_email'),
                style: TextStyle(fontWeight: FontWeight.w500)),
            subtitle: Text('${customer.email}'),
          ),
        ListTile(
          title: Text(My24i18n.tr('customers.info_contact'),
              style: TextStyle(fontWeight: FontWeight.w500)),
          subtitle: Text('${customer.contact}'),
        ),
        ListTile(
          title: Text(My24i18n.tr('customers.info_customer_id'),
              style: TextStyle(fontWeight: FontWeight.w500)),
          subtitle: Text('${customer.customerId}'),
        ),
      ],
    ));

// Widget buildOrderInfoCard(BuildContext context, Order order,
//     {String? maintenanceContract}) {
//   return Container(
//       child: Center(
//           child: Column(
//     mainAxisSize: MainAxisSize.min,
//     children: [
//       SizedBox(
//         height: 60,
//         child: ListTile(
//           title: Text('${order.orderName} (${order.customerId})',
//               style: TextStyle(fontWeight: FontWeight.w500)),
//           subtitle: Text(
//               '${order.orderAddress}\n${order.orderCountryCode}-${order.orderPostal}\n${order.orderCity}'),
//           leading: Icon(
//             Icons.home,
//             color: Colors.blue[500],
//           ),
//         ),
//       ),
//       if (order.orderTel != null && order.orderTel != '')
//         SizedBox(
//             height: 30,
//             child: ListTile(
//               title: Text('${order.orderTel}',
//                   style: TextStyle(fontWeight: FontWeight.w500)),
//               leading: Icon(
//                 Icons.contact_phone,
//                 color: Colors.blue[500],
//               ),
//               onTap: () {
//                 if (order.orderTel != '' && order.orderTel != null) {
//                   utils.launchURL("tel://${order.orderTel}");
//                 }
//               },
//             )),
//       if (order.orderMobile != null && order.orderMobile != '')
//         SizedBox(
//           height: 46,
//           child: ListTile(
//             title: Text('${order.orderMobile}',
//                 style: TextStyle(fontWeight: FontWeight.w500)),
//             leading: Icon(
//               Icons.send_to_mobile,
//               color: Colors.blue[500],
//             ),
//             onTap: () {
//               if (order.orderMobile != '' && order.orderMobile != null) {
//                 utils.launchURL("tel://${order.orderMobile}");
//               }
//             },
//           ),
//         ),
//       SizedBox(height: 10),
//       getMy24Divider(context),
//       Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           ...buildItemListKeyValueList(
//               "${My24i18n.tr('orders.info_order_id')} / ${My24i18n.tr('orders.info_order_reference')}",
//               "${order.orderId} / ${order.orderReference ?? '-'}"),
//           ...buildItemListKeyValueList(
//               "${My24i18n.tr('orders.info_order_type')} / ${My24i18n.tr('orders.info_order_date')}",
//               "${order.orderType} / ${order.orderDate}"),
//           ...buildItemListKeyValueList(
//               "${My24i18n.tr('customers.info_contact')}",
//               "${order.orderContact ?? '-'}"),
//           if (order.orderEmail != null && order.orderEmail != '')
//             ...buildItemListKeyValueList(
//                 "${My24i18n.tr('orders.info_order_email')}",
//                 "${order.orderEmail}"),
//           if (order.customerRemarks != null && order.customerRemarks != '')
//             ...buildItemListKeyValueList(
//                 "${My24i18n.tr('orders.info_order_customer_remarks')}",
//                 "${order.customerRemarks}"),
//           if (maintenanceContract != null)
//             ...buildItemListKeyValueList(
//                 "${My24i18n.tr('assigned_orders.detail.info_maintenance_contract')}",
//                 "$maintenanceContract"),
//           ...buildItemListKeyValueList(
//               "${My24i18n.tr('orders.info_last_status')}",
//               "${order.lastStatusFull}"),
//         ],
//       ),
//     ],
//   )));
// }
//
Widget buildAssignedOrderInfoCard(BuildContext context, AssignedOrder assignedOrder, CoreWidgets widgets) {
  String? maintenanceContract =
      assignedOrder.customer!.maintenanceContract != null &&
              assignedOrder.customer!.maintenanceContract != ''
          ? assignedOrder.customer!.maintenanceContract
          : null;
  return widgets.buildOrderInfoCard(context, assignedOrder.order!,
      maintenanceContract: maintenanceContract);
}

// Widget buildQuotationInfoCard(BuildContext context, Quotation quotation,
//         {bool onlyCustomer = false}) =>
//     Container(
//         child: Column(
//       // mainAxisSize: MainAxisSize.max,
//       children: [
//         ListTile(
//           title: Text('${quotation.quotationName}',
//               style: TextStyle(fontWeight: FontWeight.w500)),
//           subtitle: Text(
//               '${quotation.quotationAddress}\n${quotation.quotationCountryCode}-${quotation.quotationPostal}\n${quotation.quotationCity}'),
//           leading: Icon(
//             Icons.home,
//             color: Colors.blue[500],
//           ),
//         ),
//         if (quotation.quotationTel != null && quotation.quotationTel != '')
//           ListTile(
//             title: Text('${quotation.quotationTel}',
//                 style: TextStyle(fontWeight: FontWeight.w500)),
//             leading: Icon(
//               Icons.contact_phone,
//               color: Colors.blue[500],
//             ),
//             onTap: () {
//               if (quotation.quotationTel != '' &&
//                   quotation.quotationTel != null) {
//                 utils.launchURL("tel://${quotation.quotationTel}");
//               }
//             },
//           ),
//         if (quotation.quotationMobile != null &&
//             quotation.quotationMobile != '')
//           ListTile(
//             title: Text('${quotation.quotationMobile}',
//                 style: TextStyle(fontWeight: FontWeight.w500)),
//             leading: Icon(
//               Icons.send_to_mobile,
//               color: Colors.blue[500],
//             ),
//             onTap: () {
//               if (quotation.quotationMobile != '' &&
//                   quotation.quotationMobile != null) {
//                 utils.launchURL("tel://${quotation.quotationMobile}");
//               }
//             },
//           ),
//         ListTile(
//           title: Text(My24i18n.tr('quotations.info_quotation_id'),
//               style: TextStyle(fontWeight: FontWeight.w500)),
//           subtitle: Text('${quotation.quotationId}'),
//         ),
//         if (!onlyCustomer)
//           ListTile(
//             title: Text(My24i18n.tr('quotations.info_description'),
//                 style: TextStyle(fontWeight: FontWeight.w500)),
//             subtitle: Text('${quotation.description}'),
//           ),
//         if (!onlyCustomer)
//           ListTile(
//             title: Text(My24i18n.tr('quotations.info_last_status'),
//                 style: TextStyle(fontWeight: FontWeight.w500)),
//             subtitle: Text('${quotation.lastStatusFull}'),
//           ),
//         if (!onlyCustomer)
//           ListTile(
//             title: Text(My24i18n.tr('quotations.info_reference'),
//                 style: TextStyle(fontWeight: FontWeight.w500)),
//             subtitle: Text('${quotation.quotationReference}'),
//           ),
//         if (!onlyCustomer &&
//             quotation.quotationEmail != null &&
//             quotation.quotationEmail != '')
//           ListTile(
//             title: Text(My24i18n.tr('quotations.info_email'),
//                 style: TextStyle(fontWeight: FontWeight.w500)),
//             subtitle: Text('${quotation.quotationEmail}'),
//           ),
//       ],
//     ));
//
// Widget buildEmptyListFeedback({String? noResultsString}) {
//   if (noResultsString == null) {
//     noResultsString = My24i18n.tr('generic.empty_table');
//   }
//
//   return Column(
//     children: [
//       SizedBox(height: 1),
//       Text(noResultsString!, style: TextStyle(fontStyle: FontStyle.italic))
//     ],
//   );
// }
//
// ElevatedButton createElevatedButtonColored(String text, Function callback,
//     {foregroundColor = Colors.white, backgroundColor = Colors.blue}) {
//   return ElevatedButton(
//     style: ElevatedButton.styleFrom(
//       foregroundColor: foregroundColor,
//       backgroundColor: backgroundColor,
//     ),
//     child: new Text(text),
//     onPressed: callback as void Function()?,
//   );
// }
//
// ElevatedButton createDefaultElevatedButton(String text, Function callback) {
//   return ElevatedButton(
//     style: ElevatedButton.styleFrom(foregroundColor: Colors.white),
//     child: new Text(text),
//     onPressed: callback as void Function()?,
//   );
// }
//
// Widget createPhoneSection(BuildContext context, String number) {
//   if (number == '') {
//     return SizedBox(height: 1);
//   }
//
//   return ElevatedButton(
//     style: ElevatedButton.styleFrom(
//         foregroundColor: Colors.black,
//         backgroundColor: Colors.white,
//         padding: EdgeInsets.all(1)),
//     child: new Text(number),
//     onPressed: () => utils.launchURL("tel://$number"),
//   );
// }
//
// Widget createHeader(String text) {
//   return Container(
//       child: Column(
//     children: [
//       SizedBox(
//         height: 10.0,
//       ),
//       Text(text,
//           style: TextStyle(
//               fontWeight: FontWeight.bold, fontSize: 20, color: Colors.grey)),
//       SizedBox(
//         height: 10.0,
//       ),
//     ],
//   ));
// }
//
// Widget createSubHeader(String text) {
//   return Container(
//       child: Column(
//     children: [
//       SizedBox(
//         height: 10.0,
//       ),
//       Text(text,
//           style: TextStyle(
//               fontWeight: FontWeight.bold, fontSize: 16, color: Colors.grey)),
//       SizedBox(
//         height: 10.0,
//       ),
//     ],
//   ));
// }
//
// Future<dynamic> displayDialog(context, title, text) {
//   return showDialog(
//       context: context,
//       builder: (context) {
//         return AlertDialog(title: Text(title), content: Text(text));
//       });
// }
//
// showDeleteDialogWrapper(String title, String content, Function deleteFunction,
//     BuildContext context) {
//   // show the dialog
//   showDialog(
//     barrierDismissible: false,
//     context: context,
//     builder: (BuildContext context) {
//       return AlertDialog(
//         title: Text(title),
//         content: Text(content),
//         actions: [
//           TextButton(
//               child: Text(My24i18n.tr('utils.button_cancel')),
//               onPressed: () => Navigator.of(context).pop(false)),
//           TextButton(
//               child: Text(My24i18n.tr('utils.button_delete')),
//               onPressed: () => Navigator.of(context).pop(true)),
//         ],
//       );
//     },
//   ).then((dialogResult) {
//     if (dialogResult == null) return;
//
//     if (dialogResult) {
//       deleteFunction();
//     }
//   });
// }
//
// showActionDialogWrapper(String title, String content, String actionText,
//     Function actionFunction, BuildContext context) {
//   // show the dialog
//   showDialog(
//     barrierDismissible: false,
//     context: context,
//     builder: (BuildContext context) {
//       return AlertDialog(
//         title: Text(title),
//         content: Text(content),
//         actions: [
//           TextButton(
//               child: Text(My24i18n.tr('utils.button_cancel')),
//               onPressed: () => Navigator.of(context).pop(false)),
//           TextButton(
//               child: Text(actionText),
//               onPressed: () => Navigator.of(context).pop(true)),
//         ],
//       );
//     },
//   ).then((dialogResult) {
//     if (dialogResult == null) return;
//
//     if (dialogResult) {
//       actionFunction();
//     }
//   });
// }
//
// showDeleteDialogWrapperOldOld(String title, String content,
//     Function deleteFunction, BuildContext context) {
//   // set up the button
//   Widget cancelButton = TextButton(
//       child: Text(My24i18n.tr('utils.button_cancel')),
//       onPressed: () => Navigator.of(context).pop(false));
//   Widget deleteButton = TextButton(
//       child: Text(My24i18n.tr('utils.button_delete')),
//       onPressed: () => Navigator.of(context).pop(true));
//
//   // set up the AlertDialog
//   AlertDialog alert = AlertDialog(
//     title: Text(title),
//     content: Text(content),
//     actions: [
//       cancelButton,
//       deleteButton,
//     ],
//   );
//
//   // show the dialog
//   showDialog(
//     barrierDismissible: false,
//     context: context,
//     builder: (BuildContext context) {
//       return alert;
//     },
//   ).then((dialogResult) {
//     if (dialogResult == null) return;
//
//     if (dialogResult) {
//       deleteFunction();
//     }
//   });
// }
//
// createSnackBar(BuildContext context, String content) {
//   final snackBar = SnackBar(
//     content: Text(content),
//     duration: Duration(seconds: 1),
//   );
//
//   // Find the ScaffoldMessenger in the widget tree
//   // and use it to show a SnackBar.
//   ScaffoldMessenger.of(context).showSnackBar(snackBar);
// }
//
// Widget createTable(List<TableRow> rows) {
//   return Table(
//       border: TableBorder(
//           horizontalInside: BorderSide(
//               width: 1, color: Colors.grey, style: BorderStyle.solid)),
//       children: rows);
// }
//
// Widget createTableWidths(
//     List<TableRow> rows, Map<int, TableColumnWidth> columnWidths) {
//   return Table(
//       columnWidths: columnWidths,
//       border: TableBorder(
//           horizontalInside: BorderSide(
//               width: 1, color: Colors.grey, style: BorderStyle.solid)),
//       children: rows);
// }
//
// Widget createTableHeaderCell(String content, [double padding = 8.0]) {
//   return Padding(
//     padding: EdgeInsets.all(padding),
//     child: Text(content, style: TextStyle(fontWeight: FontWeight.bold)),
//   );
// }
//
// Widget createTableColumnCell(String? content, [double padding = 4.0]) {
//   return Padding(
//     padding: EdgeInsets.all(padding),
//     child: Text(content != null ? content : ''),
//   );
// }
//
Widget getOrderHeaderKeyWidget(String text, double fontsize) {
  return Padding(
      padding: EdgeInsets.only(top: 4.0),
      child:
          Text(text, style: TextStyle(fontSize: fontsize, color: Colors.grey)));
}

Widget getOrderHeaderValueWidget(String text, double fontsize) {
  return Padding(
      padding: EdgeInsets.only(left: 8.0, bottom: 4, top: 2),
      child: Text(text,
          style: TextStyle(
              fontSize: fontsize,
              fontWeight: FontWeight.bold,
              fontStyle: FontStyle.italic,
              color: Colors.black)));
}

Widget getOrderSubHeaderKeyWidget(String text, double fontsize) {
  return Padding(
      padding: EdgeInsets.only(top: 1.0),
      child: Text(text, style: TextStyle(fontSize: fontsize)));
}

Widget getOrderSubHeaderValueWidget(String text, double fontsize) {
  return Padding(
      padding: EdgeInsets.only(left: 8.0, bottom: 4, top: 2),
      child: Text(text,
          style: TextStyle(
            fontSize: fontsize,
            // fontWeight: FontWeight.bold,
            // fontStyle: FontStyle.italic
          )));
}

// Widget createOrderListHeader(Order order, String date) {
//   double fontsizeKey = 14.0;
//   double fontsizeValue = 20.0;
//
//   return Table(
//     columnWidths: {
//       0: FlexColumnWidth(1),
//       1: FlexColumnWidth(4),
//     },
//     children: [
//       TableRow(children: [
//         getOrderHeaderKeyWidget(
//             My24i18n.tr('orders.info_order_date'), fontsizeKey),
//         getOrderHeaderValueWidget(date, fontsizeValue)
//       ]),
//       TableRow(children: [
//         getOrderHeaderKeyWidget(
//             My24i18n.tr('orders.info_customer'), fontsizeKey),
//         getOrderHeaderValueWidget(
//             '${order.orderName}, ${order.orderCity}', fontsizeValue)
//       ]),
//       TableRow(children: [
//         SizedBox(height: 2),
//         SizedBox(height: 2),
//       ])
//     ],
//   );
// }
//
// Widget createOrderListSubtitle(Order order) {
//   double fontsizeKey = 12.0;
//   double fontsizeValue = 16.0;
//
//   return Table(
//     columnWidths: {
//       0: FlexColumnWidth(1),
//       1: FlexColumnWidth(4),
//     },
//     children: [
//       TableRow(children: [
//         getOrderSubHeaderKeyWidget(
//             My24i18n.tr('orders.info_order_id'), fontsizeKey),
//         getOrderSubHeaderValueWidget('${order.orderId}', fontsizeValue)
//       ]),
//       TableRow(children: [
//         SizedBox(height: 3),
//         SizedBox(height: 3),
//       ]),
//       TableRow(children: [
//         getOrderSubHeaderKeyWidget(
//             My24i18n.tr('orders.info_address'), fontsizeKey),
//         getOrderSubHeaderValueWidget('${order.orderAddress}', fontsizeValue)
//       ]),
//       TableRow(children: [
//         SizedBox(height: 3),
//         SizedBox(height: 3),
//       ]),
//       TableRow(children: [
//         getOrderSubHeaderKeyWidget(
//             My24i18n.tr('orders.info_postal_city'), fontsizeKey),
//         getOrderSubHeaderValueWidget(
//             '${order.orderCountryCode}-${order.orderPostal} ${order.orderCity}',
//             fontsizeValue)
//       ]),
//       TableRow(children: [
//         SizedBox(height: 3),
//         SizedBox(height: 3),
//       ]),
//       TableRow(children: [
//         getOrderSubHeaderKeyWidget(
//             My24i18n.tr('orders.info_order_type'), fontsizeKey),
//         getOrderSubHeaderValueWidget('${order.orderType}', fontsizeValue)
//       ]),
//       TableRow(children: [
//         SizedBox(height: 3),
//         SizedBox(height: 3),
//       ]),
//       TableRow(children: [
//         getOrderSubHeaderKeyWidget(
//             My24i18n.tr('orders.info_last_status'), fontsizeKey),
//         getOrderSubHeaderValueWidget('${order.lastStatusFull}', fontsizeValue)
//       ])
//     ],
//   );
// }
//
Widget createOrderListHeader2(Order order, String date) {
  double fontsizeKey = 14.0;
  double fontsizeValue = 20.0;

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      getOrderHeaderKeyWidget(
          My24i18n.tr('orders.info_customer'), fontsizeKey),
      getOrderHeaderValueWidget(
          '${order.orderName}, ${order.orderCity}', fontsizeValue),
      SizedBox(height: 2),
      getOrderHeaderKeyWidget(
          My24i18n.tr('orders.info_order_date'), fontsizeKey),
      getOrderHeaderValueWidget(date, fontsizeValue),
    ],
  );
}

Widget createOrderHistoryListHeader2(String date) {
  double fontsizeKey = 14.0;
  double fontsizeValue = 20.0;

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      getOrderHeaderKeyWidget(
          My24i18n.tr('orders.info_order_date'), fontsizeKey),
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
      getOrderSubHeaderKeyWidget(
          My24i18n.tr('orders.info_order_id'), fontsizeKey),
      getOrderSubHeaderValueWidget('${order.orderId}', fontsizeValue),
      SizedBox(height: 3),
      getOrderSubHeaderKeyWidget(
          My24i18n.tr('orders.info_address'), fontsizeKey),
      getOrderSubHeaderValueWidget('${order.orderAddress}', fontsizeValue),
      SizedBox(height: 3),
      getOrderSubHeaderKeyWidget(
          My24i18n.tr('orders.info_postal_city'), fontsizeKey),
      getOrderSubHeaderValueWidget(
          '${order.orderCountryCode}-${order.orderPostal} ${order.orderCity}',
          fontsizeValue),
      SizedBox(height: 3),
      getOrderSubHeaderKeyWidget(
          My24i18n.tr('orders.info_order_type'), fontsizeKey),
      getOrderSubHeaderValueWidget('${order.orderType}', fontsizeValue),
      SizedBox(height: 3),
      getOrderSubHeaderKeyWidget(
          My24i18n.tr('orders.info_last_status'), fontsizeKey),
      getOrderSubHeaderValueWidget('${order.lastStatusFull}', fontsizeValue)
    ],
  );
}


// Widget buildItemsSection(BuildContext context, String header,
//     List<dynamic>? items, Function itemBuilder, Function getActions,
//     {String? noResultsString,
//     bool withDivider = true,
//     bool withLastDivider = true}) {
//   if (items == null || items.length == 0) {
//     return Container(
//         child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//       if (header != "") createHeader(header),
//       buildEmptyListFeedback(noResultsString: noResultsString),
//       getMy24Divider(context, last: true)
//     ]));
//   }
//
//   List<Widget> resultItems = [];
//   for (int i = 0; i < items.length; ++i) {
//     var item = items[i];
//
//     var newList = new List<Widget>.from(resultItems)..addAll(itemBuilder(item));
//     newList = new List<Widget>.from(newList)..addAll(getActions(item));
//     if (items.length == 1 && withDivider && withLastDivider) {
//       newList.add(getMy24Divider(context, last: true));
//     } else {
//       if (i < items.length - 1 && withDivider) {
//         newList.add(getMy24Divider(context, last: false));
//       } else {
//         if (withDivider && withLastDivider) {
//           newList.add(getMy24Divider(context, last: true));
//         }
//       }
//     }
//     resultItems = newList;
//   }
//
//   return Container(
//     // clipBehavior: Clip.antiAliasWithSaveLayer,
//     child: Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [if (header != "") createHeader(header), ...resultItems],
//     ),
//   );
// }
//
// Widget buildItemListTile(String title, dynamic subtitle) {
//   String text = subtitle != null ? "$subtitle" : "";
//
//   return ListTile(
//       title: createTableHeaderCell(text),
//       subtitle: createTableColumnCell(title));
// }
//
// Widget buildItemListCustomWidget(String title, Widget content) {
//   return Row(children: [createTableHeaderCell(title), content]);
// }
//
// Widget createCancelButton(Function onClick) {
//   return createElevatedButtonColored(
//       My24i18n.tr('generic.action_cancel'), onClick,
//       backgroundColor: Colors.grey, foregroundColor: Colors.white);
// }
//
// Widget createViewButton(Function onClick) {
//   return createElevatedButtonColored(
//       My24i18n.tr('generic.action_view'), onClick,
//       backgroundColor: Colors.green, foregroundColor: Colors.white);
// }
//
// Widget createButton(Function onClick, {String? title}) {
//   if (title == null) {
//     title = My24i18n.tr('generic.action_new');
//   }
//   return createElevatedButtonColored(title!, onClick,
//       backgroundColor: Colors.green, foregroundColor: Colors.white);
// }
//
// Widget createDeleteButton(String text, Function onClick) {
//   return createElevatedButtonColored(text, onClick,
//       foregroundColor: Colors.red, backgroundColor: Colors.white);
// }
//
// Widget createEditButton(Function onClick) {
//   return createElevatedButtonColored(
//       My24i18n.tr('generic.action_edit'), () => onClick());
// }
//
// Widget createNewButton(Function onClick) {
//   return createElevatedButtonColored(
//       My24i18n.tr('generic.button_new'), () => onClick());
// }
//
// Widget createSubmitButton(Function onClick) {
//   return createDefaultElevatedButton(
//       My24i18n.tr('generic.button_submit'), () => onClick());
// }
//
// Widget createImagePart(String url, String text) {
//   return Center(
//       child: Column(children: [
//     Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Image.network(url, cacheWidth: 100),
//           SizedBox(width: 10),
//           Text(text)
//         ])
//   ]));
// }
//
// Widget getTextDisabled(bool disabled, String text) {
//   if (!disabled) {
//     return Text(text);
//   }
//
//   return Text(text, style: TextStyle(color: Colors.grey));
// }
//
// Widget getSearchContainer(BuildContext context,
//     TextEditingController searchController, Function searchFunc) {
//   final double height = 40.0;
//   return Container(
//     height: height,
//     width: 200,
//     margin: const EdgeInsets.all(1.0),
//     padding: const EdgeInsets.all(1.0),
//     decoration: BoxDecoration(border: Border.all(color: Colors.blueAccent)),
//     child: Row(
//       children: [
//         SizedBox(
//             height: height - 10,
//             width: 120,
//             child: Padding(
//                 padding: EdgeInsets.only(bottom: 4, left: 10),
//                 child: TextField(
//                   controller: searchController,
//                 ))),
//         Spacer(),
//         SizedBox(
//           height: height - 10,
//           width: 70,
//           child: Padding(
//               padding: EdgeInsets.only(right: 4),
//               child: TextButton(
//                   style: ElevatedButton.styleFrom(
//                     foregroundColor: Colors.white,
//                     backgroundColor: Colors.grey,
//                   ),
//                   child: Text(My24i18n.tr('generic.action_search', {}),
//                       style: TextStyle(color: Colors.white)),
//                   onPressed: () => {searchFunc(context)})),
//         ),
//       ],
//     ),
//   );
// }
//
// Widget wrapPaginationSearchRow(Widget child) {
//   return Container(
//       color: Colors.grey[200],
//       child: Padding(
//         padding: EdgeInsets.only(top: 8, bottom: 8),
//         child: child,
//       ));
// }
//
// Widget showPaginationSearchSection(
//     BuildContext context,
//     PaginationInfo? paginationInfo,
//     TextEditingController searchController,
//     Function nextPageFunc,
//     Function previousPageFunc,
//     Function searchFunc) {
//   if (paginationInfo == null ||
//       paginationInfo.count! <= paginationInfo.pageSize!) {
//     return wrapPaginationSearchRow(Row(
//       children: [
//         Spacer(),
//         getSearchContainer(context, searchController, searchFunc),
//         Spacer(),
//       ],
//     ));
//   }
//
//   final int numPages =
//       (paginationInfo.count! / paginationInfo.pageSize!).round();
//   return wrapPaginationSearchRow(Row(
//     children: [
//       TextButton(
//           child: getTextDisabled(paginationInfo.currentPage! <= 1,
//               My24i18n.tr('generic.button_back')),
//           onPressed: () => {
//                 if (paginationInfo.currentPage! > 1) {previousPageFunc(context)}
//               }),
//       Spacer(),
//       getSearchContainer(context, searchController, searchFunc),
//       Spacer(),
//       TextButton(
//           child: getTextDisabled(paginationInfo.currentPage! >= numPages,
//               My24i18n.tr('generic.button_next')),
//           onPressed: () => {
//                 if (paginationInfo.currentPage! < numPages)
//                   {nextPageFunc(context)}
//               })
//     ],
//   ));
// }
//
// Widget showPaginationSearchNewSection(
//     BuildContext context,
//     PaginationInfo? paginationInfo,
//     TextEditingController searchController,
//     Function nextPageFunc,
//     Function previousPageFunc,
//     Function searchFunc,
//     Function newFunc) {
//   if (paginationInfo == null ||
//       paginationInfo.count! <= paginationInfo.pageSize!) {
//     return wrapPaginationSearchRow(Row(
//       children: [
//         Spacer(),
//         createNewButton(() => {newFunc(context)}),
//         SizedBox(width: 10),
//         getSearchContainer(context, searchController, searchFunc),
//         Spacer(),
//       ],
//     ));
//   }
//
//   final int numPages =
//       (paginationInfo.count! / paginationInfo.pageSize!).round();
//   final Color backColor =
//       paginationInfo.currentPage! > 1 ? Colors.blue : Colors.grey;
//   final Color forwardColor =
//       paginationInfo.currentPage! < numPages ? Colors.blue : Colors.grey;
//
//   return wrapPaginationSearchRow(Row(
//     children: [
//       IconButton(
//           icon: Icon(
//             Icons.arrow_back,
//             color: backColor,
//             size: 20.0,
//             semanticLabel: 'Back',
//           ),
//           onPressed: () => {
//                 if (paginationInfo.currentPage! > 1) {previousPageFunc(context)}
//               }),
//       Spacer(),
//       createNewButton(() => {newFunc(context)}),
//       SizedBox(width: 5),
//       getSearchContainer(context, searchController, searchFunc),
//       Spacer(),
//       IconButton(
//           icon: Icon(
//             Icons.arrow_forward,
//             color: forwardColor,
//             size: 20.0,
//             semanticLabel: 'Forward',
//           ),
//           onPressed: () => {
//                 if (paginationInfo.currentPage! < numPages)
//                   {nextPageFunc(context)}
//               }),
//     ],
//   ));
// }
//
// // new items overview
// Widget getGenericKeyWidget(String text, {bool withPadding = true}) {
//   double fontsize = 12.0;
//
//   if (!withPadding) {
//     return Text(text, style: TextStyle(fontSize: fontsize));
//   }
//
//   return Padding(
//       padding: EdgeInsets.only(top: 1.0),
//       child: Text(text, style: TextStyle(fontSize: fontsize)));
// }
//
// Widget getGenericValueWidget(String text, {bool withPadding = true}) {
//   double fontsize = 16.0;
//
//   if (!withPadding) {
//     return Text(text,
//         style: TextStyle(
//           fontSize: fontsize,
//           fontWeight: FontWeight.bold,
//           // fontStyle: FontStyle.italic
//         ));
//   }
//
//   return Padding(
//       padding: EdgeInsets.only(left: 8.0, bottom: 4, top: 2),
//       child: Text(text,
//           style: TextStyle(
//             fontSize: fontsize,
//             fontWeight: FontWeight.bold,
//             // fontStyle: FontStyle.italic
//           )));
// }
//
// List<Widget> buildItemListKeyValueList(String key, dynamic value,
//     {bool withPadding = true}) {
//   String textValue = value != null ? "$value" : "";
//   if (textValue == "") {
//     textValue = "-";
//   }
//
//   return [
//     getGenericKeyWidget(key, withPadding: withPadding),
//     getGenericValueWidget(textValue, withPadding: withPadding),
//     SizedBox(height: 3)
//   ];
// }
//
// Widget getMy24Divider(BuildContext context, {bool last = true}) {
//   if (last) {
//     return Divider(
//       color: Theme.of(context).primaryColor,
//       thickness: 1.0,
//     );
//   }
//   return Divider(
//     color: Colors.grey,
//     thickness: 1.0,
//   );
// }
//
// Widget createSubmitSection(Row buttons) {
//   return Column(
//     children: [
//       SizedBox(height: 20),
//       Container(
//         // color: Colors.blueGrey,
//         padding: EdgeInsets.all(8),
//         child: buttons,
//         decoration: BoxDecoration(
//             color: Colors.blueGrey,
//             border: Border.all(
//               color: Colors.blueGrey[500]!,
//             ),
//             borderRadius: BorderRadius.all(
//               Radius.circular(5),
//             )),
//       )
//     ],
//   );
// }
//
// // slivers
// SliverPersistentHeader makeDefaultPaginationHeader(
//     BuildContext context, PaginationInfo paginationInfo, String modelName) {
//   String title = "";
//   if (paginationInfo.count! > paginationInfo.pageSize!) {
//     int start =
//         ((paginationInfo.currentPage! - 1) * paginationInfo.pageSize!) + 1;
//     int? end = start + paginationInfo.pageSize! <= paginationInfo.count!
//         ? start + paginationInfo.pageSize! - 1
//         : paginationInfo.count;
//     title = My24i18n.tr("generic.pagination_more_pages", {
//       "start": "$start",
//       "end": "$end",
//       "total": "${paginationInfo.count}",
//       "modelName": modelName
//     });
//   } else {
//     int start = paginationInfo.count! > 0 ? 1 : 0;
//     int? end = paginationInfo.count;
//     title = My24i18n.tr("generic.pagination_one_page", {
//       "start": "$start",
//       "end": "$end",
//       "pageSize": "${paginationInfo.pageSize}",
//       "modelName": modelName
//     });
//   }
//
//   return SliverPersistentHeader(
//     pinned: true,
//     delegate: SliverAppBarDelegate(
//       minHeight: 26.0,
//       maxHeight: 26.0,
//       child: Container(
//           color: Theme.of(context).primaryColor,
//           child: Padding(
//             child: Text(
//               title,
//               style:
//                   TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
//             ),
//             padding: EdgeInsets.only(left: 4.0, top: 7.0, bottom: 4.0),
//           )),
//     ),
//   );
// }
//
// // NOT USED, here as an example
// class SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
//   SliverAppBarDelegate({
//     required this.minHeight,
//     required this.maxHeight,
//     required this.child,
//   });
//   final double minHeight;
//   final double maxHeight;
//   final Widget child;
//   @override
//   double get minExtent => minHeight;
//   @override
//   double get maxExtent => max(maxHeight, minHeight);
//   @override
//   Widget build(
//       BuildContext context, double shrinkOffset, bool overlapsContent) {
//     return new SizedBox.expand(child: child);
//   }
//
//   @override
//   bool shouldRebuild(SliverAppBarDelegate oldDelegate) {
//     return maxHeight != oldDelegate.maxHeight ||
//         minHeight != oldDelegate.minHeight ||
//         child != oldDelegate.child;
//   }
// }
//
// // NOT USED, here as an example
// SliverPersistentHeader makeHeader(BuildContext context, String headerText) {
//   return SliverPersistentHeader(
//     pinned: true,
//     delegate: SliverAppBarDelegate(
//       minHeight: 40.0,
//       maxHeight: 40.0,
//       child: Container(
//           color: Theme.of(context).primaryColor,
//           child: Center(child: Text(headerText))),
//     ),
//   );
// }
//
// SliverPersistentHeader makeEmptyHeader() {
//   return SliverPersistentHeader(
//     delegate: SliverAppBarDelegate(
//       minHeight: 0,
//       maxHeight: 0,
//       child: SizedBox(),
//     ),
//   );
// }
//
// // NOT USED, here as an example
// SliverPersistentHeader makeAssignedOrderHeader(
//     BuildContext context, String userName, List<AssignedOrder> assignedOrders) {
//   String title = "${assignedOrders.length} orders for $userName";
//   Set<String?> customerNames = assignedOrders
//       .map((assignedOrder) => {assignedOrder.order!.orderName})
//       .map((e) => e.first)
//       .toList()
//       .toSet();
//   String subtitle = "Customers include ${customerNames.join(', ')}";
//
//   ListTile listTitle = ListTile(title: Text(title), subtitle: Text(subtitle));
//
//   return SliverPersistentHeader(
//     pinned: false,
//     delegate: SliverAppBarDelegate(
//       minHeight: 60.0,
//       maxHeight: 140.0,
//       child: Container(color: Theme.of(context).primaryColor, child: listTitle),
//     ),
//   );
// }
//
// Widget createViewWorkOrderButton(
//     String? workorderPdfUrl, BuildContext context) {
//   if (workorderPdfUrl != null && workorderPdfUrl != '') {
//     return createDefaultElevatedButton(
//         My24i18n.tr('generic.button_open_workorder'), () async {
//       Map<String, dynamic> openResult =
//           await utils.openDocument(workorderPdfUrl);
//       if (!openResult['result']) {
//         createSnackBar(
//             context,
//             My24i18n.tr(
//                 'generic.error_arg', {'error': openResult['message']}));
//       }
//     });
//   }
//
//   return createDefaultElevatedButton(
//       My24i18n.tr('generic.button_no_workorder'), () => {});
// }
//
// GestureDetector wrapGestureDetector(BuildContext context, Widget child) {
//   return GestureDetector(
//       onTap: () {
//         FocusScope.of(context).requestFocus(FocusNode());
//       },
//       child: child);
// }
//
// // mixin to handle TextEditingControllers in the form widgets
// mixin TextEditingControllerMixin {
//   List<TextEditingController> controllers = [];
//   List<FocusNode> focusNodes = [];
//
//   FocusNode createFocusNode({Function? listener}) {
//     FocusNode node = FocusNode();
//
//     if (listener != null) {
//       node.addListener(() {
//         listener();
//       });
//     }
//
//     focusNodes.add(node);
//     return node;
//   }
//
//   void addTextEditingController(
//       TextEditingController controller, BaseFormData formData, String field) {
//     controller.addListener(() {
//       formData.setProp(field, controller.text);
//     });
//
//     String? value = formData.getProp(field);
//
//     if (value != null) {
//       controller.text = value;
//     }
//
//     controllers.add(controller);
//   }
//
//   void disposeTextEditingControllers() {
//     for (int i = 0; i < controllers.length; i++) {
//       controllers[i].dispose();
//     }
//   }
//
//   void disposeFocusNodes() {
//     for (int i = 0; i < focusNodes.length; i++) {
//       focusNodes[i].dispose();
//     }
//   }
//
//   void disposeAll() {
//     disposeTextEditingControllers();
//     disposeFocusNodes();
//   }
// }

// order appbars have some more logic in them
abstract class BaseOrdersAppBarFactory extends BaseGenericAppBarFactory {
  BuildContext context;
  List<dynamic>? orders;
  OrderPageMetaData orderPageMetaData;
  int? count;
  Function? onStretch;

  BaseOrdersAppBarFactory({
    required this.orderPageMetaData,
    required this.context,
    required this.orders,
    required this.count,
    this.onStretch
  }): super(
      mainMemberPicture: orderPageMetaData.memberPicture,
      mainContext: context,
      mainSubtitle: '',
      mainTitle: ''
  );

  String? getBaseTranslateStringForUser() {
    if (orderPageMetaData.submodel == 'customer_user') {
      return 'orders.list.app_title_customer_user';
    }
    if (orderPageMetaData.submodel == 'planning_user') {
      return 'orders.list.app_title_planning_user';
    }
    if (orderPageMetaData.submodel == 'sales_user') {
      return 'orders.list.app_title_sales_user';
    }
    if (orderPageMetaData.submodel == 'branch_employee_user') {
      return 'orders.list.app_title_branch_employee_user';
    }

    return null;
  }

  List<dynamic> getCustomerNames(List<dynamic> orders) {
    return orders.map((order) => {
      order.orderName
    }).map((e) => e.first).toList().toSet().toList().take(3).toList();
  }

  Widget createTitle() {
    String? baseTranslateString = getBaseTranslateStringForUser();
    String title;
    if (orders!.length == 0) {
      final String firstName = orderPageMetaData.firstName == null ? "" : orderPageMetaData.firstName!;
      title = My24i18n.tr('${baseTranslateString}_no_orders', namedArgs: {
        'numOrders': "$count",
        'firstName': firstName
      }
      );
    } else if (orders!.length == 1) {
      final String firstName = orderPageMetaData.firstName == null ? "" : orderPageMetaData.firstName!;
      title = My24i18n.tr("${baseTranslateString}_one_order", namedArgs: {
        'numOrders': "$count",
        'firstName': firstName
      }
      );
    } else {
      final String firstName = orderPageMetaData.firstName == null ? "" : orderPageMetaData.firstName!;
      title = My24i18n.tr("$baseTranslateString", namedArgs: {
        'numOrders': "$count",
        'firstName': firstName
      }
      );
    }

    String subtitle = "";
    if (orders!.length > 1) {
      List<dynamic> copy = new List<dynamic>.from(orders!);
      copy.shuffle();
      List<dynamic> customerNames = getCustomerNames(copy);
      subtitle = My24i18n.tr("generic.orders_app_bar_subtitle",
          namedArgs: {'customers': "${customerNames.join(', ')}"});
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisAlignment: MainAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text(title, style: TextStyle(color: Colors.white, )),
        Text(subtitle, style: TextStyle(color: Colors.white, fontSize: 12.0)),
      ],
    );

    // return ListTile(
    //     contentPadding: contentPadding,
    //     textColor: Colors.white,
    //     title: Text(title),
    //     subtitle: Text(subtitle)
    // );
  }
}

class AssignedOrdersAppBarFactory extends BaseOrdersAppBarFactory {
  OrderPageMetaData orderPageMetaData;
  BuildContext context;
  List<dynamic>? orders;
  int? count;
  Function? onStretch;

  AssignedOrdersAppBarFactory({
    required this.orderPageMetaData,
    required this.context,
    required this.orders,
    required this.count,
    this.onStretch
  }): super(
      orderPageMetaData: orderPageMetaData,
      context: context,
      orders: orders,
      count: count,
      onStretch: onStretch
  );

  String getBaseTranslateStringForUser() {
    return 'assigned_orders.list.app_bar_title';
  }

  List<dynamic> getCustomerNames(List<dynamic> orders) {
    return orders.map((assignedOrder) => {
      assignedOrder.order.orderName
    }).map((e) => e.first).toList().toSet().toList().take(3).toList();
  }

}

Widget loadingNotice() {
  return const Center(child: CircularProgressIndicator());
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

ElevatedButton createDefaultElevatedButton(String text, Function callback) {
  return ElevatedButton(
    style: ElevatedButton.styleFrom(foregroundColor: Colors.white),
    child: new Text(text),
    onPressed: callback as void Function()?,
  );
}

ElevatedButton createElevatedButtonColored(String text, Function callback,
    {foregroundColor = Colors.white, backgroundColor = Colors.blue}) {
  return ElevatedButton(
    style: ElevatedButton.styleFrom(
      foregroundColor: foregroundColor,
      backgroundColor: backgroundColor,
    ),
    onPressed: callback as void Function()?,
    child: Text(text),
  );
}

Future<dynamic> displayDialog(BuildContext context, title, text) {
  return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(title: Text(title), content: Text(text));
      });
}

class MemberInfoCard extends StatelessWidget {
  final Member member;

  const MemberInfoCard({
    super.key,
    required this.member
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          ListTile(
            title: Text('${member.name}',
                style: const TextStyle(fontWeight: FontWeight.w500)),
            subtitle: Text(
                '${member.address}\n${member.countryCode}-${member
                    .postal}\n${member.city}'),
            leading: Icon(
              Icons.home,
              color: Colors.blue[500],
            ),
          ),
          ListTile(
            title: Text('${member.tel}',
                style: const TextStyle(fontWeight: FontWeight.w500)),
            leading: Icon(
              Icons.contact_phone,
              color: Colors.blue[500],
            ),
            onTap: () {
              if (member.tel != '' && member.tel != null) {
                coreUtils.launchURL("tel://${member.tel}");
              }
            },
          ),
        ],
      ),
    );
  }

}
