import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';

import 'package:my24app/core/widgets/widgets.dart';
import 'package:my24app/core/models/models.dart';
import 'package:my24app/core/widgets/slivers/base_widgets.dart';
import 'package:my24app/customer/models/api.dart';
import 'package:my24app/customer/models/models.dart';
import 'package:my24app/quotation/models/quotation/models.dart';
import 'package:my24app/quotation/models/quotation/form_data.dart';
import 'package:my24app/core/i18n_mixin.dart';
import 'package:my24app/quotation/blocs/quotation_bloc.dart';
import 'package:my24app/quotation/widgets/chapters/form.dart';

class QuotationFormWidget extends BaseSliverPlainStatelessWidget
    with i18nMixin {
  final String basePath = "quotations";
  final QuotationFormData? formData;
  final String? memberPicture;
  final CustomerApi customerApi = CustomerApi();
  final GlobalKey<FormState> _quotationFormKey = GlobalKey<FormState>();

  QuotationFormWidget(
      {Key? key, required this.memberPicture, required this.formData})
      : super(key: key, memberPicture: memberPicture);

  @override
  String getAppBarTitle(BuildContext context) {
    return formData!.id == null
        ? $trans('form.app_bar_title_insert')
        : $trans('form.app_bar_title_update');
  }

  @override
  Widget getBottomSection(BuildContext context) {
    return SizedBox(height: 1);
  }

  @override
  Widget getContentWidget(BuildContext context) {
    return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10),
        child: Container(
            alignment: Alignment.center,
            child: SingleChildScrollView(
                child: Column(
              children: [
                createHeader($trans('detail.header_quotation_details')),
                _createQuotationForm(context),
                SizedBox(
                  height: 20,
                ),
                if (formData!.id != null) createSubHeader('Chapters'),
                if (formData!.id != null) _createChapters(context),
                createSubmitSection(_getButtons(context) as Row)
              ],
            ))));
  }

  Widget _createQuotationForm(BuildContext context) {
    dynamic firstElement;

    if (formData!.id == null) {
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
            wrapGestureDetector(
                context,
                Padding(
                    padding: EdgeInsets.only(top: 16),
                    child: Text(
                        $trans('info_customer_id', pathOverride: 'generic'),
                        style: TextStyle(fontWeight: FontWeight.bold)))),
            TextFormField(
                readOnly: true,
                controller: formData!.customerIdController,
                validator: (value) {
                  return null;
                }),
          ]),
          TableRow(children: [
            wrapGestureDetector(
                context,
                Padding(
                    padding: EdgeInsets.only(top: 16),
                    child: Text(
                        $trans('info_customer', pathOverride: 'generic'),
                        style: TextStyle(fontWeight: FontWeight.bold)))),
            TextFormField(
                controller: formData!.customerNameController,
                validator: (value) {
                  if (value!.isEmpty) {
                    return $trans('validator_name', pathOverride: 'generic');
                  }
                  return null;
                }),
          ]),
          TableRow(children: [
            wrapGestureDetector(
                context,
                Padding(
                    padding: EdgeInsets.only(top: 16),
                    child: Text($trans('info_address', pathOverride: 'generic'),
                        style: TextStyle(fontWeight: FontWeight.bold)))),
            TextFormField(
                controller: formData!.quotationAddressController,
                validator: (value) {
                  if (value!.isEmpty) {
                    return $trans('validator_address', pathOverride: 'generic');
                  }
                  return null;
                }),
          ]),
          TableRow(children: [
            wrapGestureDetector(
                context,
                Padding(
                    padding: EdgeInsets.only(top: 16),
                    child: Text($trans('info_postal', pathOverride: 'generic'),
                        style: TextStyle(fontWeight: FontWeight.bold)))),
            TextFormField(
                controller: formData!.quotationPostalController,
                validator: (value) {
                  if (value!.isEmpty) {
                    return $trans('validator_postal', pathOverride: 'generic');
                  }
                  return null;
                }),
          ]),
          TableRow(children: [
            wrapGestureDetector(
                context,
                Padding(
                    padding: EdgeInsets.only(top: 16),
                    child: Text($trans('info_city', pathOverride: 'generic'),
                        style: TextStyle(fontWeight: FontWeight.bold)))),
            TextFormField(
                controller: formData!.quotationCityController,
                validator: (value) {
                  if (value!.isEmpty) {
                    return $trans('validator_city', pathOverride: 'generic');
                  }
                  return null;
                }),
          ]),
          TableRow(children: [
            wrapGestureDetector(
                context,
                Padding(
                    padding: EdgeInsets.only(top: 16),
                    child: Text(
                        $trans('info_country_code', pathOverride: 'generic'),
                        style: TextStyle(fontWeight: FontWeight.bold)))),
            DropdownButtonFormField<String>(
              value: formData!.quotationCountryCode,
              items: ['NL', 'BE', 'LU', 'FR', 'DE'].map((String value) {
                return new DropdownMenuItem<String>(
                  child: new Text(value),
                  value: value,
                );
              }).toList(),
              onChanged: (newValue) {
                formData!.quotationCountryCode = newValue;
                _updateFormData(context);
              },
            )
          ]),
          TableRow(children: [
            wrapGestureDetector(
                context,
                Padding(
                    padding: EdgeInsets.only(top: 16),
                    child: Text($trans('info_contact', pathOverride: 'generic'),
                        style: TextStyle(fontWeight: FontWeight.bold)))),
            Container(
                width: 300.0,
                child: TextFormField(
                  controller: formData!.quotationContactController,
                  keyboardType: TextInputType.multiline,
                  maxLines: null,
                )),
          ]),
          TableRow(children: [
            wrapGestureDetector(
                context,
                Padding(
                    padding: EdgeInsets.only(top: 16),
                    child: Text($trans('info_reference'),
                        style: TextStyle(fontWeight: FontWeight.bold)))),
            TextFormField(
                controller: formData!.quotationReferenceController,
                validator: (value) {
                  return null;
                })
          ]),
          TableRow(children: [
            wrapGestureDetector(
                context,
                Padding(
                    padding: EdgeInsets.only(top: 16),
                    child: Text($trans('info_email'),
                        style: TextStyle(fontWeight: FontWeight.bold)))),
            TextFormField(
                controller: formData!.quotationEmailController,
                validator: (value) {
                  return null;
                })
          ]),
          TableRow(children: [
            wrapGestureDetector(
                context,
                Padding(
                    padding: EdgeInsets.only(top: 16),
                    child: Text($trans('info_mobile'),
                        style: TextStyle(fontWeight: FontWeight.bold)))),
            TextFormField(
                controller: formData!.quotationMobileController,
                validator: (value) {
                  return null;
                })
          ]),
          TableRow(children: [
            wrapGestureDetector(
                context,
                Padding(
                    padding: EdgeInsets.only(top: 16),
                    child: Text($trans('info_tel'),
                        style: TextStyle(fontWeight: FontWeight.bold)))),
            TextFormField(
                controller: formData!.quotationTelController,
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
          child: Text($trans('form.label_search_customer'),
              style: TextStyle(fontWeight: FontWeight.bold))),
      TypeAheadFormField(
        textFieldConfiguration: TextFieldConfiguration(
            controller: formData!.typeAheadControllerCustomer,
            decoration: InputDecoration(
                labelText: $trans('form.typeahead_label_search_customer'))),
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
        onSuggestionSelected: (dynamic suggestion) {
          formData!.typeAheadControllerCustomer!.text = '';
          formData!.fillFromCustomer(suggestion);
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
      quotationId: formData!.id,
    );
  }

  _updateFormData(BuildContext context) {
    final bloc = BlocProvider.of<QuotationBloc>(context);
    bloc.add(QuotationEvent(status: QuotationEventStatus.DO_ASYNC));
    bloc.add(QuotationEvent(
        status: QuotationEventStatus.UPDATE_FORM_DATA, formData: formData));
  }

  Widget _getButtons(BuildContext context) {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
      createCancelButton(() => _fetchQuotations(context)),
      createSubmitButton(() => _doSubmit(context)),
    ]);
  }

  _fetchQuotations(context) {
    final bloc = BlocProvider.of<QuotationBloc>(context);

    bloc.add(QuotationEvent(status: QuotationEventStatus.DO_ASYNC));
    bloc.add(QuotationEvent(
      status: QuotationEventStatus.FETCH_PRELIMINARY,
    ));
  }

  Future<void> _doSubmit(context) async {
    final bloc = BlocProvider.of<QuotationBloc>(context);

    if (_quotationFormKey.currentState!.validate()) {
      _quotationFormKey.currentState!.save();

      if (formData!.id == null) {
        Quotation newQuotation = formData!.toModel();
        bloc.add(QuotationEvent(status: QuotationEventStatus.DO_ASYNC));
        bloc.add(QuotationEvent(
          status: QuotationEventStatus.INSERT,
          quotation: newQuotation,
        ));
      } else {
        Quotation updatedQuotation = formData!.toModel();
        bloc.add(QuotationEvent(status: QuotationEventStatus.DO_ASYNC));
        bloc.add(QuotationEvent(
            status: QuotationEventStatus.UPDATE,
            quotation: updatedQuotation,
            pk: formData!.id));
      }
    }
  }
}
