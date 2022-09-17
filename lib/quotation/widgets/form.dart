import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

import 'package:my24app/core/widgets/widgets.dart';
import 'package:my24app/customer/api/customer_api.dart';
import 'package:my24app/customer/models/models.dart';
import 'package:my24app/quotation/blocs/quotation_bloc.dart';
import 'package:my24app/quotation/models/models.dart';
import 'package:my24app/quotation/api/quotation_api.dart';
import 'package:my24app/quotation/pages/images.dart';
import 'package:my24app/quotation/pages/list.dart';

class QuotationFormWidget extends StatefulWidget {
  final bool isPlanning;

  QuotationFormWidget({
    @required this.isPlanning,
    Key key,
  }): super(key: key);

  @override
  State<StatefulWidget> createState() => new _QuotationFormWidgetState();
}

class _QuotationFormWidgetState extends State<QuotationFormWidget> {
  List<QuotationPartLine> _quotationProducts = [];

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _formKeyQuotationDetails = GlobalKey<FormState>();

  final TextEditingController _typeAheadControllerCustomer = TextEditingController();
  CustomerTypeAheadModel _selectedQuotationCustomer;
  String _selectedCustomerName;

  var _equipmentIdentifierController = TextEditingController();
  var _equipmentNameController = TextEditingController();
  var _equipmentAmountController = TextEditingController();

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

  bool _inAsyncCall = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ModalProgressHUD(
        child: Container(
            margin: new EdgeInsets.symmetric(horizontal: 20.0),
            child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  // customer form & autocomplete
                  createHeader('generic.info_customer'.tr()),
                  _buildCustomerForm(),
                  Divider(),
                  // products
                  createHeader('quotations.form.header_add_equipment'.tr()),
                  Form(
                      key: _formKey,
                      child: _buildEquipmentForm()
                  ),
                  createHeader('quotations.form.header_equipment'.tr()),
                  _buildEquipmentTable(),
                  Divider(),
                  // details
                  createHeader('quotations.form.header_quotation_details'.tr()),
                  Form(
                      key: _formKeyQuotationDetails,
                      child: _buildQuotationDetailsForm()
                  ),
                ]
            )
        ), inAsyncCall: _inAsyncCall);
  }

  Widget _buildCustomerForm() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        TypeAheadFormField(
          textFieldConfiguration: TextFieldConfiguration(
              controller: this._typeAheadControllerCustomer,
              decoration: InputDecoration(labelText: 'quotations.form.typeahead_label'.tr())),
          suggestionsCallback: (pattern) async {
            return await customerApi.customerTypeAhead(pattern);
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
              return 'quotations.form.typeahead_validator_customer'.tr();
            }

            return null;
          },
          onSaved: (value) => this._selectedCustomerName = value,
        ),

        SizedBox(
          height: 10.0,
        ),
        Text('generic.info_customer'.tr()),
        TextFormField(
            readOnly: true,
            controller: _customerNameController,
            validator: (value) {
              if (value.isEmpty) {
                return 'quotations.form.validator_customer'.tr();
              }
              return null;
            }
        ),
        SizedBox(
          height: 10.0,
        ),
        Text('generic.info_address'.tr()),
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
        Text('generic.info_postal'.tr()),
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
        Text('generic.info_city'.tr()),
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
        Text('generic.info_country_code'.tr()),
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
        Text('generic.info_tel'.tr()),
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
        Text('generic.info_mobile'.tr()),
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
        Text('generic.info_email'.tr()),
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
        Text('generic.info_contact'.tr()),
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

  bool _deleteQuotationProduct(QuotationPartLine product) {
    // remove product from List
    List<QuotationPartLine> newList = [];
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

  _showDeleteDialog(QuotationPartLine product, BuildContext context) {
    showDeleteDialogWrapper(
        'quotations.form.delete_dialog_title'.tr(),
        'quotations.form.delete_dialog_content'.tr(),
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

  Widget _buildEquipmentTable() {
    List<TableRow> rows = [];

    // header
    rows.add(TableRow(
      children: [
        Column(children: [
          createTableHeaderCell('generic.info_equipment'.tr())
        ]),
        Column(children: [
          createTableHeaderCell('generic.info_identifier'.tr())
        ]),
        Column(children: [
          createTableHeaderCell('generic.info_amount'.tr())
        ]),
        Column(children: [
          createTableHeaderCell('generic.action_delete'.tr())
        ])
      ],
    ));

    // products
    for (int i = 0; i < _quotationProducts.length; ++i) {
      QuotationPartLine product = _quotationProducts[i];

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

  Widget _buildEquipmentForm() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text('generic.info_equipment'.tr()),
        TextFormField(
            controller: _equipmentNameController,
            validator: (value) {
              if (value.isEmpty) {
                return 'quotations.form.validator_equipment'.tr();
              }
              return null;
            }),
        SizedBox(
          height: 10.0,
        ),
        Text('generic.info_identifier'.tr()),
        TextFormField(
            controller: _equipmentIdentifierController,
            validator: (value) {
              return null;
            }),
        SizedBox(
          height: 10.0,
        ),
        Text('generic.info_amount'.tr()),
        TextFormField(
            keyboardType: TextInputType.number,
            controller: _equipmentAmountController,
            validator: (value) {
              if (value.isEmpty) {
                return 'quotations.form.validator_amount'.tr();
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
          child: Text('quotations.form.button_submit_equipment'.tr()),
          onPressed: () {
            if (this._formKey.currentState.validate()) {
              this._formKey.currentState.save();

              QuotationPartLine product = QuotationPartLine(
                amount: double.parse(_equipmentAmountController.text),
                productName: _equipmentNameController.text,
                productIdentifier: _equipmentIdentifierController.text,
              );

              _quotationProducts.add(product);

              // reset fields
              _equipmentAmountController.text = '';
              _equipmentNameController.text = '';
              _equipmentIdentifierController.text = '';

              FocusScope.of(context).unfocus();
              setState(() {});

            } else {
              displayDialog(context,
                  'generic.error_dialog_title'.tr(),
                  'quotations.form.error_adding_equipment'.tr());
            }
          },
        ),
        SizedBox(
          height: 10.0,
        ),
      ],
    );
  }

  _navQuotationList() {
    final page = QuotationListPage(mode: listModes.ALL);
    Navigator.pushReplacement(context,
        MaterialPageRoute(
            builder: (context) => page
        )
    );
  }

  _navUnacceptedList() {
    final page = QuotationListPage(mode: listModes.UNACCEPTED);
    Navigator.pushReplacement(context,
        MaterialPageRoute(
            builder: (context) => page
        )
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
        Text('quotations.form.info_description'.tr()),
        TextFormField(
            controller: _descriptionController,
            keyboardType: TextInputType.text,
            validator: (value) {
              return null;
            }),
        SizedBox(
          height: 10.0,
        ),
        Text('quotations.form.info_reference'.tr()),
        TextFormField(
            controller: _referenceController,
            keyboardType: TextInputType.text,
            validator: (value) {
              return null;
            }),
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
                              Text(
                                  'generic.info_workhours'.tr(),
                                  style: TextStyle(fontSize: 11.0)
                              ),
                              SizedBox(width: 10),
                            ]
                        ),
                        TableRow(
                            children: [
                              Container(
                                child: TextFormField(
                                    controller: _worhourskHourController,
                                    keyboardType: TextInputType.number,
                                    validator: (value) {
                                      return null;
                                    }
                                ),
                              ),
                              Container(
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
                              Text(
                                  'generic.info_travel_to'.tr(),
                                  style: TextStyle(fontSize: 11.0)
                              ),
                              SizedBox(width: 10),
                            ]
                        ),
                        TableRow(
                            children: [
                              Container(
                                child: TextFormField(
                                    controller: _travelToController,
                                    keyboardType: TextInputType.number,
                                    validator: (value) {
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
                              Text(
                                  'generic.info_travel_back'.tr(),
                                  style: TextStyle(fontSize: 11.0)
                              ),
                              SizedBox(width: 10),
                            ]
                        ),
                        TableRow(
                            children: [
                              Container(
                                child: TextFormField(
                                    controller: _travelBackController,
                                    keyboardType: TextInputType.number,
                                    validator: (value) {
                                      return null;
                                    }
                                ),
                              ),
                              Container(
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
                            Text('generic.info_distance_to'.tr()),
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
                            Text('generic.info_distance_back'.tr()),
                          ]
                      ),
                      TableRow(
                          children: [
                            Container(
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
          child: Text('quotations.form.button_submit_quotation'.tr()),
          onPressed: () async {
            if (this._formKeyQuotationDetails.currentState.validate()) {
              this._formKeyQuotationDetails.currentState.save();

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

                signatureEngineer: '',
                signatureNameEngineer: '',
                signatureCustomer: '',
                signatureNameCustomer: '',
              );

              setState(() {
                _inAsyncCall = true;
              });

              Quotation newQuotation = await quotationApi.insertQuotation(quotation);

              setState(() {
                _inAsyncCall = false;
              });
              
              if (newQuotation == null) {
                  displayDialog(
                      context,
                      'generic.error_dialog_title'.tr(),
                      'quotations.form.error_creating'.tr()
                  );
                  return;
              }
              
              createSnackBar(context, 'quotations.form.snackbar_created'.tr());

              showDialog<void>(
                  context: context,
                  barrierDismissible: false, // user must tap button!
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text('quotations.form.dialog_add_images_title'.tr()),
                      content: Text('quotations.form.dialog_add_images_content'.tr()),
                      actions: <Widget>[
                        TextButton(
                          child: Text('quotations.form.dialog_add_images_button_yes'.tr()),
                          onPressed: () {
                          },
                        ),
                        TextButton(
                          child: Text('quotations.form.dialog_add_images_button_no'.tr()),
                          onPressed: () {
                            if (widget.isPlanning) {
                              _navQuotationList();
                            } else {
                              _navUnacceptedList();
                            }
                          },
                        ),
                      ],
                    );
                  }
              );
            }
          },
        ),
      ],
    );
  }
}
