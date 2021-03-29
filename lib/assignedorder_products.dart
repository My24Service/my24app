import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import "package:flutter/services.dart";
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:easy_localization/easy_localization.dart';

import 'models.dart';
import 'utils.dart';


Future<bool> deleteAssignedOrderProduct(http.Client client, AssignedOrderProduct product) async {
  // refresh token
  SlidingToken newToken = await refreshSlidingToken(client);

  if (newToken == null) {
    throw TokenExpiredException('token expired');
  }

  // refresh last position
  // await storeLastPosition(http.Client());

  final url = await getUrl('/mobile/assignedorderproduct/${product.id}/');
  final response = await client.delete(url, headers: getHeaders(newToken.token));

  if (response.statusCode == 204) {
    return true;
  }

  return false;
}

Future<AssignedOrderProducts> fetchAssignedOrderProducts(http.Client client) async {
  // refresh token
  SlidingToken newToken = await refreshSlidingToken(client);

  if (newToken == null) {
    throw TokenExpiredException('token expired');
  }

  // refresh last position
  // await storeLastPosition(http.Client());

  SharedPreferences prefs = await SharedPreferences.getInstance();
  final assignedorderPk = prefs.getInt('assignedorder_pk');
  final url = await getUrl('/mobile/assignedorderproduct/?assigned_order=$assignedorderPk');
  final response = await client.get(url, headers: getHeaders(newToken.token));

  if (response.statusCode == 200) {
    return AssignedOrderProducts.fromJson(json.decode(response.body));
  }

  throw Exception('Failed to load assigned order products');
}

Future<bool> storeAssignedOrderProduct(http.Client client, AssignedOrderProduct product) async {
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
  final assignedorderPk = prefs.getInt('assignedorder_pk');
  final String token = newToken.token;
  final url = await getUrl('/mobile/assignedorderproduct/');
  final authHeaders = getHeaders(token);
  final Map<String, String> headers = {"Content-Type": "application/json; charset=UTF-8"};
  Map<String, String> allHeaders = {};
  allHeaders.addAll(authHeaders);
  allHeaders.addAll(headers);

  final Map body = {
    'amount': product.amount,
    'product_name': product.productName,
    'product_identifier': product.productIdentifier,
    'assigned_order': assignedorderPk,
    'product_inventory': product.productInventory,
    'location_inventory': product.locationInventory,
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

Future<StockLocations> _fetchLocations(http.Client client) async {
  // refresh token
  SlidingToken newToken = await refreshSlidingToken(client);

  if (newToken == null) {
    throw TokenExpiredException('token expired');
  }

  final url = await getUrl('/inventory/stock-location/');
  final response = await client.get(url, headers: getHeaders(newToken.token));

  if (response.statusCode == 200) {
    return StockLocations.fromJson(json.decode(response.body));
  }

  throw Exception('Failed to load locations');
}

class AssignedOrderProductPage extends StatefulWidget {
  @override
  _AssignedOrderProductPageState createState() =>
      _AssignedOrderProductPageState();
}

class _AssignedOrderProductPageState extends State<AssignedOrderProductPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _typeAheadController = TextEditingController();
  InventoryProductTypeAheadModel _selectedProduct;
  String _selectedProductName;
  StockLocations _locations;
  String _location;
  int _locationId;

  var _productIdentifierController = TextEditingController();
  var _productNameController = TextEditingController();
  var _productAmountController = TextEditingController();

  AssignedOrderProducts _assignedOrderProducts;

  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _doAsync();
  }

  _doAsync() async {
    await _onceGetLocations();
  }

  _onceGetLocations() async {
    _locations = await _fetchLocations(http.Client());
    _location = _locations.results[0].name;
    setState(() {});
  }

  _doDelete(AssignedOrderProduct product) async {
    setState(() {
      _saving = true;
    });

    bool result = await deleteAssignedOrderProduct(http.Client(), product);

    // fetch and refresh screen
    if (result) {
      createSnackBar(context, 'Material deleted');

      await fetchAssignedOrderProducts(http.Client());
      setState(() {
        _saving = false;
      });
    }
  }

  _showDeleteDialog(AssignedOrderProduct product, BuildContext context) {
    showDeleteDialog(
        'Delete material', 'Do you want to delete this material?',
        context, () => _doDelete(product));
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
          createTableHeaderCell('Identifier')
        ]),
        Column(children: [
          createTableHeaderCell('Amount')
        ]),
        Column(children: [
          createTableHeaderCell('Delete')
        ])
      ],
    ));

    // products
    for (int i = 0; i < _assignedOrderProducts.results.length; ++i) {
      AssignedOrderProduct product = _assignedOrderProducts.results[i];

      rows.add(TableRow(children: [
        Column(
            children: [
              createTableColumnCell('${product.productName}')
            ]
        ),
        Column(
            children: [
              createTableColumnCell('${product.productIdentifier}')
            ]
        ),
        Column(
            children: [
              createTableColumnCell('${product.amount}')
            ]
        ),
        Column(children: [
          IconButton(
              icon: Icon(Icons.delete, color: Colors.red),
              onPressed: () {
                _showDeleteDialog(product, context);
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
              _selectedProduct = suggestion;
              print('_selectedInventoryProduct: $_selectedProduct');
              this._typeAheadController.text = _selectedProduct.productName;

              _productIdentifierController.text =
                  _selectedProduct.productIdentifier;
              _productNameController.text =
                  _selectedProduct.productName;

              // reload screen
              setState(() {});
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
              readOnly: true,
              controller: _productNameController,
              keyboardType: TextInputType.text,
              validator: (value) {
                if (value.isEmpty) {
                  return 'Please enter some text';
                }
                return null;
              }
          ),

          SizedBox(
            height: 10.0,
          ),
          Text('Location'),
          DropdownButtonFormField<String>(
            value: _location,
            items: _locations == null || _locations.results == null ? [] : _locations.results.map((
                StockLocation location) {
              return new DropdownMenuItem<String>(
                child: new Text(location.name),
                value: location.name,
              );
            }).toList(),
            onChanged: (newValue) {
              setState(() {
                _location = newValue;

                StockLocation location = _locations.results.firstWhere(
                    (loc) => loc.name == newValue,
                    orElse: () => _locations.results.first
                );

                _locationId = location.id;
                print('selected location: $_locationId, $_location');
              });
            },
          ),

          SizedBox(
            height: 10.0,
          ),
          Text('Identifier'),
          TextFormField(
              readOnly: true,
              controller: _productIdentifierController,
              keyboardType: TextInputType.text,
              validator: (value) {
                return null;
              }
          ),

          SizedBox(
            height: 10.0,
          ),
          Text('Amount'),
          TextFormField(
              controller: _productAmountController,
              keyboardType: TextInputType.numberWithOptions(signed: false, decimal: true),
              validator: (value) {
                if (value.isEmpty) {
                  return 'Please enter an amount';
                }
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
            child: Text('Submit'),
            onPressed: () async {
              if (this._formKey.currentState.validate()) {
                this._formKey.currentState.save();

                var amount = _productAmountController.text;
                if (amount.contains(',')) {
                  amount = amount.replaceAll(new RegExp(r','), '.');
                }

                AssignedOrderProduct product = AssignedOrderProduct(
                    amount: double.parse(amount),
                    productInventory: _selectedProduct.id,
                    locationInventory: _locationId,
                    productName: _selectedProduct.productName,
                    productIdentifier: _selectedProduct.productIdentifier,
                );

                setState(() {
                  _saving = true;
                });

                bool result = await storeAssignedOrderProduct(http.Client(), product);

                if (result) {
                  createSnackBar(context, 'Material saved');

                  // reset fields
                  _typeAheadController.text = '';
                  _productAmountController.text = '';
                  _productNameController.text = '';
                  _productIdentifierController.text = '';

                  _assignedOrderProducts = await fetchAssignedOrderProducts(http.Client());
                  FocusScope.of(context).unfocus();
                  setState(() {
                    _saving = false;
                  });
                } else {
                  displayDialog(context, 'Error', 'Error storing material');
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
          title: Text('Materials'),
        ),
        body: GestureDetector(
          onTap: () {
            FocusScope.of(context).requestFocus(new FocusNode());
          },
          child: ModalProgressHUD(child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Form(
              key: _formKey,
              child: Container(
                alignment: Alignment.center,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      createHeader('New material'),
                      _buildForm(),
                      Divider(),
                      FutureBuilder<AssignedOrderProducts>(
                        future: fetchAssignedOrderProducts(http.Client()),
                        // ignore: missing_return
                        builder: (context, snapshot) {
                          if (snapshot.data == null) {
                            return Container(
                                child: Center(
                                    child: Text("Loading...")
                                )
                            );
                          } else {
                            _assignedOrderProducts = snapshot.data;
                            return _buildProductsTable();
                          }
                        }
                      ),
                    ],
                  ),
                ),
              ),
            )
          ), inAsyncCall: _saving)
        )
    );
  }
}
