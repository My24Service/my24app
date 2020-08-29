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

Future<bool> storeQuotation(http.Client client, Quotation quotation) async {
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

  // {
  //  "order":6289,
  //  "customer_id":"1018",
  //  "customer_relation": 17,
  //  "quotation_name":"Agfa Gevaert NV",
  //  "quotation_address":"Septestraat 27",
  //  "quotation_postal":"2640",
  //  "quotation_city":"Mortsel",
  //  "quotation_country_code":"BE",
  //  "quotation_email":"richard@pedroja.tech",
  //  "quotation_tel":"0032-34442135",
  //  "quotation_mobile":"0032494569882",
  //  "quotation_contact":"richard",
  //  "quotation_reference":"",
  //  "description":"description test",
  //  "quotation_products":
  //    [
  //     {
  //      "product":284,
  //      "product_name":
  //      "Aanlasplaat hoek",
  //      "product_identifier":"108007002",
  //      "location":"location test",
  //      "amount":"2"
  //     }
  //    ],
  //   "quotation_images":[],
  //   "travel_to":"1:15",
  //   "travel_back":"1:30",
  //   "distance_to":"14",
  //   "distance_back":"14",
  //   "work_hours":"8:15"
  //  }

  List products = [];
  for(var i=0; i<quotation.quotationProducts.length; i++) {
    products.add({
      'product': quotation.quotationProducts[i].productId,
      'product_name': quotation.quotationProducts[i].productName,
      'product_identifier': quotation.quotationProducts[i].productIdentifier,
      'location': quotation.quotationProducts[i].location,
      'amount': quotation.quotationProducts[i].amount,
    });
  }

  Map body = {
    'order': quotation.orderId,
    'customer_id': quotation.customerId,
    'customer_relation': quotation.customerRelation,
    'quotation_name': quotation.quotationName,
    'quotation_address': quotation.quotationAddress,
    'quotation_postal': quotation.quotationPostal,
    'quotation_city': quotation.quotationCity,
    'quotation_country_code': quotation.quotationCountryCode,
    'quotation_email': quotation.quotationEmail,
    'quotation_tel': quotation.quotationTel,
    'quotation_mobile': quotation.quotationMobile,
    'quotation_contact': quotation.quotationContact,
    'quotation_reference': quotation.quotationReference,
    'description': quotation.description,
    'quotation_images': [],
    'quotation_products': products,
    'travel_to': quotation.travelTo,
    'travel_back': quotation.travelBack,
    'distance_to': quotation.distanceTo,
    'distance_back': quotation.distanceBack,
    'work_hours': quotation.workHours,
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

class QuotationPage extends StatefulWidget {
  @override
  _QuotationPageState createState() => _QuotationPageState();
}

class _QuotationPageState extends State<QuotationPage> {
  Order _order;
  List<QuotationProduct> _quotationProducts = [];

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _formKeyQuotationDetails = GlobalKey<FormState>();

  final TextEditingController _typeAheadController = TextEditingController();
  QuotationProduct _selectedQuotationProduct;
  String _selectedProductName;

  var _productIdentifierController = TextEditingController();
  var _productNameController = TextEditingController();
  var _productAmountController = TextEditingController();

  var _contactController = TextEditingController();
  var _emailController = TextEditingController();
  var _descriptionController = TextEditingController();
  var _worhourskHourController = TextEditingController();
  var _travelToController = TextEditingController();
  var _travelBackController = TextEditingController();
  var _distanceToController = TextEditingController();
  var _distanceBackController = TextEditingController();

  var _workhoursMin = '00';
  var _travelToMin = '00';
  var _travelBackMin = '00';

  FocusNode amountFocusNode;

  @override
  void initState() {
    super.initState();

    amountFocusNode = FocusNode();
  }

  bool _deleteQuotationProduct(QuotationProduct product) {
    // remove product from List
    List<QuotationProduct> newList = [];
    for(int i=0; i<_quotationProducts.length; i++) {
      if (_quotationProducts[i].productId == product.productId) {
        continue;
      }

      newList.add(_quotationProducts[i]);
    }

    _quotationProducts = newList;

    return true;
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
    ).then((dialogResult) {
      if (dialogResult) {
        bool result = _deleteQuotationProduct(product);

        // fetch and refresh screen
        if (result) {
          setState(() {});
        }
      }
    });
  }

  _buildWorkhoursMinutes() {
    return DropdownButton<String>(
      value: _workhoursMin,
      items: <String>['00', '15', '30', '45'].map((String value) {
        return new DropdownMenuItem<String>(
          child: new Text(value),
          value: value,
        );
      }).toList(),
      onChanged: (newValue) {
        setState(() {
          _workhoursMin = newValue;
        });
      },
    );
  }

  _buildTravelToMinutes() {
    return DropdownButton<String>(
      value: _travelToMin,
      items: <String>['00', '15', '30', '45'].map((String value) {
        return new DropdownMenuItem<String>(
          child: new Text(value),
          value: value,
        );
      }).toList(),
      onChanged: (newValue) {
        setState(() {
          _travelToMin = newValue;
        });
      },
    );
  }

  _buildTravelBackMinutes() {
    return DropdownButton<String>(
      value: _travelBackMin,
      items: <String>['00', '15', '30', '45'].map((String value) {
        return new DropdownMenuItem<String>(
          child: new Text(value),
          value: value,
        );
      }).toList(),
      onChanged: (newValue) {
        setState(() {
          _travelBackMin = newValue;
        });
      },
    );
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
    _contactController.text = _order.orderContact;
    _emailController.text = _order.orderEmail;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text('New material',  style: TextStyle(fontWeight: FontWeight.bold)),
        SizedBox(
          height: 10.0,
        ),
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

            // set focus to amount
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
          child: Text('Add product'),
          onPressed: () {
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

              FocusScope.of(context).unfocus();
              setState(() {});

            } else {
                displayDialog(context, 'Error', 'Error storing material');
            }
          },
        ),
        SizedBox(
          height: 10.0,
        ),
      ],
    );
  }

  Widget _buildFormQuotationDetails() {
    final double leftWidth = 100;
    final double rightWidth = 50;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        // text fields for the rest of the quotation
        Text('Quotation details', style: TextStyle(fontWeight: FontWeight.bold)),
        SizedBox(
          height: 10.0,
        ),
        Text('Contact'),
        TextFormField(
            controller: _contactController,
            validator: (value) {
              if (value.isEmpty) {
                return 'Please enter contact';
              }
              return null;
            }),
        SizedBox(
          height: 10.0,
        ),
        Text('Email'),
        TextFormField(
            controller: _emailController,
            validator: (value) {
              if (value.isEmpty) {
                return 'Please enter email';
              }
              return null;
            }),
        SizedBox(
          height: 10.0,
        ),
        Text('Description'),
        TextFormField(
            controller: _descriptionController,
            validator: (value) {
              if (value.isEmpty) {
                return 'Please enter email';
              }
              return null;
            }),
        SizedBox(
          height: 10.0,
        ),

        // workhours/travel to/travel back/distance to/distance back
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Column(
              children: [
                Text('Work hours'),
                Row(
                  children: [
                    Container(
                      width: leftWidth,
                      child: TextFormField(
                          controller: _worhourskHourController,
                          validator: (value) {
                            if (value.isEmpty) {
                              return 'Enter work start hour';
                            }
                            return null;
                          }
                      ),
                    ),
                    Container(
                        width: rightWidth,
                        child: _buildWorkhoursMinutes()
                    )
                  ],
                )
              ],
            )
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Column(
              children: [
                Text('Travel to'),
                Row(
                  children: [
                    Container(
                      width: leftWidth,
                      child: TextFormField(
                          controller: _travelToController,
                          validator: (value) {
                            if (value.isEmpty) {
                              return 'Enter travel hours to';
                            }
                            return null;
                          }
                      ),
                    ),
                    Container(
                        width: rightWidth,
                        child: _buildTravelToMinutes()
                    )
                  ],
                )
              ],
            )
          ],
        ),
        SizedBox(
          height: 10.0,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Column(
              children: [
                Text('Travel back'),
                Row(
                  children: [
                    Container(
                      width: leftWidth,
                      child: TextFormField(
                          controller: _travelBackController,
                          validator: (value) {
                            if (value.isEmpty) {
                              return 'Enter travel hours back';
                            }
                            return null;
                          }
                      ),
                    ),
                    Container(
                        width: rightWidth,
                        child: _buildTravelBackMinutes()
                    )
                  ],
                )
              ],
            )
          ],
        ),
        SizedBox(
          height: 10.0,
        ),
        Text('Distance to'),
        Container(
          width: 150,
          child: TextFormField(
              controller: _distanceToController,
              validator: (value) {
                if (value.isEmpty) {
                  return 'Please enter distance to';
                }
                return null;
              }),
        ),

        SizedBox(
          height: 10.0,
        ),
        Text('Distance back'),
        Container(
          width: 150,
          child: TextFormField(
              controller: _distanceBackController,
              validator: (value) {
                if (value.isEmpty) {
                  return 'Please enter distance back';
                }
                return null;
              }),
        ),

        SizedBox(
          height: 20.0,
        ),
        Divider(),
        RaisedButton(
          child: Text('Submit'),
          onPressed: () async {
            if (this._formKeyQuotationDetails.currentState.validate()) {
              this._formKeyQuotationDetails.currentState.save();

              Quotation quotation = Quotation(
                orderId: _order.id,
                customerId: _order.customerId,
                quotationName: _order.orderName,
                quotationAddress: _order.orderAddress,
                quotationPostal: _order.orderPostal,
                quotationCity: _order.orderCity,
                quotationCountryCode: _order.orderCountryCode,
                quotationTel: _order.orderTel,
                quotationMobile: _order.orderMobile,
                quotationReference: _order.orderReference,

                quotationEmail: _emailController.text,
                description: _descriptionController.text,
                quotationContact: _contactController.text,
                workHours: '',
                travelTo: '',
                travelBack: '',
                distanceTo: 0,
                distanceBack: 0,
                signatureEngineer: '',
                signatureNameEngineer: '',
                signatureCustomer: '',
                signatureNameCustomer: '',
                quotationProducts: _quotationProducts,
              );

              // bool result = await storeQuotation(http.Client(), quotation);
              bool result = false;

              if (result) {
                // nav to quotation view
              } else {
                return displayDialog(
                    context, 'Error', 'Error saving quotation');
              }
            }
          },
        ),
        SizedBox(
          height: 20.0,
        ),
        Divider(),
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
          title: Text('Quotation'),
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
                                  ),
                                  Divider(),
                                  SizedBox(
                                    height: 20.0,
                                  ),
                                  Form(
                                      key: _formKeyQuotationDetails,
                                      child: _buildFormQuotationDetails()
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
