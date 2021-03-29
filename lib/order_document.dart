import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:easy_localization/easy_localization.dart';

import 'models.dart';
import 'utils.dart';


Future<bool> deleteOrderDocument(http.Client client, OrderDocument document) async {
  // refresh token
  SlidingToken newToken = await refreshSlidingToken(client);

  final url = await getUrl('/order/document/${document.id}/');
  final response = await client.delete(url, headers: getHeaders(newToken.token));

  if (response.statusCode == 204) {
    return true;
  }

  return false;
}

Future<OrderDocuments> fetchOrderDocuments(http.Client client) async {
  // refresh token
  SlidingToken newToken = await refreshSlidingToken(client);

  SharedPreferences prefs = await SharedPreferences.getInstance();
  int orderPk = prefs.getInt('order_pk');
  final url = await getUrl('/order/document/?order=$orderPk');
  final response = await client.get(url, headers: getHeaders(newToken.token));

  if (response.statusCode == 200) {
    return OrderDocuments.fromJson(json.decode(response.body));
  }

  throw Exception('orders.documents.exception_fetch'.tr());
}

Future<bool> storeOrderDocument(http.Client client, OrderDocument document) async {
  // refresh token
  SlidingToken newToken = await refreshSlidingToken(client);

  // store it in the API
  SharedPreferences prefs = await SharedPreferences.getInstance();
  final orderPk = prefs.getInt('order_pk');
  final String token = newToken.token;
  final url = await getUrl('/order/document/');
  final authHeaders = getHeaders(token);
  final Map<String, String> headers = {"Content-Type": "application/json; charset=UTF-8"};
  Map<String, String> allHeaders = {};
  allHeaders.addAll(authHeaders);
  allHeaders.addAll(headers);

  final Map body = {
    'order': orderPk,
    'name': document.name,
    'description': document.description,
    'file': document.file,
  };

  final response = await client.post(
    url,
    body: json.encode(body),
    headers: allHeaders,
  );

  // return
  if (response.statusCode == 401) {
    return false;
  }

  if (response.statusCode == 201) {
    return true;
  }

  return false;
}

Future<File> _getLocalFile(String path) async {
  return File(path);
}

class OrderDocumentPage extends StatefulWidget {
  @override
  _OrderDocumentPageState createState() =>
      _OrderDocumentPageState();
}

class _OrderDocumentPageState extends State<OrderDocumentPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  var _nameController = TextEditingController();
  var _descriptionController = TextEditingController();
  var _documentController = TextEditingController();

  File _image;
  final picker = ImagePicker();

  String _filePath;

  OrderDocuments _orderDocuments;

  bool _saving = false;

  @override
  void initState() {
    super.initState();
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
      'orders.documents.button_choose_file'.tr(), _openFilePicker);
  }

  Widget _buildTakePictureButton() {
    return createBlueElevatedButton(
      'orders.documents.button_take_picture'.tr(), _openImageCamera);
  }

  Widget _buildChooseImageButton() {
    return createBlueElevatedButton(
      'orders.documents.button_choose_image'.tr(), _openImagePicker);
  }

  _doDelete(OrderDocument document) async {
    setState(() {
      _saving = true;
    });

    bool result = await deleteOrderDocument(http.Client(), document);

    // fetch and refresh screen
    if (result) {
      createSnackBar(context, 'orders.documents.snackbar_deleted'.tr());

      await fetchOrderDocuments(http.Client());
      setState(() {
        _saving = false;
      });
    }
  }

  _showDeleteDialog(OrderDocument document, BuildContext context) {
    showDeleteDialog(
      'orders.documents.delete_dialog_title'.tr(),
      'orders.documents.delete_dialog_content'.tr(),
      context, () => _doDelete(document)
    );
  }

  Widget _buildDocumentsTable() {
    List<TableRow> rows = [];

    // header
    rows.add(TableRow(
      children: [
        Column(children: [
          createTableHeaderCell('generic.info_name'.tr())
        ]),
        Column(children: [
          createTableHeaderCell('orders.documents.info_description'.tr())
        ]),
        Column(children: [
          createTableHeaderCell('orders.documents.info_document'.tr())
        ]),
        Column(children: [
          createTableHeaderCell('generic.action_delete'.tr())
        ])
      ],
    ));

    // documents
    for (int i = 0; i < _orderDocuments.results.length; ++i) {
      OrderDocument document = _orderDocuments.results[i];

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
          createHeader('orders.documents.header_new_document'.tr()),
          SizedBox(
            height: 10.0,
          ),
          Text('Name'),
          TextFormField(
              controller: _nameController,
              validator: (value) {
                if (value.isEmpty) {
                  return 'orders.documents.validator_name'.tr();
                }
                return null;
              }),
          SizedBox(
            height: 10.0,
          ),
          Text('orders.documents.info_description'.tr()),
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
              primary: Colors.blue, // background
              onPrimary: Colors.white, // foreground
            ),
            child: Text('orders.document.form_button_submit'.tr()),
            onPressed: () async {
              if (this._formKey.currentState.validate()) {
                this._formKey.currentState.save();

                File documentFile = _filePath != null ? await _getLocalFile(_filePath) : _image;

                if (documentFile == null) {
                  displayDialog(context,
                    'orders.documents.dialog_no_document_title'.tr(),
                    'orders.documents.dialog_no_document_content'.tr()
                  );
                  return;
                }

                OrderDocument document = OrderDocument(
                    name: _nameController.text,
                    description: _descriptionController.text,
                    file: base64Encode(documentFile.readAsBytesSync()),
                );

                setState(() {
                  _saving = true;
                });

                bool result = await storeOrderDocument(http.Client(), document);

                if (result) {
                  createSnackBar(context, 'orders.documents.snackbar_added'.tr());

                  // reset fields
                  _nameController.text = '';
                  _descriptionController.text = '';
                  _documentController.text = '';

                  _orderDocuments = await fetchOrderDocuments(http.Client());
                  FocusScope.of(context).unfocus();
                  setState(() {
                    _saving = false;
                  });
                } else {
                  displayDialog(context,
                    'generic.error_dialog_title'.tr(),
                    'orders.documents.error_adding'.tr()
                  );
                }
              }
            },
          ),
        ],
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('orders.documents.app_bar_title'.tr()),
        ),
        body: GestureDetector(
          onTap: () {
            FocusScope.of(context).requestFocus(new FocusNode());
          },
          child: ModalProgressHUD(child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Form(
              key: _formKey,
              child: Container(
                alignment: Alignment.center,
                child: SingleChildScrollView(    // new line
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      _buildForm(),
                      Divider(),
                      FutureBuilder<OrderDocuments>(
                        future: fetchOrderDocuments(http.Client()),
                        // ignore: missing_return
                        builder: (context, snapshot) {
                          if (snapshot.data == null) {
                            return Container(
                                child: Center(
                                    child: Text('generic.loading'.tr())
                                )
                            );
                          } else {
                            _orderDocuments = snapshot.data;
                            return Container(
                              child: Column(
                                children: [
                                  SizedBox(
                                    height: 10.0,
                                  ),
                                  _buildDocumentsTable(),
                                ],
                              ),
                            );
                          }
                        }
                      ),
                      SizedBox(
                        height: 20.0,
                      ),
                    ],
                  ),
                ),
              ),
            )
          ), inAsyncCall: _saving)
        )
    );
  }
}
