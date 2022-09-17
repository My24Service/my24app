import 'dart:convert';
import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:image_picker/image_picker.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:my24app/quotation/models/models.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:my24app/core/widgets/widgets.dart';
import 'package:my24app/order/pages/list.dart';
import 'package:my24app/core/utils.dart';

import '../../inventory/api/inventory_api.dart';
import '../../inventory/models/models.dart';
import '../blocs/quotation_bloc.dart';


Future<File> _getLocalFile(String path) async {
  return File(path);
}

class PartFormWidget extends StatefulWidget {
  final QuotationPart part;

  PartFormWidget({
    Key key,
    @required this.part,
  }): super(key: key);

  @override
  State<StatefulWidget> createState() => new _PartFormWidgetState();
}

class _PartFormWidgetState extends State<PartFormWidget> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  var _nameController = TextEditingController();
  var _descriptionController = TextEditingController();
  var _documentController = TextEditingController();
  var _materialIdentifierController = TextEditingController();
  var _productNameController = TextEditingController();
  var _materialAmountController = TextEditingController();

  InventoryMaterialTypeAheadModel _selectedMaterial;
  String _selectedMaterialName;
  int _selectedMaterialId;
  int _editId;
  String _editMaterialName;
  String _editMaterialIdentifier;

  final TextEditingController _typeAheadController = TextEditingController();
  InventoryMaterialTypeAheadModel _selectedProduct;
  String _selectedProductName;

  File _image;
  final picker = ImagePicker();

  String _filePath;

  bool _inAsyncCall = false;
  bool _editImageMode = false;
  bool _editLineMode = false;

  @override
  Widget build(BuildContext context) {
    return ModalProgressHUD(
        child:_showMainView(),
        inAsyncCall: _inAsyncCall
    );
  }

  Widget _showMainView() {
    if (_editImageMode) {
      return _buildImageForm();
    }

    if (_editLineMode) {
      return _buildLineForm();
    }

    return Container(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Form(
            key: _formKey,
            child: Container(
                alignment: Alignment.center,
                child: SingleChildScrollView(    // new line
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          createHeader('quotations.parts.header_edit_part'.tr()),
                          _buildPartForm(),
                          Divider(),
                          _buildImagesSection(),
                          Divider(),
                          _buildLinesSection(),
                          Divider(),
                          _buildNavOrdersButton()
                        ]
                    )
                )
            )
        )
    );
  }

  _openFilePicker() async {
    FilePickerResult result = await FilePicker.platform.pickFiles();

    if(result != null) {
      PlatformFile file = result.files.first;

      setState(() {
        _documentController.text = file.name;
        _nameController.text = file.name;
        _filePath = file.path;
        _image = null;
      });
    }
  }

  _openImageCamera() async {
    final pickedFile = await picker.getImage(source: ImageSource.camera);

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
        String filename = pickedFile.path.split("/").last;

        _documentController.text = filename;
        _filePath = null;
      } else {
        print('No image selected.');
      }
    });
  }

  _openImagePicker() async {
    final pickedFile = await picker.getImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
        String filename = pickedFile.path.split("/").last;

        _documentController.text = filename;
        _filePath = null;
      } else {
        print('No image selected.');
      }
    });
  }

  Widget _buildOpenFileButton() {
    return createElevatedButtonColored(
        'generic.button_choose_file'.tr(), _openFilePicker);
  }

  Widget _buildTakePictureButton() {
    return createElevatedButtonColored(
        'generic.button_take_picture'.tr(), _openImageCamera);
  }

  Widget _buildChooseImageButton() {
    return createElevatedButtonColored(
        'generic.button_choose_image'.tr(), _openImagePicker);
  }

  void _navQuotation() {
    final page = OrderListPage();

    Navigator.pop(context);
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => page)
    );
  }

  Widget _buildNavOrdersButton() {
    return createElevatedButtonColored(
        'quotations.parts.button_nav_quotation'.tr(), _navQuotation);
  }

  _doDeleteLine(int linePk) async {
    final bloc = BlocProvider.of<QuotationBloc>(context);

    bloc.add(QuotationEvent(status: QuotationEventStatus.DO_ASYNC));
    bloc.add(QuotationEvent(
        status: QuotationEventStatus.DELETE_LINE, linePk: linePk));
  }

  _doDeleteImage(int imagePk) async {
    final bloc = BlocProvider.of<QuotationBloc>(context);

    bloc.add(QuotationEvent(status: QuotationEventStatus.DO_ASYNC));
    bloc.add(QuotationEvent(
        status: QuotationEventStatus.DELETE_IMAGE, imagePk: imagePk));
  }

  _showDeleteLineDialog(QuotationPartLine line, BuildContext context) {
    showDeleteDialogWrapper(
        'generic.delete_dialog_title_document'.tr(),
        'generic.delete_dialog_content_document'.tr(),
        context, () => _doDeleteLine(line.id)
    );
  }

  _showDeleteImageDialog(QuotationPartImage image, BuildContext context) {
    showDeleteDialogWrapper(
        'generic.delete_dialog_title_document'.tr(),
        'generic.delete_dialog_content_document'.tr(),
        context, () => _doDeleteImage(image.id)
    );
  }

  void _handleEditImage(QuotationPartImage image) {
    _editLineMode = false;
    _editImageMode = true;
    _editId = image.id;
  }

  void _handleEditLine(QuotationPartLine line) {
    _editImageMode = false;
    _editLineMode = true;
    _editId = line.id;
  }

  Widget _buildImagesSection() {
    return buildItemsSection(
        'quotations.parts.header_table_images'.tr(),
        widget.part.images,
        (item) {
          List<Widget> items = [];

          items.add(buildItemListTile('generic.info_description'.tr(), item.description));

          return items;
        },
        (item) {
          List<Widget> items = [];

          items.add(buildItemListViewDocumentButton(
              item,
              (item) async {
                String url = await utils.getUrl(item.url);
                launchUrl(Uri.parse(url.replaceAll('/api', '')));
              }
          ));

          items.add(buildItemListEditButton(
              item,
              _handleEditImage,
              context
          ));

          items.add(buildItemListDeleteButton(
              item,
              _showDeleteImageDialog,
              context
          ));

          return items;
        }
    );
  }

  Widget _buildLinesSection() {
    return buildItemsSection(
        'quotations.parts.header_table_lines'.tr(),
        widget.part.lines,
        (QuotationPartLine line) {
            List<Widget> items = [];

            items.add(buildItemListTile('quotations.info_line_old_product_name'.tr(), line.oldProductName));
            items.add(buildItemListTile('quotations.info_line_product_name'.tr(), line.productName));
            items.add(buildItemListTile('quotations.info_line_product_identifier'.tr(), line.productIdentifier));
            items.add(buildItemListTile('quotations.info_line_product_amount'.tr(), line.amount));

            return items;
        },
        (QuotationPartLine line) {
          List<Widget> items = [];

          items.add(buildItemListEditButton(
              line,
              _handleEditLine,
              context
          ));

          items.add(buildItemListDeleteButton(
              line,
              _showDeleteLineDialog,
              context
          ));

          return items;
        }
    );
  }

  Widget _buildImageForm() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        createHeader(
            _editId == null ? 'quotations.parts.header_add_image'.tr() :
            'quotations.parts.header_edit_image'.tr()
        ),
        SizedBox(
          height: 10.0,
        ),
        Text('generic.info_description'.tr()),
        TextFormField(
            controller: _descriptionController,
            validator: (value) {
              return null;
            }),
        SizedBox(
          height: 10.0,
        ),
        Text('generic.info_document'.tr()),
        TextFormField(
            readOnly: true,
            controller: _documentController,
            validator: (value) {
              return null;
            }),
        SizedBox(
          height: 10.0,
        ),
        Column(children: [
          _buildChooseImageButton(),
          Text('generic.info_or'.tr(), style: TextStyle(
              fontWeight: FontWeight.bold,
              fontStyle: FontStyle.italic
          )),
          _buildTakePictureButton(),
        ]),
        SizedBox(
          height: 10.0,
        ),
        createDefaultElevatedButton(
            _editId == null ? 'quotations.parts.button_add_image'.tr() :
            'quotations.parts.button_edit_image'.tr(),
            _handleImageSubmit
        )
      ],
    );
  }

  Widget _buildLineForm() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        createHeader(
            _editId == null ? 'quotations.parts.header_add_line'.tr() :
            'quotations.parts.header_edit_line'.tr()
        ),
        TypeAheadFormField(
          textFieldConfiguration: TextFieldConfiguration(
              controller: this._typeAheadController,
              keyboardType: TextInputType.text,
              decoration: InputDecoration(
                  labelText:
                  'assigned_orders.materials.typeahead_label_material'
                      .tr())),
          suggestionsCallback: (pattern) async {
            return await inventoryApi.materialTypeAhead(pattern);
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
            _selectedMaterial = suggestion;

            this._typeAheadController.text = _selectedMaterial.materialName;

            _materialIdentifierController.text =
                _selectedMaterial.materialIdentifier;
            _productNameController.text = _selectedMaterial.materialName;

            // rebuild widgets
            setState(() {});
          },
          validator: (value) {
            if (_editId == null && value.isEmpty) {
              return 'assigned_orders.materials.typeahead_validator_material'
                  .tr();
            }

            return null;
          },
          onSaved: (value) => this._selectedMaterialName = value,
        ),
        SizedBox(
          height: 10.0,
        ),
        Text('assigned_orders.materials.info_material'.tr()),
        TextFormField(
            readOnly: true,
            controller: _productNameController,
            keyboardType: TextInputType.text,
            validator: (value) {
              // if (value.isEmpty) {
              //   return 'assigned_orders.materials.validator_material'.tr();
              // }
              return null;
            }),
        SizedBox(
          height: 10.0,
        ),
        Text('assigned_orders.materials.info_identifier'.tr()),
        TextFormField(
            readOnly: true,
            controller: _materialIdentifierController,
            keyboardType: TextInputType.text,
            validator: (value) {
              return null;
            }),
        SizedBox(
          height: 10.0,
        ),
        Text('assigned_orders.materials.info_amount'.tr()),
        TextFormField(
            controller: _materialAmountController,
            keyboardType:
            TextInputType.numberWithOptions(signed: false, decimal: true),
            validator: (value) {
              if (value.isEmpty) {
                return 'assigned_orders.materials.validator_amount'.tr();
              }
              return null;
            }),
        SizedBox(
          height: 10.0,
        ),
        createDefaultElevatedButton(
            _editId == null ? 'assigned_orders.materials.button_add_material'.tr() :
            'assigned_orders.materials.button_update_material'.tr(),
            _handleLineSubmit
        ),
      ],
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
            'generic.form_button_submit_document'.tr(),
            _handlePartSubmit
        )
      ],
    );
  }

  Future<void> _handlePartSubmit() async {

  }

  Future<void> _handleLineSubmit() async {

  }

  Future<void> _handleImageSubmit() async {
    if (this._formKey.currentState.validate()) {
      this._formKey.currentState.save();

      // File documentFile = _filePath != null ? await _getLocalFile(_filePath) : _image;
      //
      // if (documentFile == null) {
      //   displayDialog(context,
      //       'generic.dialog_no_document_title'.tr(),
      //       'generic.dialog_no_document_content'.tr()
      //   );
      //   return;
      // }
      //
      // OrderDocument document = OrderDocument(
      //   name: _nameController.text,
      //   description: _descriptionController.text,
      //   file: base64Encode(documentFile.readAsBytesSync()),
      // );
      //
      // setState(() {
      //   _inAsyncCall = true;
      // });
      //
      // final OrderDocument newDocument = await documentApi.insertOrderDocument(document, widget.orderPk);
      //
      // setState(() {
      //   _inAsyncCall = false;
      // });
      //
      // if (newDocument == null) {
      //   displayDialog(context,
      //       'generic.error_dialog_title'.tr(),
      //       'generic.error_adding_document'.tr()
      //   );
      //
      //   return;
      // }

      final QuotationBloc bloc = BlocProvider.of<QuotationBloc>(context);
      createSnackBar(context, 'generic.snackbar_added_document'.tr());

      bloc.add(QuotationEvent(
          status: QuotationEventStatus.DO_ASYNC)
      );
      bloc.add(QuotationEvent(
          status: QuotationEventStatus.FETCH_PART_DETAIL,
          quotationPartPk: widget.part.id)
      );
    }
  }
}
