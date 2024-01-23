import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';

import 'package:my24app/core/widgets/widgets.dart';
import 'package:my24app/customer/models/api.dart';
import 'package:my24app/quotation/blocs/quotation_bloc.dart';
import 'package:my24app/quotation/models/quotation/models.dart';
import '../pages/part_form.dart';

class PreliminaryDetailWidget extends StatefulWidget {
  final bool isPlanning;
  final Quotation? quotation;
  final CustomerApi customerApi = CustomerApi();

  PreliminaryDetailWidget({
    required this.isPlanning,
    required this.quotation,
    Key? key,
  }): super(key: key);

  @override
  State<StatefulWidget> createState() => new _PreliminaryDetailWidgetState();
}

class _PreliminaryDetailWidgetState extends State<PreliminaryDetailWidget> {
  bool _inAsyncCall = false;

  final GlobalKey<FormState> _formKeyQuotationDetails = GlobalKey<FormState>();
  var _descriptionController = TextEditingController();
  var _referenceController = TextEditingController();

  @override
  void initState() {
    _descriptionController.text = widget.quotation!.description!;
    _referenceController.text = widget.quotation!.quotationReference!;

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
                  _buildQuotationDetailSection(context),
                  getMy24Divider(context),
                  createDefaultElevatedButton(
                      "quotations.detail.button_add_part".tr(),
                      () { _navAddPartForm(); }
                  ),
                  _buildPartsSection(context),
                  _createMakeDefinitiveSection(context),
                ]
            )
        ), inAsyncCall: _inAsyncCall);
  }

  Widget _createMakeDefinitiveSection(BuildContext context) {
    if (widget.quotation!.parts!.length == 0) {
      return SizedBox(height: 1);
    }

    return Column(
      children: [
        getMy24Divider(context),
        createDefaultElevatedButton(
            "quotations.detail.button_make_definitive".tr(),
            () { _showMakeDefinitiveDialog(context); }
        ),
      ],
    );
  }

  void _showMakeDefinitiveDialog(BuildContext context) {
    // set up the button
    Widget cancelButton = TextButton(
        child: Text('utils.button_cancel'.tr()),
        onPressed: () => Navigator.of(context).pop(false)
    );
    Widget makeDefinitiveButton = TextButton(
        child: Text('quotations.detail.button_make_definitive'.tr()),
        onPressed: () => Navigator.of(context).pop(true)
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text('quotations.detail.dialog_title_make_definitive'.tr()),
      content: Text('quotations.detail.dialog_content_make_definitive'.tr()),
      actions: [
        cancelButton,
        makeDefinitiveButton,
      ],
    );

    // show the dialog
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    ).then((dialogResult) {
      if (dialogResult == null) return;

      if (dialogResult) {
        _makeDefinitive();
      }
    });
  }

  void _makeDefinitive() {
    final bloc = BlocProvider.of<QuotationBloc>(context);

    bloc.add(QuotationEvent(
        status: QuotationEventStatus.MAKE_DEFINITIVE,
        pk: widget.quotation!.id
    ));
  }

  Widget _buildPartsSection(BuildContext context) {
    return buildItemsSection(
        context,
        "quotations.detail.header_parts".tr(),
        widget.quotation!.parts,
        (QuotationPart part) {
          return <Widget>[
            createSubHeader(part.description!),
            _createImageSection(context, part.images),
            _createLinesSection(context, part.lines),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                createDefaultElevatedButton(
                    "quotations.detail.button_edit_part".tr(),
                        () { _navEditPartForm(part.id); }
                ),
              ],
            )
          ];
        },
        (QuotationPart part) {
          return <Widget>[];
        }
    );
  }

  Widget _createImageSection(BuildContext context, List<QuotationPartImage>? images) {
    return buildItemsSection(
      context,
      "quotations.detail.header_images".tr(),
      images,
      (QuotationPartImage image) {
        return <Widget>[
          createImagePart(
              image.thumbnailUrl!,
              image.description!
          )
        ];
      },
      (QuotationPartImage image) {
        return <Widget>[];
      },
      withDivider: false
    );
  }

  Widget _createLinesSection(BuildContext context, List<QuotationPartLine>? lines) {
    return buildItemsSection(
      context,
      "quotations.detail.header_lines".tr(),
      lines,
      (QuotationPartLine line) {
        return <Widget>[
          ...buildItemListKeyValueList(
              'quotations.info_line_old_product_name'.tr(), line.oldProduct
          ),
          ...buildItemListKeyValueList(
              'quotations.info_line_product_name'.tr(), line.newProductName
          ),
          ...buildItemListKeyValueList(
              'quotations.info_line_product_identifier'.tr(), line.newProductIdentifier
          ),
          ...buildItemListKeyValueList(
              'quotations.info_line_product_amount'.tr(), line.amount
          ),
        ];
      },
      (QuotationPartLine line) {
        return <Widget>[];
      },
    );
  }

  _navEditPartForm(int? quotationPartPk) {
    final page = PartFormPage(
        quotationPk: widget.quotation!.id,
        quotationPartPk: quotationPartPk
    );
    Navigator.push(context,
        MaterialPageRoute(
            builder: (context) => page
        )
    );
  }

  _navAddPartForm() {
    final page = PartFormPage(quotationPk: widget.quotation!.id);
    Navigator.push(context,
        MaterialPageRoute(
            builder: (context) => page
        )
    );
  }


  Widget _buildQuotationDetailSection(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        buildQuotationInfoCard(context, widget.quotation!, onlyCustomer: true),
        SizedBox(
          height: 10.0,
        ),
        // details
        createHeader('quotations.detail.header_quotation_details'.tr()),
        Form(
            key: _formKeyQuotationDetails,
            child: _buildQuotationDetailsForm(context)
        ),
      ],
    );
  }

  Widget _buildQuotationDetailsForm(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
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
        getMy24Divider(context),
        _renderSubmit(),
      ],
    );
  }

  Widget _renderSubmit() {
    return createDefaultElevatedButton(
        'quotations.detail.button_submit_quotation'.tr(),
        () => _submitEdit()
    );
  }

  void _submitEdit() async {
    if (this._formKeyQuotationDetails.currentState!.validate()) {
      this._formKeyQuotationDetails.currentState!.save();

      Quotation quotation = Quotation(
        // customerRelation: widget.quotation.customerRelation,
        // customerId: widget.quotation.customerId,
        // quotationName: widget.quotation.quotationName,
        // quotationAddress: widget.quotation.quotationAddress,
        // quotationPostal: widget.quotation.quotationPostal,
        // quotationCity: widget.quotation.quotationCity,
        // quotationCountryCode: widget.quotation.quotationCountryCode,
        // quotationTel: widget.quotation.quotationTel,
        // quotationMobile: widget.quotation.quotationMobile,
        // quotationEmail: widget.quotation.quotationEmail,
        // quotationContact: widget.quotation.quotationContact,
        description: _descriptionController.text,
        quotationReference: _referenceController.text,
      );

      final bloc = BlocProvider.of<QuotationBloc>(context);

      bloc.add(QuotationEvent(
          status: QuotationEventStatus.EDIT,
          quotation: quotation,
          pk: widget.quotation!.id
      ));
    }
  }

}
