import 'dart:ui' as ui;
import 'dart:convert';
import 'dart:typed_data';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_signature_pad/flutter_signature_pad.dart';
// import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

import 'package:my24app/core/widgets/widgets.dart';
import 'package:my24app/mobile/models/models.dart';
// import 'package:my24app/company/api/company_api.dart';
import 'package:my24app/mobile/api/mobile_api.dart';
import 'package:my24app/mobile/pages/assigned_list.dart';

import '../../order/api/order_api.dart';


class WorkorderWidget extends StatefulWidget {
  final AssignedOrderWorkOrderSign workorderData;
  final int assignedOrderPk;

  WorkorderWidget({
    Key key,
    this.workorderData,
    this.assignedOrderPk
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => new _WorkorderWidgetState(
    workorderData: workorderData,
    assignedOrderPk: assignedOrderPk,
  );
}

class _WorkorderWidgetState extends State<WorkorderWidget> {
  final AssignedOrderWorkOrderSign workorderData;
  final int assignedOrderPk;

  _WorkorderWidgetState({
    @required this.workorderData,
    @required this.assignedOrderPk,
  }) : super();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  ByteData _imgUser = ByteData(0);
  ByteData _imgCustomer = ByteData(0);
  var color = Colors.black;
  var strokeWidth = 2.0;
  final _signUser = GlobalKey<SignatureState>();
  final _signCustomer = GlobalKey<SignatureState>();
  var _equimentController = TextEditingController();
  var _descriptionWorkController = TextEditingController();
  var _customerEmailsController = TextEditingController();
  var _signatureUserNameInput = TextEditingController();
  var _signatureCustomerNameInput = TextEditingController();
  // double _rating;
  bool _inAsyncCall = false;

  @override
  Widget build(BuildContext context) {
    return ModalProgressHUD(
        child: Container(
            padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
            child: SingleChildScrollView(
              child: Form(
                  key: _formKey,
                  child: _showMainView()
              ),
            )
        ), inAsyncCall: _inAsyncCall);
  }

  Widget _showMainView() {
    return Column(
        children: <Widget>[
          _buildMemberInfoCard(workorderData.member),
          Divider(),
          createHeader('assigned_orders.workorder.header_orderinfo'.tr()),
          _createWorkOrderInfoSection(),
          Divider(),
          createHeader('assigned_orders.workorder.header_activity'.tr()),
          _buildActivityTable(),
          Divider(),
          createHeader('assigned_orders.workorder.header_extra_work'.tr()),
          _buildExtraWorkTable(),
          Divider(),
          createHeader('assigned_orders.workorder.header_materials'.tr()),
          _buildMaterialsTable(),
          Divider(),
          createHeader('assigned_orders.workorder.header_equipment'.tr()),
          _createTextFieldEquipment(),
          Divider(),
          createHeader('assigned_orders.workorder.header_description_work'.tr()),
          _createTextFieldDescriptionWork(),
          Divider(),
          createHeader('assigned_orders.workorder.header_customer_emails'.tr()),
          _createTextFieldCustomerEmails(),
          Divider(),
          createHeader('assigned_orders.workorder.header_signature_engineer'.tr()),
          TextFormField(
            controller: _signatureUserNameInput,
            decoration: InputDecoration(
                labelText: 'assigned_orders.workorder.label_name_engineer'.tr()
            ),
            validator: (value) {
              if (value.isEmpty) {
                return 'assigned_orders.workorder.validator_name_engineer'.tr();
              }
              return null;
            },
          ),
          SizedBox(
            height: 10.0,
          ),
          _createSignatureUser(),
          _createButtonsRowUser(),
          _imgUser.buffer.lengthInBytes == 0 ? Container() : LimitedBox(maxHeight: 200.0, child: Image.memory(_imgUser.buffer.asUint8List())),
          Divider(),
          createHeader('assigned_orders.workorder.header_signature_customer'.tr()),
          TextFormField(
            controller: _signatureCustomerNameInput,
            decoration: new InputDecoration(
                labelText: 'assigned_orders.workorder.label_name_customer'.tr()
            ),
            validator: (value) {
              if (value.isEmpty) {
                return 'assigned_orders.workorder.validator_name_customer'.tr();
              }
              return null;
            },
          ),
          SizedBox(
            height: 10.0,
          ),
          _createSignatureCustomer(),
          _createButtonsRowCustomer(),
          _imgCustomer.buffer.lengthInBytes == 0 ? Container() : LimitedBox(maxHeight: 200.0, child: Image.memory(_imgCustomer.buffer.asUint8List())),
          Divider(),
          // createHeader('assigned_orders.workorder.header_rating'.tr()),
          // RatingBar(
          //   initialRating: 3,
          //   minRating: 1,
          //   direction: Axis.horizontal,
          //   allowHalfRating: true,
          //   itemCount: 5,
          //   itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
          //   ratingWidget: RatingWidget(
          //     full: _image('assets/heart.png'),
          //     half: _image('assets/heart_half.png'),
          //     empty: _image('assets/heart_border.png'),
          //   ),
          //   onRatingUpdate: (rating) {
          //     _rating = rating;
          //   },
          // ),
          SizedBox(
            height: 10.0,
          ),
          createDefaultElevatedButton(
              'assigned_orders.workorder.button_submit_workorder'.tr(),
              _handleSubmit
          )
        ]
    );
  }

  Future<void> _handleSubmit() async {
    if (this._formKey.currentState.validate()) {
      this._formKey.currentState.save();

      String userSignature = await _getUserSignature();
      String customerSignature = await _getCustomerSignature();

      // store workorder
      AssignedOrderWorkOrder workOrder = AssignedOrderWorkOrder(
        assignedOrderWorkorderId: workorderData.assignedOrderWorkorderId,
        descriptionWork: _descriptionWorkController.text,
        equipment: _equimentController.text,
        signatureUser: userSignature,
        signatureCustomer: customerSignature,
        signatureNameUser: _signatureUserNameInput.text,
        signatureNameCustomer: _signatureCustomerNameInput.text,
        customerEmails: _customerEmailsController.text,
      );

      setState(() {
        _inAsyncCall = true;
      });

      final AssignedOrderWorkOrder newWorkOrder = await mobileApi.insertAssignedOrderWorkOrder(workOrder, assignedOrderPk);

      if (newWorkOrder == null) {
        displayDialog(context,
            'generic.error_dialog_title'.tr(),
            'assigned_orders.workorder.error_creating_dialog_content'.tr()
        );

        setState(() {
          _inAsyncCall = false;
        });

        return;
      }

      createSnackBar(context,
          'assigned_orders.workorder.snackbar_created'.tr());

      // create workorder in the background
      final bool workorderCreateResult = await orderApi.createWorkorder(workorderData.order.id, assignedOrderPk);

      if (workorderCreateResult == false) {
        displayDialog(context,
            'generic.error_dialog_title'.tr(),
            'assigned_orders.workorder.error_creating_workorder_dialog_content'.tr()
        );

        setState(() {
          _inAsyncCall = false;
        });

        return;
      }

      createSnackBar(context,
          'assigned_orders.workorder.snackbar_workorder_created'.tr());

      setState(() {
        _inAsyncCall = false;
      });

      // wait 1 second
      await Future.delayed(Duration(seconds: 1));

      // go to assigned order list
      Navigator.pushReplacement(context,
          MaterialPageRoute(
              builder: (context) => AssignedOrderListPage()
          )
      );
    }
  }

  Widget _createSignatureUser() {
    return Container(
      width: 300,
      height: 100,
      child: Signature(
        color: color,
        key: _signUser,
        onSign: () {
        },
        strokeWidth: strokeWidth,
      ),
      color: Colors.black12,
    );
  }

  Widget _createSignatureCustomer() {
    return Container(
      width: 300,
      height: 100,
      child: Signature(
        color: color,
        key: _signCustomer,
        onSign: () {
        },
        strokeWidth: strokeWidth,
      ),
      color: Colors.black12,
    );
  }

  Widget _createButtonsRowUser() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        MaterialButton(
            color: Colors.grey,
            onPressed: () {
              final sign = _signUser.currentState;
              sign.clear();
              setState(() {
                _imgUser = ByteData(0);
              });
              debugPrint("cleared");
            },
            child: Text('assigned_orders.workorder.info_clear'.tr())),
      ],
    );
  }

  Widget _createButtonsRowCustomer() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        MaterialButton(
            color: Colors.grey,
            onPressed: () {
              final sign = _signCustomer.currentState;
              sign.clear();
              setState(() {
                _imgCustomer = ByteData(0);
              });
              debugPrint("cleared");
            },
            child: Text('assigned_orders.workorder.info_clear'.tr())),
      ],
    );
  }

  Widget _createTextFieldEquipment() {
    return Container(
        width: 300.0,
        child: TextFormField(
          controller: _equimentController,
          keyboardType: TextInputType.multiline,
          maxLines: null,
        )
    );
  }

  Widget _createTextFieldDescriptionWork() {
    return Container(
        width: 300.0,
        child: TextFormField(
          controller: _descriptionWorkController,
          keyboardType: TextInputType.multiline,
          maxLines: null,
        )
    );
  }

  Widget _createTextFieldCustomerEmails() {
    return Container(
        width: 300.0,
        child: TextFormField(
          controller: _customerEmailsController,
          keyboardType: TextInputType.multiline,
          maxLines: null,
        )
    );
  }

  Widget _buildLogo(member) => SizedBox(
      width: 100,
      height: 100,
      child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.network(member.companylogoUrl,
                cacheWidth: 100),
          ]
      )
  );

  Widget _buildMemberInfoCard(member) => Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildLogo(member),
        Flexible(
            child: buildMemberInfoCard(context, member)
        ),
      ]
  );

  Widget _createWorkOrderInfoSection() {
    double lineHeight = 35;
    double leftWidth = 160;

    return Container(
        child: Align(
            alignment: Alignment.topRight,
            child: Column(
                children: [
                  Row(
                    children: <Widget>[
                      Container(
                        height: lineHeight,
                        width: leftWidth,
                        padding: const EdgeInsets.all(8),
                        child: Text('assigned_orders.workorder.info_service_nummer'.tr(),
                            style: TextStyle(fontWeight: FontWeight.bold)
                        ),
                      ),
                      Container(
                        height: lineHeight,
                        padding: const EdgeInsets.all(8),
                        child: Text('${workorderData.assignedOrderWorkorderId}'),
                      ),
                    ],
                  ),
                  Row(
                    children: <Widget>[
                      Container(
                        height: lineHeight,
                        width: leftWidth,
                        padding: const EdgeInsets.all(8),
                        child: Text('assigned_orders.workorder.info_reference'.tr(),
                            style: TextStyle(fontWeight: FontWeight.bold)
                        ),
                      ),
                      Container(
                        height: lineHeight,
                        padding: const EdgeInsets.all(8),
                        child: Text(workorderData.order.orderReference),
                      ),
                    ],
                  ),
                  Row(
                    children: <Widget>[
                      Container(
                        height: lineHeight,
                        width: leftWidth,
                        padding: const EdgeInsets.all(8),
                        child: Text('assigned_orders.workorder.info_customer_id'.tr(),
                            style: TextStyle(fontWeight: FontWeight.bold)
                        ),
                      ),
                      Container(
                        height: lineHeight,
                        padding: const EdgeInsets.all(8),
                        child: Text(workorderData.order.customerId),
                      ),
                    ],
                  ),
                  Divider(),
                  Row(
                    children: <Widget>[
                      Container(
                        height: lineHeight,
                        width: leftWidth,
                        padding: const EdgeInsets.all(8),
                        child: Text('assigned_orders.workorder.info_customer'.tr(),
                            style: TextStyle(fontWeight: FontWeight.bold)
                        ),
                      ),
                      Container(
                        height: lineHeight,
                        padding: const EdgeInsets.all(8),
                        child: Text(workorderData.order.orderName),
                      ),
                    ],
                  ),
                  Row(
                    children: <Widget>[
                      Container(
                        height: lineHeight,
                        width: leftWidth,
                        padding: const EdgeInsets.all(8),
                        child: Text('assigned_orders.workorder.info_address'.tr(),
                            style: TextStyle(fontWeight: FontWeight.bold)
                        ),
                      ),
                      Container(
                        height: lineHeight,
                        padding: const EdgeInsets.all(8),
                        child: Text(workorderData.order.orderAddress),
                      ),
                    ],
                  ),
                  Row(
                    children: <Widget>[
                      Container(
                        height: lineHeight,
                        width: leftWidth,
                        padding: const EdgeInsets.all(8),
                        child: Text('assigned_orders.workorder.info_postal'.tr(),
                            style: TextStyle(fontWeight: FontWeight.bold)
                        ),
                      ),
                      Container(
                        height: lineHeight,
                        padding: const EdgeInsets.all(8),
                        child: Text(workorderData.order.orderPostal),
                      ),
                    ],
                  ),
                  Row(
                    children: <Widget>[
                      Container(
                        height: lineHeight,
                        width: leftWidth,
                        padding: const EdgeInsets.all(8),
                        child: Text('assigned_orders.workorder.info_country_city'.tr(),
                            style: TextStyle(fontWeight: FontWeight.bold)
                        ),
                      ),
                      Container(
                        height: lineHeight,
                        padding: const EdgeInsets.all(8),
                        child: Text(workorderData.order.orderCountryCode + '/' + workorderData.order.orderCity),
                      ),
                    ],
                  ),
                  Row(
                    children: <Widget>[
                      Container(
                        height: lineHeight,
                        width: leftWidth,
                        padding: const EdgeInsets.all(8),
                        child: Text('assigned_orders.workorder.info_order_id'.tr(),
                            style: TextStyle(fontWeight: FontWeight.bold)
                        ),
                      ),
                      Container(
                        height: lineHeight,
                        padding: const EdgeInsets.all(8),
                        child: Text(workorderData.order.orderId),
                      ),
                    ],
                  ),
                  Row(
                    children: <Widget>[
                      Container(
                        height: lineHeight,
                        width: leftWidth,
                        padding: const EdgeInsets.all(8),
                        child: Text('assigned_orders.workorder.info_order_type'.tr(),
                            style: TextStyle(fontWeight: FontWeight.bold)
                        ),
                      ),
                      Container(
                        height: lineHeight,
                        padding: const EdgeInsets.all(8),
                        child: Text(workorderData.order.orderType),
                      ),
                    ],
                  ),
                  Row(
                    children: <Widget>[
                      Container(
                        height: lineHeight,
                        width: leftWidth,
                        padding: const EdgeInsets.all(8),
                        child: Text('assigned_orders.workorder.info_order_date'.tr(),
                            style: TextStyle(fontWeight: FontWeight.bold)
                        ),
                      ),
                      Container(
                        height: lineHeight,
                        padding: const EdgeInsets.all(8),
                        child: Text(workorderData.order.orderDate),
                      ),
                    ],
                  ),
                  Row(
                    children: <Widget>[
                      Container(
                        height: lineHeight,
                        width: leftWidth,
                        padding: const EdgeInsets.all(8),
                        child: Text('assigned_orders.workorder.info_contact'.tr(),
                            style: TextStyle(fontWeight: FontWeight.bold)
                        ),
                      ),
                      Container(
                        height: lineHeight,
                        padding: const EdgeInsets.all(8),
                        child: Text(workorderData.order.orderContact?? ''),
                      ),
                    ],
                  ),
                ]
            )
        )
    );
  }

  Widget _buildActivityTable() {
    if(workorderData.activity.length == 0) {
      return buildEmptyListFeedback();
    }

    List<TableRow> rows = [];

    // header
    rows.add(TableRow(
      children: [
        Column(children: [
          createTableHeaderCell('assigned_orders.workorder.info_engineer'.tr())
        ]),
        Column(children: [
          createTableHeaderCell('assigned_orders.workorder.info_work_start_end'.tr())
        ]),
        Column(children: [
          createTableHeaderCell('assigned_orders.workorder.info_travel_to_back'.tr())
        ]),
        Column(children: [
          createTableHeaderCell('assigned_orders.workorder.info_distance_to_back'.tr())
        ]),
      ],
    ));

    // activity
    for (int i = 0; i < workorderData.activity.length; ++i) {
      AssignedOrderActivity activity = workorderData.activity[i];

      rows.add(TableRow(children: [
        Column(
            children: [
              createTableColumnCell(activity.fullName)
            ]
        ),
        Column(
            children: [
              createTableColumnCell(activity.workStart + '/' + activity.workEnd)
            ]
        ),
        Column(
            children: [
              createTableColumnCell(activity.travelTo + '/' + activity.travelBack)
            ]
        ),
        Column(
            children: [
              createTableColumnCell("${activity.distanceTo}/${activity.distanceBack}")
            ]
        ),
      ]));
    }

    rows.add(TableRow(children: [
      Column(
          children: [
            createTableHeaderCell('assigned_orders.workorder.info_totals'.tr())
          ]
      ),
      Column(
          children: [
            createTableHeaderCell(workorderData.activityTotals.workTotal)
          ]
      ),
      Column(
          children: [
            createTableHeaderCell('${workorderData.activityTotals.travelToTotal}/${workorderData.activityTotals.travelBackTotal}')
          ]
      ),
      Column(
          children: [
            createTableHeaderCell('${workorderData.activityTotals.distanceToTotal}/${workorderData.activityTotals.distanceBackTotal}')
          ]
      ),
    ]));

    return createTable(rows);
  }

  Widget _buildExtraWorkTable() {
    if(workorderData.extraWork.length == 0) {
      return buildEmptyListFeedback();
    }

    List<TableRow> rows = [];

    // header
    rows.add(TableRow(
      children: [
        Column(children: [
          createTableHeaderCell('assigned_orders.workorder.info_extra_work_description'.tr())
        ]),
        Column(children: [
          createTableHeaderCell('assigned_orders.workorder.info_extra_work'.tr())
        ]),
      ],
    ));

    // products
    for (int i = 0; i < workorderData.extraWork.length; ++i) {
      AssignedOrderExtraWork extraWork = workorderData.extraWork[i];

      rows.add(TableRow(children: [
        Column(
            children: [
              createTableColumnCell('${extraWork.extraWorkDescription}')
            ]
        ),
        Column(
            children: [
              createTableColumnCell('${extraWork.extraWork}')
            ]
        ),
      ]));
    }

    rows.add(TableRow(children: [
      Column(
          children: [
            createTableHeaderCell('assigned_orders.workorder.info_totals'.tr())
          ]
      ),
      Column(
          children: [
            createTableHeaderCell('${workorderData.extraWorkTotals.extraWork}')
          ]
      ),
    ]));

    return createTable(rows);
  }

  Widget _buildMaterialsTable() {
    if(workorderData.materials.length == 0) {
      return buildEmptyListFeedback();
    }

    List<TableRow> rows = [];

    // header
    rows.add(TableRow(
      children: [
        Column(children: [
          createTableHeaderCell('assigned_orders.workorder.info_material'.tr())
        ]),
        Column(children: [
          createTableHeaderCell('assigned_orders.workorder.info_identifier'.tr())
        ]),
        Column(children: [
          createTableHeaderCell('assigned_orders.workorder.info_amount'.tr())
        ]),
      ],
    ));

    // products
    for (int i = 0; i < workorderData.materials.length; ++i) {
      AssignedOrderMaterial material = workorderData.materials[i];

      rows.add(TableRow(children: [
        Column(
            children: [
              createTableColumnCell('${material.materialName}')
            ]
        ),
        Column(
            children: [
              createTableColumnCell('${material.materialIdentifier}')
            ]
        ),
        Column(
            children: [
              createTableColumnCell('${material.amount}')
            ]
        ),
      ]));
    }

    return createTable(rows);
  }

  Future<String> _getUserSignature() async {
    final sign = _signUser.currentState;
    final image = await sign.getData();
    var data = await image.toByteData(format: ui.ImageByteFormat.png);
    sign.clear();
    final encoded = base64.encode(data.buffer.asUint8List());

    return encoded;
  }

  Future<String> _getCustomerSignature() async {
    final sign = _signCustomer.currentState;
    final image = await sign.getData();
    var data = await image.toByteData(format: ui.ImageByteFormat.png);
    sign.clear();
    final encoded = base64.encode(data.buffer.asUint8List());

    return encoded;
  }

  Widget _image(String asset) {
    return Image.asset(
      asset,
      height: 30.0,
      width: 30.0,
      color: Color.fromARGB(255, 255, 153, 51),
    );
  }

}
