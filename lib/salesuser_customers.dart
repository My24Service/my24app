import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import "package:flutter/services.dart";
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

import 'models.dart';
import 'utils.dart';


Future<bool> deleteSalesUserCustomer(http.Client client, SalesUserCustomer salesuserCustomer) async {
  SlidingToken newToken = await refreshSlidingToken(client);

  final url = await getUrl('/company/salesusercustomer/${salesuserCustomer.id}/');
  final response = await client.delete(url, headers: getHeaders(newToken.token));

  if (response.statusCode == 204) {
    return true;
  }

  return false;
}

Future<SalesUserCustomers> fetchSalesUserCustomers(http.Client client) async {
  SlidingToken newToken = await refreshSlidingToken(client);

  SharedPreferences prefs = await SharedPreferences.getInstance();
  final userPk = prefs.getInt('user_id');
  final url = await getUrl('/company/salesusercustomer/?user=$userPk');
  final response = await client.get(url, headers: getHeaders(newToken.token));

  if (response.statusCode == 200) {
    return SalesUserCustomers.fromJson(json.decode(response.body));
  }

  throw Exception('sales.customers.exception_fetch'.tr());
}

Future<bool> storeSalesUserCustomer(http.Client client, SalesUserCustomer salesUserCustomer) async {
  SlidingToken newToken = await refreshSlidingToken(client);

  SharedPreferences prefs = await SharedPreferences.getInstance();
  final userPk = prefs.getInt('user_id');
  final String token = newToken.token;
  final url = await getUrl('/company/salesusercustomer/');
  final authHeaders = getHeaders(token);
  final Map<String, String> headers = {"Content-Type": "application/json; charset=UTF-8"};
  Map<String, String> allHeaders = {};
  allHeaders.addAll(authHeaders);
  allHeaders.addAll(headers);

  final Map body = {
    'customer': salesUserCustomer.customer,
    'user': userPk,
  };

  final response = await client.post(
    url,
    body: json.encode(body),
    headers: allHeaders,
  );

  if (response.statusCode == 201) {
    return true;
  }

  return false;
}

class SalesUserCustomersPage extends StatefulWidget {
  @override
  _SalesUserCustomersPageState createState() =>
      _SalesUserCustomersPageState();
}

class _SalesUserCustomersPageState extends State<SalesUserCustomersPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _typeAheadController = TextEditingController();
  CustomerTypeAheadModel _selectedCustomer;
  String _selectedCustomerName;
  int _customerPk;

  var _addressController = TextEditingController();
  var _cityController = TextEditingController();
  var _emailController = TextEditingController();
  var _telController = TextEditingController();

  SalesUserCustomers _salesUserCustomers;

  bool _inAsyncCall = false;
  bool _error = false;

  @override
  void initState() {
    super.initState();
    _doAsync();
  }

  _doAsync() async {
    await _doFetchSalesUserCustomers();
  }

  _doFetchSalesUserCustomers() async {
    setState(() {
      _inAsyncCall = true;
      _error = false;
    });

    try {
      _salesUserCustomers = await fetchSalesUserCustomers(http.Client());

      setState(() {
        _inAsyncCall = false;
      });
    } catch(e) {
      setState(() {
        _inAsyncCall = false;
        _error = true;
      });
    }
  }

  _doDelete(SalesUserCustomer salesUserCustomer) async {
    setState(() {
      _inAsyncCall = true;
      _error = false;
    });

    bool result = await deleteSalesUserCustomer(http.Client(), salesUserCustomer);

    // fetch and rebuild widgets
    if (result) {
      createSnackBar(context, 'sales.customers.snackbar_deleted'.tr());
      _salesUserCustomers = await fetchSalesUserCustomers(http.Client());
      setState(() {
        _inAsyncCall = false;
      });
    } else {
      setState(() {
        _inAsyncCall = false;
      });

      displayDialog(context,
        'generic.error_dialog_title'.tr(),
        'sales.customers.error_deleting_dialog_content'.tr()
      );
    }
  }

  _showDeleteDialog(SalesUserCustomer salesUserCustomer, BuildContext context) {
    showDeleteDialog(
        'sales.customers.delete_dialog_title'.tr(),
        'sales.customers.delete_dialog_content'.tr(),
        context, () => _doDelete(salesUserCustomer));
  }

  Widget _buildCustomersTable() {
    List<TableRow> rows = [];

    // header
    rows.add(TableRow(
      children: [
        Column(children: [
          createTableHeaderCell('generic.info_customer'.tr())
        ]),
        Column(children: [
          createTableHeaderCell('generic.info_address'.tr())
        ]),
        Column(children: [
          createTableHeaderCell('generic.info_city'.tr())
        ]),
        Column(children: [
          createTableHeaderCell('generic.action_delete'.tr())
        ])
      ],
    ));

    // products
    for (int i = 0; i < _salesUserCustomers.results.length; ++i) {
      SalesUserCustomer salesUserCustomer = _salesUserCustomers.results[i];

      rows.add(TableRow(children: [
        Column(
            children: [
              createTableColumnCell('${salesUserCustomer.customerDetails.name}')
            ]
        ),
        Column(
            children: [
              createTableColumnCell('${salesUserCustomer.customerDetails.address}')
            ]
        ),
        Column(
            children: [
              createTableColumnCell('${salesUserCustomer.customerDetails.city}')
            ]
        ),
        Column(children: [
          IconButton(
            icon: Icon(Icons.delete, color: Colors.red),
            onPressed: () {
              _showDeleteDialog(salesUserCustomer, context);
            },
          )
        ]),
      ]));
    }

    return createTable(rows);
  }

  Widget _buildForm() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        TypeAheadFormField(
          textFieldConfiguration: TextFieldConfiguration(
              controller: this._typeAheadController,
              keyboardType: TextInputType.text,
              decoration: InputDecoration(
                  labelText: 'sales.customers.form_typeahead_label'.tr())),
          suggestionsCallback: (pattern) async {
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
            this._typeAheadController.text = _selectedCustomer.name;

            _customerPk = _selectedCustomer.id;

            _addressController.text =
                _selectedCustomer.address;
            _cityController.text =
                _selectedCustomer.city;
            _emailController.text =
                _selectedCustomer.email;
            _telController.text =
                _selectedCustomer.tel;

            // reload screen
            setState(() {});
          },
          validator: (value) {
            if (value.isEmpty) {
              return 'sales.customers.form_validator_customer'.tr();
            }

            return null;
          },
          onSaved: (value) => this._selectedCustomerName = value,
        ),

        SizedBox(
          height: 10.0,
        ),
        Text('generic.info_address'.tr()),
        TextFormField(
            readOnly: true,
            controller: _addressController,
            keyboardType: TextInputType.text,
            validator: (value) {
              return null;
            }
        ),

        SizedBox(
          height: 10.0,
        ),
        Text('generic.info_city'.tr()),
        TextFormField(
            readOnly: true,
            controller: _cityController,
            validator: (value) {
              return null;
            }
        ),

        SizedBox(
          height: 10.0,
        ),
        Text('generic.info_email'.tr()),
        TextFormField(
            readOnly: true,
            controller: _emailController,
            validator: (value) {
              return null;
            }
        ),

        SizedBox(
          height: 10.0,
        ),
        Text('generic.info_tel'.tr()),
        TextFormField(
            readOnly: true,
            controller: _telController,
            validator: (value) {
              return null;
            }
        ),

        SizedBox(
          height: 10.0,
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            primary: Colors.blue, // background
            onPrimary: Colors.white, // foreground
          ),
          child: Text('sales.customers.form_button_submit'.tr()),
          onPressed: () async {
            if (this._formKey.currentState.validate()) {
              this._formKey.currentState.save();

              SalesUserCustomer salesUserCustomer = SalesUserCustomer(
                customer: _customerPk,
              );

              setState(() {
                _inAsyncCall = true;
                _error = false;
              });

              bool result = await storeSalesUserCustomer(http.Client(), salesUserCustomer);

              if (result) {
                createSnackBar(context, 'sales.customers.snackbar_added'.tr());

                // reset fields
                _typeAheadController.text = '';
                _addressController.text = '';
                _cityController.text = '';
                _emailController.text = '';
                _telController.text = '';

                _salesUserCustomers = await fetchSalesUserCustomers(http.Client());

                setState(() {
                  _inAsyncCall = false;
                });
              } else {
                setState(() {
                  _inAsyncCall = false;
                });
                displayDialog(context, 'generic.error_dialog_title'.tr(), 'sales.customers.error_adding'.tr());
              }
            }
          },
        ),
      ],
    );
  }

  Widget _showMainView() {
    if (_error) {
      return RefreshIndicator(
        child: Center(
            child: Column(
              children: [
                SizedBox(height: 30),
                Text('orders.assign.exception_fetch'.tr())
              ],
            )
        ), onRefresh: () => _doFetchSalesUserCustomers(),
      );
    }

    if (_salesUserCustomers == null && _inAsyncCall) {
      return Center(child: CircularProgressIndicator());
    }

    return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          createHeader('sales.customers.header'.tr()),
          _buildForm(),
          Divider(),
          _buildCustomersTable()
        ]
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('sales.customers.app_bar_title'.tr()),
        ),
        body: ModalProgressHUD(child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Form(
              key: _formKey,
              child: Container(
                alignment: Alignment.center,
                child: SingleChildScrollView(
                  child: _showMainView()
                ),
              ),
            ),
        ), inAsyncCall: _inAsyncCall)
    );
  }
}
