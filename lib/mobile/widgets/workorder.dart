import 'dart:ui' as ui;
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_signature_pad/flutter_signature_pad.dart';
// import 'package:flutter_rating_bar/flutter_rating_bar.dart';

import 'package:my24_flutter_core/widgets/widgets.dart';
import 'package:my24_flutter_core/widgets/slivers/base_widgets.dart';

import 'package:my24app/mobile/models/workorder/models.dart';
import 'package:my24app/mobile/models/workorder/form_data.dart';
import 'package:my24app/mobile/models/activity/models.dart';
import 'package:my24app/mobile/blocs/workorder_bloc.dart';
import 'package:my24app/mobile/models/material/models.dart';
import 'package:my24app/core/i18n_mixin.dart';

class WorkorderWidget extends BaseSliverPlainStatelessWidget with i18nMixin {
  final String basePath = "assigned_orders.workorder";
  final AssignedOrderWorkOrderSign? workorderData;
  final int? assignedOrderId;
  final AssignedOrderWorkOrderFormData? formData;
  final String? memberPicture;
  final CoreWidgets widgetsIn;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final Color color = Colors.black;
  final double strokeWidth = 2.0;
  final _signUser = GlobalKey<SignatureState>();
  final _signCustomer = GlobalKey<SignatureState>();

  WorkorderWidget({
    Key? key,
    required this.memberPicture,
    required this.assignedOrderId,
    required this.formData,
    required this.workorderData,
    required this.widgetsIn,
  }) : super(
      key: key,
      mainMemberPicture: memberPicture,
      widgets: widgetsIn
  );

  @override
  Widget getBottomSection(BuildContext context) {
    return SizedBox(height: 1);
  }

  @override
  Widget getContentWidget(BuildContext context) {
    return Container(
        padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
        child: SingleChildScrollView(
          child: Form(
              key: _formKey,
              child: _showMainView(context)
          ),
        )
    );
  }

  @override
  String getAppBarTitle(BuildContext context) {
    return $trans('app_bar_title');
  }

  // private methods
  Widget _showMainView(BuildContext context) {
    return Column(
        children: <Widget>[
          _buildMemberInfoCard(context, workorderData!.member),
          Divider(),
          widgetsIn.createHeader($trans('header_orderinfo')),
          _createWorkOrderInfoSection(),
          Divider(),
          widgetsIn.createHeader($trans('header_activity')),
          _buildWorkorderTable(),
          Divider(),
          widgetsIn.createHeader($trans('header_extra_work')),
          _buildExtraWorkTable(),
          Divider(),
          widgetsIn.createHeader($trans('header_materials')),
          _buildMaterialsTable(),
          Divider(),
          widgetsIn.createHeader($trans('header_equipment')),
          _createTextFieldEquipment(),
          Divider(),
          widgetsIn.createHeader($trans('header_description_work')),
          _createTextFieldDescriptionWork(),
          Divider(),
          widgetsIn.createHeader($trans('header_customer_emails')),
          _createTextFieldCustomerEmails(),
          Divider(),
          widgetsIn.createHeader($trans('header_signature_engineer')),
          TextFormField(
            key: UniqueKey(),
            controller: formData!.signatureUserNameController,
            decoration: InputDecoration(
                labelText: $trans('label_name_engineer')
            ),
            validator: (value) {
              if (value!.isEmpty) {
                return $trans('validator_name_engineer');
              }
              return null;
            },
          ),
          SizedBox(
            height: 10.0,
          ),
          _createSignatureUser(),
          _createButtonsRowUser(context),
          formData!.imgUser!.buffer.lengthInBytes == 0 ? Container() :
            LimitedBox(maxHeight: 200.0, child: Image.memory(formData!.imgUser!.buffer.asUint8List())),
          Divider(),
          widgetsIn.createHeader($trans('header_signature_customer')),
          TextFormField(
            key: UniqueKey(),
            controller: formData!.signatureCustomerNameController,
            decoration: new InputDecoration(
                labelText: $trans('label_name_customer')
            ),
            validator: (value) {
              if (value!.isEmpty) {
                return $trans('validator_name_customer');
              }
              return null;
            },
          ),
          SizedBox(
            height: 10.0,
          ),
          _createSignatureCustomer(),
          _createButtonsRowCustomer(context),
          formData!.imgCustomer!.buffer.lengthInBytes == 0 ? Container() :
            LimitedBox(maxHeight: 200.0, child: Image.memory(formData!.imgCustomer!.buffer.asUint8List())),
          Divider(),
          // widgetsIn.createHeader('assigned_orders.workorder.header_rating'.tr()),
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
          widgetsIn.createDefaultElevatedButton(
              $trans('button_submit_workorder'),
              () { _submitForm(context); }
          )
        ]
    );
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

  Widget _createButtonsRowUser(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        MaterialButton(
            color: Colors.grey,
            onPressed: () {
              final sign = _signUser.currentState!;
              sign.clear();
              formData!.imgUser = ByteData(0);
              _updateFormData(context);
              debugPrint("cleared");
            },
            child: Text($trans('info_clear'))),
      ],
    );
  }

  Widget _createButtonsRowCustomer(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        MaterialButton(
            color: Colors.grey,
            onPressed: () {
              final sign = _signCustomer.currentState!;
              sign.clear();
              formData!.imgCustomer = ByteData(0);
              _updateFormData(context);
              debugPrint("cleared");
            },
            child: Text($trans('info_clear'))),
      ],
    );
  }

  Widget _createTextFieldEquipment() {
    return Container(
        width: 300.0,
        child: TextFormField(
          controller: formData!.equipmentController,
          keyboardType: TextInputType.multiline,
          maxLines: null,
        )
    );
  }

  Widget _createTextFieldDescriptionWork() {
    return Container(
        width: 300.0,
        child: TextFormField(
          controller: formData!.descriptionWorkController,
          keyboardType: TextInputType.multiline,
          maxLines: null,
        )
    );
  }

  Widget _createTextFieldCustomerEmails() {
    return Container(
        width: 300.0,
        child: TextFormField(
          controller: formData!.customerEmailsController,
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

  Widget _buildMemberInfoCard(BuildContext context, member) => Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildLogo(member),
        Flexible(
            child: widgetsIn.buildMemberInfoCard(context, member)
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
                        child: Text($trans('info_service_nummer'),
                            style: TextStyle(fontWeight: FontWeight.bold)
                        ),
                      ),
                      Flexible(
                        child: Container(
                          height: lineHeight,
                          padding: const EdgeInsets.only(left: 8, top: 8, bottom: 8),
                          child: Text('${workorderData!.assignedOrderWorkorderId}'),
                        )
                      ),
                    ],
                  ),
                  Row(
                    children: <Widget>[
                      Container(
                        height: lineHeight,
                        width: leftWidth,
                        padding: const EdgeInsets.all(8),
                        child: Text($trans('info_reference'),
                            style: TextStyle(fontWeight: FontWeight.bold)
                        ),
                      ),
                      Flexible(
                        child: Container(
                          height: lineHeight,
                          padding: const EdgeInsets.only(left: 8, top: 8, bottom: 8),
                          child: Text(workorderData!.order!.orderReference!),
                        )
                      ),
                    ],
                  ),
                  Row(
                    children: <Widget>[
                      Container(
                        height: lineHeight,
                        width: leftWidth,
                        padding: const EdgeInsets.all(8),
                        child: Text($trans('info_customer_id'),
                            style: TextStyle(fontWeight: FontWeight.bold)
                        ),
                      ),
                      Flexible(
                        child: Container(
                          height: lineHeight,
                          padding: const EdgeInsets.only(left: 8, top: 8, bottom: 8),
                          child: Text(workorderData!.order!.customerId!),
                        )
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
                        child: Text($trans('info_customer'),
                            style: TextStyle(fontWeight: FontWeight.bold)
                        ),
                      ),
                      Flexible(
                        child: Container(
                          height: lineHeight,
                          padding: const EdgeInsets.only(left: 8, top: 8, bottom: 8),
                          child: Text(workorderData!.order!.orderName!),
                        )
                      ),
                    ],
                  ),
                  Row(
                    children: <Widget>[
                      Container(
                        height: lineHeight,
                        width: leftWidth,
                        padding: const EdgeInsets.all(8),
                        child: Text($trans('info_address'),
                            style: TextStyle(fontWeight: FontWeight.bold)
                        ),
                      ),
                      Flexible(
                        child: Container(
                          height: lineHeight,
                          padding: const EdgeInsets.only(left: 8, top: 8, bottom: 8),
                          child: Text(workorderData!.order!.orderAddress!),
                        )
                      ),
                    ],
                  ),
                  Row(
                    children: <Widget>[
                      Container(
                        height: lineHeight,
                        width: leftWidth,
                        padding: const EdgeInsets.all(8),
                        child: Text($trans('info_postal'),
                            style: TextStyle(fontWeight: FontWeight.bold)
                        ),
                      ),
                      Flexible(
                        child: Container(
                          height: lineHeight,
                          padding: const EdgeInsets.only(left: 8, top: 8, bottom: 8),
                          child: Text(workorderData!.order!.orderCountryCode! + '-' + workorderData!.order!.orderPostal!),
                        )
                      ),
                    ],
                  ),
                  Row(
                    children: <Widget>[
                      Container(
                        height: lineHeight,
                        width: leftWidth,
                        padding: const EdgeInsets.all(8),
                        child: Text($trans('info_city', pathOverride: 'generic'),
                            style: TextStyle(fontWeight: FontWeight.bold)
                        ),
                      ),
                      Flexible(
                        child: Container(
                          height: lineHeight,
                          padding: const EdgeInsets.only(left: 8, top: 8, bottom: 8),
                          child: Text(workorderData!.order!.orderCity!),
                        )
                      ),
                    ],
                  ),
                  Row(
                    children: <Widget>[
                      Container(
                        height: lineHeight,
                        width: leftWidth,
                        padding: const EdgeInsets.all(8),
                        child: Text($trans('info_order_id'),
                            style: TextStyle(fontWeight: FontWeight.bold)
                        ),
                      ),
                      Flexible(
                        child: Container(
                          height: lineHeight,
                          padding: const EdgeInsets.only(left: 8, top: 8, bottom: 8),
                          child: Text(workorderData!.order!.orderId!),
                        )
                      ),
                    ],
                  ),
                  Row(
                    children: <Widget>[
                      Container(
                        height: lineHeight,
                        width: leftWidth,
                        padding: const EdgeInsets.all(8),
                        child: Text($trans('info_order_type'),
                            style: TextStyle(fontWeight: FontWeight.bold)
                        ),
                      ),
                      Flexible(
                        child: Container(
                          height: lineHeight,
                          padding: const EdgeInsets.only(left: 8, top: 8, bottom: 8),
                          child: Text(workorderData!.order!.orderType!),
                        )
                      ),
                    ],
                  ),
                  Row(
                    children: <Widget>[
                      Container(
                        height: lineHeight,
                        width: leftWidth,
                        padding: const EdgeInsets.all(8),
                        child: Text($trans('info_order_date'),
                            style: TextStyle(fontWeight: FontWeight.bold)
                        ),
                      ),
                      Flexible(
                        child: Container(
                          height: lineHeight,
                          padding: const EdgeInsets.only(left: 8, top: 8, bottom: 8),
                          child: Text(workorderData!.order!.orderDate!),
                        )
                      ),
                    ],
                  ),
                  Row(
                    children: <Widget>[
                      Container(
                        height: lineHeight,
                        width: leftWidth,
                        padding: const EdgeInsets.all(8),
                        child: Text($trans('info_contact'),
                            style: TextStyle(fontWeight: FontWeight.bold)
                        ),
                      ),
                      Flexible(
                        child: Container(
                          height: lineHeight,
                          padding: const EdgeInsets.only(left: 8, top: 8, bottom: 8),
                          child: Text(workorderData!.order!.orderContact?? ''),
                        )
                      ),
                    ],
                  ),
                ]
            )
        )
    );
  }

  Widget _buildWorkorderTable() {
    if(workorderData!.activity!.length == 0) {
      return widgetsIn.buildEmptyListFeedback();
    }

    List<TableRow> rows = [];

    // header
    rows.add(TableRow(
      children: [
        Column(children: [
          widgetsIn.createTableHeaderCell($trans('info_engineer'))
        ]),
        Column(children: [
          widgetsIn.createTableHeaderCell($trans('info_work_start_end'))
        ]),
        Column(children: [
          widgetsIn.createTableHeaderCell($trans('info_travel_to_back'))
        ]),
        Column(children: [
          widgetsIn.createTableHeaderCell($trans('info_distance_to_back'))
        ]),
      ],
    ));

    // activity
    for (int i = 0; i < workorderData!.activity!.length; ++i) {
      AssignedOrderActivity activity = workorderData!.activity![i];

      rows.add(TableRow(children: [
        Column(
            children: [
              widgetsIn.createTableColumnCell(activity.fullName)
            ]
        ),
        Column(
            children: [
              widgetsIn.createTableColumnCell(activity.workStart! + '/' + activity.workEnd!)
            ]
        ),
        Column(
            children: [
              widgetsIn.createTableColumnCell(activity.travelTo! + '/' + activity.travelBack!)
            ]
        ),
        Column(
            children: [
              widgetsIn.createTableColumnCell("${activity.distanceTo}/${activity.distanceBack}")
            ]
        ),
      ]));
    }

    rows.add(TableRow(children: [
      Column(
          children: [
            widgetsIn.createTableHeaderCell($trans('info_totals'))
          ]
      ),
      Column(
          children: [
            widgetsIn.createTableHeaderCell(workorderData!.activityTotals!.workTotal!)
          ]
      ),
      Column(
          children: [
            widgetsIn.createTableHeaderCell('${workorderData!.activityTotals!.travelToTotal}/${workorderData!.activityTotals!.travelBackTotal}')
          ]
      ),
      Column(
          children: [
            widgetsIn.createTableHeaderCell('${workorderData!.activityTotals!.distanceToTotal}/${workorderData!.activityTotals!.distanceBackTotal}')
          ]
      ),
    ]));

    return widgetsIn.createTable(rows);
  }

  Widget _buildExtraWorkTable() {
    if(workorderData!.extraWork!.length == 0) {
      return widgetsIn.buildEmptyListFeedback();
    }

    List<TableRow> rows = [];

    // header
    rows.add(TableRow(
      children: [
        Column(children: [
          widgetsIn.createTableHeaderCell($trans('info_extra_work_description'))
        ]),
        Column(children: [
          widgetsIn.createTableHeaderCell($trans('info_extra_work'))
        ]),
      ],
    ));

    // products
    for (int i = 0; i < workorderData!.extraWork!.length; ++i) {
      AssignedOrderExtraWork extraWork = workorderData!.extraWork![i];

      rows.add(TableRow(children: [
        Column(
            children: [
              widgetsIn.createTableColumnCell('${extraWork.extraWorkDescription}')
            ]
        ),
        Column(
            children: [
              widgetsIn.createTableColumnCell('${extraWork.extraWork}')
            ]
        ),
      ]));
    }

    rows.add(TableRow(children: [
      Column(
          children: [
            widgetsIn.createTableHeaderCell($trans('info_totals'))
          ]
      ),
      Column(
          children: [
            widgetsIn.createTableHeaderCell('${workorderData!.activityTotals!.extraWorkTotal}')
          ]
      ),
    ]));

    return widgetsIn.createTable(rows);
  }

  Widget _buildMaterialsTable() {
    if(workorderData!.materials!.length == 0) {
      return widgetsIn.buildEmptyListFeedback();
    }

    List<TableRow> rows = [];

    // header
    rows.add(TableRow(
      children: [
        Column(children: [
          widgetsIn.createTableHeaderCell($trans('info_material'))
        ]),
        Column(children: [
          widgetsIn.createTableHeaderCell($trans('info_identifier'))
        ]),
        Column(children: [
          widgetsIn.createTableHeaderCell($trans('info_amount'))
        ]),
      ],
    ));

    // products
    for (int i = 0; i < workorderData!.materials!.length; ++i) {
      AssignedOrderMaterial material = workorderData!.materials![i];

      rows.add(TableRow(children: [
        Column(
            children: [
              widgetsIn.createTableColumnCell('${material.materialName}')
            ]
        ),
        Column(
            children: [
              widgetsIn.createTableColumnCell('${material.materialIdentifier}')
            ]
        ),
        Column(
            children: [
              widgetsIn.createTableColumnCell('${material.amount}')
            ]
        ),
      ]));
    }

    return widgetsIn.createTable(rows);
  }

  Future<String> _getUserSignature() async {
    final sign = _signUser.currentState!;
    final image = await sign.getData();
    var data = (await image.toByteData(format: ui.ImageByteFormat.png))!;
    sign.clear();
    final encoded = base64.encode(data.buffer.asUint8List());

    return encoded;
  }

  Future<String> _getCustomerSignature() async {
    final sign = _signCustomer.currentState!;
    final image = await sign.getData();
    var data = (await image.toByteData(format: ui.ImageByteFormat.png))!;
    sign.clear();
    final encoded = base64.encode(data.buffer.asUint8List());

    return encoded;
  }

  Future<void> _submitForm(BuildContext context) async {
    if (this._formKey.currentState!.validate()) {
      this._formKey.currentState!.save();

      formData!.userSignature = await _getUserSignature();
      formData!.customerSignature = await _getCustomerSignature();

      if (!formData!.isValid()) {
        FocusScope.of(context).unfocus();
        return;
      }

      final bloc = BlocProvider.of<WorkorderBloc>(context);
      AssignedOrderWorkOrder newWorkorder = formData!.toModel();
      bloc.add(WorkorderEvent(status: WorkorderEventStatus.DO_ASYNC));
      bloc.add(WorkorderEvent(
          status: WorkorderEventStatus.INSERT,
          workorder: newWorkorder,
          assignedOrderId: newWorkorder.assignedOrderId,
          orderPk: workorderData!.order!.id
      ));
    }
  }

  _updateFormData(BuildContext context) {
    final bloc = BlocProvider.of<WorkorderBloc>(context);
    bloc.add(WorkorderEvent(status: WorkorderEventStatus.DO_ASYNC));
    bloc.add(WorkorderEvent(
        status: WorkorderEventStatus.UPDATE_FORM_DATA,
        formData: formData
    ));
  }
}
