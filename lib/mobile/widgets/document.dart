import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

import 'package:my24app/core/widgets/widgets.dart';
import 'package:my24app/mobile/models/models.dart';
import 'package:my24app/mobile/blocs/document_bloc.dart';
import 'package:my24app/mobile/api/mobile_api.dart';


Future<File> _getLocalFile(String path) async {
  return File(path);
}

class DocumentWidget extends StatefulWidget {
  final AssignedOrderDocuments documents;
  final int assignedOrderPk;

  DocumentWidget({
    Key key,
    this.documents,
    this.assignedOrderPk
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => new _DocumentWidgetState(
      documents: documents,
      assignedOrderPk: assignedOrderPk
  );
}

class _DocumentWidgetState extends State<DocumentWidget> {
  final AssignedOrderDocuments documents;
  final int assignedOrderPk;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  var _nameController = TextEditingController();
  var _descriptionController = TextEditingController();
  var _documentController = TextEditingController();

  File _image;
  final picker = ImagePicker();

  String _filePath;

  bool _inAsyncCall = false;

  _DocumentWidgetState({
    @required this.documents,
    @required this.assignedOrderPk,
  }) : super();

  @override
  Widget build(BuildContext context) {
    return ModalProgressHUD(
        child: _showMainView(context),
        inAsyncCall: _inAsyncCall
    );
  }

  Widget _showMainView(BuildContext context) {
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
                          _buildForm(context),
                          Divider(),
                          _buildDocumentsSection(context),
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

  _doDelete(AssignedOrderDocument document) async {
    final bloc = BlocProvider.of<DocumentBloc>(context);

    bloc.add(DocumentEvent(status: DocumentEventStatus.DO_ASYNC));
    bloc.add(DocumentEvent(
        status: DocumentEventStatus.DELETE, value: document.id));
  }

  _showDeleteDialog(AssignedOrderDocument document, BuildContext context) {
    showDeleteDialogWrapper(
        'generic.delete_dialog_title_document'.tr(),
        'generic.delete_dialog_content_document'.tr(),
        () => _doDelete(document),
        context
    );
  }

  Widget _buildDocumentsSection(BuildContext context) {
    return buildItemsSection(
        context,
        'orders.documents.info_header_table'.tr(),
        documents.results,
        (AssignedOrderDocument item) {
          String value = item.name;
          if (item.description != null && item.description != "") {
            value = "$value (${item.description})";
          }
          return buildItemListKeyValueList('generic.info_document'.tr(), value);
        },
        (item) {
          return <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                createDeleteButton(
                  "orders.documents.button_delete_document".tr(),
                  () {
                    _showDeleteDialog(item, context);
                  }
                )
              ],
            )
          ];
        }
    );
  }

  Widget _buildForm(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        createHeader('generic.header_new_document'.tr()),
        SizedBox(
          height: 10.0,
        ),
        Text('generic.info_name'.tr()),
        TextFormField(
            controller: _nameController,
            validator: (value) {
              if (value.isEmpty) {
                return 'generic.validator_name_document'.tr();
              }
              return null;
            }),
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
          _buildOpenFileButton(),
          SizedBox(
            height: 20.0,
          ),
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
            'generic.form_button_submit_document'.tr(),
            _handleSubmit
        )
      ],
    );
  }

  Future<void> _handleSubmit() async {
    if (this._formKey.currentState.validate()) {
      this._formKey.currentState.save();

      File documentFile = _filePath != null ? await _getLocalFile(_filePath) : _image;

      if (documentFile == null) {
        return await displayDialog(
            context,
            'generic.dialog_no_document_title'.tr(),
            'generic.dialog_no_document_content'.tr()
        );
      }

      AssignedOrderDocument document = AssignedOrderDocument(
        assignedOrderId: assignedOrderPk,
        name: _nameController.text,
        description: _descriptionController.text,
        document: base64Encode(documentFile.readAsBytesSync()),
      );

      setState(() {
        _inAsyncCall = true;
      });

      final AssignedOrderDocument newDocument = await mobileApi.insertAssignedOrderDocument(document, assignedOrderPk);

      setState(() {
        _inAsyncCall = false;
      });

      if (newDocument == null) {
        displayDialog(context,
            'generic.error_dialog_title'.tr(),
            'generic.error_adding_document'.tr()
        );

        return;
      }

      final bloc = BlocProvider.of<DocumentBloc>(context);
      bloc.add(DocumentEvent(status: DocumentEventStatus.INSERTED));
    }
  }
}
