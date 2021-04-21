import 'dart:convert';
import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

import 'package:my24app/order/models/models.dart';
import 'package:my24app/order/blocs/document_bloc.dart';
import 'package:my24app/core/widgets/widgets.dart';
import 'package:my24app/order/api/document_api.dart';


Future<File> _getLocalFile(String path) async {
  return File(path);
}

class DocumentListWidget extends StatefulWidget {
  final OrderDocuments documents;
  final dynamic orderPk;

  DocumentListWidget({
    Key key,
    @required this.documents,
    @required this.orderPk,
  }): super(key: key);

  @override
  State<StatefulWidget> createState() => new _DocumentListWidgetState();
}

class _DocumentListWidgetState extends State<DocumentListWidget> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  var _nameController = TextEditingController();
  var _descriptionController = TextEditingController();
  var _documentController = TextEditingController();

  File _image;
  final picker = ImagePicker();

  String _filePath;

  bool _inAsyncCall = false;

  @override
  Widget build(BuildContext context) {
    return ModalProgressHUD(
      child:_showMainView(),
      inAsyncCall: _inAsyncCall
    );
  }

  Widget _showMainView() {
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
                          createHeader('orders.documents.header_new_document'.tr()),
                          _buildForm(),
                          Divider(),
                          createHeader('orders.documents.header_table'.tr()),
                          _buildDocumentsTable()
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
    return createBlueElevatedButton(
        'generic.button_choose_file'.tr(), _openFilePicker);
  }

  Widget _buildTakePictureButton() {
    return createBlueElevatedButton(
        'generic.button_take_picture'.tr(), _openImageCamera);
  }

  Widget _buildChooseImageButton() {
    return createBlueElevatedButton(
        'generic.button_choose_image'.tr(), _openImagePicker);
  }

  _doDelete(int documentPk) async {
    final bloc = BlocProvider.of<DocumentBloc>(context);

    bloc.add(DocumentEvent(status: DocumentEventStatus.DO_ASYNC));
    bloc.add(DocumentEvent(
        status: DocumentEventStatus.DELETE, value: documentPk));
  }

  _showDeleteDialog(OrderDocument document, BuildContext context) {
    showDeleteDialogWrapper(
        'generic.delete_dialog_title_document'.tr(),
        'generic.delete_dialog_content_document'.tr(),
        context, () => _doDelete(document.id)
    );
  }

  Widget _buildDocumentsTable() {
    if(widget.documents.results.length == 0) {
      return buildEmptyListFeedback();
    }

    List<TableRow> rows = [];

    // header
    rows.add(TableRow(
      children: [
        Column(children: [
          createTableHeaderCell('generic.info_name'.tr())
        ]),
        Column(children: [
          createTableHeaderCell('generic.info_description'.tr())
        ]),
        Column(children: [
          createTableHeaderCell('generic.info_document'.tr())
        ]),
        Column(children: [
          createTableHeaderCell('generic.action_delete'.tr())
        ])
      ],
    ));

    // documents
    for (int i = 0; i < widget.documents.results.length; ++i) {
      OrderDocument document = widget.documents.results[i];

      rows.add(TableRow(children: [
        Column(
            children: [
              createTableColumnCell(document.name)
            ]
        ),
        Column(
            children: [
              createTableColumnCell(document.description)
            ]
        ),
        Column(
            children: [
              createTableColumnCell(document.file.split('/').last)
            ]
        ),
        Column(children: [
          IconButton(
            icon: Icon(Icons.delete, color: Colors.red),
            onPressed: () {
              _showDeleteDialog(document, context);
            },
          )
        ]),
      ]));
    }

    return createTable(rows);
  }

  Widget _buildForm() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text('Name'),
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
        Text('orders.documents.info_photo'.tr()),
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
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            primary: Colors.blue,
            onPrimary: Colors.white,
          ),
          child: Text('generic.form_button_submit_document'.tr()),
          onPressed: () async {
            if (this._formKey.currentState.validate()) {
              this._formKey.currentState.save();

              File documentFile = _filePath != null ? await _getLocalFile(_filePath) : _image;

              if (documentFile == null) {
                displayDialog(context,
                    'generic.dialog_no_document_title'.tr(),
                    'generic.dialog_no_document_content'.tr()
                );
                return;
              }

              OrderDocument document = OrderDocument(
                name: _nameController.text,
                description: _descriptionController.text,
                file: base64Encode(documentFile.readAsBytesSync()),
              );

              setState(() {
                _inAsyncCall = true;
              });

              final OrderDocument newDocument = await documentApi.insertOrderDocument(document, widget.orderPk);

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

              final DocumentBloc bloc = BlocProvider.of<DocumentBloc>(context);
              createSnackBar(context, 'generic.snackbar_added_document'.tr());

              bloc.add(DocumentEvent(
                  status: DocumentEventStatus.DO_ASYNC));
              bloc.add(DocumentEvent(
                  status: DocumentEventStatus.FETCH_ALL,
                  orderPk: widget.orderPk));
            }
          },
        ),
      ],
    );
  }
}
