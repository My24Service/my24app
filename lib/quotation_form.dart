import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_typeahead/flutter_typeahead.dart';

import 'models.dart';
import 'utils.dart';
import 'assigned_order.dart';
import 'quotation_not_accepted_list.dart';


Future<bool> storeQuotation(http.Client client, Quotation quotation) async {
  // refresh token
  SlidingToken newToken = await refreshSlidingToken(client);

  if (newToken == null) {
    // do nothing
    return false;
  }

  // store quotation in the API
  // SharedPreferences prefs = await SharedPreferences.getInstance();
  // int customerRelation = prefs.getInt('customer_relation');
  final String token = newToken.token;
  final url = await getUrl('/quotation/quotation/');
  final authHeaders = getHeaders(token);
  final Map<String, String> headers = {"Content-Type": "application/json; charset=UTF-8"};
  Map<String, String> allHeaders = {};
  allHeaders.addAll(authHeaders);
  allHeaders.addAll(headers);

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
  print(response.body);

  // return
  if (response.statusCode == 401) {
    return false;
  }

  if (response.statusCode == 201) {
    return true;
  }

  return false;
}

class QuotationFormPage extends StatefulWidget {
  @override
  _QuotationFormPageState createState() => _QuotationFormPageState();
}

class _QuotationFormPageState extends State<QuotationFormPage> {
  List<QuotationProduct> _quotationProducts = [];

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _formKeyQuotationDetails = GlobalKey<FormState>();

  final TextEditingController _typeAheadControllerProduct = TextEditingController();
  InventoryProductTypeAheadModel _selectedProduct;
  String _selectedProductName;

  final TextEditingController _typeAheadControllerCustomer = TextEditingController();
  CustomerTypeAheadModel _selectedQuotationCustomer;
  String _selectedCustomerName;

  var _productIdentifierController = TextEditingController();
  var _productNameController = TextEditingController();
  var _productAmountController = TextEditingController();

  int _customerPk;
  String _customerId;
  var _customerNameController = TextEditingController();
  var _customerAddressController = TextEditingController();
  var _customerPostalController = TextEditingController();
  var _customerCityController = TextEditingController();
  var _customerCountryCodeController = TextEditingController();
  var _customerTelController = TextEditingController();
  var _customerMobileController = TextEditingController();
  var _customerEmailController = TextEditingController();
  var _customerContactController = TextEditingController();

  var _descriptionController = TextEditingController();
  var _referenceController = TextEditingController();
  var _worhourskHourController = TextEditingController();
  var _travelToController = TextEditingController();
  var _travelBackController = TextEditingController();
  var _distanceToController = TextEditingController();
  var _distanceBackController = TextEditingController();

  var _workhoursMin = '00';
  var _travelToMin = '00';
  var _travelBackMin = '00';

  @override
  void initState() {
    super.initState();
  }

  Widget _buildCustomerForm() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        TypeAheadFormField(
          textFieldConfiguration: TextFieldConfiguration(
              controller: this._typeAheadControllerCustomer,
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
            _selectedQuotationCustomer = suggestion;
            this._typeAheadControllerCustomer.text = '';

            // fill fields
            _customerPk = _selectedQuotationCustomer.id;
            _customerId = _selectedQuotationCustomer.customerId;
            _customerNameController.text = _selectedQuotationCustomer.name;
            _customerAddressController.text = _selectedQuotationCustomer.address;
            _customerPostalController.text = _selectedQuotationCustomer.postal;
            _customerCityController.text = _selectedQuotationCustomer.city;
            _customerCountryCodeController.text = _selectedQuotationCustomer.countryCode;
            _customerTelController.text = _selectedQuotationCustomer.tel;
            _customerMobileController.text = _selectedQuotationCustomer.mobile;
            _customerEmailController.text = _selectedQuotationCustomer.email;
            _customerContactController.text = _selectedQuotationCustomer.contact;

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
        Text('Customer'),
        TextFormField(
            readOnly: true,
            controller: _customerNameController,
            validator: (value) {
              if (value.isEmpty) {
                return 'Please enter a customer';
              }
              return null;
            }
        ),
        SizedBox(
          height: 10.0,
        ),
        Text('Address'),
        TextFormField(
            readOnly: true,
            controller: _customerAddressController,
            validator: (value) {
              return null;
            }
        ),
        SizedBox(
          height: 10.0,
        ),
        Text('Postal'),
        TextFormField(
            readOnly: true,
            controller: _customerPostalController,
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
            controller: _customerCityController,
            validator: (value) {
              return null;
            }
        ),
        SizedBox(
          height: 10.0,
        ),
        Text('Country'),
        TextFormField(
            readOnly: true,
            controller: _customerCountryCodeController,
            validator: (value) {
              return null;
            }
        ),
        SizedBox(
          height: 10.0,
        ),
        Text('Tel.'),
        TextFormField(
            readOnly: true,
            controller: _customerTelController,
            validator: (value) {
              return null;
            }
        ),
        SizedBox(
          height: 10.0,
        ),
        Text('Mobile'),
        TextFormField(
            readOnly: true,
            controller: _customerMobileController,
            validator: (value) {
              return null;
            }
        ),
        SizedBox(
          height: 10.0,
        ),
        Text('Email'),
        TextFormField(
            // readOnly: true,
            controller: _customerEmailController,
            validator: (value) {
              return null;
            }
        ),
        SizedBox(
          height: 10.0,
        ),
        Text('Contact'),
        TextFormField(
            // readOnly: true,
            controller: _customerContactController,
            validator: (value) {
              return null;
            }
        ),
        SizedBox(
          height: 10.0,
        ),
      ],
    );
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

    setState(() {});

    return true;
  }

  _showDeleteDialog(QuotationProduct product, BuildContext context) {
    showDeleteDialog(
        'Delete product', 'Do you want to delete this product?',
        context, () => _deleteQuotationProduct(product));
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
    for (int i = 0; i < _quotationProducts.length; ++i) {
      QuotationProduct product = _quotationProducts[i];

      rows.add(TableRow(children: [
        Column(
            children: [
              createTableColumnCell(product.productName)
            ]
        ),
        Column(
            children: [
              createTableColumnCell(product.productIdentifier)
            ]
        ),
        Column(
            children: [
              createTableColumnCell("${product.amount}")
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

  Widget _buildProductForm() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        TypeAheadFormField(
          textFieldConfiguration: TextFieldConfiguration(
              controller: this._typeAheadControllerProduct,
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
            this._typeAheadControllerProduct.text = _selectedProduct.productName;

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
            keyboardType: TextInputType.number,
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
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            primary: Colors.blue, // background
            onPrimary: Colors.white, // foreground
          ),
          child: Text('Add product'),
          onPressed: () {
            if (this._formKey.currentState.validate()) {
              this._formKey.currentState.save();

              QuotationProduct product = QuotationProduct(
                amount: double.parse(_productAmountController.text),
                productId: _selectedProduct.id,
                productName: _selectedProduct.productName,
                productIdentifier: _selectedProduct.productIdentifier,
              );

              _quotationProducts.add(product);

              // reset fields
              _typeAheadControllerProduct.text = '';
              _productAmountController.text = '';
              _productNameController.text = '';
              _productIdentifierController.text = '';

              FocusScope.of(context).unfocus();
              setState(() {});

            } else {
                displayDialog(context, 'Error', 'Error storing product');
            }
          },
        ),
        SizedBox(
          height: 10.0,
        ),
      ],
    );
  }

  Widget _buildQuotationDetailsForm() {
    final double leftWidth = 100;
    final double rightWidth = 50;
    _distanceToController.text = '0';
    _distanceBackController.text = '0';

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        // text fields for the rest of the quotation
        Text('Description'),
        TextFormField(
            controller: _descriptionController,
            keyboardType: TextInputType.text,
            validator: (value) {
              return null;
            }),
        SizedBox(
          height: 10.0,
        ),
        Text('Reference'),
        TextFormField(
            controller: _referenceController,
            keyboardType: TextInputType.text,
            validator: (value) {
              return null;
            }),
        SizedBox(
          height: 10.0,
        ),
        // workhours/travel to/travel back/distance to/distance back
        Table(
          children: [
            TableRow(
              children: [
                Table(
                  children: [
                    TableRow(
                      children: [
                        Text('Work hours.', style: TextStyle(fontSize: 11.0)),
                        SizedBox(width: 10),
                      ]
                    ),
                    TableRow(
                      children: [
                        Container(
                          // width: leftWidth,
                          child: TextFormField(
                              controller: _worhourskHourController,
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                return null;
                              }
                          ),
                        ),
                        Container(
                            // width: rightWidth,
                            child: _buildWorkhoursMinutes()
                        )
                      ]
                    )
                  ],
                ),
                Table(
                  children: [
                    TableRow(
                      children: [
                        Text('Travel to', style: TextStyle(fontSize: 11.0)),
                        SizedBox(width: 10),
                      ]
                    ),
                    TableRow(
                      children: [
                        Container(
                          // width: leftWidth,
                          child: TextFormField(
                              controller: _travelToController,
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                // if (value.isEmpty) {
                                //   return 'Enter travel hours to';
                                // }
                                return null;
                              }
                          ),
                        ),
                        Container(
                            // width: rightWidth,
                            child: _buildTravelToMinutes()
                        )

                      ]
                    )
                  ],
                ),
                Table(
                  children: [
                    TableRow(
                      children: [
                        Text('Travel back', style: TextStyle(fontSize: 11.0)),
                        SizedBox(width: 10),
                      ]
                    ),
                    TableRow(
                      children: [
                        Container(
                          // width: leftWidth,
                          child: TextFormField(
                              controller: _travelBackController,
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                return null;
                              }
                          ),
                        ),
                        Container(
                            // width: rightWidth,
                            child: _buildTravelBackMinutes()
                        )
                      ]
                    )
                  ],
                )
              ]
            ),
          ]
        ),
        SizedBox(
          height: 10.0,
        ),
        Table(
          children: [
            TableRow(
              children: [
                Table(
                  children: [
                    TableRow(
                      children: [
                        Text('Distance to'),
                      ]
                    ),
                    TableRow(
                      children: [
                        Container(
                          width: 150,
                          child: TextFormField(
                              controller: _distanceToController,
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                return null;
                              }),
                        )
                      ]
                    )
                  ],
                ),
                SizedBox(width: 10),
                Table(
                  children: [
                    TableRow(
                      children: [
                        Text('Distance back'),
                      ]
                    ),
                    TableRow(
                      children: [
                        Container(
                          // width: 150,
                          child: TextFormField(
                              controller: _distanceBackController,
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                return null;
                              }),
                        )
                      ]
                    )
                  ],
                )
              ]
            )
          ],
        ),
        SizedBox(
          height: 20.0,
        ),
        Divider(),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            primary: Colors.blue, // background
            onPrimary: Colors.white, // foreground
          ),
          child: Text('Submit'),
          onPressed: () async {
            if (this._formKeyQuotationDetails.currentState.validate()) {
              this._formKeyQuotationDetails.currentState.save();

              String workhours = '00:00:00';
              String travelTo = '00:00:00';
              String travelBack = '00:00:00';

              if (_worhourskHourController.text != '' || _workhoursMin != '00') {
                workhours = '${_worhourskHourController.text}:$_workhoursMin:00';
              }

              if (_travelToController.text != '' || _travelToMin != '00') {
                travelTo = '${_travelToController.text}:$_travelToMin:00';
              }

              if (_travelBackController.text != '' || _travelBackMin != '00') {
                travelBack = '${_travelBackController.text}:$_travelBackMin:00';
              }

              int distanceTo = int.parse(_distanceToController.text);
              int distanceBack = int.parse(_distanceBackController.text);

              print('workhours: $workhours');
              print('travelTo: $travelTo');
              print('travelBack: $travelBack');
              print('distanceTo: $distanceTo');
              print('distanceBack: $distanceBack');
              // return;

              Quotation quotation = Quotation(
                customerRelation: _customerPk,
                customerId: _customerId,
                quotationName: _customerNameController.text,
                quotationAddress: _customerAddressController.text,
                quotationPostal: _customerPostalController.text,
                quotationCity: _customerCityController.text,
                quotationCountryCode: _customerCountryCodeController.text,
                quotationTel: _customerTelController.text,
                quotationMobile: _customerMobileController.text,
                quotationEmail: _customerEmailController.text,
                quotationContact: _customerContactController.text,

                description: _descriptionController.text,
                quotationReference: _referenceController.text,

                workHours: workhours,
                travelTo: travelTo,
                travelBack: travelBack,
                distanceTo: distanceTo,
                distanceBack: distanceBack,
                signatureEngineer: '',
                signatureNameEngineer: '',
                signatureCustomer: '',
                signatureNameCustomer: '',
                quotationProducts: _quotationProducts,
              );

              bool result = await storeQuotation(http.Client(), quotation);

              if (result) {
                // nav to quotation view
                Navigator.push(
                    context, MaterialPageRoute(builder: (context) => QuotationNotAcceptedListPage())
                );
              } else {
                return displayDialog(
                    context, 'Error', 'Error saving quotation');
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
          title: Text('New quotation'),
        ),
        body: GestureDetector(
                onTap: () {
                  FocusScope.of(context).requestFocus(new FocusNode());
                },
                child: Container(
                  margin: new EdgeInsets.symmetric(horizontal: 20.0),
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: [
                      // customer form & autocomplete
                      createHeader('Customer'),
                      _buildCustomerForm(),
                      Divider(),
                      // products
                      createHeader('New product'),
                      Form(
                          key: _formKey,
                          child: _buildProductForm()
                      ),
                      createHeader('Products'),
                      _buildProductsTable(),
                      Divider(),
                      // details
                      createHeader('Quotation details'),
                      Form(
                          key: _formKeyQuotationDetails,
                          child: _buildQuotationDetailsForm()
                      ),
                    ]
                  )
                )
        )
    );
  }
}
