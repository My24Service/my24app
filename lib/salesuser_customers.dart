import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import "package:flutter/services.dart";

import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

import 'models.dart';
import 'utils.dart';


Future<bool> deleteSalesUserCustomer(http.Client client, SalesUserCustomer salesuserCustomer) async {
  // refresh token
  SlidingToken newToken = await refreshSlidingToken(client);

  if (newToken == null) {
    throw TokenExpiredException('token expired');
  }

  // refresh last position
  // await storeLastPosition(http.Client());

  final url = await getUrl('/company/salesusercustomer/${salesuserCustomer.id}/');
  final response = await client.delete(url, headers: getHeaders(newToken.token));

  if (response.statusCode == 204) {
    return true;
  }

  return false;
}

Future<SalesUserCustomers> fetchSalesUserCustomers(http.Client client) async {
  // refresh token
  SlidingToken newToken = await refreshSlidingToken(client);

  if (newToken == null) {
    throw TokenExpiredException('token expired');
  }

  // refresh last position
  // await storeLastPosition(http.Client());

  SharedPreferences prefs = await SharedPreferences.getInstance();
  final userPk = prefs.getInt('user_id');
  final url = await getUrl('/company/salesusercustomer/?user=$userPk');
  final response = await client.get(url, headers: getHeaders(newToken.token));

  if (response.statusCode == 200) {
    return SalesUserCustomers.fromJson(json.decode(response.body));
  }

  throw Exception('Failed to load customers');
}

Future<bool> storeSalesUserCustomer(http.Client client, SalesUserCustomer salesUserCustomer) async {
  // refresh token
  SlidingToken newToken = await refreshSlidingToken(client);

  if (newToken == null) {
    // do nothing
    return false;
  }

  // refresh last position
  // await storeLastPosition(http.Client());

  // store it in the API
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

  // return
  if (response.statusCode == 401) {
    return false;
  }

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

  bool _saving = false;

  @override
  void initState() {
    super.initState();
  }
  
  showDeleteDialog(SalesUserCustomer salesUserCustomer) {
    // set up the buttons
    Widget cancelButton = TextButton(
        child: Text("Cancel"),
        onPressed: () => Navigator.pop(context, false)
    );
    Widget deleteButton = TextButton(
        child: Text("Delete"),
        onPressed: () => Navigator.pop(context, true)
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("Delete customer"),
      content: Text("Do you want to delete this customer?"),
      actions: [
        cancelButton,
        deleteButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (_) {
        return alert;
      },
    ).then((dialogResult) async {
      if (dialogResult == null) return;

      if (dialogResult) {
        setState(() {
          _saving = true;
        });

        bool result = await deleteSalesUserCustomer(http.Client(), salesUserCustomer);

        // fetch and refresh screen
        if (result) {
          await fetchSalesUserCustomers(http.Client());
          setState(() {
            _saving = false;
          });
        }
      }
    });
  }

  Widget _buildCustomersTable() {
    List<TableRow> rows = [];

    // header
    rows.add(TableRow(
      children: [
        Column(children: [
          createTableHeaderCell('Customer')
        ]),
        Column(children: [
          createTableHeaderCell('Address')
        ]),
        Column(children: [
          createTableHeaderCell('City')
        ]),
        Column(children: [
          createTableHeaderCell('Delete')
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
              showDeleteDialog(salesUserCustomer);
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
              decoration: InputDecoration(labelText: 'Search customer')),
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
              return 'Please select a customer';
            }

            return null;
          },
          onSaved: (value) => this._selectedCustomerName = value,
        ),

        SizedBox(
          height: 10.0,
        ),
        Text('Address'),
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
        Text('City'),
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
        Text('Email'),
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
        Text('Tel'),
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
          child: Text('Add'),
          onPressed: () async {
            if (this._formKey.currentState.validate()) {
              this._formKey.currentState.save();

              SalesUserCustomer salesUserCustomer = SalesUserCustomer(
                customer: _customerPk,
              );

              setState(() {
                _saving = true;
              });

              bool result = await storeSalesUserCustomer(http.Client(), salesUserCustomer);

              if (result) {
                // reset fields
                _typeAheadController.text = '';
                _addressController.text = '';
                _cityController.text = '';
                _emailController.text = '';
                _telController.text = '';

                _salesUserCustomers = await fetchSalesUserCustomers(http.Client());

                setState(() {
                  _saving = false;
                });
              } else {
                displayDialog(context, 'Error', 'Error storing customer');
              }
            }
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Your customers'),
        ),
        body: ModalProgressHUD(child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Form(
              key: _formKey,
              child: Container(
                alignment: Alignment.center,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      createHeader('Add customer'),
                      _buildForm(),
                      Divider(),
                      FutureBuilder<SalesUserCustomers>(
                          future: fetchSalesUserCustomers(http.Client()),
                          // ignore: missing_return
                          builder: (context, snapshot) {
                            if (snapshot.data == null) {
                              return Container(
                                  child: Center(
                                      child: Text("Loading...")
                                  )
                              );
                            } else {
                              _salesUserCustomers = snapshot.data;
                              return _buildCustomersTable();
                            }
                          }
                      ),
                    ],
                  ),
                ),
              ),
            )
        ), inAsyncCall: _saving)
    );
  }
}
