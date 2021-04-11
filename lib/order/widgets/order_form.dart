import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';

import 'package:my24app/order/blocs/order_bloc.dart';
import 'package:my24app/core/widgets/widgets.dart';
import 'package:my24app/core/utils.dart';
import 'package:my24app/order/models/models.dart';
import 'package:my24app/inventory/models/models.dart';
import 'package:my24app/order/api/order_api.dart';

class OrderFormWidget extends StatefulWidget {
  final Order order;

  OrderFormWidget({
    Key key,
    @required this.order,
  }): super(key: key);

  @override
  State<StatefulWidget> createState() => new _OrderFormWidgetState();
}

class _OrderFormWidgetState extends State<OrderFormWidget> {
  List<GlobalKey<FormState>> _formKeys = [
    GlobalKey<FormState>(),
    GlobalKey<FormState>(),
    GlobalKey<FormState>()
  ];

  final TextEditingController _typeAheadController = TextEditingController();
  InventoryMaterialTypeAheadModel _selectedProduct;
  String _selectedProductName;

  var _orderlineLocationController = TextEditingController();
  var _orderlineProductController = TextEditingController();
  var _orderlineRemarksController = TextEditingController();

  var _infolineInfoController = TextEditingController();

  var _orderNameController = TextEditingController();
  var _orderAddressController = TextEditingController();
  var _orderPostalController = TextEditingController();
  var _orderCityController = TextEditingController();
  var _orderContactController = TextEditingController();
  var _orderReferenceController = TextEditingController();
  var _customerRemarksController = TextEditingController();
  var _orderEmailController = TextEditingController();
  var _orderMobileController = TextEditingController();
  var _orderTelController = TextEditingController();

  List<Orderline> _orderLines = [];
  List<Infoline> _infoLines = [];

  DateTime _startDate = DateTime.now();
  DateTime _startTime; // = DateTime.now();
  DateTime _endDate = DateTime.now();
  DateTime _endTime; // = DateTime.now();

  OrderTypes _orderTypes;
  String _orderType;
  String _orderCountryCode;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<OrderTypes>(
      future: orderApi.fetchOrderTypes(),
      builder: (ctx, snapshot) {
        _orderTypes = snapshot.data;
        _orderType = _orderTypes.orderTypes[0];

        if (widget.order != null) {
          _fillOrderData();
        }

        return Scaffold(
            appBar: AppBar(
              title: Text('orders.edit_form.app_bar_title'.tr()),
            ),
            body: GestureDetector(
              onTap: () {
                FocusScope.of(context).requestFocus(new FocusNode());
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
                child: Container(
                    alignment: Alignment.center,
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                        createHeader('orders.header_order_details'.tr()),
                          _createOrderForm(context),
                          Divider(),
                        createHeader('orders.header_orderlines'.tr()),
                          _buildOrderlineForm(),
                          _buildOrderlineTable(),
                          Divider(),
                        createHeader('orders.header_infolines'.tr()),
                          _buildInfolineForm(),
                          _buildInfolineTable(),
                          Divider(),
                          SizedBox(
                            height: 20,
                          ),
                          _createSubmitButton(),
                        ],
                      )
                    )
                )
              )
          )
        );
      }
    );
  }

  _fillOrderData() {
    _orderNameController.text = widget.order.orderName;
    _orderAddressController.text = widget.order.orderAddress;
    _orderPostalController.text = widget.order.orderPostal;
    _orderCityController.text = widget.order.orderCity;
    _orderCountryCode = widget.order.orderCountryCode;
    _orderContactController.text = widget.order.orderContact;
    _orderEmailController.text = widget.order.orderEmail;
    _orderTelController.text = widget.order.orderTel;
    _orderMobileController.text = widget.order.orderMobile;
    _orderEmailController.text = widget.order.orderEmail;
    _orderContactController.text = widget.order.orderContact;
    _orderType = widget.order.orderType;
    _orderReferenceController.text = widget.order.orderReference;
    _customerRemarksController.text = widget.order.customerRemarks;

    _startDate = DateFormat('d/M/yyyy').parse(widget.order.startDate); // // "start_date": "26/10/2020",

    if (widget.order.startTime != null) {
      _startTime = DateFormat('d/M/yyyy H:m:s').parse('${widget.order.startDate} ${widget.order.startTime}');
    }
    _endDate = DateFormat('d/M/yyyy').parse(widget.order.endDate); // // "end_date": "26/10/2020",

    if (widget.order.endTime != null) {
      _endTime = DateFormat('d/M/yyyy H:m:s').parse('${widget.order.endDate} ${widget.order.endTime}');
    }

    _orderLines = widget.order.orderLines;
    _infoLines = widget.order.infoLines;
  }

  Widget _createSubmitButton() {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        primary: Colors.blue, // background
        onPrimary: Colors.white, // foreground
      ),
      child: Text('orders.edit_form.button_update_order'.tr()),
      onPressed: () async {
        FocusScope.of(context).unfocus();

        if (this._formKeys[0].currentState.validate()) {
          if (_orderType == null) {
            displayDialog(context,
              'orders.validator_ordertype_dialog_title'.tr(),
              'orders.validator_ordertype_dialog_content'.tr()
            );
            return;
          }

          this._formKeys[0].currentState.save();

          Order order = Order(
            id: widget.order.id,
            customerId: widget.order.customerId,
            customerRelation: widget.order.customerRelation,
            orderReference: _orderReferenceController.text,
            orderType: _orderType,
            customerRemarks: _customerRemarksController.text,
            startDate: _formatDate(_startDate),
            startTime: _startTime != null ? _formatTime(_startTime.toLocal()) : null,
            endDate: _formatDate(_endDate),
            endTime: _endTime != null ? _formatTime(_endTime.toLocal()) : null,
            orderName: _orderNameController.text,
            orderAddress: _orderAddressController.text,
            orderPostal: _orderPostalController.text,
            orderCity: _orderCityController.text,
            orderCountryCode: _orderCountryCode,
            orderTel: _orderTelController.text,
            orderMobile: _orderMobileController.text,
            orderEmail: _orderEmailController.text,
            orderContact: _orderContactController.text,
            orderLines: _orderLines,
            infoLines: _infoLines,
          );

          final bloc = BlocProvider.of<OrderBloc>(context);

          if (widget.order != null) {
            bloc.add(OrderEvent(
                status: OrderEventStatus.EDIT, value: order));
          } else {
            bloc.add(OrderEvent(
              status: OrderEventStatus.EDIT, value: order));
          }
        }
      },
    );
  }

  _selectStartDate(BuildContext context) async {
    DatePicker.showDatePicker(context,
        showTitleActions: true,
        theme: DatePickerTheme(
            headerColor: Colors.orange,
            backgroundColor: Colors.blue,
            itemStyle: TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
            doneStyle: TextStyle(color: Colors.white, fontSize: 16)
        ),
        onChanged: (date) {
        }, onConfirm: (date) {
          setState(() {
            _startDate = date;
            _endDate = date;
          });
        },
        currentTime: DateTime.now(),
        locale: LocaleType.en
    );
  }

  Future<DateTime> _selectStartTime(BuildContext context) async {
    return DatePicker.showTimePicker(context, showTitleActions: true, onChanged: (date) {
    }, onConfirm: (date) {
      setState(() {
        _startTime = date;
      });
    }, currentTime: DateTime.now());
  }

  _selectEndDate(BuildContext context) async {
    DatePicker.showDatePicker(context,
        showTitleActions: true,
        theme: DatePickerTheme(
            headerColor: Colors.orange,
            backgroundColor: Colors.blue,
            itemStyle: TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
            doneStyle: TextStyle(color: Colors.white, fontSize: 16)
        ),
        onChanged: (date) {
        }, onConfirm: (date) {
          setState(() {
            _endDate = date;
          });
        },
        currentTime: DateTime.now(),
        locale: LocaleType.en
    );
  }

  Future<DateTime> _selectEndTime(BuildContext context) async {
    return DatePicker.showTimePicker(context, showTitleActions: true, onChanged: (date) {
    }, onConfirm: (date) {
      setState(() {
        _endTime = date;
      });
    }, currentTime: DateTime.now());
  }

  String _formatTime(DateTime time) {
    String timePart = '$time'.split(' ')[1];
    List<String> hoursMinutes = timePart.split(':');

    return '${hoursMinutes[0]}:${hoursMinutes[1]}';
  }

  String _formatDate(DateTime date) {
    return "${date.toLocal()}".split(' ')[0];
  }

  Widget _createOrderForm(BuildContext context) {
    return Form(key: _formKeys[0], child: Table(
      children: [
        TableRow(
            children: [
              Padding(padding: EdgeInsets.only(top: 16), child: Text(
                'generic.info_customer'.tr(),
                style: TextStyle(fontWeight: FontWeight.bold))
              ),
              TextFormField(
                controller: _orderNameController,
                validator: (value) {
                  if (value.isEmpty) {
                    return 'generic.validator_name'.tr();
                  }
                  return null;
                }
              ),
            ]
        ),
        TableRow(
            children: [
              Padding(padding: EdgeInsets.only(top: 16), child: Text(
                'generic.info_address'.tr(),
                style: TextStyle(fontWeight: FontWeight.bold))
              ),
              TextFormField(
                  controller: _orderAddressController,
                  validator: (value) {
                    if (value.isEmpty) {
                      return 'generic.validator_address'.tr();
                    }
                    return null;
                  }
              ),
            ]
        ),
        TableRow(
            children: [
              Padding(padding: EdgeInsets.only(top: 16), child: Text(
                'generic.info_postal'.tr(),
                style: TextStyle(fontWeight: FontWeight.bold))
              ),
              TextFormField(
                  controller: _orderPostalController,
                  validator: (value) {
                    if (value.isEmpty) {
                      return 'generic.validator_postal'.tr();
                    }
                    return null;
                  }
              ),
            ]
        ),
        TableRow(
            children: [
              Padding(padding: EdgeInsets.only(top: 16), child: Text(
                'generic.info_city'.tr(),
                style: TextStyle(fontWeight: FontWeight.bold))
              ),
              TextFormField(
                  controller: _orderCityController,
                  validator: (value) {
                    if (value.isEmpty) {
                      return 'generic.validator_city'.tr();
                    }
                    return null;
                  }
              ),
            ]
        ),
        TableRow(
            children: [
              Padding(padding: EdgeInsets.only(top: 16), child: Text(
                'generic.info_country_code'.tr(),
                style: TextStyle(fontWeight: FontWeight.bold))
              ),
              DropdownButtonFormField<String>(
                value: _orderCountryCode,
                items: ['NL', 'BE', 'LU', 'FR', 'DE'].map((String value) {
                  return new DropdownMenuItem<String>(
                    child: new Text(value),
                    value: value,
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    _orderCountryCode = newValue;
                  });
                },
              )
            ]
        ),
        TableRow(
            children: [
              Padding(padding: EdgeInsets.only(top: 16), child: Text(
                'generic.info_contact'.tr(),
                style: TextStyle(fontWeight: FontWeight.bold))
              ),
              Container(
                  width: 300.0,
                  child: TextFormField(
                    controller: _orderContactController,
                    keyboardType: TextInputType.multiline,
                    maxLines: null,
                  )
              ),
            ]
        ),
        TableRow(
          children: [
            Divider(),
            SizedBox(height: 10,)
          ]
        ),
        TableRow(
          children: [
            Padding(padding: EdgeInsets.only(top: 16), child: Text(
              'orders.info_start_date'.tr(),
              style: TextStyle(fontWeight: FontWeight.bold))
            ),
            createBlueElevatedButton(
                "${_startDate.toLocal()}".split(' ')[0],
                () => _selectStartDate(context),
                primaryColor: Colors.white,
                onPrimary: Colors.black)
          ]
        ),
        TableRow(
            children: [
              Padding(padding: EdgeInsets.only(top: 16), child: Text(
                'orders.info_start_time'.tr(),
                style: TextStyle(fontWeight: FontWeight.bold))
              ),
              createBlueElevatedButton(
                  _startTime != null ? _formatTime(_startTime.toLocal()) : '',
                  () => _selectStartTime(context),
                  primaryColor: Colors.white,
                  onPrimary: Colors.black)
            ]
        ),
        TableRow(
            children: [
              Padding(padding: EdgeInsets.only(top: 16), child: Text(
                'orders.info_end_date'.tr(),
                style: TextStyle(fontWeight: FontWeight.bold))
              ),
              createBlueElevatedButton(
                  "${_endDate.toLocal()}".split(' ')[0],
                  () => _selectEndDate(context),
                  primaryColor: Colors.white,
                  onPrimary: Colors.black)
            ]
        ),
        TableRow(
            children: [
              Padding(padding: EdgeInsets.only(top: 16), child: Text(
                'orders.info_end_time'.tr(),
                style: TextStyle(fontWeight: FontWeight.bold))
              ),
              createBlueElevatedButton(
                  _endTime != null ? _formatTime(_endTime.toLocal()) : '',
                  () => _selectEndTime(context),
                  primaryColor: Colors.white,
                  onPrimary: Colors.black)
            ]
        ),
        TableRow(
            children: [
              Padding(padding: EdgeInsets.only(top: 16), child: Text(
                'orders.info_order_type'.tr(),
                style: TextStyle(fontWeight: FontWeight.bold))
              ),
              DropdownButtonFormField<String>(
                value: _orderType,
                items: _orderTypes == null ? [] : _orderTypes.orderTypes.map((String value) {
                  return new DropdownMenuItem<String>(
                    child: new Text(value),
                    value: value,
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    _orderType = newValue;
                  });
                },
              )
            ]
        ),
        TableRow(
            children: [
              Padding(padding: EdgeInsets.only(top: 16), child: Text(
                'orders.info_order_reference'.tr(),
                style: TextStyle(fontWeight: FontWeight.bold))
              ),
              TextFormField(
                controller: _orderReferenceController,
                validator: (value) {
                  return null;
                }
              )
            ]
        ),
        TableRow(
            children: [
              Padding(padding: EdgeInsets.only(top: 16), child: Text(
                'orders.info_order_email'.tr(),
                style: TextStyle(fontWeight: FontWeight.bold))
              ),
              TextFormField(
                  controller: _orderEmailController,
                  validator: (value) {
                    return null;
                  }
              )
            ]
        ),
        TableRow(
            children: [
              Padding(padding: EdgeInsets.only(top: 16), child: Text(
                'orders.info_order_mobile'.tr(),
                style: TextStyle(fontWeight: FontWeight.bold))
              ),
              TextFormField(
                  controller: _orderMobileController,
                  validator: (value) {
                    return null;
                  }
              )
            ]
        ),
        TableRow(
            children: [
              Padding(padding: EdgeInsets.only(top: 16), child: Text(
                'orders.info_order_tel'.tr(),
                style: TextStyle(fontWeight: FontWeight.bold))
              ),
              TextFormField(
                  controller: _orderTelController,
                  validator: (value) {
                    return null;
                  }
              )
            ]
        ),
        TableRow(
            children: [
              Padding(padding: EdgeInsets.only(top: 16), child: Text(
                'orders.info_order_customer_remarks'.tr(),
                style: TextStyle(fontWeight: FontWeight.bold))
              ),
              Container(
                width: 300.0,
                child: TextFormField(
                  controller: _customerRemarksController,
                  keyboardType: TextInputType.multiline,
                  maxLines: null,
                )
              ),
            ]
        ),
      ]
    ));
  }

  Widget _buildOrderlineForm() {
    return Form(key: _formKeys[1], child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text('generic.info_equipment'.tr()),
        TextFormField(
            controller: _orderlineProductController,
            keyboardType: TextInputType.text,
            validator: (value) {
              if (value.isEmpty) {
                return 'orders.validator_equipment'.tr();
              }
              return null;
            }),
        SizedBox(
          height: 10.0,
        ),
        Text('generic.info_location'.tr()),
        TextFormField(
            controller: _orderlineLocationController,
            keyboardType: TextInputType.text,
            validator: (value) {
              return null;
            }),
        SizedBox(
          height: 10.0,
        ),
        Text('generic.info_remarks'.tr()),
        TextFormField(
            controller: _orderlineRemarksController,
            validator: (value) {
              return null;
            }),
        SizedBox(
          height: 10.0,
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            primary: Colors.blue,
            onPrimary: Colors.white,
          ),
          child: Text('orders.info_add_orderline'.tr()),
          onPressed: () async {
            if (this._formKeys[1].currentState.validate()) {
              this._formKeys[1].currentState.save();

              Orderline orderline = Orderline(
                product: _orderlineProductController.text,
                location: _orderlineLocationController.text,
                remarks: _orderlineRemarksController.text,
              );

              _orderLines.add(orderline);

              // reset fields
              _typeAheadController.text = '';
              _orderlineRemarksController.text = '';
              _orderlineLocationController.text = '';
              _orderlineProductController.text = '';

              setState(() {});
              FocusScope.of(context).unfocus();
            } else {
              displayDialog(context,
                'generic.error_dialog_title'.tr(),
                'orders.error_adding_orderline'.tr()
              );
            }
          },
        ),
      ],
    ));
  }

  Widget _buildOrderlineTable() {
    List<TableRow> rows = [];

    // header
    rows.add(TableRow(
      children: [
        Column(children: [
          createTableHeaderCell('generic.info_equipment'.tr())
        ]),
        Column(children: [
          createTableHeaderCell('generic.info_location'.tr())
        ]),
        Column(children: [
          createTableHeaderCell('generic.info_remarks'.tr())
        ]),
        Column(children: [
          createTableHeaderCell('generic.action_delete'.tr())
        ])
      ],
    ));

    // orderlines
    for (int i = 0; i < _orderLines.length; ++i) {
      Orderline orderline = _orderLines[i];

      rows.add(TableRow(children: [
        Column(
            children: [
              createTableColumnCell('${orderline.product}')
            ]
        ),
        Column(
            children: [
              createTableColumnCell('${orderline.location}')
            ]
        ),
        Column(
            children: [
              createTableColumnCell('${orderline.remarks}')
            ]
        ),
        Column(children: [
          IconButton(
            icon: Icon(Icons.delete, color: Colors.red),
            onPressed: () {
              _showDeleteDialogOrderline(i, context);
            },
          )
        ]),
      ]));
    }

    return createTable(rows);
  }

  Widget _buildInfolineForm() {
    return Form(key: _formKeys[2], child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text('orders.info_infoline'.tr()),
        TextFormField(
            controller: _infolineInfoController,
            validator: (value) {
              if (value.isEmpty) {
                return 'orders.validator_infoline'.tr();
              }

              return null;
            }),
        SizedBox(
          height: 10.0,
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            primary: Colors.blue, // background
            onPrimary: Colors.white, // foreground
          ),
          child: Text('orders.button_add_infoline'.tr()),
          onPressed: () async {
            if (this._formKeys[2].currentState.validate()) {
              this._formKeys[2].currentState.save();

              Infoline infoline = Infoline(
                info: _infolineInfoController.text,
              );

              _infoLines.add(infoline);

              // reset fields
              _infolineInfoController.text = '';

              setState(() {});
              FocusScope.of(context).unfocus();
            } else {
              displayDialog(context,
                'generic.error_dialog_title'.tr(),
                'orders.error_adding_infoline'.tr()
              );
            }
          },
        ),
      ],
    ));
  }

  Widget _buildInfolineTable() {
    List<TableRow> rows = [];

    // header
    rows.add(TableRow(
      children: [
        Column(children: [
          createTableHeaderCell('orders.info_infoline'.tr())
        ]),
        Column(children: [
          createTableHeaderCell('generic.action_delete'.tr())
        ])
      ],
    ));

    // infolines
    for (int i = 0; i < _infoLines.length; ++i) {
      Infoline infoline = _infoLines[i];

      rows.add(TableRow(children: [
        Column(
            children: [
              createTableColumnCell('${infoline.info}')
            ]
        ),
        Column(children: [
          IconButton(
            icon: Icon(Icons.delete, color: Colors.red),
            onPressed: () {
              _showDeleteDialogInfoline(i, context);
            },
          )
        ]),
      ]));
    }

    return createTable(rows);
  }

  _deleteOrderLine(int index) {
    _orderLines.removeAt(index);

    setState(() {});
  }

  _showDeleteDialogOrderline(int index, BuildContext context) {
    showDeleteDialog(
      'orders.delete_dialog_title_orderline'.tr(),
      'orders.delete_dialog_content_orderline'.tr(),
      context, () => _deleteOrderLine(index)
    );
  }

  _deleteInfoLine(int index) {
    _infoLines.removeAt(index);

    setState(() {});
  }

  _showDeleteDialogInfoline(int index, BuildContext context) {
    showDeleteDialog(
      'orders.delete_dialog_title_infoline'.tr(),
      'orders.delete_dialog_content_infoline'.tr(),
      context, () => _deleteInfoLine(index)
    );
  }

}
