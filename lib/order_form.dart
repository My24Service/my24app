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
  // var _startDateController = TextEditingController();

  DateTime _startDate = DateTime.now();
  DateTime _startTime = DateTime.now();
  DateTime _endDate = DateTime.now();
  DateTime _endTime = DateTime.now();
  String _orderType;

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

  Widget _createOrderForm(BuildContext context) {
    return Form(key: _formKey, child: Table(
      children: [
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
          child: _createOrderForm(context)
        ), inAsyncCall: _saving)
    );
  }
}
