import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:easy_localization/easy_localization.dart';

import 'models.dart';
import 'utils.dart';
import 'customer_list.dart';


Future<bool> _storeCustomer(http.Client client, Customer customer) async {
  // refresh token
  SlidingToken newToken = await refreshSlidingToken(client);

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

  throw Exception('customers.edit_form.exception_fetch'.tr());
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
                    child: Text('customers.info_customer_id'.tr(),
                        style: TextStyle(fontWeight: FontWeight.bold))
                    ),
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
                    child: Text('customers.info_name'.tr(),
                        style: TextStyle(fontWeight: FontWeight.bold))
                    ),
                TextFormField(
                    controller: _nameController,
                    validator: (value) {
                      if (value.isEmpty) {
                        return 'customers.validator_name'.tr();
                      }
                      return null;
                    }
                ),
              ]
          ),
          TableRow(
              children: [
                Padding(padding: EdgeInsets.only(top: 16),
                    child: Text('customers.info_address'.tr(),
                        style: TextStyle(fontWeight: FontWeight.bold))
                    ),
                TextFormField(
                    controller: _addressController,
                    validator: (value) {
                      if (value.isEmpty) {
                        return 'customers.validator_address'.tr();
                      }
                      return null;
                    }
                ),
              ]
          ),
          TableRow(
              children: [
                Padding(padding: EdgeInsets.only(top: 16),
                    child: Text('customers.info_postal'.tr(),
                        style: TextStyle(fontWeight: FontWeight.bold))
                    ),
                TextFormField(
                    controller: _postalController,
                    validator: (value) {
                      if (value.isEmpty) {
                        return 'customers.validator_postal'.tr();
                      }
                      return null;
                    }
                ),
              ]
          ),
          TableRow(
              children: [
                Padding(padding: EdgeInsets.only(top: 16),
                    child: Text('customers.info_city'.tr(),
                        style: TextStyle(fontWeight: FontWeight.bold))
                    ),
                TextFormField(
                    controller: _cityController,
                    validator: (value) {
                      if (value.isEmpty) {
                        return 'customers.validator_city'.tr();
                      }
                      return null;
                    }
                ),
              ]
          ),
          TableRow(
              children: [
                Padding(padding: EdgeInsets.only(top: 16),
                    child: Text('customers.info_country_code'.tr(),
                        style: TextStyle(fontWeight: FontWeight.bold))
                    ),
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
                    child: Text('customers.info_email'.tr(),
                        style: TextStyle(fontWeight: FontWeight.bold))
                    ),
                TextFormField(
                    controller: _emailController,
                    validator: (value) {
                      return null;
                    }
                )
              ]
          ),
          TableRow(
              children: [
                Padding(padding: EdgeInsets.only(top: 16),
                    child: Text('customers.info_tel'.tr(),
                        style: TextStyle(fontWeight: FontWeight.bold))
                    ),
                TextFormField(
                    controller: _telController,
                    validator: (value) {
                      return null;
                    }
                )
              ]
          ),
          TableRow(
              children: [
                Padding(padding: EdgeInsets.only(top: 16),
                    child: Text('customers.info_mobile'.tr(),
                        style: TextStyle(fontWeight: FontWeight.bold))
                    ),
                TextFormField(
                    controller: _mobileController,
                    validator: (value) {
                      return null;
                    }
                )
              ]
          ),
          TableRow(
              children: [
                Padding(padding: EdgeInsets.only(top: 16),
                    child: Text('customers.info_contact'.tr(),
                        style: TextStyle(fontWeight: FontWeight.bold))
                    ),
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
                    child: Text('customers.info_remarks'.tr(),
                        style: TextStyle(fontWeight: FontWeight.bold))
                    ),
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
      child: Text('customers.edit_form.button_update_customer'.tr()),
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
            createSnackBar(context, 'customers.edit_form.snackbar_updated'.tr());

            // nav to sales user customers
            Navigator.pushReplacement(context,
                new MaterialPageRoute(builder: (context) => CustomerListPage())
            );
          } else {
            displayDialog(context,
              'generic.error_dialog_title'.tr(),
              'customers.edit_form.error_dialog_content'.tr()
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
          title: Text('customers.edit_form.button_update_customer'.tr()),
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
                      createHeader('customers.edit_form.header_customer_details'.tr()),
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
