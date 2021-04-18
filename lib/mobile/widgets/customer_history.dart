import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:my24app/core/utils.dart';

import 'package:my24app/core/widgets/widgets.dart';
import 'package:my24app/order/models/models.dart';

class CustomerHistoryWidget extends StatefulWidget {
  final CustomerHistory customerHistory;

  CustomerHistoryWidget({
    Key key,
    this.customerHistory,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => new _CustomerHistoryWidgetState(
      customerHistory: customerHistory,
  );
}

class _CustomerHistoryWidgetState extends State<CustomerHistoryWidget> {
  final CustomerHistory customerHistory;

  _CustomerHistoryWidgetState({
    @required this.customerHistory,
  }) : super();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
      child: _buildList(),
    );
  }

  Widget _buildList() {
    if (customerHistory.orderData.length == 0) {
      return Center(
          child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                Center(
                    child: Column(
                      children: [
                        SizedBox(height: 30),
                        Text('customers.history.notice_no_history'.tr())
                      ],
                    )
                )
              ]
          )
      );
    }

    return ListView.builder(
        padding: EdgeInsets.all(8),
        itemCount: customerHistory.orderData.length,
        itemBuilder: (BuildContext context, int index) {
          return Container(
              child: _createOrderRow(customerHistory.orderData[index])
          );
        } // itemBuilder
    );
  }

  Widget _createOrderRow(CustomerHistoryOrder orderData) {
    return Table(
      children: [
        TableRow(
            children: [
              Table(
                children: [
                  TableRow(
                      children: [
                        Text('customers.history.info_date'.tr(),
                            style: TextStyle(fontWeight: FontWeight.bold)
                        ),
                        Text('${orderData.orderDate}')
                      ]
                  ),
                  TableRow(
                      children: [
                        Text('customers.history.info_order_type'.tr(),
                            style: TextStyle(fontWeight: FontWeight.bold)
                        ),
                        Text('${orderData.orderType}'),
                      ]
                  )
                ],
              ),
              Table(
                children: [
                  TableRow(
                      children: [
                        Text('customers.history.info_reference'.tr(),
                            style: TextStyle(fontWeight: FontWeight.bold)
                        ),
                        Text(orderData.orderReference != null ? orderData.orderReference : '-')
                      ]
                  ),
                  TableRow(
                      children: [
                        Text('customers.history.info_customer_id'.tr(),
                            style: TextStyle(fontWeight: FontWeight.bold)
                        ),
                        Text(orderData.orderId != null ? orderData.orderId : '-')
                      ]
                  ),
                ],
              )
              // _createOrderLinesTable(orderData.orderLines)
            ]
        ),
        TableRow(
            children: [
              SizedBox(height: 10),
              SizedBox(height: 10),
            ]
        ),
        TableRow(
            children: [
              SizedBox(width: 10),
              createBlueElevatedButton(
                  orderData.workorderPdfUrl != null && orderData.workorderPdfUrl != '' ?
                  'customers.history.button_open_workorder'.tr() :
                  'customers.history.button_no_workorder'.tr(),
                      () => utils.launchURL(orderData.workorderPdfUrl)
              ),
            ]
        ),
        TableRow(
            children: [
              Divider(),
              Divider(),
            ]
        )
      ],
    );
  }

  Widget _createOrderLinesTable(List<Orderline> orderlines) {
    if(orderlines.length == 0) {
      return buildEmptyListFeedback();
    }

    List<TableRow> rows = [];

    // header
    rows.add(TableRow(
      children: [
        Column(children: [
          createTableHeaderCell('generic.info_product'.tr())
        ]),
        Column(children: [
          createTableHeaderCell('generic.info_location'.tr())
        ]),
        Column(children: [
          createTableHeaderCell('generic.info_remarks'.tr())
        ]),
      ],
    ));

    // orderlines
    for (int i = 0; i < orderlines.length; ++i) {
      Orderline orderLine = orderlines[i];

      rows.add(TableRow(children: [
        Column(
            children: [
              createTableColumnCell('${orderLine.product}')
            ]
        ),
        Column(
            children: [
              createTableColumnCell('${orderLine.location}')
            ]
        ),
        Column(
            children: [
              createTableColumnCell('${orderLine.remarks}')
            ]
        ),
      ]));
    }

    return createTable(rows);
  }

}
