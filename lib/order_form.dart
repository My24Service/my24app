import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';

import 'models.dart';
import 'utils.dart';


BuildContext localContext;

Future<bool> storeOrder(http.Client client, Order order) async {
  // refresh token
  SlidingToken newToken = await refreshSlidingToken(client);

  if (newToken == null) {
    // do nothing
    return false;
  }

  // refresh last position
  // await storeLastPosition(http.Client());

  // store it in the API
  final String token = newToken.token;
  final url = await getUrl('/order/order/');
  final authHeaders = getHeaders(token);
  final Map<String, String> headers = {"Content-Type": "application/json; charset=UTF-8"};
  Map<String, String> allHeaders = {};
  allHeaders.addAll(authHeaders);
  allHeaders.addAll(headers);

  // {
  //    "customer_id":"1018",
  //    "order_name":"Agfa Gevaert NV",
  //    "order_address":"Septestraat 27",
  //    "order_postal":"2640",
  //    "order_city":"Mortsel",
  //    "order_country_code":"BE",
  //    "customer_relation":17,
  //    "order_type":"Storing",
  //    "order_reference":"",
  //    "order_tel":"0032-34442135",
  //    "order_mobile":"0032494569882",
  //    "order_email":"patrick.wolfs@agfa.com",
  //    "order_contact":"Dhr Patrick Wolfs",
  //    "start_date":"22/10/2020",
  //    "end_date":"22/10/2020",
  //    "order_date":"",
  //    "customer_remarks":" ",
  //    "required_users":1,
  //    "statusses":[],
  //    "orderlines":[
  //      {
  //        "product":"fds",
  //        "location":"sdf",
  //        "remarks":"sdf"
  //      }
  //    ],
  //    "product_name":"",
  //    "brand":"",
  //    "amount":"",
  //    "times_per_year":0,
  //    "installation_date":"",
  //    "production_date":"",
  //    "serialnumber":"",
  //    "contract_value":0,
  //    "standard_hours":0,
  //    "workorder_pdf_url":"",
  //    "workorder_pdf_url_partner":""
  //  }
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
  };
  print(body);

  final response = await client.post(
    url,
    body: json.encode(body),
    headers: allHeaders,
  );

  // return
  if (response.statusCode == 401) {
    return false;
  }

  if (response.statusCode == 201) {
    return true;
  }

  return false;
}

Future<Customer> _fetchCustomerDetail(http.Client client) async {
  // refresh token
  SlidingToken newToken = await refreshSlidingToken(client);

  if (newToken == null) {
    throw TokenExpiredException('token expired');
  }

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

  throw Exception('Failed to load orders: ${response.statusCode}, ${response.body}');
}

Future<OrderTypes> _fetchOrderTypes(http.Client client) async {
  // refresh token
  SlidingToken newToken = await refreshSlidingToken(client);

  if (newToken == null) {
    throw TokenExpiredException('token expired');
  }

  final url = await getUrl('/order/order/order_types/');
  final response = await client.get(url, headers: getHeaders(newToken.token));

  if (response.statusCode == 200) {
    return OrderTypes.fromJson(json.decode(response.body));
  }

  throw Exception('Failed to load order types');
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

  // final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  // final GlobalKey<FormState> _orderLineFormKey = GlobalKey<FormState>();
  List<GlobalKey<FormState>> _formKeys = [GlobalKey<FormState>(), GlobalKey<FormState>()];

  final TextEditingController _typeAheadController = TextEditingController();
  PurchaseProduct _selectedPurchaseProduct;
  String _selectedProductName;

  var _orderlineLocationController = TextEditingController();
  var _orderlineProductController = TextEditingController();
  var _orderlineRemarksController = TextEditingController();

  FocusNode amountFocusNode;

  bool _saving = false;

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

  DateTime _startDate = DateTime.now();
  DateTime _startTime = DateTime.now();
  DateTime _endDate = DateTime.now();
  DateTime _endTime = DateTime.now();

  String _orderType;
  String _orderCountryCode;

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
          // print('change $date in time zone ' + date.timeZoneOffset.inHours.toString());
        }, onConfirm: (date) {
          setState(() {
            _startDate = date;
          });
        },
        currentTime: DateTime.now(),
        locale: LocaleType.en
    );
  }

  Future<DateTime> _selectStartTime(BuildContext context) async {
    return DatePicker.showTimePicker(context, showTitleActions: true, onChanged: (date) {
      // print('change $date in time zone ' + date.timeZoneOffset.inHours.toString());
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
          // print('change $date in time zone ' + date.timeZoneOffset.inHours.toString());
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
      // print('change $date in time zone ' + date.timeZoneOffset.inHours.toString());
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

  @override
  void initState() {
    _onceGetOrderTypes();
    _onceGetCustomerDetail();
    super.initState();
  }

  void _onceGetCustomerDetail() async {
    _customer = await _fetchCustomerDetail(http.Client());

    // fill default values
    _orderNameController.text = _customer.name;
    _orderAddressController.text = _customer.address;
    _orderPostalController.text = _customer.postal;
    _orderCityController.text = _customer.city;
    _orderCountryCode = _customer.countryCode;
    _orderContactController.text = _customer.contact;
    _orderEmailController.text = _customer.email;
    _orderTelController.text = _customer.tel;
    _orderMobileController.text = _customer.mobile;

    setState(() {}); // <-- trigger "build" method
  }

  void _onceGetOrderTypes() async {
     _orderTypes = await _fetchOrderTypes(http.Client());
    setState(() {});
  }

  void _onceGetCountryCodes() async {
    _orderTypes = await _fetchOrderTypes(http.Client());
    setState(() {});
  }

  String _formatDate(DateTime date) {
    // final DateFormat formatter = DateFormat('dd/MM/yyyy');
    // return formatter.format(date);
    return "${date.toLocal()}".split(' ')[0];
  }

  Widget _createOrderForm(BuildContext context) {
    return Form(key: _formKeys[0], child: Table(
      children: [
        TableRow(
            children: [
              Text('Customer: ', style: TextStyle(fontWeight: FontWeight.bold)),
              TextFormField(
                controller: _orderNameController,
                validator: (value) {
                  if (value.isEmpty) {
                    return 'Please enter the company name';
                  }
                  return null;
                }
              ),
            ]
        ),
        TableRow(
            children: [
              Text('Address: ', style: TextStyle(fontWeight: FontWeight.bold)),
              TextFormField(
                  controller: _orderAddressController,
                  validator: (value) {
                    if (value.isEmpty) {
                      return 'Please enter the company address';
                    }
                    return null;
                  }
              ),
            ]
        ),
        TableRow(
            children: [
              Text('Postal: ', style: TextStyle(fontWeight: FontWeight.bold)),
              TextFormField(
                  controller: _orderPostalController,
                  validator: (value) {
                    if (value.isEmpty) {
                      return 'Please enter the company postal';
                    }
                    return null;
                  }
              ),
            ]
        ),
        TableRow(
            children: [
              Text('City: ', style: TextStyle(fontWeight: FontWeight.bold)),
              TextFormField(
                  controller: _orderCityController,
                  validator: (value) {
                    if (value.isEmpty) {
                      return 'Please enter the company city';
                    }
                    return null;
                  }
              ),
            ]
        ),
        TableRow(
            children: [
              Text('Country: ', style: TextStyle(fontWeight: FontWeight.bold)),
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
              Text('Contact: ', style: TextStyle(fontWeight: FontWeight.bold)),
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
            Text('Start date: ', style: TextStyle(fontWeight: FontWeight.bold)),
            RaisedButton(
              onPressed: () => _selectStartDate(context),
              child: Text(
                'Select date (' + "${_startDate.toLocal()}".split(' ')[0] + ')',
                style:
                TextStyle(color: Colors.black),
              ),
              color: Colors.white,
            ),
          ]
        ),
        TableRow(
            children: [
              Text('Start time: ', style: TextStyle(fontWeight: FontWeight.bold)),
              RaisedButton(
                onPressed: () => _selectStartTime(context),
                child: Text(
                  'Select time (' + _formatTime(_startTime.toLocal()) + ')',
                  style:
                  TextStyle(color: Colors.black),
                ),
                color: Colors.white,
              ),
            ]
        ),
        TableRow(
            children: [
              Text('End date: ', style: TextStyle(fontWeight: FontWeight.bold)),
              RaisedButton(
                onPressed: () => _selectEndDate(context),
                child: Text(
                  'Select date (' + "${_endDate.toLocal()}".split(' ')[0] + ')',
                  style:
                  TextStyle(color: Colors.black),
                ),
                color: Colors.white,
              ),
            ]
        ),
        TableRow(
            children: [
              Text('End time: ', style: TextStyle(fontWeight: FontWeight.bold)),
              RaisedButton(
                onPressed: () => _selectEndTime(context),
                child: Text(
                  'Select time (' + _formatTime(_endTime.toLocal()) + ')',
                  style:
                  TextStyle(color: Colors.black),
                ),
                color: Colors.white,
              ),
            ]
        ),
        TableRow(
            children: [
              Text('Order type: ', style: TextStyle(fontWeight: FontWeight.bold)),
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
              Text('Order reference: ', style: TextStyle(fontWeight: FontWeight.bold)),
              TextFormField(
                // focusNode: amountFocusNode,
                controller: _orderReferenceController,
                validator: (value) {
                  if (value.isEmpty) {
                    return 'Please enter a reference';
                  }
                  return null;
                }
              )
            ]
        ),
        TableRow(
            children: [
              Text('Order email: ', style: TextStyle(fontWeight: FontWeight.bold)),
              TextFormField(
                // focusNode: amountFocusNode,
                  controller: _orderEmailController,
                  validator: (value) {
                    if (value.isEmpty) {
                      return 'Please enter a reference';
                    }
                    return null;
                  }
              )
            ]
        ),
        TableRow(
            children: [
              Text('Order mobile: ', style: TextStyle(fontWeight: FontWeight.bold)),
              TextFormField(
                // focusNode: amountFocusNode,
                  controller: _orderMobileController,
                  validator: (value) {
                    if (value.isEmpty) {
                      return 'Please enter a reference';
                    }
                    return null;
                  }
              )
            ]
        ),
        TableRow(
            children: [
              Text('Order tel.: ', style: TextStyle(fontWeight: FontWeight.bold)),
              TextFormField(
                // focusNode: amountFocusNode,
                  controller: _orderTelController,
                  validator: (value) {
                    if (value.isEmpty) {
                      return 'Please enter a reference';
                    }
                    return null;
                  }
              )
            ]
        ),
        TableRow(
            children: [
              Text('Customer remarks: ', style: TextStyle(fontWeight: FontWeight.bold)),
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
              decoration: InputDecoration(labelText: 'Search product')),
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
            _selectedPurchaseProduct = suggestion;
            this._typeAheadController.text = _selectedPurchaseProduct.productName;

            _orderlineProductController.text =
                _selectedPurchaseProduct.productName;

            // reload screen
            setState(() {});

            // set focus
            amountFocusNode.requestFocus();
          },
          validator: (value) {
            if (value.isEmpty) {
              return 'Please select a product';
            }

            return null;
          },
          onSaved: (value) => this._selectedProductName = value,
        ),

        SizedBox(
          height: 10.0,
        ),
        Text('Product'),
        TextFormField(
            // readOnly: true,
            controller: _orderlineProductController,
            keyboardType: TextInputType.text,
            validator: (value) {
              if (value.isEmpty) {
                return 'Please enter some text';
              }
              return null;
            }),
        SizedBox(
          height: 10.0,
        ),
        Text('Location'),
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
        Text('Remarks'),
        TextFormField(
            focusNode: amountFocusNode,
            controller: _orderlineRemarksController,
            validator: (value) {
              return null;
              // if (value.isEmpty) {
              //   return 'Please enter some remarks';
              // }
              // return null;
            }),
        SizedBox(
          height: 10.0,
        ),
        RaisedButton(
          color: Colors.blue,
          textColor: Colors.white,
          child: Text('Add orderline'),
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

            } else {
              displayDialog(context, 'Error', 'Error adding orderline');
            }
          },
        ),
      ],
    ));
  }

  Widget _buildProductsTable() {
    List<TableRow> rows = [];

    // header
    rows.add(TableRow(
      children: [
        Column(children: [
          createTableHeaderCell('Product')
        ]),
        Column(children: [
          createTableHeaderCell('Location')
        ]),
        Column(children: [
          createTableHeaderCell('Remarks')
        ]),
        Column(children: [
          createTableHeaderCell('Delete')
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
              showDeleteDialog(orderline);
            },
          )
        ]),
      ]));
    }

    return createTable(rows);
  }

  showDeleteDialog(Orderline orderlineToRemove) {
    // set up the buttons
    Widget cancelButton = FlatButton(
      child: Text("Cancel"),
      onPressed:  () {
        Navigator.pop(context, false);
      },
    );
    Widget deleteButton = FlatButton(
      child: Text("Delete"),
      onPressed:  () async {
        Navigator.pop(context, true);
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("Delete orderline"),
      content: Text("Do you want to delete this orderline?"),
      actions: [
        cancelButton,
        deleteButton,
      ],
    );

    // show the dialog
    showDialog(
      context: localContext,
      builder: (BuildContext context) {
        return alert;
      },
    ).then((dialogResult) async {
      if (dialogResult) {
        List<Orderline> newOrderLines = [];

        for (int i = 0; i < _orderLines.length; ++i) {
          Orderline orderline = _orderLines[i];

          if (orderline.product != orderlineToRemove.product &&
              orderline.location != orderlineToRemove.location &&
              orderline.remarks != orderlineToRemove.remarks) {
            newOrderLines.add(orderline);
          }
        }

        _orderLines = newOrderLines;

        setState(() {});
      }
    });
  }

  Widget _createSubmitButton() {
    return RaisedButton(
      color: Colors.blue,
      textColor: Colors.white,
      child: Text('Submit'),
      onPressed: () async {
        if (this._formKeys[0].currentState.validate()) {
          this._formKeys[0].currentState.save();

          Order order = Order(
            customerId: _customer.customerId,
            customerRelation: _customer.id,
            orderReference: _orderReferenceController.text,
            orderType: _orderType,
            customerRemarks: _customerRemarksController.text,
            startDate: _formatDate(_startDate),
            startTime: _formatTime(_startTime.toLocal()),
            endDate: _formatDate(_endDate),
            endTime: _formatTime(_endTime.toLocal()),
            orderName: _orderNameController.text,
            orderAddress: _orderAddressController.text,
            orderPostal: _orderPostalController.text,
            orderCity: _orderCityController.text,
            orderCountryCode: _orderCountryCode,
            orderTel: _orderTelController.text,
            orderMobile: _orderMobileController.text,
            orderEmail: _orderEmailController.text,
            orderContact: _orderContactController.text,
          );

          setState(() {
            _saving = true;
          });

          bool result = await storeOrder(http.Client(), order);

          setState(() {
            _saving = false;
          });

          if (result) {
            // nav to order list

            FocusScope.of(context).unfocus();
          } else {
            displayDialog(context, 'Error', 'Error storing order');
          }
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    localContext = context;

    return Scaffold(
        appBar: AppBar(
          title: Text('New order'),
        ),
        body: ModalProgressHUD(child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
          child: Container(
              alignment: Alignment.center,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    createHeader('Order details'),
                    _createOrderForm(context),
                    Divider(),
                    createHeader('Orderlines'),
                    _buildOrderlineForm(),
                    _buildProductsTable(),
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
    );
  }
}
