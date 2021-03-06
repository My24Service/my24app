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


BuildContext localContext;

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

  // {"amount":"2","product_name":"Aanlasplaat hoek","product_identifier":"108007002","assigned_order":"6921","product":284}

  final Map body = {
    'amount': product.amount,
    'product_name': product.productName,
    'product_identifier': product.productIdentifier,
    'assigned_order': assignedorderPk,
    'product': product.productId,
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

class AssignedOrderProductPage extends StatefulWidget {
  @override
  _AssignedOrderProductPageState createState() =>
      _AssignedOrderProductPageState();
}

class _AssignedOrderProductPageState extends State<AssignedOrderProductPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _typeAheadController = TextEditingController();
  PurchaseProduct _selectedPurchaseProduct;
  String _selectedProductName;

  var _productIdentifierController = TextEditingController();
  var _productNameController = TextEditingController();
  var _productAmountController = TextEditingController();

  FocusNode amountFocusNode;

  AssignedOrderProducts _assignedOrderProducts;

  bool _saving = false;

  @override
  void initState() {
    super.initState();

    amountFocusNode = FocusNode();
  }

  showDeleteDialog(AssignedOrderProduct product) {
    // set up the buttons
    Widget cancelButton = TextButton(
      child: Text("Cancel"),
      onPressed:  () {
        Navigator.pop(context, false);
      },
    );
    Widget deleteButton = TextButton(
      child: Text("Delete"),
      onPressed:  () async {
        Navigator.pop(context, true);
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("Delete product"),
      content: Text("Do you want to delete this product?"),
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
        setState(() {
          _saving = true;
        });

        bool result = await deleteAssignedOrderProduct(http.Client(), product);

          // fetch and refresh screen
          if (result) {
            await fetchAssignedOrderProducts(http.Client());
            setState(() {
              _saving = false;
            });
          }
      }
    });
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
                showDeleteDialog(product);
              },
          )
        ]),
      ]));
    }

    return createTable(rows);
  }

  Widget _buildFormTypeAhead() {
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
              _selectedPurchaseProduct = suggestion;
              this._typeAheadController.text = _selectedPurchaseProduct.productName;

              _productIdentifierController.text =
                  _selectedPurchaseProduct.productIdentifier;
              _productNameController.text =
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
              readOnly: true,
              controller: _productNameController,
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
          Text('Identifier'),
          TextFormField(
              readOnly: true,
              controller: _productIdentifierController,
              keyboardType: TextInputType.text,
              validator: (value) {
                return null;
              }),
          SizedBox(
            height: 10.0,
          ),
          Text('Amount'),
          TextFormField(
              focusNode: amountFocusNode,
              controller: _productAmountController,
              keyboardType: TextInputType.numberWithOptions(signed: false, decimal: true),
              validator: (value) {
                if (value.isEmpty) {
                  return 'Please enter an amount';
                }
                return null;
              }),
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
                    productId: _selectedPurchaseProduct.id,
                    productName: _selectedPurchaseProduct.productName,
                    productIdentifier: _selectedPurchaseProduct.productIdentifier,
                );

                setState(() {
                  _saving = true;
                });

                bool result = await storeAssignedOrderProduct(http.Client(), product);

                if (result) {
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
    localContext = context;

    return Scaffold(
        appBar: AppBar(
          title: Text('Materials'),
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
                    createHeader('New material'),
                    _buildFormTypeAhead(),
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
    );
  }
}
