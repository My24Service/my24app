import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:my24app/customer/models/models.dart';
import 'package:my24app/mobile/pages/activity.dart';
import 'package:my24app/mobile/pages/customer_history.dart';
import 'package:my24app/mobile/pages/document.dart';
import 'package:my24app/mobile/pages/material.dart';
import 'package:my24app/mobile/pages/workorder.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:my24app/core/widgets/slivers/base_widgets.dart';
import 'package:my24app/core/widgets/slivers/app_bars.dart';
import 'package:my24app/core/widgets/widgets.dart';
import 'package:my24app/core/utils.dart';
import 'package:my24app/mobile/blocs/assignedorder_bloc.dart';
import 'package:my24app/mobile/models/models.dart';
import 'package:my24app/order/models/models.dart';


class AssignedWidget extends BaseSliverPlainStatelessWidget {
  final AssignedOrder assignedOrder;
  final Map<int, TextEditingController> extraDataTexts = {};

  AssignedWidget({
    Key key,
    @required this.assignedOrder,
  }) : super(key: key);


  @override
  Widget getBottomSection(BuildContext context) {
    return SizedBox(height: 1);
  }

  @override
  void doRefresh(BuildContext context) {
  }

  @override
  String getAppBarSubtitle(BuildContext context) {
    return "${assignedOrder.order.orderName}, ${assignedOrder.order.orderCity},"
        " ${assignedOrder.order.orderType}, ${assignedOrder.order.orderDate}";
  }

  @override
  String getAppBarTitle(BuildContext context) {
    return 'assigned_orders.detail.app_bar_title'.tr();
  }

  @override
  Widget getContentWidget(BuildContext context) {
    return Column(
      children: [
        buildAssignedOrderInfoCard(context, assignedOrder),
        getMy24Divider(context),
        _showAlsoAssignedSection(context, assignedOrder),
        _createOrderlinesSection(context),
        _createInfolinesSection(context),
        _buildDocumentsSection(context),
        _buildCustomerDocumentsSection(context),
        _buildButtons(context)
      ],
    );
  }

  // orderlines
  Widget _createOrderlinesSection(BuildContext context) {
    return buildItemsSection(
      context,
      'assigned_orders.detail.header_orderlines'.tr(),
      assignedOrder.order.orderLines,
      (Orderline item) {
        String equipmentLocationTitle = "${'generic.info_equipment'.tr()} / ${'generic.info_location'.tr()}";
        String equipmentLocationValue = "${item.product} / ${item.location}";
        return <Widget>[
          ...buildItemListKeyValueList(equipmentLocationTitle, equipmentLocationValue),
          ...buildItemListKeyValueList('generic.info_remarks'.tr(), item.remarks)
        ];
      },
      (item) {
        return <Widget>[];
      },
    );
  }

  // infolines
  Widget _createInfolinesSection(BuildContext context) {
    return buildItemsSection(
      context,
      'assigned_orders.detail.header_infolines'.tr(),
      assignedOrder.order.infoLines,
      (Infoline item) {
        return buildItemListKeyValueList('orders.info_infoline'.tr(), item.info);
      },
      (item) {
        return <Widget>[];
      },
    );
  }

  // documents
  Widget _buildDocumentsSection(BuildContext context) {
    return buildItemsSection(
      context,
      'assigned_orders.detail.header_documents'.tr(),
      assignedOrder.order.documents,
      (OrderDocument item) {
        String value = item.name;
        if (item.description != null && item.description != "") {
          value = "$value (${item.description})";
        }
        return buildItemListKeyValueList('generic.info_info'.tr(), value);
      },
      (item) {
        return <Widget>[
          Padding(
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
          )
        ];
      },
    );
  }

  // customer documents
  Widget _buildCustomerDocumentsSection(BuildContext context) {
    // filter out documents that can't be viewed by users
    List <CustomerDocument> documents= [];

    for (int i = 0; i < assignedOrder.customer.documents.length; ++i) {
      if (assignedOrder.customer.documents[i].userCanView) {
        documents.add(assignedOrder.customer.documents[i]);
      }
    }

    return buildItemsSection(
        context,
        'assigned_orders.detail.header_customer_documents'.tr(),
        documents,
        (CustomerDocument item) {
          String value = item.name;
          if (item.description != null && item.description != "") {
            value = "$value (${item.description})";
          }
          return buildItemListKeyValueList('generic.info_info'.tr(), value);
        },
        (item) {
          return <Widget>[
            Padding(
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
            )
          ];
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
    final page = AssignedOrderActivityPage(assignedOrderId: assignedOrder.id);
    Navigator.push(context,
        MaterialPageRoute(
            builder: (context) => page
        )
    );
  }

  _materialsPressed(BuildContext context) {
    final page = AssignedOrderMaterialPage(assignedOrderId: assignedOrder.id);
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

  _showAlsoAssignedSection(BuildContext context, AssignedOrder assignedOrder) {
      return buildItemsSection(
        context,
        'assigned_orders.detail.header_also_assigned'.tr(),
        assignedOrder.assignedUserData,
        (AssignedUserdata item) {
          String key = "${'generic.info_name'.tr()} / ${'generic.info_date'.tr()}";
          String value = "${item.fullName} / ${item.date}";
          return buildItemListKeyValueList(key, value);
        },
        (item) {
          return <Widget>[];
        },
        noResultsString: 'assigned_orders.detail.info_no_one_else_assigned'.tr()
      );
  }
}
