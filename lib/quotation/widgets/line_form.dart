import 'dart:convert';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:my24app/quotation/models/models.dart';

import 'package:my24app/core/widgets/widgets.dart';

import '../../inventory/api/inventory_api.dart';
import '../../inventory/models/models.dart';
import '../blocs/line_bloc.dart';
import '../pages/part_form.dart';


class PartLineFormWidget extends StatefulWidget {
  final int quotationPk;
  final int quotatonPartId;
  final QuotationPartLine line;

  PartLineFormWidget({
    Key key,
    this.quotationPk,
    this.quotatonPartId,
    this.line,
  }): super(key: key);

  @override
  State<StatefulWidget> createState() => new _PartLineFormWidgetState();
}

class _PartLineFormWidgetState extends State<PartLineFormWidget> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  var _oldProductController = TextEditingController();
  var _newProductNameController = TextEditingController();
  var _newProductIdentifierController = TextEditingController();
  var _amountController = TextEditingController();
  var _locationController = TextEditingController();
  var _infoController = TextEditingController();

  final TextEditingController _typeAheadController = TextEditingController();
  InventoryMaterialTypeAheadModel _selectedMaterial;

  int _newProductRelation;
  bool _inAsyncCall = false;

  @override
  void initState() {
    if (widget.line != null) {
      _oldProductController.text = widget.line.oldProduct;
      _newProductNameController.text = widget.line.newProductName;
      _newProductIdentifierController.text = widget.line.newProductIdentifier;
      _newProductRelation = widget.line.newProductRelation;
      _amountController.text = "${widget.line.amount}";
      _locationController.text = widget.line.location;
      _infoController.text = widget.line.info;
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
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        alignment: Alignment.center,
        child: SingleChildScrollView(
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  createHeader(widget.line != null ? 'quotations.part_lines.header_edit'.tr() : 'quotations.part_lines.header_add'.tr()),
                  Form(
                      key: _formKey,
                      child: _buildForm(context)
                  ),
                ]
            )
        )
    );
  }

  void _cancelEdit() {
    final page = PartFormPage(
        quotationPk: widget.quotationPk,
        quotationPartPk: widget.quotatonPartId
    );

    Navigator.pop(context);
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => page)
    );
  }

  Widget _buildForm(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        SizedBox(
          height: 10.0,
        ),
        Text('quotations.info_line_old_product_name'.tr()),
        TextFormField(
            controller: _oldProductController,
            validator: (value) {
              return null;
            }),
        SizedBox(
          height: 10.0,
        ),
        TypeAheadFormField(
          textFieldConfiguration: TextFieldConfiguration(
              controller: _typeAheadController,
              decoration: InputDecoration(
                  labelText:
                  'quotations.part_lines.typeahead_label_search_products'.tr()
              )
          ),
          suggestionsCallback: (pattern) async {
            if (pattern.length < 1) return null;
            return await inventoryApi.materialTypeAhead(pattern);
          },
          itemBuilder: (context, suggestion) {
            return ListTile(
              title: Text(
                  '${suggestion.materialName}'
              ),
            );
          },
          transitionBuilder: (context, suggestionsBox, controller) {
            return suggestionsBox;
          },
          onSuggestionSelected: (suggestion) {
            _selectedMaterial = suggestion;
            _newProductRelation = suggestion.id;
            _newProductNameController.text = suggestion.materialName;
            _newProductIdentifierController.text = suggestion.materialIdentifier;

            _typeAheadController.text = '';

            // rebuild widgets
            setState(() {});
          },
          validator: (value) {
            return null;
          },
        ),
        Text('quotations.info_line_product_name'.tr()),
        TextFormField(
            readOnly: true,
            controller: _newProductNameController,
            validator: (value) {
              return null;
            }),
        SizedBox(
          height: 10.0,
        ),
        Text('quotations.info_line_product_identifier'.tr()),
        TextFormField(
            readOnly: true,
            controller: _newProductIdentifierController,
            validator: (value) {
              return null;
            }),
        SizedBox(
          height: 10.0,
        ),
        Text('quotations.info_line_product_amount'.tr()),
        TextFormField(
            controller: _amountController,
            keyboardType:
            TextInputType.numberWithOptions(signed: false, decimal: true),
            validator: (value) {
              if (value.isEmpty) {
                return 'quotations.part_lines.validator_amount'.tr();
              }
              return null;
            }),
        SizedBox(
          height: 10.0,
        ),
        Text('quotations.info_line_product_info'.tr()),
        TextFormField(
            controller: _infoController,
            validator: (value) {
              return null;
            }),
        SizedBox(
          height: 10.0,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            createDefaultElevatedButton(
                widget.line == null ? 'quotations.part_lines.button_add'.tr() :
                'quotations.part_lines.button_edit'.tr(),
                _handleSubmit
            ),
            if (widget.line != null)
              SizedBox(width: 10),
            if (widget.line != null)
              createDeleteButton(
                  'quotations.part_lines.button_delete'.tr(),
                  () { _showDeleteDialog(widget.line, context); }
              ),
            SizedBox(width: 10),
            createCancelButton(_cancelEdit),
          ],
        )
      ],
    );
  }

  Future<void> _handleSubmit() async {
    if (this._formKey.currentState.validate()) {
      this._formKey.currentState.save();
      final bloc = BlocProvider.of<PartLineBloc>(context);
      
      QuotationPartLine line = QuotationPartLine(
        quotatonPartId: widget.quotatonPartId,
        oldProduct: _oldProductController.text,
        newProductName: _newProductNameController.text,
        newProductIdentifier: _newProductIdentifierController.text,
        newProductRelation: _newProductRelation,
        amount: double.parse(_amountController.text),
        location: _locationController.text,
        info: _infoController.text,
      );

      if (widget.line == null) {
        bloc.add(PartLineEvent(
            status: PartLineEventStatus.INSERT,
            line: line
        ));
      } else {
        bloc.add(PartLineEvent(
            status: PartLineEventStatus.EDIT,
            line: line,
            pk: widget.line.id
        ));
      }
    }
  }

  _showDeleteDialog(QuotationPartLine image, BuildContext context) {
    assert(context != null);
    showDeleteDialogWrapper(
        'generic.delete_dialog_title_document'.tr(),
        'generic.delete_dialog_content_document'.tr(),
        context, () => _doDelete(image.id)
    );
  }

  _doDelete(int pk) async {
    final bloc = BlocProvider.of<PartLineBloc>(context);

    bloc.add(PartLineEvent(
        status: PartLineEventStatus.DELETE,
        pk: pk
    ));
  }
}
