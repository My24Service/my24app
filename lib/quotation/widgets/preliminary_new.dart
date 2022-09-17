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

import '../pages/preliminary_detail.dart';

class PreliminaryNewWidget extends StatefulWidget {
  final bool isPlanning;

  PreliminaryNewWidget({
    @required this.isPlanning,
    Key key,
  }): super(key: key);

  @override
  State<StatefulWidget> createState() => new _PreliminaryNewWidgetState();
}

class _PreliminaryNewWidgetState extends State<PreliminaryNewWidget> {
  final GlobalKey<FormState> _formKeyQuotationDetails = GlobalKey<FormState>();

  final TextEditingController _typeAheadControllerCustomer = TextEditingController();
  var _quotationIdController = TextEditingController();

  CustomerTypeAheadModel _selectedQuotationCustomer;

  var _descriptionController = TextEditingController();
  var _referenceController = TextEditingController();

  bool _inAsyncCall = false;

  List<QuotationPart> parts = [];
  Customer customer;

  @override
  void initState() {
    _quotationIdController.text = "RJ-00012";
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ModalProgressHUD(
        child: Container(
            margin: new EdgeInsets.symmetric(horizontal: 20.0),
            child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: _renderWidgetBasedOnCustomer(context)
            )
        ), inAsyncCall: _inAsyncCall);
  }

  List<Widget> _renderWidgetBasedOnCustomer(BuildContext context) {
    if (_selectedQuotationCustomer == null) {
      return [
          createHeader('generic.info_customer'.tr()),
          _buildCustomerForm(),
        ];
    }

    customer = Customer(
        name: _selectedQuotationCustomer.name,
        address: _selectedQuotationCustomer.address,
        postal: _selectedQuotationCustomer.postal,
        city: _selectedQuotationCustomer.city,
        countryCode: _selectedQuotationCustomer.countryCode,
        tel: _selectedQuotationCustomer.tel,
        mobile: _selectedQuotationCustomer.mobile,
        email: _selectedQuotationCustomer.email,
        contact: _selectedQuotationCustomer.contact,
        customerId: _selectedQuotationCustomer.customerId,
    );

    return [
        SizedBox(height: 20),
        buildCustomerInfoCard(context, customer),
        Divider(),
        // details
        createHeader('quotations.new.header_quotation_details'.tr()),
        Form(
            key: _formKeyQuotationDetails,
            child: _buildQuotationDetailsForm()
        ),
      ];
  }

  Widget _buildCustomerForm() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        TypeAheadFormField(
          textFieldConfiguration: TextFieldConfiguration(
              controller: this._typeAheadControllerCustomer,
              decoration: InputDecoration(labelText: 'quotations.new.typeahead_label'.tr())
          ),
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
            setState(() {});
          },
          validator: (value) {
            if (value.isEmpty) {
              return 'quotations.new.typeahead_validator_customer'.tr();
            }

            return null;
          },
          onSaved: (value) => {},
        ),
      ],
    );
  }

  Widget _buildPartsSection() {
    return SizedBox(height: 1);
  }

  _navQuotationList() {
    final page = QuotationListPage(mode: listModes.ALL);
    Navigator.pushReplacement(context,
        MaterialPageRoute(
            builder: (context) => page
        )
    );
  }

  _navDetail() {
    final page = PreliminaryDetailPage(quotationPk: 1);
    Navigator.pushReplacement(context,
        MaterialPageRoute(
            builder: (context) => page
        )
    );
  }

  Widget _buildQuotationDetailsForm() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        // text fields for the rest of the quotation
        Text('quotations.info_quotation_id'.tr()),
        TextFormField(
            readOnly: true,
            controller: _quotationIdController,
            keyboardType: TextInputType.text,
            validator: (value) {
              return null;
            }),
        SizedBox(
          height: 10.0,
        ),
        // text fields for the rest of the quotation
        Text('quotations.info_description'.tr()),
        TextFormField(
            controller: _descriptionController,
            keyboardType: TextInputType.text,
            validator: (value) {
              return null;
            }),
        SizedBox(
          height: 10.0,
        ),
        Text('quotations.info_reference'.tr()),
        TextFormField(
            controller: _referenceController,
            keyboardType: TextInputType.text,
            validator: (value) {
              return null;
            }),
        SizedBox(
          height: 10.0,
        ),
        Divider(),
        _renderSubmit(),
        _renderNavDetailButton()
      ],
    );
  }

  Widget _renderSubmit() {
    return createDefaultElevatedButton(
        'quotations.new.button_submit_quotation'.tr(),
        () => _submit()
    );
  }

  Widget _renderNavDetailButton() {
    return createDefaultElevatedButton(
        "Detail",
        _navDetail
    );
  }

  void _submit() async {
    if (this._formKeyQuotationDetails.currentState.validate()) {
      this._formKeyQuotationDetails.currentState.save();

      Quotation quotation = Quotation(
        customerRelation: customer.id,
        customerId: customer.customerId,
        quotationName: customer.name,
        quotationAddress: customer.address,
        quotationPostal: customer.postal,
        quotationCity: customer.city,
        quotationCountryCode: customer.countryCode,
        quotationTel: customer.tel,
        quotationMobile: customer.mobile,
        quotationEmail: customer.email,
        quotationContact: customer.contact,

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
            'quotations.new.error_creating'.tr()
        );
        return;
      }

      createSnackBar(context, 'quotations.new.snackbar_created'.tr());
    }
  }
}
