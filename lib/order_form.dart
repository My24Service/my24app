import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:http/http.dart' as http;

import 'models.dart';
import 'utils.dart';


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

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool _saving = false;

  var _orderNameController = TextEditingController();
  var _orderAddressController = TextEditingController();
  var _orderPostalController = TextEditingController();
  var _orderCityController = TextEditingController();
  var _orderContactController = TextEditingController();

  var _orderReferenceController = TextEditingController();
  var _customerRemarksController = TextEditingController();

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
    super.initState();
  }

  void _onceGetOrderTypes() async {
     _orderTypes = await _fetchOrderTypes(http.Client());
    setState(() {}); // <-- trigger flutter to re-execute "build" method
  }

  void _onceGetCountryCodes() async {
    _orderTypes = await _fetchOrderTypes(http.Client());
    setState(() {}); // <-- trigger flutter to re-execute "build" method
  }

  Widget _createOrderForm(BuildContext context) {
    return Form(key: _formKey, child: Table(
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('New order'),
        ),
        body: ModalProgressHUD(child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
          child: Container(
              alignment: Alignment.center,
              child: SingleChildScrollView(    // new line
                child: _createOrderForm(context)
              )
          )
        ), inAsyncCall: _saving)
    );
  }
}
