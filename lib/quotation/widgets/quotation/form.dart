import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';

import 'package:my24_flutter_core/widgets/widgets.dart';
import 'package:my24_flutter_core/i18n.dart';
import 'package:my24_flutter_core/widgets/slivers/app_bars.dart';

import 'package:my24app/customer/models/api.dart';
import 'package:my24app/quotation/models/quotation/models.dart';
import 'package:my24app/quotation/models/quotation/form_data.dart';
import 'package:my24app/quotation/blocs/quotation_bloc.dart';
import 'package:my24app/quotation/widgets/chapters/form.dart';

class QuotationFormWidget extends StatefulWidget{
  final QuotationFormData? formData;
  final String? memberPicture;
  final QuotationEventStatus fetchStatus;
  final CoreWidgets widgetsIn;
  final My24i18n i18nIn;

  QuotationFormWidget(
      {Key? key,
      required this.memberPicture,
      required this.formData,
      required this.fetchStatus,
      required this.widgetsIn,
      required this.i18nIn,
    });

  @override
  State<QuotationFormWidget> createState() => _QuotationFormWidgetState();
}

class _QuotationFormWidgetState extends State<QuotationFormWidget> with TextEditingControllerMixin {
  final String basePath = "quotations";
  final CustomerApi customerApi = CustomerApi();
  final GlobalKey<FormState> _quotationFormKey = GlobalKey<FormState>();

  final TextEditingController searchCustomerTextController =
      TextEditingController();
  final TextEditingController customerIdController = TextEditingController();
  final TextEditingController customerNameController = TextEditingController();
  final TextEditingController quotationAddressController =
      TextEditingController();
  final TextEditingController quotationPostalController =
      TextEditingController();
  final TextEditingController quotationCityController = TextEditingController();
  final TextEditingController quotationContactController =
      TextEditingController();
  final TextEditingController quotationReferenceController =
      TextEditingController();
  final TextEditingController quotationDescriptionController =
      TextEditingController();
  final TextEditingController quotationEmailController =
      TextEditingController();
  final TextEditingController quotationMobileController =
      TextEditingController();
  final TextEditingController quotationTelController = TextEditingController();

  @override
  void initState() {
    addTextEditingController(
        searchCustomerTextController, widget.formData!, 'searchCustomerText');
    addTextEditingController(
        customerIdController, widget.formData!, 'customerId');
    addTextEditingController(
        customerNameController, widget.formData!, 'customerName');
    addTextEditingController(
        quotationAddressController, widget.formData!, 'quotationAddress');
    addTextEditingController(
        quotationPostalController, widget.formData!, 'quotationPostal');
    addTextEditingController(
        quotationCityController, widget.formData!, 'quotationCity');
    addTextEditingController(
        quotationContactController, widget.formData!, 'quotationContact');
    addTextEditingController(
        quotationReferenceController, widget.formData!, 'quotationReference');
    addTextEditingController(quotationDescriptionController, widget.formData!,
        'quotationDescription');
    addTextEditingController(
        quotationEmailController, widget.formData!, 'quotationEmail');
    addTextEditingController(
        quotationMobileController, widget.formData!, 'quotationMobile');
    addTextEditingController(
        quotationTelController, widget.formData!, 'quotationTel');
    super.initState();
  }

  void dispose() {
    disposeAll();
    super.dispose();
  }

  SliverAppBar getAppBar(BuildContext context) {
    GenericAppBarFactory factory = GenericAppBarFactory(
        context: context,
        title: getAppBarTitle(context),
        subtitle: "",
        memberPicture: widget.memberPicture);
    return factory.createAppBar();
  }

  String getAppBarTitle(BuildContext context) {
    return widget.formData!.id == null
        ? widget.i18nIn.$trans('form.app_bar_title_insert')
        : widget.i18nIn.$trans('form.app_bar_title_update');
  }

  Widget getBottomSection(BuildContext context) {
    return SizedBox(height: 1);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: CustomScrollView(slivers: <Widget>[
      getAppBar(context),
      SliverToBoxAdapter(child: getContentWidget(context))
    ]));
  }

  Widget getContentWidget(BuildContext context) {
    return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10),
        child: Container(
            alignment: Alignment.center,
            child: SingleChildScrollView(
                child: Column(
              children: [
                widget.widgetsIn.createHeader(widget.i18nIn.$trans('detail.header_quotation_details')),
                _createQuotationForm(context),
                SizedBox(
                  height: 20,
                ),
                if (widget.formData!.id != null) widget.widgetsIn.createSubHeader('Chapters'),
                if (widget.formData!.id != null) _createChapters(context),
                widget.widgetsIn.createSubmitSection(_getButtons(context) as Row)
              ],
            ))));
  }

  Widget _createQuotationForm(BuildContext context) {
    dynamic firstElement;

    if (widget.formData!.id == null) {
      firstElement = _getCustomerTypeAhead(context);
    } else {
      firstElement = TableRow(children: [
        SizedBox(height: 1),
        SizedBox(height: 1),
      ]);
    }

    return Form(
        key: _quotationFormKey,
        child: Table(children: [
          firstElement,
          TableRow(children: [
            widget.widgetsIn.wrapGestureDetector(
                context,
                Padding(
                    padding: EdgeInsets.only(top: 16),
                    child: Text(
                        widget.i18nIn.$trans('info_customer_id', pathOverride: 'generic'),
                        style: TextStyle(fontWeight: FontWeight.bold)))),
            TextFormField(
                readOnly: true,
                controller: customerIdController,
                validator: (value) {
                  return null;
                }),
          ]),
          TableRow(children: [
            widget.widgetsIn.wrapGestureDetector(
                context,
                Padding(
                    padding: EdgeInsets.only(top: 16),
                    child: Text(
                        widget.i18nIn.$trans('info_customer', pathOverride: 'generic'),
                        style: TextStyle(fontWeight: FontWeight.bold)))),
            TextFormField(
                controller: customerNameController,
                validator: (value) {
                  if (value!.isEmpty) {
                    return widget.i18nIn.$trans('validator_name', pathOverride: 'generic');
                  }
                  return null;
                }),
          ]),
          TableRow(children: [
            widget.widgetsIn.wrapGestureDetector(
                context,
                Padding(
                    padding: EdgeInsets.only(top: 16),
                    child: Text(widget.i18nIn.$trans('info_address', pathOverride: 'generic'),
                        style: TextStyle(fontWeight: FontWeight.bold)))),
            TextFormField(
                controller: quotationAddressController,
                validator: (value) {
                  if (value!.isEmpty) {
                    return widget.i18nIn.$trans('validator_address', pathOverride: 'generic');
                  }
                  return null;
                }),
          ]),
          TableRow(children: [
            widget.widgetsIn.wrapGestureDetector(
                context,
                Padding(
                    padding: EdgeInsets.only(top: 16),
                    child: Text(widget.i18nIn.$trans('info_postal', pathOverride: 'generic'),
                        style: TextStyle(fontWeight: FontWeight.bold)))),
            TextFormField(
                controller: quotationPostalController,
                validator: (value) {
                  if (value!.isEmpty) {
                    return widget.i18nIn.$trans('validator_postal', pathOverride: 'generic');
                  }
                  return null;
                }),
          ]),
          TableRow(children: [
            widget.widgetsIn.wrapGestureDetector(
                context,
                Padding(
                    padding: EdgeInsets.only(top: 16),
                    child: Text(widget.i18nIn.$trans('info_city', pathOverride: 'generic'),
                        style: TextStyle(fontWeight: FontWeight.bold)))),
            TextFormField(
                controller: quotationCityController,
                validator: (value) {
                  if (value!.isEmpty) {
                    return widget.i18nIn.$trans('validator_city', pathOverride: 'generic');
                  }
                  return null;
                }),
          ]),
          TableRow(children: [
            widget.widgetsIn.wrapGestureDetector(
                context,
                Padding(
                    padding: EdgeInsets.only(top: 16),
                    child: Text(
                        widget.i18nIn.$trans('info_country_code', pathOverride: 'generic'),
                        style: TextStyle(fontWeight: FontWeight.bold)))),
            DropdownButtonFormField<String>(
              value: widget.formData!.quotationCountryCode,
              items: ['NL', 'BE', 'LU', 'FR', 'DE'].map((String value) {
                return new DropdownMenuItem<String>(
                  child: new Text(value),
                  value: value,
                );
              }).toList(),
              onChanged: (newValue) {
                widget.formData!.quotationCountryCode = newValue;
                _updateFormData(context);
              },
            )
          ]),
          TableRow(children: [
            widget.widgetsIn.wrapGestureDetector(
                context,
                Padding(
                    padding: EdgeInsets.only(top: 16),
                    child: Text(widget.i18nIn.$trans('info_contact', pathOverride: 'generic'),
                        style: TextStyle(fontWeight: FontWeight.bold)))),
            Container(
                width: 300.0,
                child: TextFormField(
                  controller: quotationContactController,
                  keyboardType: TextInputType.multiline,
                  maxLines: null,
                )),
          ]),
          TableRow(children: [
            widget.widgetsIn.wrapGestureDetector(
                context,
                Padding(
                    padding: EdgeInsets.only(top: 16),
                    child: Text(widget.i18nIn.$trans('info_reference'),
                        style: TextStyle(fontWeight: FontWeight.bold)))),
            TextFormField(
                controller: quotationReferenceController,
                validator: (value) {
                  return null;
                })
          ]),
          TableRow(children: [
            widget.widgetsIn.wrapGestureDetector(
                context,
                Padding(
                    padding: EdgeInsets.only(top: 16),
                    child: Text(widget.i18nIn.$trans('info_email'),
                        style: TextStyle(fontWeight: FontWeight.bold)))),
            TextFormField(
                controller: quotationEmailController,
                validator: (value) {
                  return null;
                })
          ]),
          TableRow(children: [
            widget.widgetsIn.wrapGestureDetector(
                context,
                Padding(
                    padding: EdgeInsets.only(top: 16),
                    child: Text(widget.i18nIn.$trans('info_mobile'),
                        style: TextStyle(fontWeight: FontWeight.bold)))),
            TextFormField(
                controller: quotationMobileController,
                validator: (value) {
                  return null;
                })
          ]),
          TableRow(children: [
            widget.widgetsIn.wrapGestureDetector(
                context,
                Padding(
                    padding: EdgeInsets.only(top: 16),
                    child: Text(widget.i18nIn.$trans('info_tel'),
                        style: TextStyle(fontWeight: FontWeight.bold)))),
            TextFormField(
                controller: quotationTelController,
                validator: (value) {
                  return null;
                })
          ])
        ]));
  }

  TableRow _getCustomerTypeAhead(BuildContext context) {
    return TableRow(children: [
      Padding(
          padding: EdgeInsets.only(top: 16),
          child: Text(widget.i18nIn.$trans('form.label_search_customer'),
              style: TextStyle(fontWeight: FontWeight.bold))),
      TypeAheadFormField(
        textFieldConfiguration: TextFieldConfiguration(
            controller: searchCustomerTextController,
            decoration: InputDecoration(
                labelText: widget.i18nIn.$trans('form.typeahead_label_search_customer'))),
        suggestionsCallback: (pattern) async {
          return await customerApi.customerTypeAhead(pattern);
        },
        itemBuilder: (context, dynamic suggestion) {
          return ListTile(
            title: Text(suggestion.value),
          );
        },
        transitionBuilder: (context, suggestionsBox, controller) {
          return suggestionsBox;
        },
        onSuggestionSelected: (dynamic customer) {
          searchCustomerTextController.text = '';
          widget.formData!.fillFromCustomer(customer);
          customerIdController.text = customer.customerId!;
          customerNameController.text = customer.name!;
          quotationAddressController.text = customer.address!;
          quotationPostalController.text = customer.postal!;
          quotationCityController.text = customer.city!;
          quotationContactController.text = customer.contact!;
          quotationEmailController.text = customer.email!;
          quotationTelController.text = customer.tel!;
          quotationMobileController.text = customer.mobile!;
          _updateFormData(context);
        },
        validator: (value) {
          return null;
        },
        onSaved: (value) => {},
      )
    ]);
  }

  Widget _createChapters(BuildContext context) {
    return ChapterFormWidget(
      quotationId: widget.formData!.id,
      widgetsIn: widget.widgetsIn,
      i18nIn: widget.i18nIn,
    );
  }

  _updateFormData(BuildContext context) {
    final bloc = BlocProvider.of<QuotationBloc>(context);
    bloc.add(QuotationEvent(status: QuotationEventStatus.DO_ASYNC));
    bloc.add(QuotationEvent(
        status: QuotationEventStatus.UPDATE_FORM_DATA,
        formData: widget.formData));
  }

  Widget _getButtons(BuildContext context) {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
      widget.widgetsIn.createCancelButton(() => _fetchQuotations(context)),
      widget.widgetsIn.createSubmitButton(context, () => _doSubmit(context)),
    ]);
  }

  _fetchQuotations(context) {
    final bloc = BlocProvider.of<QuotationBloc>(context);

    bloc.add(QuotationEvent(status: QuotationEventStatus.DO_ASYNC));
    bloc.add(QuotationEvent(
      status: widget.fetchStatus,
    ));
  }

  Future<void> _doSubmit(context) async {
    final bloc = BlocProvider.of<QuotationBloc>(context);

    if (_quotationFormKey.currentState!.validate()) {
      _quotationFormKey.currentState!.save();

      if (widget.formData!.id == null) {
        Quotation newQuotation = widget.formData!.toModel();
        bloc.add(QuotationEvent(status: QuotationEventStatus.DO_ASYNC));
        bloc.add(QuotationEvent(
          status: QuotationEventStatus.INSERT,
          quotation: newQuotation,
        ));
      } else {
        Quotation updatedQuotation = widget.formData!.toModel();
        bloc.add(QuotationEvent(status: QuotationEventStatus.DO_ASYNC));
        bloc.add(QuotationEvent(
            status: QuotationEventStatus.UPDATE,
            quotation: updatedQuotation,
            pk: widget.formData!.id));
      }
    }
  }
}
