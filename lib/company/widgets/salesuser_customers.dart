import 'dart:convert';
import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:image_picker/image_picker.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

import 'package:my24app/company/models/models.dart';
import 'package:my24app/company/blocs/salesuser_customers_bloc.dart';
import 'package:my24app/core/widgets/widgets.dart';
import 'package:my24app/customer/models/models.dart';
import 'package:my24app/customer/api/customer_api.dart';
import 'package:my24app/company/api/company_api.dart';


class SalesUserCustomerListWidget extends StatefulWidget {
  final SalesUserCustomers customers;

  SalesUserCustomerListWidget({
    Key key,
    @required this.customers,
  }): super(key: key);

  @override
  State<StatefulWidget> createState() => new _SalesUserCustomerListWidgetState();
}

class _SalesUserCustomerListWidgetState extends State<SalesUserCustomerListWidget> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _typeAheadController = TextEditingController();
  CustomerTypeAheadModel _selectedCustomer;
  String _selectedCustomerName;
  int _customerPk;

  var _addressController = TextEditingController();
  var _cityController = TextEditingController();
  var _emailController = TextEditingController();
  var _telController = TextEditingController();

  bool _inAsyncCall = false;

  @override
  Widget build(BuildContext context) {
    return ModalProgressHUD(child: Container(
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
    ), inAsyncCall: _inAsyncCall);
  }

  Widget _showMainView() {
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
              });

              bool result = await companyApi.insertSalesUserCustomer(salesUserCustomer);

              setState(() {
                _inAsyncCall = true;
              });

              if (!result) {
                  displayDialog(context, 'generic.error_dialog_title'.tr(), 'sales.customers.error_adding'.tr());
                  return;
                }
              
              createSnackBar(context, 'sales.customers.snackbar_added'.tr());

              // reset fields
              _typeAheadController.text = '';
              _addressController.text = '';
              _cityController.text = '';
              _emailController.text = '';
              _telController.text = '';

              final SalesUserCustomerBloc bloc = BlocProvider.of<SalesUserCustomerBloc>(context);

              bloc.add(SalesUserCustomerEvent(
                  status: SalesUserCustomerEventStatus.DO_ASYNC));
              bloc.add(SalesUserCustomerEvent(
                  status: SalesUserCustomerEventStatus.FETCH_ALL));
            }
          },
        ),
      ],
    );
  }

  Widget _buildCustomersTable() {
    if(widget.customers.results.length == 0) {
      return buildEmptyListFeedback();
    }

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
    for (int i = 0; i < widget.customers.results.length; ++i) {
      SalesUserCustomer salesUserCustomer = widget.customers.results[i];

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

  _doDelete(SalesUserCustomer salesUserCustomer) async {
    final bloc = BlocProvider.of<SalesUserCustomerBloc>(context);

    bloc.add(SalesUserCustomerEvent(status: SalesUserCustomerEventStatus.DO_ASYNC));
    bloc.add(SalesUserCustomerEvent(
        status: SalesUserCustomerEventStatus.DELETE, value: salesUserCustomer));
  }

  _showDeleteDialog(SalesUserCustomer salesUserCustomer, BuildContext context) {
    showDeleteDialogWrapper(
        'sales.customers.delete_dialog_title'.tr(),
        'sales.customers.delete_dialog_content'.tr(),
        context, () => _doDelete(salesUserCustomer));
  }
}
