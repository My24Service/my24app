import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:http/http.dart' as http;
import 'package:easy_localization/easy_localization.dart';

import 'models.dart';
import 'utils.dart';
import 'salesuser_customers.dart';


Future<Customer> storeCustomer(http.Client client, Customer customer) async {
  // refresh token
  SlidingToken newToken = await refreshSlidingToken(client);

  // store it in the API
  final String token = newToken.token;
  final url = await getUrl('/customer/customer/');
  final authHeaders = getHeaders(token);
  final Map<String, String> headers = {"Content-Type": "application/json; charset=UTF-8"};
  Map<String, String> allHeaders = {};
  allHeaders.addAll(authHeaders);
  allHeaders.addAll(headers);

  final Map body = {
    'customer_id': customer.customerId,
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

  final response = await client.post(
    url,
    body: json.encode(body),
    headers: allHeaders,
  );

  if (response.statusCode == 201) {
    Customer customer = Customer.fromJson(json.decode(response.body));
    return customer;
  }

  return null;
}

Future<String> fetchNewCustomerId(http.Client client) async {
  // refresh token
  SlidingToken newToken = await refreshSlidingToken(client);

  final url = await getUrl('/customer/customer/check_customer_id_handling/');
  final response = await client.get(url, headers: getHeaders(newToken.token));

  if (response.statusCode == 200) {
    Map result = json.decode(response.body);

    return result['customer_id'].toString();
  }

  throw Exception('customers.form.exception_fetch'.tr());
}


class CustomerFormPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _OrderFormState();
  }
}

class _OrderFormState extends State<CustomerFormPage> {
  String _customerId;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

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
    await _doFetchNewCustomerId();
  }

  _doFetchNewCustomerId() async {
    String customerId = await fetchNewCustomerId(http.Client());

    setState(() {
      _customerId = customerId;
      _customerIdController.text = customerId;
    });
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
      child: Text('customers.form.button_add_customer'.tr()),
      onPressed: () async {
        FocusScope.of(context).unfocus();

        if (this._formKey.currentState.validate()) {
          this._formKey.currentState.save();

          Customer customer = Customer(
            customerId: _customerId,
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

          Customer newCustomer = await storeCustomer(http.Client(), customer);

          setState(() {
            _saving = false;
          });

          if (newCustomer != null) {
            createSnackBar(context, 'customers.form.snackbar_added'.tr());

            // nav to sales user customers
            Navigator.pushReplacement(context,
              new MaterialPageRoute(builder: (context) => SalesUserCustomersPage())
            );
          } else {
            displayDialog(context,
              'generic.error_dialog_title'.tr(),
              'customers.form.error_dialog_content'.tr()
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
          title: Text(''),
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
                      createHeader('customers.form.header_details'.tr()),
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
