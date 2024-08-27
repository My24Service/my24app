import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my24_flutter_core/utils.dart';
import 'package:my24_flutter_orders/models/document/models.dart';
import 'package:my24_flutter_orders/models/infoline/models.dart';
import 'package:my24_flutter_orders/models/orderline/models.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:my24_flutter_core/widgets/slivers/base_widgets.dart';
import 'package:my24_flutter_core/widgets/widgets.dart';
import 'package:my24_flutter_core/i18n.dart';

import 'package:my24app/customer/models/models.dart';
import 'package:my24app/mobile/pages/activity.dart';
import 'package:my24app/mobile/pages/document.dart';
import 'package:my24app/mobile/pages/material.dart';
import 'package:my24app/mobile/pages/workorder.dart';
import 'package:my24app/common/utils.dart';
import 'package:my24app/mobile/blocs/assignedorder_bloc.dart';
import 'package:my24app/mobile/models/assignedorder/models.dart';
import 'package:my24app/mobile/blocs/activity_bloc.dart';
import 'package:my24app/mobile/blocs/document_bloc.dart';
import 'package:my24app/mobile/blocs/material_bloc.dart';
import 'package:my24app/mobile/blocs/workorder_bloc.dart';
import 'package:my24app/customer/blocs/customer_bloc.dart';
import 'package:my24app/customer/pages/detail.dart';
import 'package:my24app/common/widgets/widgets.dart';

class AssignedWidget extends BaseSliverPlainStatelessWidget{
  final AssignedOrder? assignedOrder;
  final Map<int?, TextEditingController> extraDataTexts = {};
  final String? memberPicture;
  final CoreWidgets widgetsIn;
  final My24i18n i18nIn = My24i18n(basePath: "assigned_orders.detail");

  AssignedWidget({
    Key? key,
    required this.assignedOrder,
    required this.memberPicture,
    required this.widgetsIn,
  }) : super(
      key: key,
      mainMemberPicture: memberPicture,
      widgets: widgetsIn,
      i18n: My24i18n(basePath: "assigned_orders.detail")
  );

  @override
  Widget getBottomSection(BuildContext context) {
    return Column(
      children: [
        widgetsIn.createElevatedButtonColored(
           i18nIn.$trans('button_nav_orders'),
            () => _fetchOrders(context),
            backgroundColor: Colors.grey,
            foregroundColor: Colors.white
        ),
      ],
    );
  }

  @override
  String getAppBarSubtitle(BuildContext context) {
    return "${assignedOrder!.order!.orderName}, ${assignedOrder!.order!.orderCity},"
        " ${assignedOrder!.order!.orderType}, ${assignedOrder!.order!.orderDate}";
  }

  @override
  Widget getContentWidget(BuildContext context) {
    return Column(
      children: [
        buildAssignedOrderInfoCard(context, assignedOrder!, widgetsIn),
        widgetsIn.getMy24Divider(context),
        _showAlsoAssignedSection(context, assignedOrder!),
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
    return widgetsIn.buildItemsSection(
      context,
     i18nIn.$trans('header_orderlines'),
      assignedOrder!.order!.orderLines,
      (Orderline item) {
        String equipmentLocationTitle = "${i18nIn.$trans('info_equipment', pathOverride: 'generic')} / "
            "${i18nIn.$trans('info_location', pathOverride: 'generic')}";
        String equipmentLocationValue = "${item.product} / ${item.location}";
        return <Widget>[
          ...widgetsIn.buildItemListKeyValueList(equipmentLocationTitle, equipmentLocationValue),
          ...widgetsIn.buildItemListKeyValueList(i18nIn.$trans('info_remarks', pathOverride: 'generic'), item.remarks)
        ];
      },
      (item) {
        return <Widget>[];
      },
    );
  }

  // infolines
  Widget _createInfolinesSection(BuildContext context) {
    return widgetsIn.buildItemsSection(
      context,
     i18nIn.$trans('header_infolines'),
      assignedOrder!.order!.infoLines,
      (Infoline item) {
        return widgetsIn.buildItemListKeyValueList(i18nIn.$trans('info_infoline', pathOverride: 'orders'), item.info);
      },
      (item) {
        return <Widget>[];
      },
    );
  }

  // documents
  Widget _buildDocumentsSection(BuildContext context) {
    return widgetsIn.buildItemsSection(
      context,
     i18nIn.$trans('header_documents'),
      assignedOrder!.order!.documents,
      (OrderDocument item) {
        String? value = item.name;
        if (item.description != null && item.description != "") {
          value = "$value (${item.description})";
        }
        return widgetsIn.buildItemListKeyValueList(i18nIn.$trans('info_info', pathOverride: 'generic'), value);
      },
      (item) {
        return <Widget>[
          Padding(
              padding: EdgeInsets.only(left: 16),
              child: Row(
                  children: [
                    widgetsIn.createTableHeaderCell(i18nIn.$trans('action_open', pathOverride: 'generic')),
                    IconButton(
                      icon: Icon(Icons.view_agenda, color: Colors.red),
                      onPressed: () async {
                        String url = await utils.getUrl(item.url);
                        url = url.replaceAll('/api', '');
                        Map<String, dynamic> openResult = await coreUtils.openDocument(url);
                        if (!openResult['result']) {
                          String error =i18nIn.$trans('error_arg', namedArgs: {'error': openResult['message']}, pathOverride: 'generic');
                          widgetsIn.createSnackBar(
                              context, error
                              //
                          );
                        }
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

    for (int i = 0; i < assignedOrder!.customer!.documents!.length; ++i) {
      if (assignedOrder!.customer!.documents![i].userCanView!) {
        documents.add(assignedOrder!.customer!.documents![i]);
      }
    }

    return widgetsIn.buildItemsSection(
        context,
       i18nIn.$trans('header_customer_documents'),
        documents,
        (CustomerDocument item) {
          String? value = item.name;
          if (item.description != null && item.description != "") {
            value = "$value (${item.description})";
          }
          return widgetsIn.buildItemListKeyValueList(i18nIn.$trans('info_info', pathOverride: 'generic'), value);
        },
        (item) {
          return <Widget>[
            Padding(
                padding: EdgeInsets.only(left: 16),
                child: Row(
                    children: [
                      widgetsIn.createTableHeaderCell(i18nIn.$trans('action_open', pathOverride: 'generic')),
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
        pk: assignedOrder!.id
    ));
  }

  _endCodePressed(BuildContext context, EndCode endCode) async {
    final bloc = BlocProvider.of<AssignedOrderBloc>(context);
    bloc.add(AssignedOrderEvent(status: AssignedOrderEventStatus.DO_ASYNC));
    bloc.add(AssignedOrderEvent(
        status: AssignedOrderEventStatus.REPORT_ENDCODE,
        code: endCode,
        pk: assignedOrder!.id
    ));
  }

  _extraWorkButtonPressed(BuildContext context) {
    // set up the buttons
    Widget cancelButton = TextButton(
        child: Text(i18nIn.$trans('action_cancel', pathOverride: 'generic')),
        onPressed: () => Navigator.pop(context, false)
    );
    Widget deleteButton = TextButton(
        child: Text(i18nIn.$trans('button_create_extra_order')),
        onPressed: () => Navigator.pop(context, true)
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text(i18nIn.$trans('dialog_extra_order_title')),
      content: Text(i18nIn.$trans('dialog_extra_order_content')),
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
            pk: assignedOrder!.id
        ));
      }
    });
  }

  _signWorkorderPressed(BuildContext context) {
    final page = WorkorderPage(
      assignedOrderId: assignedOrder!.id,
      bloc: WorkorderBloc()
    );

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
        pk: assignedOrder!.id
    ));
  }

  _customerHistoryPressed(BuildContext context, int? customerPk) {
    final page = CustomerDetailPage(
      pk: customerPk,
      bloc: CustomerBloc(),
      isEngineer: true,
    );

    Navigator.push(context,
        MaterialPageRoute(
            builder: (context) => page
        )
    );
  }

  _activityPressed(BuildContext context) {
    final page = AssignedOrderActivityPage(
        assignedOrderId: assignedOrder!.id,
        bloc: ActivityBloc(),
    );
    Navigator.push(context,
        MaterialPageRoute(
            builder: (context) => page
        )
    );
  }

  _materialsPressed(BuildContext context) {
    final page = AssignedOrderMaterialPage(
        assignedOrderId: assignedOrder!.id,
        quotationId: assignedOrder!.quotationId,
        bloc: AssignedOrderMaterialBloc()
    );
    Navigator.push(context,
        MaterialPageRoute(
            builder: (context) => page
        )
    );
  }

  _documentsPressed(BuildContext context) {
    final page = DocumentPage(
        assignedOrderId: assignedOrder!.id,
        bloc: DocumentBloc()
    );
    Navigator.push(context,
        MaterialPageRoute(
            builder: (context) => page
        )
    );
  }

  Widget _buildButtons(BuildContext context) {
    // if not started, only show first startCode as a button
    if (!assignedOrder!.isStarted!) {
      if (assignedOrder!.startCodes!.length == 0) {
        widgetsIn.displayDialog(context,
         i18nIn.$trans('dialog_no_startcode_title'),
         i18nIn.$trans('dialog_no_startcode_content')
        );

        return SizedBox(height: 1);
      }

      StartCode startCode = assignedOrder!.startCodes![0];
      final String text = startCode.statuscode!;

      return new Container(
        child: new Column(
          children: <Widget>[
            widgetsIn.createElevatedButtonColored(
                text, () => _startCodePressed(context, startCode)
            )
          ],
        ),
      );
    }

    if (assignedOrder!.isStarted!) {
      // started, show 'Register time/km', 'Register materials', and 'Manage documents' and 'Finish order'
      ElevatedButton customerHistoryButton = widgetsIn.createElevatedButtonColored(
         i18nIn.$trans('button_customer_history'),
          () => _customerHistoryPressed(context, assignedOrder!.order!.customerRelation));
      ElevatedButton activityButton = widgetsIn.createElevatedButtonColored(
         i18nIn.$trans('button_register_time_km'),
          () => _activityPressed(context));
      ElevatedButton materialsButton = widgetsIn.createElevatedButtonColored(
         i18nIn.$trans('button_register_materials'),
          () => _materialsPressed(context));
      ElevatedButton documentsButton = widgetsIn.createElevatedButtonColored(
         i18nIn.$trans('button_manage_documents'),
          () => _documentsPressed(context));


      if (assignedOrder!.endCodes!.length == 0) {
        widgetsIn.displayDialog(context,
           i18nIn.$trans('dialog_no_endcode_title'),
           i18nIn.$trans('dialog_no_endcode_content')
        );

        return SizedBox(height: 1);
      }

      EndCode endCode = assignedOrder!.endCodes![0];

      ElevatedButton finishButton = widgetsIn.createElevatedButtonColored(
          endCode.statuscode!, () => _endCodePressed(context, endCode));

      ElevatedButton extraWorkButton = widgetsIn.createElevatedButtonColored(
         i18nIn.$trans('button_extra_work'),
          () => _extraWorkButtonPressed(context),
          foregroundColor: Colors.red,
          backgroundColor: Colors.white
      );
      ElevatedButton signWorkorderButton = widgetsIn.createElevatedButtonColored(
         i18nIn.$trans('button_sign_workorder'),
          () => _signWorkorderPressed(context),
          foregroundColor: Colors.red,
          backgroundColor: Colors.white
      );
      ElevatedButton noWorkorderButton = widgetsIn.createElevatedButtonColored(
         i18nIn.$trans('button_no_workorder'),
          () => _noWorkorderPressed(context),
          foregroundColor: Colors.red,
          backgroundColor: Colors.white
      );

      // no ended yet, show a subset of the buttons
      if (!assignedOrder!.isEnded!) {
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

    return SizedBox(height: 1);
  }

  bool _isAfterEndCodeInReports(AfterEndCode code) {
    for (var i=0; i<assignedOrder!.afterEndReports!.length; i++) {
      if (assignedOrder!.afterEndReports![i].statuscodeId == code.id) {
        return true;
      }
    }

    return false;
  }

  String? _getAfterEndCodeExtraData(AfterEndCode code) {
    for (var i=0; i<assignedOrder!.afterEndReports!.length; i++) {
      if (assignedOrder!.afterEndReports![i].statuscodeId == code.id) {
        return assignedOrder!.afterEndReports![i].extraData;
      }
    }

    return null;
  }

  Widget _showAfterEndButtons(BuildContext context) {
    if (assignedOrder!.afterEndCodes!.length == 0) {
      return SizedBox(height: 1);
    }

    List<Widget> result = [
      Divider(),
      widgetsIn.createHeader(i18nIn.$trans('header_after_end_actions'))
    ];

    for (var i=0; i<assignedOrder!.afterEndCodes!.length; i++) {
      extraDataTexts[assignedOrder!.afterEndCodes![i].id] = TextEditingController();
      final String text = assignedOrder!.afterEndCodes![i].statuscode!;

      if (!_isAfterEndCodeInReports(assignedOrder!.afterEndCodes![i])) {
        result.add(
            TextFormField(
                controller: extraDataTexts[assignedOrder!.afterEndCodes![i].id],
                keyboardType: TextInputType.multiline,
                maxLines: null,
                validator: (value) {
                  return null;
                },
                decoration: new InputDecoration(
                    labelText: text
                )
            )
        );
      } else {
        result.add(
          Text(text, style: TextStyle(fontWeight: FontWeight.bold))
        );

        result.add(
          Text(_getAfterEndCodeExtraData(assignedOrder!.afterEndCodes![i])!)
        );
      }

      if (!_isAfterEndCodeInReports(assignedOrder!.afterEndCodes![i])) {
        result.add(
            widgetsIn.createElevatedButtonColored(
              text,
              () => _afterEndButtonClicked(context, assignedOrder!.afterEndCodes![i])
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
        pk: assignedOrder!.id,
        extraData: extraDataTexts[code.id]!.text
    ));
  }

  _showAlsoAssignedSection(BuildContext context, AssignedOrder assignedOrder) {
      return widgetsIn.buildItemsSection(
        context,
       i18nIn.$trans('header_also_assigned'),
        assignedOrder.assignedUserData,
        (AssignedUserdata item) {
          String key = "${i18nIn.$trans('info_name', pathOverride: 'generic')} / "
              "${i18nIn.$trans('info_date', pathOverride: 'generic')}";
          String value = "${item.fullName} / ${item.date}";
          return widgetsIn.buildItemListKeyValueList(key, value);
        },
        (item) {
          return <Widget>[];
        },
        noResultsString:i18nIn.$trans('info_no_one_else_assigned')
      );
  }

  _fetchOrders(BuildContext context) {
    final bloc = BlocProvider.of<AssignedOrderBloc>(context);

    bloc.add(AssignedOrderEvent(status: AssignedOrderEventStatus.DO_ASYNC));
    bloc.add(AssignedOrderEvent(
        status: AssignedOrderEventStatus.FETCH_ALL
    ));
  }
}
