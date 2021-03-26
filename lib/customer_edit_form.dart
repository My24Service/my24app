import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'models.dart';
import 'utils.dart';
import 'salesuser_customers.dart';
import 'customer_list.dart';


Future<bool> _storeCustomer(http.Client client, Customer customer) async {
  // refresh token
  SlidingToken newToken = await refreshSlidingToken(client);

  if (newToken == null) {
    // do nothing
    return null;
  }

  // refresh last position
  // await storeLastPosition(http.Client());

  // store it in the API
  SharedPreferences prefs = await SharedPreferences.getInstance();
  final int customerPk = prefs.getInt('customer_pk');
  final String token = newToken.token;
  final url = await getUrl('/customer/customer/$customerPk/');
  final authHeaders = getHeaders(token);
  final Map<String, String> headers = {"Content-Type": "application/json; charset=UTF-8"};
  Map<String, String> allHeaders = {};
  allHeaders.addAll(authHeaders);
  allHeaders.addAll(headers);

  final Map body = {
    'name': customer.name,
    'address': customer.address,
    'postal': customer.postal,
    'city': customer.city,
    'country_code': customer.countryCode,
    'tel': customer.tel,
    'mobile': customer.mobile,
    'email': customer.email,
    'contact': customer.contact,
    'remarks': customer.remarks,
  };

  final response = await client.put(
    url,
    body: json.encode(body),
    headers: allHeaders,
  );

  // return
  if (response.statusCode == 200) {
    return true;
  }

  return false;
}

Future<Customer> fetchCustomerDetail(http.Client client) async {
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

  throw Exception('Failed to load customer: ${response.statusCode}, ${response.body}');
}


class CustomerEditFormPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _CustomerFormState();
  }
}

class _CustomerFormState extends State<CustomerEditFormPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  Customer _customer;
  
  bool _saving = false;

  String _countryCode = 'NL';

  var _customerIdController = TextEditingController();
  var _nameController = TextEditingController();
  var _addressController = TextEditingController();
  var _postalController = TextEditingController();
  var _cityController = TextEditingController();
  var _emailController = TextEditingController();
  var _telController = TextEditingController();
  var _mobileController = TextEditingController();
  var _contactController = TextEditingController();
  var _remarksController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _doAsync();
  }

  _doAsync() async {
    await _onceGetCustomerDetail();
  }

  _onceGetCustomerDetail() async {
    _customer = await fetchCustomerDetail(http.Client());

    // fill default values
    _customerIdController.text = _customer.customerId;
    _nameController.text = _customer.name;
    _addressController.text = _customer.address;
    _postalController.text = _customer.postal;
    _cityController.text = _customer.city;
    _countryCode = _customer.countryCode;
    _telController.text = _customer.tel;
    _mobileController.text = _customer.mobile;
    _emailController.text = _customer.email;
    _contactController.text = _customer.contact;
    _remarksController.text = _customer.remarks;

    setState(() {}); // <-- trigger "build" method
  }

  Widget _createCustomerForm(BuildContext context) {
    return Form(key: _formKey, child: Table(
        children: [
          TableRow(
              children: [
                Padding(padding: EdgeInsets.only(top: 16),
                    child: Text('Customer ID: ',
                        style: TextStyle(fontWeight: FontWeight.bold))),
                TextFormField(
                    readOnly: true,
                    controller: _customerIdController,
                    validator: (value) {
                      return null;
                    }
                ),
              ]
          ),
          TableRow(
              children: [
                Padding(padding: EdgeInsets.only(top: 16),
                    child: Text('Name: ',
                        style: TextStyle(fontWeight: FontWeight.bold))),
                TextFormField(
                    controller: _nameController,
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
                Padding(padding: EdgeInsets.only(top: 16),
                    child: Text('Address: ',
                        style: TextStyle(fontWeight: FontWeight.bold))),
                TextFormField(
                    controller: _addressController,
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
                Padding(padding: EdgeInsets.only(top: 16),
                    child: Text('Postal: ',
                        style: TextStyle(fontWeight: FontWeight.bold))),
                TextFormField(
                    controller: _postalController,
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
                Padding(padding: EdgeInsets.only(top: 16),
                    child: Text('City: ',
                        style: TextStyle(fontWeight: FontWeight.bold))),
                TextFormField(
                    controller: _cityController,
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
                Padding(padding: EdgeInsets.only(top: 16),
                    child: Text('Country: ',
                        style: TextStyle(fontWeight: FontWeight.bold))),
                DropdownButtonFormField<String>(
                  value: _countryCode,
                  items: ['NL', 'BE', 'LU', 'FR', 'DE'].map((String value) {
                    return new DropdownMenuItem<String>(
                      child: new Text(value),
                      value: value,
                    );
                  }).toList(),
                  onChanged: (newValue) {
                    setState(() {
                      _countryCode = newValue;
                    });
                  },
                )
              ]
          ),
          TableRow(
              children: [
                Padding(padding: EdgeInsets.only(top: 16),
                    child: Text('Order email: ',
                        style: TextStyle(fontWeight: FontWeight.bold))),
                TextFormField(
                  // focusNode: amountFocusNode,
                    controller: _emailController,
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
                    child: Text('Tel.: ',
                        style: TextStyle(fontWeight: FontWeight.bold))),
                TextFormField(
                  // focusNode: amountFocusNode,
                    controller: _telController,
                    validator: (value) {
                      // if (value.isEmpty) {
                      //   return 'Please enter a number';
                      // }
                      return null;
                    }
                )
              ]
          ),
          TableRow(
              children: [
                Padding(padding: EdgeInsets.only(top: 16),
                    child: Text('Order mobile: ',
                        style: TextStyle(fontWeight: FontWeight.bold))),
                TextFormField(
                  // focusNode: amountFocusNode,
                    controller: _mobileController,
                    validator: (value) {
                      // if (value.isEmpty) {
                      //   return 'Please enter a mobile number';
                      // }
                      return null;
                    }
                )
              ]
          ),
          TableRow(
              children: [
                Padding(padding: EdgeInsets.only(top: 16),
                    child: Text('Contact: ',
                        style: TextStyle(fontWeight: FontWeight.bold))),
                Container(
                    width: 300.0,
                    child: TextFormField(
                      controller: _contactController,
                      keyboardType: TextInputType.multiline,
                      maxLines: null,
                    )
                ),
              ]
          ),
          TableRow(
              children: [
                Padding(padding: EdgeInsets.only(top: 16),
                    child: Text('Remarks: ',
                        style: TextStyle(fontWeight: FontWeight.bold))),
                Container(
                    width: 300.0,
                    child: TextFormField(
                      controller: _remarksController,
                      keyboardType: TextInputType.multiline,
                      maxLines: null,
                    )
                ),
              ]
          ),
        ]
    ));
  }

  Widget _createSubmitButton() {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        primary: Colors.blue, // background
        onPrimary: Colors.white, // foreground
      ),
      child: Text('Update customer'),
      onPressed: () async {
        FocusScope.of(context).unfocus();

        if (this._formKey.currentState.validate()) {
          this._formKey.currentState.save();

          Customer customer = Customer(
            name: _nameController.text,
            address: _addressController.text,
            postal: _postalController.text,
            city: _cityController.text,
            countryCode: _countryCode,
            tel: _telController.text,
            mobile: _mobileController.text,
            email: _emailController.text,
            contact: _contactController.text,
            remarks: _remarksController.text,
          );

          setState(() {
            _saving = true;
          });

          final bool result = await _storeCustomer(http.Client(), customer);

          setState(() {
            _saving = false;
          });

          if (result) {
            createSnackBar(context, 'Customer updated');

            // nav to sales user customers
            Navigator.pushReplacement(context,
                new MaterialPageRoute(builder: (context) => CustomerListPage())
            );
          } else {
            displayDialog(context, 'Error', 'Error updating customer');
          }
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Update customer'),
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
                      createHeader('Customer details'),
                      _createCustomerForm(context),
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
