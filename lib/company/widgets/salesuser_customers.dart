import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

import 'package:my24app/company/models/models.dart';
import 'package:my24app/company/blocs/salesuser_customers_bloc.dart';
import 'package:my24app/core/widgets/widgets.dart';
import 'package:my24app/customer/models/models.dart';
import 'package:my24app/customer/models/api.dart';
import 'package:my24app/company/api/company_api.dart';


class SalesUserCustomerListWidget extends StatefulWidget {
  final SalesUserCustomers customers;
  final CustomerApi customerApi = CustomerApi();

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
  BuildContext _context;

  var _addressController = TextEditingController();
  var _cityController = TextEditingController();
  var _emailController = TextEditingController();
  var _telController = TextEditingController();

  bool _inAsyncCall = false;

  @override
  Widget build(BuildContext context) {
    _context = context;

    return ModalProgressHUD(child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Form(
        key: _formKey,
        child: Container(
          alignment: Alignment.center,
          child: SingleChildScrollView(
              child: _showMainView(context)
          ),
        ),
      ),
    ), inAsyncCall: _inAsyncCall);
  }

  Widget _showMainView(BuildContext context) {
    return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          createHeader('sales.customers.header'.tr()),
          _buildForm(),
          Divider(),
          _buildCustomersSection(context)
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
            return await widget.customerApi.customerTypeAhead(pattern);
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
        createDefaultElevatedButton(
            'sales.customers.form_button_submit'.tr(),
            _handleSubmit
        )
      ],
    );
  }

  Future<void> _handleSubmit() async {
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
  }

  Widget _buildCustomersSection(BuildContext context) {
    return buildItemsSection(
        context,
        'sales.customers.header_section'.tr(),
        widget.customers.results,
        (item) {
          String key = "${'generic.info_address'.tr()} / ${'generic.info_city'.tr()}";
          String value = "${item.customerDetails.address} / ${item.customerDetails.city}";
          return [
            ...buildItemListKeyValueList('generic.info_customer'.tr(), item.customerDetails.name),
            ...buildItemListKeyValueList(key, value)
          ];
        },
        (item) {
          return [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                createDeleteButton(
                  "sales.customers.button_delete_customer".tr(),
                  () { _showDeleteDialog(item); }
                ),
              ],
            )
          ];
        }
    );
  }

  _doDelete(SalesUserCustomer salesUserCustomer) async {
    final bloc = BlocProvider.of<SalesUserCustomerBloc>(context);

    bloc.add(SalesUserCustomerEvent(status: SalesUserCustomerEventStatus.DO_ASYNC));
    bloc.add(SalesUserCustomerEvent(
        status: SalesUserCustomerEventStatus.DELETE, value: salesUserCustomer));
  }

  _showDeleteDialog(SalesUserCustomer salesUserCustomer) {
    showDeleteDialogWrapper(
        'sales.customers.delete_dialog_title'.tr(),
        'sales.customers.delete_dialog_content'.tr(),
        () => _doDelete(salesUserCustomer),
        _context
    );
  }
}
