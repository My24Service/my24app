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
import 'package:my24app/quotation/pages/list.dart';

import '../pages/part_form.dart';

class PreliminaryDetailWidget extends StatefulWidget {
  final bool isPlanning;
  final Quotation quotation;

  PreliminaryDetailWidget({
    @required this.isPlanning,
    @required this.quotation,
    Key key,
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
    _descriptionController.text = widget.quotation.description;
    _referenceController.text = widget.quotation.quotationReference;

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
                  Divider(),
                  createDefaultElevatedButton(
                      "quotations.detail.button_add_part".tr(),
                      () { _navAddPartForm(); }
                  ),
                  _buildPartsSection()
                ]
            )
        ), inAsyncCall: _inAsyncCall);
  }

  Widget _buildPartsSection() {
    return buildItemsSection(
        "quotations.detail.header_parts".tr(),
        widget.quotation.parts,
        (QuotationPart part) {
          List<Widget> items = [];
          items.add(createSubHeader(part.description));

          items.add(_createImageSection(part.images));
          items.add(_createLinesSection(part.lines));
          items.add(Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              createDefaultElevatedButton(
                  "quotations.detail.button_edit_part".tr(),
                  () { _navEditPartForm(part.id); }
              ),
              SizedBox(width: 10),
              createDeleteButton(
                  "quotations.detail.button_delete_part".tr(),
                  () { }
              ),
            ],
          ));

          return items;
        },
        (QuotationPart part) {
          List<Widget> items = [];
          return items;
        }
    );
  }

  Widget _createImageSection(List<QuotationPartImage> images) {
    return buildItemsSection(
      "quotations.detail.header_images".tr(),
      images,
      (QuotationPartImage image) {
        List<Widget> items = [];

        items.add(createImagePart(
            image.thumbnailUrl,
            image.description
        ));

        return items;
      },
      (QuotationPartImage image) {
        List<Widget> items = [];
        return items;
      },
    );
  }

  Widget _createLinesSection(List<QuotationPartLine> lines) {
    return buildItemsSection(
      "quotations.detail.header_lines".tr(),
      lines,
      (QuotationPartLine line) {
        List<Widget> items = [];

        items.add(buildItemListTile('quotations.info_line_old_product_name'.tr(), line.oldProduct));
        items.add(buildItemListTile('quotations.info_line_product_name'.tr(), line.newProductName));
        items.add(buildItemListTile('quotations.info_line_product_identifier'.tr(), line.newProductIdentifier));
        items.add(buildItemListTile('quotations.info_line_product_amount'.tr(), line.amount));

        return items;
      },
      (QuotationPartLine line) {
        List<Widget> items = [];
        return items;
      },
    );
  }

  void _showDeleteDialog() {

  }

  _navEditPartForm(int quotationPartPk) {
    final page = PartFormPage(
        quotationPk: widget.quotation.id,
        quotationPartPk: quotationPartPk
    );
    Navigator.push(context,
        MaterialPageRoute(
            builder: (context) => page
        )
    );
  }

  _navAddPartForm() {
    final page = PartFormPage(quotationPk: widget.quotation.id);
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
        buildQuotationInfoCard(context, widget.quotation, onlyCustomer: true),
        SizedBox(
          height: 10.0,
        ),
        // details
        createHeader('quotations.detail.header_quotation_details'.tr()),
        Form(
            key: _formKeyQuotationDetails,
            child: _buildQuotationDetailsForm()
        ),
      ],
    );
  }

  Widget _buildQuotationDetailsForm() {
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
        Divider(),
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
    if (this._formKeyQuotationDetails.currentState.validate()) {
      this._formKeyQuotationDetails.currentState.save();

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
          pk: widget.quotation.id
      ));
    }
  }

}
