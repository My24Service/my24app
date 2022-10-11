import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:my24app/quotation/models/models.dart';
import 'package:my24app/quotation/pages/image_form.dart';

import 'package:my24app/core/widgets/widgets.dart';

import '../blocs/part_bloc.dart';
import '../pages/line_form.dart';
import '../pages/preliminary_detail.dart';


class PartFormWidget extends StatefulWidget {
  final int quotationPk;
  final QuotationPart part;

  PartFormWidget({
    Key key,
    this.quotationPk,
    this.part,
  }): super(key: key);

  @override
  State<StatefulWidget> createState() => new _PartFormWidgetState();
}

class _PartFormWidgetState extends State<PartFormWidget> {
  final GlobalKey<FormState> _formKeyQuotationPart = GlobalKey<FormState>();

  var _descriptionController = TextEditingController();
  bool _inAsyncCall = false;

  @override
  void initState() {
    if (widget.part != null) {
      _descriptionController.text = widget.part.description;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ModalProgressHUD(
        child:_showMainView(context),
        inAsyncCall: _inAsyncCall
    );
  }

  Widget _showMainView(BuildContext context) {
    return Container(
        alignment: Alignment.center,
        child: SingleChildScrollView(    // new line
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Column(
                      children: [
                        createHeader(
                            widget.part != null ? 'quotations.parts.header_edit_part'.tr() : 'quotations.parts.header_add_part'.tr()
                        ),
                        Form(
                            key: _formKeyQuotationPart,
                            child: _buildPartForm()
                        ),
                        if (widget.part != null)
                          createDeleteButton(
                              'quotations.parts.button_delete'.tr(),
                              () { _showDeleteDialog(widget.part); }
                          )
                      ],
                    ),
                  ),
                  if (widget.part != null)
                    Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            createDefaultElevatedButton(
                                'quotations.parts.header_add_image'.tr(),
                                () { _handleEditImage(null, context); }
                            ),
                            SizedBox(width: 10),
                            createDefaultElevatedButton(
                                'quotations.parts.header_add_line'.tr(),
                                () { _handleEditLine(null, context); }
                            ),
                          ],
                        ),
                        Divider(),
                        _buildImagesSection(),
                        Divider(),
                        _buildLinesSection(),
                        Divider(),
                        _buildNavQuotationButton()
                      ],
                    )
                ]
            )
        )
    );
  }

  Widget _buildPartForm() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text('generic.info_description'.tr()),
        TextFormField(
            controller: _descriptionController,
            keyboardType: TextInputType.multiline,
            maxLines: null,
            validator: (value) {
              return null;
            }),
        Divider(),
        SizedBox(
          height: 10.0,
        ),
        createDefaultElevatedButton(
            widget.part == null ? 'quotations.parts.form_button_add_part'.tr() :
            'quotations.parts.form_button_edit_part'.tr(),
            _submitEdit
        )
      ],
    );
  }

  void _submitEdit() async {
    if (this._formKeyQuotationPart.currentState.validate()) {
      this._formKeyQuotationPart.currentState.save();

      QuotationPart part = QuotationPart(
        quotationId: widget.quotationPk,
        description: _descriptionController.text,
      );

      final bloc = BlocProvider.of<QuotationPartBloc>(context);

      if (widget.part == null) {
        bloc.add(QuotationPartEvent(
          status: QuotationPartEventStatus.INSERT,
          part: part,
        ));
      } else {
        bloc.add(QuotationPartEvent(
          status: QuotationPartEventStatus.EDIT,
          part: part,
          pk: widget.part.id,
          quotationPk: widget.quotationPk,
        ));
      }
    }
  }

  void _handleEditImage(QuotationPartImage image, BuildContext context) {
    final page =  (image != null) ?
      PartImageFormPage(partImagePk: image.id, quotationPartPk: widget.part.id, quotationPk: widget.quotationPk) :
      PartImageFormPage(partImagePk: null, quotationPartPk: widget.part.id, quotationPk: widget.quotationPk)
      ;

    Navigator.push(
        context, MaterialPageRoute(builder: (context) => page)
    );
  }

  void _handleEditLine(QuotationPartLine line, BuildContext context) {
    final page =  (line != null) ?
      PartLineFormPage(partLinePk: line.id, quotationPartPk: widget.part.id, quotationPk: widget.quotationPk) :
      PartLineFormPage(partLinePk: null, quotationPartPk: widget.part.id, quotationPk: widget.quotationPk)
    ;

    Navigator.push(
        context, MaterialPageRoute(builder: (context) => page)
    );
  }

  void _navQuotation() {
    final page = PreliminaryDetailPage(quotationPk: widget.quotationPk);

    Navigator.push(
        context, MaterialPageRoute(builder: (context) => page)
    );
  }

  Widget _buildNavQuotationButton() {
    return createElevatedButtonColored(
        'quotations.parts.button_nav_quotation'.tr(), _navQuotation);
  }

  Widget _buildImagesSection() {
    return buildItemsSection(
        'quotations.parts.header_table_images'.tr(),
        widget.part != null ? widget.part.images : [],
        (QuotationPartImage image) {
          List<Widget> items = [];

          items.add(createImagePart(
              image.thumbnailUrl,
              image.description
          ));

          return items;
        },
        (item) {
          List<Widget> items = [];

          items.add(
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  createDefaultElevatedButton(
                      'quotations.part_images.button_edit'.tr(),
                      () { _handleEditImage(item, context); }
                  ),
                ],
              )
          );

          return items;
        }
    );
  }

  Widget _buildLinesSection() {
    return buildItemsSection(
        'quotations.parts.header_table_lines'.tr(),
        widget.part != null ? widget.part.lines : [],
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

          items.add(
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  createDefaultElevatedButton(
                      'quotations.parts.button_edit_line'.tr(),
                      () { _handleEditLine(line, context); }
                  ),
                ],
              )
          );

          return items;
        }
    );
  }

  _showDeleteDialog(QuotationPart part) {
    showDeleteDialogWrapper(
        'generic.delete_dialog_title_document'.tr(),
        'quotations.parts.delete_dialog_content'.tr(),
        () => _doDelete(part.id)
    );
  }

  _doDelete(int pk) async {
    final bloc = BlocProvider.of<QuotationPartBloc>(context);

    bloc.add(QuotationPartEvent(
      status: QuotationPartEventStatus.DELETE,
      pk: pk,
    ));
  }

}
