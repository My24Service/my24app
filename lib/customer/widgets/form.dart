import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:my24_flutter_core/widgets/slivers/base_widgets.dart';
import 'package:my24_flutter_core/widgets/widgets.dart';
import 'package:my24_flutter_core/i18n.dart';

import 'package:my24app/customer/models/models.dart';
import 'package:my24app/customer/pages/list_form.dart';
import '../blocs/customer_bloc.dart';
import '../models/form_data.dart';

class CustomerFormWidget extends BaseSliverPlainStatelessWidget{
  final CustomerFormData? formData;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final String? memberPicture;
  final bool? newFromEmpty;
  final CoreWidgets widgetsIn;
  final My24i18n i18nIn;

  CustomerFormWidget({
    Key? key,
    required this.memberPicture,
    required this.formData,
    required this.newFromEmpty,
    required this.widgetsIn,
    required this.i18nIn,
  }) : super(
      key: key,
      mainMemberPicture: memberPicture,
      widgets: widgetsIn,
      i18n: i18nIn
  );

  @override
  String getAppBarTitle(BuildContext context) {
    return formData!.id == null ? i18nIn.$trans('form.app_bar_title_new') : i18nIn.$trans('form.app_bar_title_edit');
  }

  @override
  Widget getBottomSection(BuildContext context) {
    return SizedBox(height: 1);
  }

  @override
  Widget getContentWidget(BuildContext context) {
    return Container(
        child: Form(
            key: _formKey,
            child: Container(
                alignment: Alignment.center,
                child: SingleChildScrollView(    // new line
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Container(
                            alignment: Alignment.center,
                            child: _buildForm(context),
                          ),
                          widgetsIn.createSubmitSection(_getButtons(context) as Row)
                        ]
                    )
                )
            )
        )
    );
  }

  // private methods
  Widget _getButtons(BuildContext context) {
    return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          widgetsIn.createCancelButton(() => _navList(context)),
          SizedBox(width: 10),
          widgetsIn.createSubmitButton(context, () => _submitForm(context)),
        ]
    );
  }

  Widget _buildForm(BuildContext context) {
    return Table(
        children: [
          TableRow(
              children: [
                widgetsIn.wrapGestureDetector(context, Padding(padding: EdgeInsets.only(top: 16),
                    child: Text(i18nIn.$trans('info_customer_id'),
                        style: TextStyle(fontWeight: FontWeight.bold))
                )),
                TextFormField(
                    readOnly: true,
                    controller: formData!.customerIdController,
                    validator: (value) {
                      return null;
                    }
                ),
              ]
          ),
          TableRow(
              children: [
                widgetsIn.wrapGestureDetector(context, Padding(padding: EdgeInsets.only(top: 16),
                    child: Text(i18nIn.$trans('info_name'),
                        style: TextStyle(fontWeight: FontWeight.bold))
                )),
                TextFormField(
                    controller: formData!.nameController,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return i18nIn.$trans('validator_name');
                      }
                      return null;
                    }
                ),
              ]
          ),
          TableRow(
              children: [
                widgetsIn.wrapGestureDetector(context, Padding(padding: EdgeInsets.only(top: 16),
                    child: Text(i18nIn.$trans('info_address'),
                        style: TextStyle(fontWeight: FontWeight.bold))
                )),
                TextFormField(
                    controller: formData!.addressController,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return i18nIn.$trans('validator_address');
                      }
                      return null;
                    }
                ),
              ]
          ),
          TableRow(
              children: [
                widgetsIn.wrapGestureDetector(context, Padding(padding: EdgeInsets.only(top: 16),
                    child: Text(i18nIn.$trans('info_postal'),
                        style: TextStyle(fontWeight: FontWeight.bold))
                )),
                TextFormField(
                    controller: formData!.postalController,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return i18nIn.$trans('validator_postal');
                      }
                      return null;
                    }
                ),
              ]
          ),
          TableRow(
              children: [
                widgetsIn.wrapGestureDetector(context, Padding(padding: EdgeInsets.only(top: 16),
                    child: Text(i18nIn.$trans('info_city'),
                        style: TextStyle(fontWeight: FontWeight.bold))
                )),
                TextFormField(
                    controller: formData!.cityController,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return i18nIn.$trans('validator_city');
                      }
                      return null;
                    }
                ),
              ]
          ),
          TableRow(
              children: [
                widgetsIn.wrapGestureDetector(context, Padding(padding: EdgeInsets.only(top: 16),
                    child: Text(i18nIn.$trans('info_country_code'),
                        style: TextStyle(fontWeight: FontWeight.bold))
                )),
                DropdownButtonFormField<String>(
                  value: formData!.countryCode,
                  items: ['NL', 'BE', 'LU', 'FR', 'DE'].map((String value) {
                    return new DropdownMenuItem<String>(
                      child: new Text(value),
                      value: value,
                    );
                  }).toList(),
                  onChanged: (newValue) {
                    formData!.countryCode = newValue;
                    _updateFormData(context);
                  },
                )
              ]
          ),
          TableRow(
              children: [
                widgetsIn.wrapGestureDetector(context, Padding(padding: EdgeInsets.only(top: 16),
                    child: Text(i18nIn.$trans('info_email'),
                        style: TextStyle(fontWeight: FontWeight.bold))
                )),
                TextFormField(
                    controller: formData!.emailController,
                    validator: (value) {
                      return null;
                    }
                )
              ]
          ),
          TableRow(
              children: [
                widgetsIn.wrapGestureDetector(context, Padding(padding: EdgeInsets.only(top: 16),
                    child: Text(i18nIn.$trans('info_tel'),
                        style: TextStyle(fontWeight: FontWeight.bold))
                )),
                TextFormField(
                    controller: formData!.telController,
                    validator: (value) {
                      return null;
                    }
                )
              ]
          ),
          TableRow(
              children: [
                widgetsIn.wrapGestureDetector(context, Padding(padding: EdgeInsets.only(top: 16),
                    child: Text(i18nIn.$trans('info_mobile'),
                        style: TextStyle(fontWeight: FontWeight.bold))
                )),
                TextFormField(
                    controller: formData!.mobileController,
                    validator: (value) {
                      return null;
                    }
                )
              ]
          ),
          TableRow(
              children: [
                widgetsIn.wrapGestureDetector(context, Padding(padding: EdgeInsets.only(top: 16),
                    child: Text(i18nIn.$trans('info_contact'),
                        style: TextStyle(fontWeight: FontWeight.bold))
                )),
                Container(
                    width: 300.0,
                    child: TextFormField(
                      controller: formData!.contactController,
                      keyboardType: TextInputType.multiline,
                      maxLines: null,
                    )
                ),
              ]
          ),
          TableRow(
              children: [
                widgetsIn.wrapGestureDetector(context, Padding(padding: EdgeInsets.only(top: 16),
                    child: Text(i18nIn.$trans('info_remarks'),
                        style: TextStyle(fontWeight: FontWeight.bold))
                )),
                Container(
                    width: 300.0,
                    child: TextFormField(
                      controller: formData!.remarksController,
                      keyboardType: TextInputType.multiline,
                      maxLines: null,
                    )
                ),
              ]
          ),
        ]
    );
  }

  Future<void> _submitForm(BuildContext context) async {
    if (this._formKey.currentState!.validate()) {
      this._formKey.currentState!.save();

      if (!formData!.isValid()) {
        FocusScope.of(context).unfocus();
        return;
      }

      final bloc = BlocProvider.of<CustomerBloc>(context);
      if (formData!.id != null) {
        Customer updatedCustomer = formData!.toModel();
        bloc.add(CustomerEvent(status: CustomerEventStatus.DO_ASYNC));
        bloc.add(CustomerEvent(
            pk: updatedCustomer.id,
            status: CustomerEventStatus.UPDATE,
            customer: updatedCustomer,
        ));
      } else {
        Customer newCustomer = formData!.toModel();
        bloc.add(CustomerEvent(status: CustomerEventStatus.DO_ASYNC));
        bloc.add(CustomerEvent(
            status: CustomerEventStatus.INSERT,
            customer: newCustomer,
        ));
      }
    }
  }

  void _navList(BuildContext context) {
    final page = CustomerPage(
        bloc: CustomerBloc()
    );

    Navigator.pushReplacement(context,
        MaterialPageRoute(
            builder: (context) => page
        )
    );
  }

  _updateFormData(BuildContext context) {
    final bloc = BlocProvider.of<CustomerBloc>(context);
    bloc.add(CustomerEvent(status: CustomerEventStatus.DO_ASYNC));
    bloc.add(CustomerEvent(
        status: CustomerEventStatus.UPDATE_FORM_DATA,
        formData: formData
    ));
  }
}
