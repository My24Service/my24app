import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_typeahead/flutter_typeahead.dart';

import 'models.dart';
import 'utils.dart';
import 'assigned_order.dart';

BuildContext localContext;


Future<Order> fetchOrderDetail(http.Client client) async {
  // refresh token
  SlidingToken newToken = await refreshSlidingToken(client);

  if (newToken == null) {
    throw TokenExpiredException('token expired');
  }

  SharedPreferences prefs = await SharedPreferences.getInstance();
  final orderPk = prefs.getInt('order_pk');
  final url = await getUrl('/order/order/$orderPk/');
  final response = await client.get(
      url,
      headers: getHeaders(newToken.token)
  );

  if (response.statusCode == 200) {
    return Order.fromJson(json.decode(response.body));
  }

  throw Exception('Failed to load order detail');
}

class QuotationPage extends StatefulWidget {
  @override
  _QuotationPageState createState() => _QuotationPageState();
}

class _QuotationPageState extends State<QuotationPage> {
  Order _order;
  List<QuotationProduct> _quotationProducts = [];

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _typeAheadController = TextEditingController();
  QuotationProduct _selectedQuotationProduct;
  String _selectedProductName;

  var _productIdentifierController = TextEditingController();
  var _productNameController = TextEditingController();
  var _productAmountController = TextEditingController();

  FocusNode amountFocusNode;

  AssignedOrderProducts _assignedOrderProducts;

  @override
  void initState() {
    super.initState();

    amountFocusNode = FocusNode();
  }

  _deleteQuotationProduct(QuotationProduct product) {
    // remove product from List

  }

  showDeleteDialog(QuotationProduct product) {
    // set up the buttons
    Widget cancelButton = FlatButton(
      child: Text("Cancel"),
      onPressed:  () {
        Navigator.pop(context, false);
      },
    );
    Widget deleteButton = FlatButton(
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
        bool result = await _deleteQuotationProduct(product);

        // fetch and refresh screen
        if (result) {
          setState(() {});
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
          Text('Product', style: TextStyle(fontWeight: FontWeight.bold))
        ]),
        Column(children: [
          Text('Identifier', style: TextStyle(fontWeight: FontWeight.bold))
        ]),
        Column(children: [
          Text('Amount', style: TextStyle(fontWeight: FontWeight.bold))
        ]),
        Column(children: [
          Text('Delete', style: TextStyle(fontWeight: FontWeight.bold))
        ])
      ],
    ));

    // products
    for (int i = 0; i < _quotationProducts.length; ++i) {
      QuotationProduct product = _quotationProducts[i];

      rows.add(TableRow(children: [
        Column(children: [Text(product.productName)]),
        Column(children: [Text(product.productIdentifier)]),
        Column(children: [Text("${product.amount}")]),
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

    return Table(border: TableBorder.all(), children: rows);
  }

  Widget _buildFormTypeAhead() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text('New material',  style: TextStyle(fontWeight: FontWeight.bold)),
        TypeAheadFormField(
          textFieldConfiguration: TextFieldConfiguration(
              controller: this._typeAheadController,
              decoration: InputDecoration(labelText: 'Search product')),
          suggestionsCallback: (pattern) async {
            return await quotationProductTypeAhead(http.Client(), pattern);
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
            _selectedQuotationProduct = suggestion;
            this._typeAheadController.text = _selectedQuotationProduct.productName;

            _productIdentifierController.text =
                _selectedQuotationProduct.productIdentifier;
            _productNameController.text =
                _selectedQuotationProduct.productName;

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
            validator: (value) {
              if (value.isEmpty) {
                return 'Please enter a product';
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

              QuotationProduct product = QuotationProduct(
                amount: double.parse(_productAmountController.text),
                productId: _selectedQuotationProduct.id,
                productName: _selectedQuotationProduct.productName,
                productIdentifier: _selectedQuotationProduct.productIdentifier,
              );

              _quotationProducts.add(product);

              // reset fields
              _typeAheadController.text = '';
              _productAmountController.text = '';
              _productNameController.text = '';
              _productIdentifierController.text = '';

              setState(() {});

            } else {
                displayDialog(context, 'Error', 'Error storing material');
            }
          },
        ),
        SizedBox(
          height: 10.0,
        ),
        RaisedButton(
          child: Text('Back to order'),
          onPressed: () {
            Navigator.push(context,
                new MaterialPageRoute(
                    builder: (context) => AssignedOrderPage())
            );
          },
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    localContext = context;

    return Scaffold(
        appBar: AppBar(
          title: Text('Order details'),
        ),
        body: Center(
            child: FutureBuilder<Order>(
                future: fetchOrderDetail(http.Client()),
                // ignore: missing_return
                builder: (context, snapshot) {
                  if (snapshot.data == null) {
                    return Container(
                        child: Center(
                            child: Text("Loading...")
                        )
                    );
                  } else {
                    Order order = snapshot.data;
                    _order = order;

                    double lineHeight = 35;
                    double leftWidth = 160;
                    return Align(
                        alignment: Alignment.topRight,
                        child: ListView(
                            padding: const EdgeInsets.all(20),
                            children: [
                              Row(
                                children: <Widget>[
                                  Container(
                                    height: lineHeight,
                                    width: leftWidth,
                                    padding: const EdgeInsets.all(8),
                                    child: Text('Order ID:', style: TextStyle(
                                        fontWeight: FontWeight.bold)),
                                  ),
                                  Container(
                                    height: lineHeight,
                                    padding: const EdgeInsets.all(8),
                                    child: Text(order.orderId),
                                  ),
                                ],
                              ),
                              Row(
                                children: <Widget>[
                                  Container(
                                    height: lineHeight,
                                    width: leftWidth,
                                    padding: const EdgeInsets.all(8),
                                    child: Text('Order type:', style: TextStyle(
                                        fontWeight: FontWeight.bold)),
                                  ),
                                  Container(
                                    height: lineHeight,
                                    padding: const EdgeInsets.all(8),
                                    child: Text(order.orderType),
                                  ),
                                ],
                              ),
                              Row(
                                children: <Widget>[
                                  Container(
                                    height: lineHeight,
                                    width: leftWidth,
                                    padding: const EdgeInsets.all(8),
                                    child: Text('Order date:', style: TextStyle(
                                        fontWeight: FontWeight.bold)),
                                  ),
                                  Container(
                                    height: lineHeight,
                                    padding: const EdgeInsets.all(8),
                                    child: Text(order.orderDate),
                                  ),
                                ],
                              ),
                              Divider(),
                              Row(
                                children: <Widget>[
                                  Container(
                                    height: lineHeight,
                                    width: leftWidth,
                                    padding: const EdgeInsets.all(8),
                                    child: Text('Customer:', style: TextStyle(
                                        fontWeight: FontWeight.bold)),
                                  ),
                                  Container(
                                    height: lineHeight,
                                    padding: const EdgeInsets.all(8),
                                    child: Text(order.orderName),
                                  ),
                                ],
                              ),
                              Row(
                                children: <Widget>[
                                  Container(
                                    height: lineHeight,
                                    width: leftWidth,
                                    padding: const EdgeInsets.all(8),
                                    child: Text('Address:', style: TextStyle(
                                        fontWeight: FontWeight.bold)),
                                  ),
                                  Container(
                                    height: lineHeight,
                                    padding: const EdgeInsets.all(8),
                                    child: Text(order.orderAddress),
                                  ),
                                ],
                              ),
                              Row(
                                children: <Widget>[
                                  Container(
                                    height: lineHeight,
                                    width: leftWidth,
                                    padding: const EdgeInsets.all(8),
                                    child: Text('Postal:', style: TextStyle(
                                        fontWeight: FontWeight.bold)),
                                  ),
                                  Container(
                                    height: lineHeight,
                                    padding: const EdgeInsets.all(8),
                                    child: Text(order.orderPostal),
                                  ),
                                ],
                              ),
                              Row(
                                children: <Widget>[
                                  Container(
                                    height: lineHeight,
                                    width: leftWidth,
                                    padding: const EdgeInsets.all(8),
                                    child: Text('Country/City:',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold)),
                                  ),
                                  Container(
                                    height: lineHeight,
                                    padding: const EdgeInsets.all(8),
                                    child: Text(order.orderCountryCode + '/' +
                                        order.orderCity),
                                  ),
                                ],
                              ),
                              Row(
                                children: <Widget>[
                                  Container(
                                    height: lineHeight,
                                    width: leftWidth,
                                    padding: const EdgeInsets.all(8),
                                    child: Text('Contact:', style: TextStyle(
                                        fontWeight: FontWeight.bold)),
                                  ),
                                  Container(
                                    height: lineHeight,
                                    padding: const EdgeInsets.all(8),
                                    child: Text(order.orderContact),
                                  ),
                                ],
                              ),
                              Row(
                                children: <Widget>[
                                  Container(
                                    height: lineHeight,
                                    width: leftWidth,
                                    padding: const EdgeInsets.all(8),
                                    child: Text('Tel:', style: TextStyle(
                                        fontWeight: FontWeight.bold)),
                                  ),
                                  Container(
                                    height: lineHeight,
                                    padding: const EdgeInsets.all(8),
                                    child: Text(order.orderTel),
                                  ),
                                ],
                              ),
                              Row(
                                children: <Widget>[
                                  Container(
                                    height: lineHeight,
                                    width: leftWidth,
                                    padding: const EdgeInsets.all(8),
                                    child: Text('Mobile:', style: TextStyle(
                                        fontWeight: FontWeight.bold)),
                                  ),
                                  Container(
                                    height: lineHeight,
                                    padding: const EdgeInsets.all(8),
                                    child: Text(order.orderMobile),
                                  ),
                                ],
                              ),
                              Divider(),
                              SizedBox(
                                height: 10.0,
                              ),
                              Column(
                                children: [
                                  _buildProductsTable(),
                                  Divider(),
                                  SizedBox(
                                    height: 10.0,
                                  ),
                                  Form(
                                    key: _formKey,
                                    child: _buildFormTypeAhead()
                                  )
                                ],
                              )
                            ]
                        )
                    );
                  } // else
                } // builder
            )
        )
    );
  }
}
