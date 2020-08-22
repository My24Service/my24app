import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_typeahead/flutter_typeahead.dart';

import 'models.dart';
import 'utils.dart';
import 'assigned_order.dart';


Future<bool> storeAssignedOrderProduct(http.Client client, AssignedOrderProduct product) async {
  // refresh token
  SlidingToken newToken = await refreshSlidingToken(client);

  if (newToken == null) {
    // do nothing
    return false;
  }

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
  PurchaseProduct _selectedProduct;
  String _selectedProductName;

  var _productIdentifierController = TextEditingController();
  var _productNameController = TextEditingController();
  var _productAmountController = TextEditingController();

  FocusNode amountFocusNode;

  @override
  void initState() {
    super.initState();

    amountFocusNode = FocusNode();
  }

  Widget _buildFormTypeAhead() {
    return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text('New material'),
          TypeAheadFormField(
            textFieldConfiguration: TextFieldConfiguration(
                controller: this._typeAheadController,
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
              this._typeAheadController.text = _selectedProduct.productName;

              _productIdentifierController.text =
                  _selectedProduct.productIdentifier;
              _productNameController.text =
                  _selectedProduct.productName;

              // reload screen
              setState(() {});

              // set focus
              amountFocusNode.requestFocus();
            },
            validator: (value) {
              print(value);
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
              validator: (value) {
                if (value.isEmpty) {
                  return 'Please enter an amount';
                }
                return null;
              }),
          SizedBox(
            height: 10.0,
          ),
          RaisedButton(
            child: Text('Submit'),
            onPressed: () async {
              if (this._formKey.currentState.validate()) {
                this._formKey.currentState.save();

                AssignedOrderProduct product = AssignedOrderProduct(
                    amount: double.parse(_productAmountController.text),
                    productId: _selectedProduct.id,
                    productName: _selectedProduct.productName,
                    productIdentifier: _selectedProduct.productIdentifier,
                );

                bool result = await storeAssignedOrderProduct(http.Client(), product);

                if (result) {
                  Navigator.push(context,
                      new MaterialPageRoute(
                          builder: (context) => AssignedOrderPage())
                  );
                } else {
                  displayDialog(context, 'Error', 'Error storing material');
                }
              }
            },
          )
        ],
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Materials'),
        ),
        body: Container(
          padding: const EdgeInsets.symmetric(horizontal: 43.0),
          child: Form(
            key: _formKey,
            child: Container(
              alignment: Alignment.center,
              child: SingleChildScrollView(    // new line
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    _buildFormTypeAhead(),
                  ],
                ),
              ),
            ),
          )
        )
    );
  }
}
