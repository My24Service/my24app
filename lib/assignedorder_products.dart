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
  SlidingToken newToken = await refreshSlidingToken(client);

  final url = await getUrl('/mobile/assignedorderproduct/${product.id}/');
  final response = await client.delete(url, headers: getHeaders(newToken.token));

  if (response.statusCode == 204) {
    return true;
  }

  return false;
}

Future<AssignedOrderProducts> fetchAssignedOrderProducts(http.Client client) async {
  SlidingToken newToken = await refreshSlidingToken(client);

  SharedPreferences prefs = await SharedPreferences.getInstance();
  final assignedorderPk = prefs.getInt('assignedorder_pk');
  final url = await getUrl('/mobile/assignedorderproduct/?assigned_order=$assignedorderPk');
  final response = await client.get(url, headers: getHeaders(newToken.token));

  if (response.statusCode == 200) {
    return AssignedOrderProducts.fromJson(json.decode(response.body));
  }

  throw Exception('assigned_orders.products.products'.tr());
}

Future<bool> storeAssignedOrderProduct(http.Client client, AssignedOrderProduct product) async {
  SlidingToken newToken = await refreshSlidingToken(client);

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

Future<StockLocations> fetchLocations(http.Client client) async {
  SlidingToken newToken = await refreshSlidingToken(client);

  final url = await getUrl('/inventory/stock-location/');
  final response = await client.get(url, headers: getHeaders(newToken.token));

  if (response.statusCode == 200) {
    return StockLocations.fromJson(json.decode(response.body));
  }

  throw Exception('assigned_orders.products.exception_fetch_locations'.tr());
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
    _locations = await fetchLocations(http.Client());
    _location = _locations.results[0].name;
    setState(() {});
  }

  _doDelete(AssignedOrderProduct product) async {
    setState(() {
      _saving = true;
    });

    bool result = await deleteAssignedOrderProduct(http.Client(), product);

    // fetch and rebuild widgets
    if (result) {
      createSnackBar(context, 'assigned_orders.products.snackbar_deleted'.tr());

      await fetchAssignedOrderProducts(http.Client());
      setState(() {
        _saving = false;
      });
    }
  }

  _showDeleteDialog(AssignedOrderProduct product, BuildContext context) {
    showDeleteDialog(
        'assigned_orders.products.delete_dialog_title'.tr(),
        'assigned_orders.products.delete_dialog_content'.tr(),
        context, () => _doDelete(product));
  }

  Widget _buildProductsTable() {
    List<TableRow> rows = [];

    // header
    rows.add(TableRow(
      children: [
        Column(children: [
          createTableHeaderCell('assigned_orders.products.info_product'.tr())
        ]),
        Column(children: [
          createTableHeaderCell('assigned_orders.products.info_identifier'.tr())
        ]),
        Column(children: [
          createTableHeaderCell('assigned_orders.products.info_amount'.tr())
        ]),
        Column(children: [
          createTableHeaderCell('generic.action_delete'.tr())
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
                decoration: InputDecoration(
                  labelText: 'assigned_orders.products.typeahead_label_product'.tr())
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
                return 'assigned_orders.products.typeahead_validator_product'.tr();
              }

              return null;
            },
            onSaved: (value) => this._selectedProductName = value,
          ),

          SizedBox(
            height: 10.0,
          ),
          Text('assigned_orders.products.info_product'.tr()),
          TextFormField(
              readOnly: true,
              controller: _productNameController,
              keyboardType: TextInputType.text,
              validator: (value) {
                if (value.isEmpty) {
                  return 'assigned_orders.products.validator_product'.tr();
                }
                return null;
              }
          ),

          SizedBox(
            height: 10.0,
          ),
          Text('assigned_orders.products.info_location'.tr()),
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
              });
            },
          ),

          SizedBox(
            height: 10.0,
          ),
          Text('assigned_orders.products.info_identifier'.tr()),
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
          Text('assigned_orders.products.info_amount'.tr()),
          TextFormField(
              controller: _productAmountController,
              keyboardType: TextInputType.numberWithOptions(signed: false, decimal: true),
              validator: (value) {
                if (value.isEmpty) {
                  return 'assigned_orders.products.validator_amount'.tr();
                }
                return null;
              }
          ),

          SizedBox(
            height: 10.0,
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              primary: Colors.blue,
              onPrimary: Colors.white,
            ),
            child: Text('assigned_orders.products.button_add_product'.tr()),
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
                  createSnackBar(context, 'assigned_orders.products.snackbar_added'.tr());

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
                  displayDialog(context,
                    'generic.error_dialog_title'.tr(),
                    'assigned_orders.products.error_dialog_content'.tr()
                  );
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
          title: Text('assigned_orders.products.app_bar_title'.tr()),
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
                      createHeader('assigned_orders.products.header_new_product'.tr()),
                      _buildForm(),
                      Divider(),
                      FutureBuilder<AssignedOrderProducts>(
                        future: fetchAssignedOrderProducts(http.Client()),
                        // ignore: missing_return
                        builder: (context, snapshot) {
                          if (snapshot.hasError) {
                            Container(
                                child: Center(
                                    child: Text(
                                        'assigned_orders.products.products'.tr()
                                    )
                                )
                            );
                          }

                          if (snapshot.data == null) {
                            return Container(
                                child: Center(
                                    child: Text('generic.loading'.tr())
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
