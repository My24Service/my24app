import 'dart:ui' as ui;
import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:easy_localization/easy_localization.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_signature_pad/flutter_signature_pad.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'utils.dart';
import 'models.dart';
import 'assignedorders_list.dart';


Future<AssignedOrderWorkOrderSign> fetchAssignedOrderWorkOrderSign(http.Client client) async {
  SlidingToken newToken = await refreshSlidingToken(client);

  SharedPreferences prefs = await SharedPreferences.getInstance();
  final assignedorderPk = prefs.getInt('assignedorder_pk');
  final url = await getUrl('/mobile/assignedorder/$assignedorderPk/get_workorder_sign_details/');
  final response = await client.get(url, headers: getHeaders(newToken.token));

  if (response.statusCode == 200) {
    return AssignedOrderWorkOrderSign.fromJson(json.decode(response.body));
  }

  throw Exception('assigned_orders.workorder.exception_fetch'.tr());
}

Future<bool> storeRating(http.Client client, double rating) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  final assignedorderPk = prefs.getInt('assignedorder_pk');
  final userId = prefs.getInt('user_id');
  final ratedBy = 1;
  final customerName = prefs.getString('member_name');

  SlidingToken newToken = await refreshSlidingToken(client);

  final String token = newToken.token;
  final url = await getUrl('/company/userrating/');
  final authHeaders = getHeaders(token);
  final Map<String, String> headers = {"Content-Type": "application/json; charset=UTF-8"};
  Map<String, String> allHeaders = {};
  allHeaders.addAll(authHeaders);
  allHeaders.addAll(headers);

  final Map body = {
    'rating': rating,
    'assignedorder_id': assignedorderPk,
    'user': userId,
    'rated_by': ratedBy,  // obsolete
    'customer_name': customerName,
  };

  final response = await client.post(
    url,
    body: json.encode(body),
    headers: allHeaders,
  );

  // return
  if (response.statusCode == 201) {
    return true;
  }

  return false;
}

Future<bool> storeAssignedOrderWorkOrder(http.Client client, AssignedOrderWorkOrder workOrder) async {
  SlidingToken newToken = await refreshSlidingToken(client);

  // store it in the API
  SharedPreferences prefs = await SharedPreferences.getInstance();
  final assignedorderPk = prefs.getInt('assignedorder_pk');
  final String token = newToken.token;
  final url = await getUrl('/mobile/assignedorder-workorder/');
  final authHeaders = getHeaders(token);
  final Map<String, String> headers = {"Content-Type": "application/json; charset=UTF-8"};
  Map<String, String> allHeaders = {};
  allHeaders.addAll(authHeaders);
  allHeaders.addAll(headers);

  final Map body = {
    'assigned_order': assignedorderPk,
    'signature_name_user': workOrder.signatureNameUser,
    'signature_name_customer': workOrder.signatureNameCustomer,
    'signature_user': workOrder.signatureUser,
    'signature_customer': workOrder.signatureCustomer,
    'description_work': workOrder.descriptionWork,
    'equipment': workOrder.equipment,
    'customer_emails': workOrder.customerEmails,
  };

  final response = await client.post(
    url,
    body: json.encode(body),
    headers: allHeaders,
  );

  // return
  if (response.statusCode == 201) {
    return true;
  }

  return false;
}


class AssignedOrderWorkOrderPage extends StatefulWidget {
  @override
  AssignedOrderWorkOrderPageState createState() => AssignedOrderWorkOrderPageState();
}

class AssignedOrderWorkOrderPageState extends State<AssignedOrderWorkOrderPage> {
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
  AssignedOrderWorkOrderSign _signData;
  double _rating;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
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
            FutureBuilder<dynamic>(
              future: getUrl(member.companylogo),
              builder: (context, snapshot) {
                return Image.network(snapshot.data, cacheWidth: 100, width: 100,);
              }
            )
          ]
      )
  );

  Widget _buildMemberInfoCard(member) => Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildLogo(member),
        Flexible(
          child: _buildInfoCard(member)
        ),
      ]
  );

  Widget _buildInfoCard(member) {
    return SizedBox(
      height: 150,
      width: 1000,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            ListTile(
              title: Text(member.address,
                  style: TextStyle(fontWeight: FontWeight.w500)),
              subtitle: Text(
                  '${member.countryCode}-${member.postal}\n${member.city}'),
              leading: Icon(
                Icons.restaurant_menu,
                color: Colors.blue[500],
              ),
            ),
            Divider(),
            ListTile(
              title: Text(member.tel,
                  style: TextStyle(fontWeight: FontWeight.w500)),
              leading: Icon(
                Icons.contact_phone,
                color: Colors.blue[500],
              ),
            ),
          ],
        ),
      ),
    );
  }

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
                  child: Text('${_signData.assignedOrderWorkorderId}'),
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
                  child: Text(_signData.order.orderReference),
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
                  child: Text(_signData.order.customerId),
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
                  child: Text(_signData.order.orderName),
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
                  child: Text(_signData.order.orderAddress),
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
                  child: Text(_signData.order.orderPostal),
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
                  child: Text(_signData.order.orderCountryCode + '/' + _signData.order.orderCity),
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
                  child: Text(_signData.order.orderId),
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
                  child: Text(_signData.order.orderType),
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
                  child: Text(_signData.order.orderDate),
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
                  child: Text(_signData.order.orderContact),
                ),
              ],
            ),
          ]
        )
      )
    );
  }

  Widget _buildActivityTable() {
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

    // products
    for (int i = 0; i < _signData.activity.length; ++i) {
      AssignedOrderActivity activity = _signData.activity[i];

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
            createTableHeaderCell(_signData.activityTotals.workTotal)
          ]
      ),
      Column(
          children: [
            createTableHeaderCell('${_signData.activityTotals.travelToTotal}/${_signData.activityTotals.travelBackTotal}')
          ]
      ),
      Column(
          children: [
            createTableHeaderCell('${_signData.activityTotals.distanceToTotal}/${_signData.activityTotals.distanceBackTotal}')
          ]
      ),
    ]));

    return createTable(rows);
  }

  Widget _buildProductsTable() {
    List<TableRow> rows = [];

    // header
    rows.add(TableRow(
      children: [
        Column(children: [
          createTableHeaderCell('assigned_orders.workorder.info_product'.tr())
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
    for (int i = 0; i < _signData.products.length; ++i) {
      AssignedOrderProduct product = _signData.products[i];

      rows.add(TableRow(children: [
        Column(
            children: [
              createTableColumnCell('${product.productName}')
            ]
        ),
        Column(
            children: [
              createTableColumnCell('${product.productIdentifier}')
            ]
        ),
        Column(
            children: [
              createTableColumnCell('${product.amount}')
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('assigned_orders.workorder.app_bar_title'.tr()),
        ),
        body: ModalProgressHUD(child: GestureDetector(
          onTap: () {
            FocusScope.of(context).requestFocus(new FocusNode());
          },
          child: Container(
              padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
              child: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: FutureBuilder<AssignedOrderWorkOrderSign>(
                    future: fetchAssignedOrderWorkOrderSign(http.Client()),
                    builder: (context, snapshot) {
                      if (snapshot.data == null) {
                        return Container(
                            child: Center(
                                child: Text('generic.loading'.tr())
                            )
                        );
                      } else {
                        _signData = snapshot.data;
                        return Column(
                            children: <Widget>[
                              _buildMemberInfoCard(_signData.member),
                              Divider(),
                              createHeader('assigned_orders.workorder.header_orderinfo'.tr()),
                              _createWorkOrderInfoSection(),
                              Divider(),
                              createHeader('assigned_orders.workorder.header_activity'.tr()),
                              _buildActivityTable(),
                              Divider(),
                              createHeader('assigned_orders.workorder.header_products'.tr()),
                              _buildProductsTable(),
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
                              createHeader('assigned_orders.workorder.header_rating'.tr()),
                              RatingBar(
                                initialRating: 3,
                                minRating: 1,
                                direction: Axis.horizontal,
                                allowHalfRating: true,
                                itemCount: 5,
                                itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
                                // itemBuilder: (context, _) => Icon(
                                //   Icons.star,
                                //   color: Colors.amber,
                                // ),
                                onRatingUpdate: (rating) {
                                  _rating = rating;
                                },
                              ),
                              SizedBox(
                                height: 10.0,
                              ),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  primary: Colors.blue, // background
                                  onPrimary: Colors.white, // foreground
                                ),
                                child: Text('assigned_orders.workorder.button_submit_workorder'.tr()),
                                onPressed: () async {
                                  if (this._formKey.currentState.validate()) {
                                    this._formKey.currentState.save();
                                    bool result = false;

                                    setState(() {
                                      _saving = true;
                                    });

                                    // store rating
                                    await storeRating(http.Client(), _rating);

                                    String userSignature = await _getUserSignature();
                                    String customerSignature = await _getCustomerSignature();

                                    // store workorder
                                    AssignedOrderWorkOrder workOrder = AssignedOrderWorkOrder(
                                      assignedOrderWorkorderId: _signData.assignedOrderWorkorderId,
                                      descriptionWork: _descriptionWorkController.text,
                                      equipment: _equimentController.text,
                                      signatureUser: userSignature,
                                      signatureCustomer: customerSignature,
                                      signatureNameUser: _signatureUserNameInput.text,
                                      signatureNameCustomer: _signatureCustomerNameInput.text,
                                      customerEmails: _customerEmailsController.text,
                                    );

                                    result = await storeAssignedOrderWorkOrder(http.Client(), workOrder);

                                    if (result) {
                                      createSnackBar(context,
                                        'assigned_orders.workorder.snackbar_created'.tr());

                                      setState(() {
                                        _saving = false;
                                      });

                                      // go to order list
                                      Navigator.pushReplacement(context,
                                          new MaterialPageRoute(
                                              builder: (context) => AssignedOrdersListPage())
                                      );
                                    } else {
                                      displayDialog(context,
                                        'generic.error_dialog_title'.tr(),
                                        'assigned_orders.workorder.error_creating_dialog_content'.tr()
                                      );
                                    }
                                  }
                                },
                              ),

                            ]
                          );
                      }
                    }
                ),
            )
          )
          )
        ), inAsyncCall: _saving)
    );
  }
}
