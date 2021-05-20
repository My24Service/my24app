import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

import 'package:my24app/core/widgets/widgets.dart';
import 'package:my24app/order/models/models.dart';
import 'package:my24app/inventory/models/models.dart';
import 'package:my24app/order/api/order_api.dart';
import 'package:my24app/customer/api/customer_api.dart';
import 'package:my24app/customer/models/models.dart';
import 'package:my24app/order/pages/documents.dart';
import 'package:my24app/order/pages/list.dart';
import 'package:my24app/order/pages/unaccepted.dart';


class OrderFormWidget extends StatefulWidget {
  final Order order;
  final bool isPlanning;

  OrderFormWidget({
    Key key,
    @required this.order,
    @required this.isPlanning,
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

  final TextEditingController _typeAheadControllerCustomer = TextEditingController();
  CustomerTypeAheadModel _selectedCustomer;
  String _selectedCustomerName;

  int _customerPk;
  String _customerId;

  var _orderlineLocationController = TextEditingController();
  var _orderlineProductController = TextEditingController();
  var _orderlineRemarksController = TextEditingController();

  var _infolineInfoController = TextEditingController();

  var _orderCustomerIdController = TextEditingController();
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
  String _orderCountryCode = 'NL';

  bool _inAsyncCall = false;

  @override
  Widget build(BuildContext context) {
    if (widget.order != null) {
      _fillOrderData();
    }

    return ModalProgressHUD(
        child: _buildMainContainer(),
        inAsyncCall: _inAsyncCall
    );
  }

  @override
  void initState() {
    super.initState();
    _doAsync();
  }

  _doAsync() async {
    setState(() {
      _inAsyncCall = true;
    });
    await _fetchOrderTypes();
    if (!widget.isPlanning) {
      await _fetchCustomer();
    }
    setState(() {
      _inAsyncCall = false;
    });
  }

  _fetchOrderTypes() async {
    try {
      OrderTypes _types = await orderApi.fetchOrderTypes();
      _orderTypes = _types;
      _orderType = _orderTypes.orderTypes[0];
    }  catch (e) {
      displayDialog(
          context,
          'generic.error'.tr(),
          'orders.form.dialog_content_error_loading_ordertypes'.tr()
      );
    }
  }

  _fetchCustomer() async {
    try {
      Customer customer = await customerApi.fetchCustomerFromPrefs();
      _fillCustomerData(customer);
    } catch (e) {
      displayDialog(
          context,
          'generic.error'.tr(),
          'orders.form.dialog_content_error_loading_customer'.tr()
      );
    }
  }

  Widget _buildMainContainer() {
        return Container(
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
                      Text(
                          'orders.form.notification_order_date'.tr(),
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontStyle: FontStyle.italic,
                              color: Colors.red),
                      ),
                      _createSubmitButton(),
                    ],
                  )
                )
            )
          );
  }

  // only show when a planning user is entering an order
  TableRow _getCustomerTypeAhead() {
    return TableRow(
        children: [
          Padding(padding: EdgeInsets.only(top: 16),
              child: Text('orders.form.label_search_customer'.tr(),
                  style: TextStyle(fontWeight: FontWeight.bold))),

          TypeAheadFormField(
            textFieldConfiguration: TextFieldConfiguration(
                controller: this._typeAheadControllerCustomer,
                decoration: InputDecoration(
                    labelText: 'orders.form.typeahead_label_search_customer'.tr())),
            suggestionsCallback: (pattern) async {
              if (pattern.length < 3) return null;
              return await customerApi.customerTypeAhead(pattern);
            },
            itemBuilder: (context, suggestion) {
              return ListTile(
                title: Text(suggestion.value),
              );
            },
            transitionBuilder: (context, suggestionsBox, controller) {
              return suggestionsBox;
            },
            onSuggestionSelected: (suggestion) {
              _selectedCustomer = suggestion;
              this._typeAheadControllerCustomer.text = '';

              // fill fields
              _customerPk = _selectedCustomer.id;
              _customerId = _selectedCustomer.customerId;
              _orderCustomerIdController.text = _selectedCustomer.customerId;
              _orderNameController.text = _selectedCustomer.name;
              _orderAddressController.text = _selectedCustomer.address;
              _orderPostalController.text = _selectedCustomer.postal;
              _orderCityController.text = _selectedCustomer.city;
              _orderCountryCode = _selectedCustomer.countryCode;
              _orderTelController.text = _selectedCustomer.tel;
              _orderMobileController.text = _selectedCustomer.mobile;
              _orderEmailController.text = _selectedCustomer.email;
              _orderContactController.text = _selectedCustomer.contact;

              // rebuild widgets
              setState(() {});
            },
            validator: (value) {
              return null;
            },
            onSaved: (value) => this._selectedCustomerName = value,
          )
        ]
    );
  }

  TableRow _getCustomerNameTextField() {
    return TableRow(
        children: [
          SizedBox(height: 1),
          SizedBox(height: 1),
        ]
    );
  }

  _fillCustomerData(Customer customer) {
    _customerId = customer.customerId;
    _customerPk = customer.id;

    // fill default values
    _orderCustomerIdController.text = customer.customerId;
    _orderNameController.text = customer.name;
    _orderAddressController.text = customer.address;
    _orderPostalController.text = customer.postal;
    _orderCityController.text = customer.city;
    _orderCountryCode = customer.countryCode;
    _orderContactController.text = customer.contact;
    _orderEmailController.text = customer.email;
    _orderTelController.text = customer.tel;
    _orderMobileController.text = customer.mobile;
  }

  _fillOrderData() {
    _customerId = widget.order.customerId;
    _orderCustomerIdController.text = widget.order.customerId;
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

  _navOrderList() {
    Navigator.pushReplacement(context,
        MaterialPageRoute(
            builder: (context) => OrderListPage())
    );
  }

  _navUnacceptedList() {
    // nav to orders processing list
    Navigator.pushReplacement(context,
        MaterialPageRoute(
            builder: (context) => UnacceptedPage())
    );
  }

  Widget _createSubmitButton() {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        primary: Colors.blue, // background
        onPrimary: Colors.white, // foreground
      ),
      child: Text(widget.order != null ? 'orders.form.button_order_update'.tr() : 'orders.form.button_order_insert'.tr()),
      onPressed: () async {
        if (this._formKeys[0].currentState.validate()) {
          if (_orderType == null) {
            displayDialog(context,
              'orders.validator_ordertype_dialog_title'.tr(),
              'orders.validator_ordertype_dialog_content'.tr()
            );
            return;
          }

          this._formKeys[0].currentState.save();

          // set values based on insert/edit
          int id;
          String customerId;
          int customerRelation;
          if (widget.order != null) {
            id = widget.order.id;
            customerId = widget.order.customerId;
            customerRelation = widget.order.customerRelation;
          } else {
            id = null;
            customerId = _customerId;
            customerRelation = _customerPk;
          }

          Order order = Order(
            id: id,
            customerId: customerId,
            customerRelation: customerRelation,
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

          Order newOrder;

          setState(() {
            _inAsyncCall = true;
          });

          if (widget.order != null) {
            newOrder = await orderApi.editOrder(order);
          } else {
            newOrder = await orderApi.insertOrder(order);
          }

          setState(() {
            _inAsyncCall = false;
          });

          // insert/edit ok?
          if (newOrder == null) {
              displayDialog(context,
                  'generic.error_dialog_title'.tr(),
                  'orders.error_storing_order'.tr()
              );

              return;
          }

          if (widget.order == null) {
            createSnackBar(context, 'orders.snackbar_order_saved'.tr());

            await showDialog<void>(
                context: context,
                barrierDismissible: false, // user must tap button!
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text('orders.form.dialog_add_documents_title'.tr()),
                    content: Text('orders.form.dialog_add_documents_content'.tr()),
                    actions: <Widget>[
                      TextButton(
                        child: Text('orders.form.dialog_add_documents_button_yes'.tr()),
                        onPressed: () {
                          Navigator.of(context).pop();
                          Navigator.pushReplacement(context,
                              MaterialPageRoute(
                                  builder: (context) => OrderDocumentsPage(
                                      orderPk: newOrder.id))
                          );
                        },
                      ),
                      TextButton(
                        child: Text('orders.form.dialog_add_documents_button_no'.tr()),
                        onPressed: () {
                          if (widget.isPlanning) {
                            _navOrderList();
                          } else {
                            _navUnacceptedList();
                          }
                        },
                      ),
                    ],
                  );
                }
            );
          } else {
            createSnackBar(context, 'orders.snackbar_order_saved'.tr());

            if (widget.isPlanning) {
              _navOrderList();
            } else {
              _navUnacceptedList();
            }
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
    var firstElement;

    // only show the typeahead when creating a new order
    if (widget.isPlanning && widget.order == null) {
      firstElement = _getCustomerTypeAhead();
    } else {
      firstElement = _getCustomerNameTextField();
    }

    return Form(key: _formKeys[0], child: Table(
      children: [
        firstElement,
        TableRow(
            children: [
              Padding(padding: EdgeInsets.only(top: 16),
                  child: Text('generic.info_customer_id'.tr(),
                      style: TextStyle(fontWeight: FontWeight.bold))
              ),
              TextFormField(
                  readOnly: true,
                  controller: _orderCustomerIdController,
                  validator: (value) {
                    return null;
                  }
              ),
            ]
        ),
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
            keyboardType: TextInputType.multiline,
            maxLines: null,
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
            keyboardType: TextInputType.multiline,
            maxLines: null,
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
    showDeleteDialogWrapper(
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
    showDeleteDialogWrapper(
      'orders.delete_dialog_title_infoline'.tr(),
      'orders.delete_dialog_content_infoline'.tr(),
      context, () => _deleteInfoLine(index)
    );
  }

}
