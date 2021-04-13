import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:my24app/order/models/models.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:my24app/order/blocs/order_bloc.dart';
import 'package:my24app/core/widgets/widgets.dart';
import 'package:my24app/core/utils.dart';
import 'package:my24app/order/pages/documents.dart';
import 'package:my24app/order/pages/form.dart';

class OrderInfoWidget extends StatelessWidget {
  final Order order;

  OrderInfoWidget({
    Key key,
    @required this.order,
  }): super(key: key);

  @override
  Widget build(BuildContext context) {
    _showMainView();
  }

  Widget _showMainView() {
    return Align(
        alignment: Alignment.topRight,
        child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              createHeader('orders.info_order'.tr()),
              Table(
                children: [
                  TableRow(
                      children: [
                        Text('orders.info_order_id'.tr(),
                            style: TextStyle(fontWeight: FontWeight.bold)
                        ),
                        Text(order.orderId != null ? order.orderId : ''),
                      ]
                  ),
                  TableRow(
                      children: [
                        Text('orders.info_order_type'.tr(),
                            style: TextStyle(fontWeight: FontWeight.bold)
                        ),
                        Text(order.orderType != null ? order.orderType : ''),
                      ]
                  ),
                  TableRow(
                      children: [
                        Text('orders.info_order_date'.tr(),
                            style: TextStyle(fontWeight: FontWeight.bold)
                        ),
                        Text(order.orderDate != null ? order.orderDate : ''),
                      ]
                  ),
                  TableRow(
                      children: [
                        Divider(),
                        SizedBox(height: 10),
                      ]
                  ),
                  TableRow(
                      children: [
                        Text('orders.info_customer'.tr(),
                            style: TextStyle(fontWeight: FontWeight.bold)
                        ),
                        Text(order.orderName != null ? order.orderName : ''),
                      ]
                  ),
                  TableRow(
                      children: [
                        Text('orders.info_customer_id'.tr(),
                            style: TextStyle(fontWeight: FontWeight.bold)
                        ),
                        Text(order.orderName != null ? order.customerId : ''),
                      ]
                  ),
                  TableRow(
                      children: [
                        Text('orders.info_address'.tr(),
                            style: TextStyle(fontWeight: FontWeight.bold)
                        ),
                        Text(order.orderAddress != null ? order.orderAddress : ''),
                      ]
                  ),
                  TableRow(
                      children: [
                        Text('orders.info_postal'.tr(),
                            style: TextStyle(fontWeight: FontWeight.bold)
                        ),
                        Text(order.orderPostal != null ? order.orderPostal : ''),
                      ]
                  ),
                  TableRow(
                      children: [
                        Text('orders.info_country_city'.tr(),
                            style: TextStyle(fontWeight: FontWeight.bold)
                        ),
                        Text(order.orderCountryCode + '/' + order.orderCity),
                      ]
                  ),
                  TableRow(
                      children: [
                        Text('orders.info_contact'.tr(),
                            style: TextStyle(fontWeight: FontWeight.bold)
                        ),
                        Text(order.orderContact != null ? order.orderContact : ''),
                      ]
                  ),
                  TableRow(
                      children: [
                        Text('orders.info_tel'.tr(),
                            style: TextStyle(fontWeight: FontWeight.bold)
                        ),
                        Text(order.orderTel != null ? order.orderTel : ''),
                      ]
                  ),
                  TableRow(
                      children: [
                        Text('orders.info_mobile'.tr(),
                            style: TextStyle(fontWeight: FontWeight.bold)
                        ),
                        Text(order.orderMobile != null ? order.orderMobile : ''),
                      ]
                  ),
                  TableRow(
                      children: [
                        Text('orders.info_order_customer_remarks'.tr(),
                            style: TextStyle(fontWeight: FontWeight.bold)
                        ),
                        Text(order.customerRemarks != null ? order.customerRemarks : '')
                      ]
                  )
                ],
              ),
              Divider(),
              createHeader('orders.header_orderlines'.tr()),
              _createOrderlinesTable(),
              Divider(),
              createHeader('orders.header_infolines'.tr()),
              _createInfolinesTable(),
              Divider(),
              createHeader('orders.header_documents'.tr()),
              _buildDocumentsTable(),
              Divider(),
              createHeader('orders.header_status_history'.tr()),
              _createStatusView(),
              Divider(),
              _createWorkorderWidget(),
            ]
        )
    );
  }

  Widget _createWorkorderWidget() {
    Widget result;

    if(order.workorderPdfUrl != null && order.workorderPdfUrl != '') {
      result = createBlueElevatedButton(
        'orders.button_open_workorder'.tr(),
        () => launchURL(order.workorderPdfUrl)
      );
    } else {
      result = Text('orders.button_no_workorder'.tr());
    }

    return result;
  }

  // order lines
  Widget _createOrderlinesTable() {
    List<TableRow> rows = [];

    // header
    rows.add(TableRow(
      children: [
        Column(
          children:[
            createTableHeaderCell('generic.info_equipment'.tr())
          ]
        ),
        Column(
            children:[
              createTableHeaderCell('generic.info_location'.tr())
            ]
        ),
        Column(
            children:[
              createTableHeaderCell('generic.info_remarks'.tr())
            ]
        )
      ],

    ));

    for (int i = 0; i < order.orderLines.length; ++i) {
      Orderline orderline = order.orderLines[i];

      rows.add(
          TableRow(
              children: [
                Column(
                    children:[
                      createTableColumnCell(orderline.product)
                    ]
                ),
                Column(
                    children:[
                      createTableColumnCell(orderline.location)
                    ]
                ),
                Column(
                    children:[
                      createTableColumnCell(orderline.remarks)
                    ]
                ),
              ]
          )
      );
    }

    return createTable(rows);
  }

  // info lines
  Widget _createInfolinesTable() {
    List<TableRow> rows = [];

    // header
    rows.add(TableRow(
      children: [
        Column(
            children:[
              createTableHeaderCell('orders.info_infoline'.tr())
            ]
        ),
      ],

    ));

    for (int i = 0; i < order.infoLines.length; ++i) {
      Infoline infoline = order.infoLines[i];

      rows.add(
          TableRow(
              children: [
                Column(
                    children:[
                      createTableColumnCell(infoline.info)
                    ]
                ),
              ]
          )
      );
    }

    return createTable(rows);
  }

  // documents
  Widget _buildDocumentsTable() {
    List<TableRow> rows = [];

    // header
    rows.add(TableRow(
      children: [
        Column(children: [
          createTableHeaderCell('generic.info_name'.tr())
        ]),
        Column(children: [
          createTableHeaderCell('generic.info_description'.tr())
        ]),
        Column(children: [
          createTableHeaderCell('orders.info_document'.tr())
        ]),
      ],
    ));

    // documents
    for (int i = 0; i < order.documents.length; ++i) {
      OrderDocument document = order.documents[i];

      rows.add(TableRow(children: [
        Column(
            children: [
              createTableColumnCell(document.name)
            ]
        ),
        Column(
            children: [
              createTableColumnCell(document.description)
            ]
        ),
        Column(
            children: [
              createTableColumnCell(document.file.split('/').last)
            ]
        ),
      ]));
    }

    return createTable(rows);
  }

  Widget _createStatusView() {
    List<TableRow> rows = [];

    // statusses
    for (int i = 0; i < order.statusses.length; ++i) {
      Status status = order.statusses[i];

      rows.add(
          TableRow(
              children: [
                Column(
                    children:[
                      createTableColumnCell(status.created)
                    ]
                ),
                Column(
                    children:[
                      createTableColumnCell(status.status)
                    ]
                ),
              ]
          )
      );
    }

    return createTable(rows);
  }

}
