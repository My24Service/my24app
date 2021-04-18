import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:my24app/mobile/pages/activity.dart';
import 'package:my24app/mobile/pages/customer_history.dart';
import 'package:my24app/mobile/pages/doucment.dart';
import 'package:my24app/mobile/pages/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:my24app/core/widgets/widgets.dart';
import 'package:my24app/core/utils.dart';
import 'package:my24app/mobile/blocs/assignedorder_bloc.dart';
import 'package:my24app/mobile/models/models.dart';
import 'package:my24app/order/models/models.dart';


class AssignedWidget extends StatelessWidget {
  final AssignedOrder assignedOrder;

  AssignedWidget({
    Key key,
    @required this.assignedOrder,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return _showMainView(context);
  }

  Widget _showMainView(BuildContext context) {
    return Align(
        alignment: Alignment.topRight,
        child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Table(
                children: [
                  TableRow(
                      children: [
                        Text('orders.info_order_id'.tr(),
                            style: TextStyle(fontWeight: FontWeight.bold)
                        ),
                        Text(assignedOrder.order.orderId != null ? assignedOrder.order.orderId : '-'),
                      ]
                  ),
                  TableRow(
                      children: [
                        Text('orders.info_order_type'.tr(),
                            style: TextStyle(fontWeight: FontWeight.bold)
                        ),
                        Text(assignedOrder.order.orderType != null ? assignedOrder.order.orderType : '-'),
                      ]
                  ),
                  TableRow(
                      children: [
                        Text('orders.info_order_date'.tr(), style: TextStyle(fontWeight: FontWeight.bold)),
                        Text(assignedOrder.order.orderDate != null ? assignedOrder.order.orderDate : '-'),
                      ]
                  ),
                  TableRow(
                      children: [
                        Divider(),
                        SizedBox(height: 10)
                      ]
                  ),
                  TableRow(
                      children: [
                        Text('orders.info_customer'.tr(),
                            style: TextStyle(fontWeight: FontWeight.bold)
                        ),
                        Text(assignedOrder.order.orderName != null ? assignedOrder.order.orderName : '-'),
                      ]
                  ),
                  TableRow(
                      children: [
                        Text('orders.info_customer_id'.tr(),
                            style: TextStyle(fontWeight: FontWeight.bold)
                        ),
                        Text(assignedOrder.order.orderName != null ? assignedOrder.order.customerId : '-'),
                      ]
                  ),
                  TableRow(
                      children: [
                        Text('orders.info_address'.tr(),
                            style: TextStyle(fontWeight: FontWeight.bold)
                        ),
                        Text(assignedOrder.order.orderAddress != null ? assignedOrder.order.orderAddress : '-'),
                      ]
                  ),
                  TableRow(
                      children: [
                        Text('orders.info_postal'.tr(),
                            style: TextStyle(fontWeight: FontWeight.bold)
                        ),
                        Text(assignedOrder.order.orderPostal != null ? assignedOrder.order.orderPostal : '-'),
                      ]
                  ),
                  TableRow(
                      children: [
                        Text('orders.info_country_city'.tr(),
                            style: TextStyle(fontWeight: FontWeight.bold)
                        ),
                        Text(assignedOrder.order.orderCountryCode + '/' + assignedOrder.order.orderCity),
                      ]
                  ),
                  TableRow(
                      children: [
                        Text('orders.info_contact'.tr(),
                            style: TextStyle(fontWeight: FontWeight.bold)
                        ),
                        Text(assignedOrder.order.orderContact != null ? assignedOrder.order.orderContact : '-'),
                      ]
                  ),
                  TableRow(
                      children: [
                        Text('orders.info_tel'.tr(),
                            style: TextStyle(fontWeight: FontWeight.bold)
                        ),
                        Text(assignedOrder.order.orderTel != null ? assignedOrder.order.orderTel : '-'),
                      ]
                  ),
                  TableRow(
                      children: [
                        Text('orders.info_mobile'.tr(),
                            style: TextStyle(fontWeight: FontWeight.bold)
                        ),
                        Text(assignedOrder.order.orderMobile != null ? assignedOrder.order.orderMobile : '-'),
                      ]
                  ),
                  TableRow(
                      children: [
                        Text('generic.info_email'.tr(),
                            style: TextStyle(fontWeight: FontWeight.bold)
                        ),
                        Text(assignedOrder.order.orderEmail != null ? assignedOrder.order.orderEmail : '-'),
                      ]
                  ),
                  TableRow(
                      children: [
                        Text('orders.info_order_customer_remarks'.tr(),
                            style: TextStyle(fontWeight: FontWeight.bold)
                        ),
                        Text(assignedOrder.order.customerRemarks != null ? assignedOrder.order.customerRemarks : '-'),
                      ]
                  ),
                  TableRow(
                      children: [
                        Divider(),
                        SizedBox(height: 10)
                      ]
                  ),
                  TableRow(
                      children: [
                        Text('assigned_orders.detail.info_maintenance_contract'.tr(),
                            style: TextStyle(fontWeight: FontWeight.bold)
                        ),
                        Text(assignedOrder.customer.maintenanceContract != null ? assignedOrder.customer.maintenanceContract : '-'),
                      ]
                  ),
                  TableRow(
                      children: [
                        Text('assigned_orders.detail.info_standard_hours'.tr(),
                            style: TextStyle(fontWeight: FontWeight.bold)
                        ),
                        Text(assignedOrder.customer.standardHours != null ? assignedOrder.customer.standardHours : '-'),
                      ]
                  )
                ],
              ),
              Divider(),
              createHeader('assigned_orders.detail.header_also_assigned'.tr()),
              _showAlsoAssigned(assignedOrder),
              Divider(),
              createHeader('assigned_orders.detail.header_orderlines'.tr()),
              _createOrderlinesTable(),
              Divider(),
              createHeader('assigned_orders.detail.header_infolines'.tr()),
              _createInfolinesTable(),
              Divider(),
              createHeader('assigned_orders.detail.header_documents'.tr()),
              _buildDocumentsTable(),
              Divider(),
              _buildButtons(context),
            ]
        )
    );
  }

  // orderlines
  Widget _createOrderlinesTable() {
    if(assignedOrder.order.orderLines.length == 0) {
      return buildEmptyListFeedback();
    }

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

    for (int i = 0; i < assignedOrder.order.orderLines.length; ++i) {
      Orderline orderline = assignedOrder.order.orderLines[i];

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

  // infolines
  Widget _createInfolinesTable() {
    if(assignedOrder.order.infoLines.length == 0) {
      return buildEmptyListFeedback();
    }

    List<TableRow> rows = [];

    // header
    rows.add(TableRow(
      children: [
        Column(
            children:[
              createTableHeaderCell('assigned_orders.detail.info_info'.tr())
            ]
        ),
      ],

    ));

    for (int i = 0; i < assignedOrder.order.infoLines.length; ++i) {
      Infoline infoline = assignedOrder.order.infoLines[i];

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
    if(assignedOrder.order.documents.length == 0) {
      return buildEmptyListFeedback();
    }

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
          createTableHeaderCell('generic.info_document'.tr())
        ]),
        Column(children: [
          createTableHeaderCell('generic.action_open'.tr())
        ])
      ],
    ));

    for (int i = 0; i < assignedOrder.order.documents.length; ++i) {
      OrderDocument document = assignedOrder.order.documents[i];

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
        Column(children: [
          IconButton(
            icon: Icon(Icons.view_agenda, color: Colors.red),
            onPressed: () async {
              String url = await utils.getUrl(document.url);
              launch(url);
            },
          )
        ]),
      ]));
    }

    return createTable(rows);
  }

  _startCodePressed(BuildContext context, StartCode startCode) {
    final bloc = BlocProvider.of<AssignedOrderBloc>(context);
    bloc.add(AssignedOrderEvent(status: AssignedOrderEventStatus.DO_ASYNC));
    bloc.add(AssignedOrderEvent(
        status: AssignedOrderEventStatus.REPORT_STARTCODE,
        code: startCode,
        value: assignedOrder.id
    ));
  }

  _endCodePressed(BuildContext context, EndCode endCode) async {
    final bloc = BlocProvider.of<AssignedOrderBloc>(context);
    bloc.add(AssignedOrderEvent(status: AssignedOrderEventStatus.DO_ASYNC));
    bloc.add(AssignedOrderEvent(
        status: AssignedOrderEventStatus.REPORT_ENDCODE,
        code: endCode,
        value: assignedOrder.id
    ));
  }

  _extraWorkButtonPressed(BuildContext context) {
    // set up the buttons
    Widget cancelButton = TextButton(
        child: Text('generic.action_cancel'.tr()),
        onPressed: () => Navigator.pop(context, false)
    );
    Widget deleteButton = TextButton(
        child: Text('assigned_orders.detail.button_create_extra_order'.tr()),
        onPressed: () => Navigator.pop(context, true)
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text('assigned_orders.detail.dialog_extra_order_title'.tr()),
      content: Text('assigned_orders.detail.dialog_extra_order_content'.tr()),
      actions: [
        cancelButton,
        deleteButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (_) {
        return alert;
      },
    ).then((dialogResult) {
      if (dialogResult == null) return;

      if (dialogResult) {
        final bloc = BlocProvider.of<AssignedOrderBloc>(context);
        bloc.add(AssignedOrderEvent(status: AssignedOrderEventStatus.DO_ASYNC));
        bloc.add(AssignedOrderEvent(
            status: AssignedOrderEventStatus.REPORT_EXTRAWORK,
            value: assignedOrder.id
        ));
      }
    });
  }

  _signWorkorderPressed(BuildContext context) {
    // final page = AssignedOrderWorkOrderPage();

    // Navigator.push(context,
    //     MaterialPageRoute(
    //         builder: (context) => page
    //     )
    // );
  }

  _noWorkorderPressed(BuildContext context) async {
    final bloc = BlocProvider.of<AssignedOrderBloc>(context);
    bloc.add(AssignedOrderEvent(status: AssignedOrderEventStatus.DO_ASYNC));
    bloc.add(AssignedOrderEvent(
        status: AssignedOrderEventStatus.REPORT_NOWORKORDER,
        value: assignedOrder.id
    ));
  }

  _customerHistoryPressed(BuildContext context, int customerPk) {
    final page = CustomerHistoryPage(
        customerPk: customerPk,
        customerName: assignedOrder.order.orderName,
    );
    Navigator.push(context,
        MaterialPageRoute(
            builder: (context) => page
        )
    );
  }

  _activityPressed(BuildContext context) {
    final page = AssignedOrderActivityPage(assignedOrderPk: assignedOrder.id);
    Navigator.push(context,
        MaterialPageRoute(
            builder: (context) => page
        )
    );
  }

  _materialsPressed(BuildContext context) {
    final page = AssignedOrderMaterialPage(assignedOrderPk: assignedOrder.id);
    Navigator.push(context,
        MaterialPageRoute(
            builder: (context) => page
        )
    );
  }

  _documentsPressed(BuildContext context) {
    final page = DocumentPage(assignedOrderPk: assignedOrder.id);
    Navigator.push(context,
        MaterialPageRoute(
            builder: (context) => page
        )
    );
  }

  Widget _buildButtons(BuildContext context) {
    // if not started, only show first startCode as a button
    if (!assignedOrder.isStarted) {
      StartCode startCode = assignedOrder.startCodes[0];

      return new Container(
        child: new Column(
          children: <Widget>[
            createBlueElevatedButton(
                startCode.description, () => _startCodePressed(context, startCode)
            )
          ],
        ),
      );
    }

    if (assignedOrder.isStarted) {
      // started, show 'Register time/km', 'Register materials', and 'Manage documents' and 'Finish order'
      ElevatedButton customerHistoryButton = createBlueElevatedButton(
          'assigned_orders.detail.button_customer_history'.tr(),
          () => _customerHistoryPressed(context, assignedOrder.order.customerRelation));
      ElevatedButton activityButton = createBlueElevatedButton(
          'assigned_orders.detail.button_register_time_km'.tr(),
          () => _activityPressed(context));
      ElevatedButton materialsButton = createBlueElevatedButton(
          'assigned_orders.detail.button_register_materials'.tr(),
          () => _materialsPressed(context));
      ElevatedButton documentsButton = createBlueElevatedButton(
          'assigned_orders.detail.button_manage_documents'.tr(),
          () => _documentsPressed(context));

      EndCode endCode = assignedOrder.endCodes[0];

      ElevatedButton finishButton = createBlueElevatedButton(
          endCode.description, () => _endCodePressed(context, endCode));

      ElevatedButton extraWorkButton = createBlueElevatedButton(
          'assigned_orders.detail.button_extra_work'.tr(),
          () => _extraWorkButtonPressed(context),
          primaryColor: Colors.red);
      ElevatedButton signWorkorderButton = createBlueElevatedButton(
          'assigned_orders.detail.button_sign_workorder'.tr(),
          () => _signWorkorderPressed(context),
          primaryColor: Colors.red);
      ElevatedButton noWorkorderButton = createBlueElevatedButton(
          'assigned_orders.detail.button_no_workorder'.tr(),
          () => _noWorkorderPressed(context),
          primaryColor: Colors.red);

      // no ended yet, show a subset of the buttons
      if (!assignedOrder.isEnded) {
        return new Container(
          child: new Column(
            children: <Widget>[
              customerHistoryButton,
              activityButton,
              materialsButton,
              documentsButton,
              Divider(),
              finishButton,
            ],
          ),
        );
      }

      // ended, show all buttons
      return new Container(
        child: new Column(
          children: <Widget>[
            customerHistoryButton,
            activityButton,
            materialsButton,
            documentsButton,
            Divider(),
            finishButton,
            Divider(),
            extraWorkButton,
            signWorkorderButton,
            noWorkorderButton,
            // quotationButton,
          ],
        ),
      );
    }
  }

  _showAlsoAssigned(AssignedOrder assignedOrder) {
    if (assignedOrder.assignedUserData.length == 0) {
      return Table(children: [
        TableRow(
            children: [
              Column(children: [
                createTableColumnCell('assigned_orders.detail.info_no_one_else_assigned'.tr())
              ])
            ]
        )
      ]);
    }

    List<TableRow> users = [];

    for (int i=0; i<assignedOrder.assignedUserData.length; i++) {
      users.add(TableRow(
          children: [
            Column(children: [
              createTableColumnCell(assignedOrder.assignedUserData[i].fullName)
            ])
          ]
      )
      );
    }

    return Table(children: users);
  }
}
