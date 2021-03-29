import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:easy_localization/easy_localization.dart';

import 'models.dart';
import 'utils.dart';
import 'order_not_accepted_list.dart';
import 'order_list.dart';


Future<Order> _storeOrder(http.Client client, Order order) async {
  // refresh token
  SlidingToken newToken = await refreshSlidingToken(client);

  // store it in the API
  final String token = newToken.token;
  final url = await getUrl('/order/order/');
  final authHeaders = getHeaders(token);
  final Map<String, String> headers = {"Content-Type": "application/json; charset=UTF-8"};
  Map<String, String> allHeaders = {};
  allHeaders.addAll(authHeaders);
  allHeaders.addAll(headers);

  List<Map> orderlines = [];
  for (int i=0; i<order.orderLines.length; i++) {
    Orderline orderline = order.orderLines[i];

    orderlines.add({
      'product': orderline.product,
      'location': orderline.location,
      'remarks': orderline.remarks,
    });
  }

  List<Map> infolines = [];
  for (int i=0; i<order.infoLines.length; i++) {
    Infoline infoline = order.infoLines[i];

    infolines.add({
      'info': infoline.info,
    });
  }

  final Map body = {
    'customer_id': order.customerId,
    'order_name': order.orderName,
    'order_address': order.orderAddress,
    'order_postal': order.orderPostal,
    'order_city': order.orderCity,
    'order_country_code': order.orderCountryCode,
    'customer_relation': order.customerRelation,
    'order_type': order.orderType,
    'order_reference': order.orderReference,
    'order_tel': order.orderTel,
    'order_mobile': order.orderMobile,
    'order_contact': order.orderContact,
    'start_date': order.startDate,
    'start_time': order.startTime,
    'end_date': order.endDate,
    'end_time': order.endTime,
    'customer_remarks': order.customerRemarks,
    'customer_order_accepted': order.customerOrderAccepted,
    'orderlines': orderlines,
    'infolines': infolines,
  };

  final response = await client.post(
    url,
    body: json.encode(body),
    headers: allHeaders,
  );

  // return
  if (response.statusCode == 401) {
    return null;
  }

  if (response.statusCode == 201) {
    Order order = Order.fromJson(json.decode(response.body));
    return order;
  }

  return null;
}

Future<Customer> _fetchCustomerDetail(http.Client client) async {
  // refresh token
  SlidingToken newToken = await refreshSlidingToken(client);

  // make call
  SharedPreferences prefs = await SharedPreferences.getInstance();
  final int customerPk = prefs.getInt('customer_pk');
  final String token = newToken.token;
  final url = await getUrl('/customer/customer/$customerPk/');
  final response = await client.get(
      url,
      headers: getHeaders(token)
  );

  if (response.statusCode == 200) {
    Customer result = Customer.fromJson(json.decode(response.body));
    return result;
  }

  throw Exception('orders.form.error_loading_customer'.tr());
}

Future<OrderTypes> _fetchOrderTypes(http.Client client) async {
  // refresh token
  SlidingToken newToken = await refreshSlidingToken(client);

  final url = await getUrl('/order/order/order_types/');
  final response = await client.get(url, headers: getHeaders(newToken.token));

  if (response.statusCode == 200) {
    return OrderTypes.fromJson(json.decode(response.body));
  }

  throw Exception('orders.form.error_loading_ordertypes'.tr());
}

class OrderFormPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _OrderFormState();
  }
}

class _OrderFormState extends State<OrderFormPage> {
  OrderTypes _orderTypes;
  Customer _customer;
  int _customerPk;
  String _customerId;

  // all forms used
  List<GlobalKey<FormState>> _formKeys = [
    GlobalKey<FormState>(),
    GlobalKey<FormState>(),
    GlobalKey<FormState>()
  ];

  final TextEditingController _typeAheadController = TextEditingController();
  InventoryProductTypeAheadModel _selectedProduct;
  String _selectedProductName;

  var _orderlineLocationController = TextEditingController();
  var _orderlineProductController = TextEditingController();
  var _orderlineRemarksController = TextEditingController();

  var _infolineInfoController = TextEditingController();

  final TextEditingController _typeAheadControllerCustomer = TextEditingController();
  CustomerTypeAheadModel _selectedCustomer;
  String _selectedCustomerName;

  bool _saving = false;

  bool _isPlanning = false;

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

  String _orderType;
  String _orderCountryCode;

  @override
  void initState() {
    super.initState();
    _doAsync();
  }

  _doAsync() async {
    await _setIsPlanning();
    await _onceGetOrderTypes();

    if (!_isPlanning) {
      await _onceGetCustomerDetail();
    }
  }

  _setIsPlanning() async {
    final String submodel = await getUserSubmodel();

    setState(() {
      _isPlanning = submodel == 'planning_user';
    });
  }

  _onceGetOrderTypes() async {
    _orderTypes = await _fetchOrderTypes(http.Client());
    _orderType = _orderTypes.orderTypes[0];
    setState(() {});
  }

  _onceGetCustomerDetail() async {
    _customer = await _fetchCustomerDetail(http.Client());

    _customerId = _customer.customerId;
    _customerPk = _customer.id;

    // fill default values
    _orderCustomerIdController.text = _customer.customerId;
    _orderNameController.text = _customer.name;
    _orderAddressController.text = _customer.address;
    _orderPostalController.text = _customer.postal;
    _orderCityController.text = _customer.city;
    _orderCountryCode = _customer.countryCode;
    _orderContactController.text = _customer.contact;
    _orderEmailController.text = _customer.email;
    _orderTelController.text = _customer.tel;
    _orderMobileController.text = _customer.mobile;

    setState(() {});
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
          });
        },
        currentTime: DateTime.now(),
        locale: LocaleType.en
    );
  }

  Future<DateTime> _selectStartTime(BuildContext context) async {
    return DatePicker.showTimePicker(
        context, showTitleActions: true, onChanged: (date) {
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
        currentTime: DateTime.now(),
        locale: LocaleType.en
    );
  }

  Future<DateTime> _selectEndTime(BuildContext context) async {
    return DatePicker.showTimePicker(
        context, showTitleActions: true, onChanged: (date) {
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
                return await customerTypeAhead(http.Client(), pattern);
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

                // reload screen
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

  Widget _createOrderForm(BuildContext context) {
    // in case of planning, the first element is a typeAhead to customers
    var firstElement;

    if (_isPlanning) {
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
                Padding(padding: EdgeInsets.only(top: 16),
                    child: Text('generic.info_name'.tr(),
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
                Padding(padding: EdgeInsets.only(top: 16),
                    child: Text('generic.info_address'.tr(),
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
                Padding(padding: EdgeInsets.only(top: 16),
                    child: Text('generic.info_postal'.tr(),
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
                Padding(padding: EdgeInsets.only(top: 16),
                    child: Text('generic.info_city'.tr(),
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
                Padding(padding: EdgeInsets.only(top: 16),
                    child: Text('generic.info_country_code'.tr(),
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
                Padding(padding: EdgeInsets.only(top: 16),
                    child: Text('generic.info_contact'.tr(),
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
                Padding(padding: EdgeInsets.only(top: 16),
                    child: Text('orders.info_start_date'.tr(),
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
                Padding(padding: EdgeInsets.only(top: 16),
                    child: Text('orders.info_start_time'.tr(),
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
                Padding(padding: EdgeInsets.only(top: 16),
                    child: Text('orders.info_end_date'.tr(),
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
                Padding(padding: EdgeInsets.only(top: 16),
                    child: Text('orders.info_end_time'.tr(),
                        style: TextStyle(fontWeight: FontWeight.bold))
                    ),
                createBlueElevatedButton(
                    _endTime != null ? _formatTime(_startTime.toLocal()) : '',
                    () => _selectEndTime(context),
                    primaryColor: Colors.white,
                    onPrimary: Colors.black)
              ]
          ),
          TableRow(
              children: [
                Padding(padding: EdgeInsets.only(top: 16),
                    child: Text('orders.info_order_type'.tr(),
                        style: TextStyle(fontWeight: FontWeight.bold))
                    ),
                DropdownButtonFormField<String>(
                  value: _orderType,
                  items: _orderTypes == null ? [] : _orderTypes.orderTypes.map((
                      String value) {
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
                Padding(padding: EdgeInsets.only(top: 16),
                    child: Text('orders.info_order_reference'.tr(),
                        style: TextStyle(fontWeight: FontWeight.bold))
                    ),
                TextFormField(
                    controller: _orderReferenceController,
                    validator: (value) {
                      if (value.isEmpty) {
                        return 'orders.validator_order_reference'.tr();
                      }
                      return null;
                    }
                )
              ]
          ),
          TableRow(
              children: [
                Padding(padding: EdgeInsets.only(top: 16),
                    child: Text('orders.info_order_email'.tr(),
                        style: TextStyle(fontWeight: FontWeight.bold))),
                TextFormField(
                    controller: _orderEmailController,
                    validator: (value) {
                      // if (value.isEmpty) {
                      //   return 'Please enter an email';
                      // }
                      return null;
                    }
                )
              ]
          ),
          TableRow(
              children: [
                Padding(padding: EdgeInsets.only(top: 16),
                    child: Text('orders.info_order_mobile'.tr(),
                        style: TextStyle(fontWeight: FontWeight.bold))),
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
                Padding(padding: EdgeInsets.only(top: 16),
                    child: Text('orders.info_order_tel'.tr(),
                        style: TextStyle(fontWeight: FontWeight.bold))),
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
                Padding(padding: EdgeInsets.only(top: 16),
                    child: Text('orders.info_order_customer_remarks'.tr(),
                        style: TextStyle(fontWeight: FontWeight.bold))),
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
        TypeAheadFormField(
          textFieldConfiguration: TextFieldConfiguration(
              controller: this._typeAheadController,
              keyboardType: TextInputType.text,
              decoration: InputDecoration(
                labelText: 'orders.typeahead_label_search_product'.tr()
              )
          ),
          suggestionsCallback: (pattern) async {
            return await productTypeAhead(http.Client(), pattern);
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
            _selectedProduct = suggestion;
            this._typeAheadController.text =
                _selectedProduct.productName;

            _orderlineProductController.text =
                _selectedProduct.productName;

            // reload screen
            setState(() {});
          },
          validator: (value) {
            return null;
          },
          onSaved: (value) => this._selectedProductName = value,
        ),

        SizedBox(
          height: 10.0,
        ),
        Text('generic.info_product'.tr()),
        TextFormField(
          // readOnly: true,
            controller: _orderlineProductController,
            keyboardType: TextInputType.text,
            validator: (value) {
              if (value.isEmpty) {
                return 'generic.validator_product'.tr();
              }
              return null;
            }),
        SizedBox(
          height: 10.0,
        ),
        Text('generic.info_location'.tr()),
        TextFormField(
          // readOnly: true,
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
            primary: Colors.blue, // background
            onPrimary: Colors.white, // foreground
          ),
          child: Text('orders.info_add_orderline'.tr()),
          onPressed: () {
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
  } // end widget

  Widget _buildOrderlineTable() {
    List<TableRow> rows = [];

    // header
    rows.add(TableRow(
      children: [
        Column(children: [
          createTableHeaderCell('generic.info_product'.tr())
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
  } // end table

  Widget _buildInfolineForm() {
    return Form(key: _formKeys[2], child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text('orders.info_infoline'.tr()),
        TextFormField(
            controller: _infolineInfoController,
            validator: (value) {
              if (value.isEmpty) {
                return 'generic.validator_infoline'.tr();
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
      context, () => _deleteInfoLine(index));
  }

  Widget _createSubmitButton() {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        primary: Colors.blue, // background
        onPrimary: Colors.white, // foreground
      ),
      child: Text('Submit order'),
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

          Order order = Order(
            customerId: _customerId,
            customerRelation: _customerPk,
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
            customerOrderAccepted: _isPlanning ? true : false,
          );

          setState(() {
            _saving = true;
          });

          Order newOrder = await _storeOrder(http.Client(), order);

          setState(() {
            _saving = false;
          });

          if (newOrder != null) {
            createSnackBar(context, 'orders.snackbar_order_saved'.tr());

            if (_isPlanning) {
              // nav to orders processing list
              Navigator.pushReplacement(context,
                  new MaterialPageRoute(builder: (context) => OrderListPage())
              );
            } else {
              // nav to orders processing list
              Navigator.pushReplacement(context,
                  new MaterialPageRoute(builder: (context) => OrderNotAcceptedListPage())
              );
            }
          } else {
            displayDialog(context,
              'generic.error_dialog_title'.tr(),
              'orders.error_storing_order'.tr()
            );
          }
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('orders.form.app_bar_title'.tr()),
        ),
        body: GestureDetector(
          onTap: () {
            FocusScope.of(context).requestFocus(new FocusNode());
          },
          child: ModalProgressHUD(child: Container(
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
        ), inAsyncCall: _saving)
      )
    );
  }
}
