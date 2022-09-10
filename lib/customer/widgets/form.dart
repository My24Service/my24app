import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

import 'package:my24app/core/widgets/widgets.dart';
import 'package:my24app/customer/models/models.dart';
import 'package:my24app/customer/api/customer_api.dart';
import 'package:my24app/customer/pages/list.dart';

class CustomerFormWidget extends StatefulWidget {
  final bool isPlanning;
  final Customer customer;

  CustomerFormWidget({
    @required this.isPlanning,
    @required this.customer,
    Key key,
  }): super(key: key);

  @override
  State<StatefulWidget> createState() => new _CustomerFormWidgetState();
}

class _CustomerFormWidgetState extends State<CustomerFormWidget> {
  String _customerId;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  String _countryCode = 'NL';

  var _customerIdController = TextEditingController();
  var _nameController = TextEditingController();
  var _addressController = TextEditingController();
  var _postalController = TextEditingController();
  var _cityController = TextEditingController();
  var _emailController = TextEditingController();
  var _telController = TextEditingController();
  var _mobileController = TextEditingController();
  var _contactController = TextEditingController();
  var _remarksController = TextEditingController();

  bool _inAsyncCall = false;

  @override
  Widget build(BuildContext context) {
    return ModalProgressHUD(child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
        child: Container(
            alignment: Alignment.center,
            child: SingleChildScrollView(
                child: Column(
                  children: [
                    createHeader('customers.form.header_details'.tr()),
                    _createCustomerForm(context),
                    SizedBox(
                      height: 20,
                    ),
                    _createSubmitButton(),
                  ],
                )
            )
        )
    ), inAsyncCall: _inAsyncCall);
  }

  @override
  void initState() {
    if (widget.customer != null) {
      _fillCustomerData();
    } else {
      _doAsync();
    }

    super.initState();
  }

  _doAsync() async {
    await _doFetchNewCustomerId();
  }

  _doFetchNewCustomerId() async {
    String customerId = await customerApi.fetchNewCustomerId();

    setState(() {
      _customerId = customerId;
      _customerIdController.text = customerId;
    });
  }

  _fillCustomerData() async {
    _customerIdController.text = widget.customer.customerId;
    _nameController.text = widget.customer.name;
    _addressController.text = widget.customer.address;
    _postalController.text = widget.customer.postal;
    _cityController.text = widget.customer.city;
    _countryCode = widget.customer.countryCode;
    _telController.text = widget.customer.tel;
    _mobileController.text = widget.customer.mobile;
    _emailController.text = widget.customer.email;
    _contactController.text = widget.customer.contact;
    _remarksController.text = widget.customer.remarks;
  }
  
  Widget _createCustomerForm(BuildContext context) {
    return Form(key: _formKey, child: Table(
        children: [
          TableRow(
              children: [
                Padding(padding: EdgeInsets.only(top: 16),
                    child: Text('customers.info_customer_id'.tr(),
                        style: TextStyle(fontWeight: FontWeight.bold))
                ),
                TextFormField(
                    readOnly: true,
                    controller: _customerIdController,
                    validator: (value) {
                      return null;
                    }
                ),
              ]
          ),
          TableRow(
              children: [
                Padding(padding: EdgeInsets.only(top: 16),
                    child: Text('customers.info_name'.tr(),
                        style: TextStyle(fontWeight: FontWeight.bold))
                ),
                TextFormField(
                    controller: _nameController,
                    validator: (value) {
                      if (value.isEmpty) {
                        return 'customers.validator_name'.tr();
                      }
                      return null;
                    }
                ),
              ]
          ),
          TableRow(
              children: [
                Padding(padding: EdgeInsets.only(top: 16),
                    child: Text('customers.info_address'.tr(),
                        style: TextStyle(fontWeight: FontWeight.bold))
                ),
                TextFormField(
                    controller: _addressController,
                    validator: (value) {
                      if (value.isEmpty) {
                        return 'customers.validator_address'.tr();
                      }
                      return null;
                    }
                ),
              ]
          ),
          TableRow(
              children: [
                Padding(padding: EdgeInsets.only(top: 16),
                    child: Text('customers.info_postal'.tr(),
                        style: TextStyle(fontWeight: FontWeight.bold))
                ),
                TextFormField(
                    controller: _postalController,
                    validator: (value) {
                      if (value.isEmpty) {
                        return 'customers.validator_postal'.tr();
                      }
                      return null;
                    }
                ),
              ]
          ),
          TableRow(
              children: [
                Padding(padding: EdgeInsets.only(top: 16),
                    child: Text('customers.info_city'.tr(),
                        style: TextStyle(fontWeight: FontWeight.bold))
                ),
                TextFormField(
                    controller: _cityController,
                    validator: (value) {
                      if (value.isEmpty) {
                        return 'customers.validator_city'.tr();
                      }
                      return null;
                    }
                ),
              ]
          ),
          TableRow(
              children: [
                Padding(padding: EdgeInsets.only(top: 16),
                    child: Text('customers.info_country_code'.tr(),
                        style: TextStyle(fontWeight: FontWeight.bold))
                ),
                DropdownButtonFormField<String>(
                  value: _countryCode,
                  items: ['NL', 'BE', 'LU', 'FR', 'DE'].map((String value) {
                    return new DropdownMenuItem<String>(
                      child: new Text(value),
                      value: value,
                    );
                  }).toList(),
                  onChanged: (newValue) {
                    setState(() {
                      _countryCode = newValue;
                    });
                  },
                )
              ]
          ),
          TableRow(
              children: [
                Padding(padding: EdgeInsets.only(top: 16),
                    child: Text('customers.info_email'.tr(),
                        style: TextStyle(fontWeight: FontWeight.bold))
                ),
                TextFormField(
                    controller: _emailController,
                    validator: (value) {
                      return null;
                    }
                )
              ]
          ),
          TableRow(
              children: [
                Padding(padding: EdgeInsets.only(top: 16),
                    child: Text('customers.info_tel'.tr(),
                        style: TextStyle(fontWeight: FontWeight.bold))
                ),
                TextFormField(
                    controller: _telController,
                    validator: (value) {
                      return null;
                    }
                )
              ]
          ),
          TableRow(
              children: [
                Padding(padding: EdgeInsets.only(top: 16),
                    child: Text('customers.info_mobile'.tr(),
                        style: TextStyle(fontWeight: FontWeight.bold))
                ),
                TextFormField(
                    controller: _mobileController,
                    validator: (value) {
                      return null;
                    }
                )
              ]
          ),
          TableRow(
              children: [
                Padding(padding: EdgeInsets.only(top: 16),
                    child: Text('customers.info_contact'.tr(),
                        style: TextStyle(fontWeight: FontWeight.bold))
                ),
                Container(
                    width: 300.0,
                    child: TextFormField(
                      controller: _contactController,
                      keyboardType: TextInputType.multiline,
                      maxLines: null,
                    )
                ),
              ]
          ),
          TableRow(
              children: [
                Padding(padding: EdgeInsets.only(top: 16),
                    child: Text('customers.info_remarks'.tr(),
                        style: TextStyle(fontWeight: FontWeight.bold))
                ),
                Container(
                    width: 300.0,
                    child: TextFormField(
                      controller: _remarksController,
                      keyboardType: TextInputType.multiline,
                      maxLines: null,
                    )
                ),
              ]
          ),
        ]
    ));
  }

  Widget _createSubmitButton() {
    final String buttonText = widget.customer != null ? 'customers.form.button_update_customer'.tr() : 'customers.form.button_add_customer'.tr();

    return createDefaultElevatedButton(
        buttonText,
      _handleSubmit
    );
  }

  Future<void> _handleSubmit() async {
    if (this._formKey.currentState.validate()) {
      this._formKey.currentState.save();

      Customer customer = Customer(
        customerId: _customerId,
        name: _nameController.text,
        address: _addressController.text,
        postal: _postalController.text,
        city: _cityController.text,
        countryCode: _countryCode,
        tel: _telController.text,
        mobile: _mobileController.text,
        email: _emailController.text,
        contact: _contactController.text,
        remarks: _remarksController.text,
      );

      setState(() {
        _inAsyncCall = true;
      });

      Customer newCustomer;
      if (widget.customer != null) {
        newCustomer = await customerApi.editCustomer(customer, widget.customer.id);
      } else {
        newCustomer = await customerApi.insertCustomer(customer);
      }

      setState(() {
        _inAsyncCall = false;
      });

      if (newCustomer == null) {
        final String content = widget.customer != null ? 'customers.form.error_dialog_content_update'.tr() : 'customers.form.error_dialog_content_add'.tr();

        displayDialog(context,
            'generic.error_dialog_title'.tr(),
            content
        );
      }

      final String snackbarText = widget.customer != null ? 'customers.form.snackbar_updated'.tr() : 'customers.form.snackbar_added'.tr();
      createSnackBar(context, snackbarText);
      await Future.delayed(Duration(milliseconds: 500));

      if (widget.isPlanning) {
        // nav to customer list
        final page = CustomerListPage();

        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) => page)
        );
      } else {
        // nav to sales user customers
        final page = CustomerListPage();

        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) => page)
        );
      }
    }
  }
}