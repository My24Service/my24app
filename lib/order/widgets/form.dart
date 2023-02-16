import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:my24app/core/utils.dart';

import 'package:my24app/core/widgets/widgets.dart';
import 'package:my24app/order/models/models.dart';
import 'package:my24app/inventory/models/models.dart';
import 'package:my24app/order/api/order_api.dart';
import 'package:my24app/customer/api/customer_api.dart';
import 'package:my24app/customer/models/models.dart';
import 'package:my24app/order/pages/documents.dart';
import 'package:my24app/order/pages/list.dart';
import 'package:my24app/order/pages/unaccepted.dart';


final navigatorKey = GlobalKey<NavigatorState>();

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
  bool _initalLoadDone = false;

  @override
  Widget build(BuildContext context) {
    if (widget.order != null) {
      _fillOrderData();
    }

    return ModalProgressHUD(
        child: _buildMainContainer(context),
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
    if (mounted) {
      setState(() {
        _inAsyncCall = false;
      });
    }
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

  Widget _buildMainContainer(BuildContext context) {
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
                      createHeader('orders.header_orderline_form'.tr()),
                      _buildOrderlineForm(),
                      _buildOrderlineSection(context),
                      Divider(),
                      if (widget.isPlanning)
                        createHeader('orders.header_infoline_form'.tr()),
                      if (widget.isPlanning)
                        _buildInfolineForm(),
                      if (widget.isPlanning)
                        _buildInfolineSection(context),
                      if (widget.isPlanning)
                          Divider(),
                      SizedBox(
                        height: 20,
                      ),
                      if (!widget.isPlanning)
                        Text(
                            'orders.form.notification_order_date'.tr(),
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontStyle: FontStyle.italic,
                                color: Colors.red),
                        ),
                      _createButtonSection(context),
                    ],
                  )
                )
            )
          );
  }

  Widget _createButtonSection(BuildContext context) {
    if (widget.isPlanning && widget.order != null && widget.order.lastAcceptedStatus == 'not_yet_accepted') {
      return Column(
        children: [
          createDefaultElevatedButton(
              'orders.form.button_order_update_accept'.tr(),
              () => _doAcceptAndSubmit(context)
          ),
          SizedBox(width: 10),
          createElevatedButtonColored(
              'orders.form.button_order_reject'.tr(),
              () => _doReject(context),
              foregroundColor: Colors.white,
              backgroundColor: Colors.red
          )
        ],
      );
    }

    return _createSubmitButton(context);
  }

  void _doReject(BuildContext context) async {
    await orderApi.rejectOrder(widget.order.id);

    createSnackBar(
        context,
        'orders.unaccepted.snackbar_rejected'.tr());

    await Future.delayed(const Duration(seconds: 1), (){});

    _navContinue(context);
  }

  void _doAcceptAndSubmit(BuildContext context) async {
    await orderApi.acceptOrder(widget.order.id);

    createSnackBar(
        context,
        'orders.unaccepted.snackbar_accepted'.tr());

    await Future.delayed(const Duration(seconds: 1), (){});

    await _doSubmit(context);
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

    if (!_initalLoadDone) {
      _startDate = DateFormat('d/M/yyyy').parse(widget.order.startDate); // // "start_date": "26/10/2020",
    }

    if (widget.order.startTime != null && !_initalLoadDone) {
      _startTime = DateFormat('d/M/yyyy H:m:s').parse('${widget.order.startDate} ${widget.order.startTime}');
    }

    if (!_initalLoadDone) {
      _endDate = DateFormat('d/M/yyyy').parse(widget.order.endDate); // // "end_date": "26/10/2020",
    }

    if (widget.order.endTime != null && !_initalLoadDone) {
      _endTime = DateFormat('d/M/yyyy H:m:s').parse('${widget.order.endDate} ${widget.order.endTime}');
    }

    _orderLines = widget.order.orderLines;
    _infoLines = widget.order.infoLines;

    _initalLoadDone = true;
  }

  _navOrderList(BuildContext context) {
    Navigator.pushReplacement(context,
        MaterialPageRoute(
            builder: (context) => OrderListPage())
    );
  }

  _navUnacceptedList(BuildContext context) {
    // nav to orders processing list
    Navigator.pushReplacement(context,
        MaterialPageRoute(
            builder: (context) => UnacceptedPage())
    );
  }

  Widget _createSubmitButton(BuildContext context) {
    return createDefaultElevatedButton(
        widget.order != null ? 'orders.form.button_order_update'.tr() : 'orders.form.button_order_insert'.tr(),
        () => _doSubmit(context)
    );
  }

  Future<void> _doSubmit(BuildContext context) async {
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
        startDate: utils.formatDate(_startDate),
        startTime: _startTime != null ? _formatTime(_startTime.toLocal()) : null,
        endDate: utils.formatDate(_endDate),
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
        customerOrderAccepted: widget.isPlanning ? true : false
      );


      setState(() {
        _inAsyncCall = true;
      });

      Order newOrder = widget.order != null ? await orderApi.editOrder(order) : await orderApi.insertOrder(order);

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
                        _navOrderList(context);
                      } else {
                        _navUnacceptedList(context);
                      }
                    },
                  ),
                ],
              );
            }
        );
      } else {
        createSnackBar(context, 'orders.snackbar_order_saved'.tr());

        _navContinue(context);
      }
    }
  }

  _navContinue(BuildContext context) {
    if (widget.isPlanning) {
      _navOrderList(context);
    } else {
      _navUnacceptedList(context);
    }
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
        },
        onConfirm: (date) {
          setState(() {
            _startDate = date;
            _endDate = date;
          });
        },
        currentTime: _startDate,
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
        },
        onConfirm: (date) {
          setState(() {
            _endDate = date;
          });
        },
        currentTime: _endDate,
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
            createElevatedButtonColored(
                "${_startDate.toLocal()}".split(' ')[0],
                () => _selectStartDate(context),
                foregroundColor: Colors.white,
                backgroundColor: Colors.black)
          ]
        ),
        TableRow(
            children: [
              Padding(padding: EdgeInsets.only(top: 16), child: Text(
                'orders.info_start_time'.tr(),
                style: TextStyle(fontWeight: FontWeight.bold))
              ),
              createElevatedButtonColored(
                  _startTime != null ? _formatTime(_startTime.toLocal()) : '',
                  () => _selectStartTime(context),
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.black)
            ]
        ),
        TableRow(
            children: [
              Padding(padding: EdgeInsets.only(top: 16), child: Text(
                'orders.info_end_date'.tr(),
                style: TextStyle(fontWeight: FontWeight.bold))
              ),
              createElevatedButtonColored(
                  "${_endDate.toLocal()}".split(' ')[0],
                  () => _selectEndDate(context),
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.black)
            ]
        ),
        TableRow(
            children: [
              Padding(padding: EdgeInsets.only(top: 16), child: Text(
                'orders.info_end_time'.tr(),
                style: TextStyle(fontWeight: FontWeight.bold))
              ),
              createElevatedButtonColored(
                  _endTime != null ? _formatTime(_endTime.toLocal()) : '',
                  () => _selectEndTime(context),
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.black)
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
        // Text('generic.info_equipment'.tr()),
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
        createElevatedButtonColored(
            'orders.button_add_orderline'.tr(),
            _addOrderLine
        )
      ],
    ));
  }

  Future<void> _addOrderLine() async {
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
  }

  Widget _buildOrderlineSection(BuildContext context) {
    assert(context != null);
    return buildItemsSection(
          context,
          'orders.header_orderlines'.tr(),
          _orderLines,
          (item) {
            String equipmentLocationTitle = "${'generic.info_equipment'.tr()} / ${'generic.info_location'.tr()}";
            String equipmentLocationValue = "${item.product} / ${item.location}";
            return <Widget>[
              ...buildItemListKeyValueList(equipmentLocationTitle, equipmentLocationValue),
              ...buildItemListKeyValueList('generic.info_remarks'.tr(), item.remarks)
            ];
          },
          (Orderline item) {
            return <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  createDeleteButton(
                    "orders.form.button_delete_orderline".tr(),
                    () { _showDeleteDialogOrderline(item, context); }
                  )
                ],
              )
            ];
          }
      );
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
        createElevatedButtonColored(
            'orders.button_add_infoline'.tr(),
            _addInfoLine
        )
      ],
    ));
  }

  Future<void> _addInfoLine() async {
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
  }

  Widget _buildInfolineSection(BuildContext context) {
    assert(context != null);
    return buildItemsSection(
        context,
        'orders.header_infolines'.tr(),
        _infoLines,
        (item) {
          return buildItemListKeyValueList('orders.info_infoline'.tr(), item.info);
        },
        (Infoline item) {
          return <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                createDeleteButton(
                  "orders.form.button_delete_infoline".tr(),
                  () { _showDeleteDialogInfoline(item, context); }
                )
              ],
            )
          ];
        }
    );
  }

  _deleteOrderLine(Orderline orderLine) {
    _orderLines.removeAt(_orderLines.indexOf(orderLine));
    setState(() {});
  }

  _showDeleteDialogOrderline(Orderline orderLine, BuildContext context) {
    showDeleteDialogWrapper(
      'orders.delete_dialog_title_orderline'.tr(),
      'orders.delete_dialog_content_orderline'.tr(),
      () => _deleteOrderLine(orderLine),
      context
    );
  }

  _deleteInfoLine(Infoline infoline) {
    _infoLines.removeAt(_infoLines.indexOf(infoline));
    setState(() {});
  }

  _showDeleteDialogInfoline(Infoline infoline, BuildContext context) {
    showDeleteDialogWrapper(
      'orders.delete_dialog_title_infoline'.tr(),
      'orders.delete_dialog_content_infoline'.tr(),
      () => _deleteInfoLine(infoline),
      context
    );
  }

}
