import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:my24app/customer/models/models.dart';
import 'package:my24app/mobile/pages/activity.dart';
import 'package:my24app/mobile/pages/customer_history.dart';
import 'package:my24app/mobile/pages/doucment.dart';
import 'package:my24app/mobile/pages/material.dart';
import 'package:my24app/mobile/pages/material_stock.dart';
import 'package:my24app/mobile/pages/workorder.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:my24app/core/widgets/widgets.dart';
import 'package:my24app/core/utils.dart';
import 'package:my24app/mobile/blocs/assignedorder_bloc.dart';
import 'package:my24app/mobile/models/models.dart';
import 'package:my24app/order/models/models.dart';


class AssignedWidget extends StatelessWidget {
  final AssignedOrder assignedOrder;
  final Map<int, TextEditingController> extraDataTexts = {};

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
                        Text('orders.info_order_reference'.tr(), style: TextStyle(fontWeight: FontWeight.bold)),
                        Text(assignedOrder.order.orderReference != null ? assignedOrder.order.orderReference : '-'),
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
              _showAlsoAssignedSection(assignedOrder),
              Divider(),
              _createOrderlinesSection(),
              Divider(),
              _createInfolinesSection(),
              Divider(),
              _buildDocumentsSection(),
              Divider(),
              _buildCustomerDocumentsSection(),
              Divider(),
              _buildButtons(context),
            ]
        )
    );
  }

  // orderlines
  Widget _createOrderlinesSection() {
    return buildItemsSection(
      'assigned_orders.detail.header_orderlines'.tr(),
      assignedOrder.order.orderLines,
          (item) {
            List<Widget> items = [];

            items.add(buildItemListTile('generic.info_equipment'.tr(), item.product));
            items.add(buildItemListTile('generic.info_location'.tr(), item.location));
            items.add(buildItemListTile('generic.info_remarks'.tr(), item.remarks));

            return items;
          },
          (item) {
            List<Widget> items = [];
            return items;
      },
    );
  }

  // infolines
  Widget _createInfolinesSection() {
    return buildItemsSection(
      'assigned_orders.detail.header_infolines'.tr(),
      assignedOrder.order.infoLines,
          (item) {
            List<Widget> items = [];
    
            items.add(buildItemListTile('assigned_orders.detail.info_info'.tr(), item.info));
    
            return items;
          },
          (item) {
        List<Widget> items = [];
        return items;
      },
    );
  }

  // documents
  Widget _buildDocumentsSection() {
    return buildItemsSection(
      'assigned_orders.detail.header_documents'.tr(),
      assignedOrder.order.documents,
          (item) {
            List<Widget> items = [];
    
            items.add(buildItemListTile('generic.info_name'.tr(), item.name));
            items.add(buildItemListTile('generic.info_description'.tr(), item.description));
            items.add(buildItemListTile('generic.info_document'.tr(), item.file.split('/').last));
            
            return items;
          },
          (item) {
            List<Widget> items = [];

            items.add(Padding(
                padding: EdgeInsets.only(left: 16),
                child: Row(
                    children: [
                      createTableHeaderCell('generic.action_open'.tr()),
                      IconButton(
                        icon: Icon(Icons.view_agenda, color: Colors.red),
                        onPressed: () async {
                          String url = await utils.getUrl(item.url);
                          launchUrl(Uri.parse(url.replaceAll('/api', '')));
                        },
                      )
                    ]
                )
            ));

            return items;
          },
      );
  }

  // customer documents
  Widget _buildCustomerDocumentsSection() {
    // filter out documents that can't be viewed by users
    List <CustomerDocument> documents= [];

    for (int i = 0; i < assignedOrder.customer.documents.length; ++i) {
      if (assignedOrder.customer.documents[i].userCanView) {
        documents.add(assignedOrder.customer.documents[i]);
      }
    }

    return buildItemsSection(
        'assigned_orders.detail.header_customer_documents'.tr(),
        documents,
        (item) {
          List<Widget> items = [];

          items.add(buildItemListTile('generic.info_name'.tr(), item.name));
          items.add(buildItemListTile('generic.info_description'.tr(), item.description));
          items.add(buildItemListTile('generic.info_document'.tr(), item.file
              .split('/')
              .last));

          return items;
        },
        (item) {
          List<Widget> items = [];

          items.add(Padding(
              padding: EdgeInsets.only(left: 16),
              child: Row(
                  children: [
                    createTableHeaderCell('generic.action_open'.tr()),
                    IconButton(
                      icon: Icon(Icons.view_agenda, color: Colors.green),
                      onPressed: () async {
                        String url = await utils.getUrl(item.url);
                        launchUrl(Uri.parse(url.replaceAll('/api', '')));
                      },
                    )
                  ]
              )
          ));

          return items;
        },
    );
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
    final page = WorkorderPage(assignedorderPk: assignedOrder.id);
    Navigator.push(context,
        MaterialPageRoute(
            builder: (context) => page
        )
    );
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

  _materialsStockPressed(BuildContext context) {
    final page = AssignedOrderMaterialStockPage(assignedOrderPk: assignedOrder.id);
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
      if (assignedOrder.startCodes.length == 0) {
        displayDialog(context,
          'assigned_orders.detail.dialog_no_startcode_title'.tr(),
          'assigned_orders.detail.dialog_no_startcode_content'.tr()
        );

        return SizedBox(height: 1);
      }

      StartCode startCode = assignedOrder.startCodes[0];

      return new Container(
        child: new Column(
          children: <Widget>[
            createElevatedButtonColored(
                startCode.description, () => _startCodePressed(context, startCode)
            )
          ],
        ),
      );
    }

    if (assignedOrder.isStarted) {
      // started, show 'Register time/km', 'Register materials', and 'Manage documents' and 'Finish order'
      ElevatedButton customerHistoryButton = createElevatedButtonColored(
          'assigned_orders.detail.button_customer_history'.tr(),
          () => _customerHistoryPressed(context, assignedOrder.order.customerRelation));
      ElevatedButton activityButton = createElevatedButtonColored(
          'assigned_orders.detail.button_register_time_km'.tr(),
          () => _activityPressed(context));
      ElevatedButton materialsButton = createElevatedButtonColored(
          'assigned_orders.detail.button_register_materials'.tr(),
          () => _materialsPressed(context));
      ElevatedButton materialsStockButton = createElevatedButtonColored(
          'assigned_orders.detail.button_register_materials_stock'.tr(),
              () => _materialsStockPressed(context));
      ElevatedButton documentsButton = createElevatedButtonColored(
          'assigned_orders.detail.button_manage_documents'.tr(),
          () => _documentsPressed(context));


      if (assignedOrder.endCodes.length == 0) {
        displayDialog(context,
            'assigned_orders.detail.dialog_no_endcode_title'.tr(),
            'assigned_orders.detail.dialog_no_endcode_content'.tr()
        );

        return SizedBox(height: 1);
      }

      EndCode endCode = assignedOrder.endCodes[0];

      ElevatedButton finishButton = createElevatedButtonColored(
          endCode.description, () => _endCodePressed(context, endCode));

      ElevatedButton extraWorkButton = createElevatedButtonColored(
          'assigned_orders.detail.button_extra_work'.tr(),
          () => _extraWorkButtonPressed(context),
          foregroundColor: Colors.red,
          backgroundColor: Colors.white
      );
      ElevatedButton signWorkorderButton = createElevatedButtonColored(
          'assigned_orders.detail.button_sign_workorder'.tr(),
          () => _signWorkorderPressed(context),
          foregroundColor: Colors.red,
          backgroundColor: Colors.white
      );
      ElevatedButton noWorkorderButton = createElevatedButtonColored(
          'assigned_orders.detail.button_no_workorder'.tr(),
          () => _noWorkorderPressed(context),
          foregroundColor: Colors.red,
          backgroundColor: Colors.white
      );

      // no ended yet, show a subset of the buttons
      if (!assignedOrder.isEnded) {
        return new Container(
          child: new Column(
            children: <Widget>[
              customerHistoryButton,
              activityButton,
              materialsButton,
              // materialsStockButton,
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
            // materialsStockButton,
            documentsButton,
            Divider(),
            finishButton,
            _showAfterEndButtons(context),
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

  bool _isAfterEndCodeInReports(AfterEndCode code) {
    for (var i=0; i<assignedOrder.afterEndReports.length; i++) {
      if (assignedOrder.afterEndReports[i].statuscodeId == code.id) {
        return true;
      }
    }

    return false;
  }

  String _getAfterEndCodeExtraData(AfterEndCode code) {
    for (var i=0; i<assignedOrder.afterEndReports.length; i++) {
      if (assignedOrder.afterEndReports[i].statuscodeId == code.id) {
        return assignedOrder.afterEndReports[i].extraData;
      }
    }

    return null;
  }

  Widget _showAfterEndButtons(BuildContext context) {
    if (assignedOrder.afterEndCodes.length == 0) {
      return SizedBox(height: 1);
    }

    List<Widget> result = [
      Divider(),
      createHeader('assigned_orders.detail.header_after_end_actions'.tr())
    ];

    for (var i=0; i<assignedOrder.afterEndCodes.length; i++) {
      extraDataTexts[assignedOrder.afterEndCodes[i].id] = TextEditingController();

      if (!_isAfterEndCodeInReports(assignedOrder.afterEndCodes[i])) {
        result.add(
            TextFormField(
                controller: extraDataTexts[assignedOrder.afterEndCodes[i].id],
                keyboardType: TextInputType.multiline,
                maxLines: null,
                validator: (value) {
                  return null;
                },
                decoration: new InputDecoration(
                    labelText: assignedOrder.afterEndCodes[i].description
                )
            )
        );
      } else {
        result.add(
          Text(assignedOrder.afterEndCodes[i].description,
              style: TextStyle(fontWeight: FontWeight.bold))
        );

        result.add(
          Text(_getAfterEndCodeExtraData(assignedOrder.afterEndCodes[i]))
        );
      }

      if (!_isAfterEndCodeInReports(assignedOrder.afterEndCodes[i])) {
        result.add(
            createElevatedButtonColored(
                assignedOrder.afterEndCodes[i].description,
                    () => _afterEndButtonClicked(context, assignedOrder.afterEndCodes[i])
            )
        );
      }
    }

    return Column(
      children: result
    );
  }

  _afterEndButtonClicked(BuildContext context, AfterEndCode code) {
    final bloc = BlocProvider.of<AssignedOrderBloc>(context);
    bloc.add(AssignedOrderEvent(status: AssignedOrderEventStatus.DO_ASYNC));
    bloc.add(AssignedOrderEvent(
        status: AssignedOrderEventStatus.REPORT_AFTER_ENDCODE,
        code: code,
        value: assignedOrder.id,
        extraData: extraDataTexts[code.id].text
    ));
  }

  _showAlsoAssignedSection(AssignedOrder assignedOrder) {
      return buildItemsSection(
        'assigned_orders.detail.header_also_assigned'.tr(),
        assignedOrder.assignedUserData,
        (item) {
          List<Widget> items = [];

          items.add(buildItemListTile('generic.info_name'.tr(), item.fullName));
          items.add(buildItemListTile('generic.info_date'.tr(), item.date));

          return items;
        },
        (item) {
          List<Widget> items = [];
          return items;
        },
        noResultsString: 'assigned_orders.detail.info_no_one_else_assigned'.tr()
      );
  }
}
