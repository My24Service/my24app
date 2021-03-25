import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';

import 'models.dart';
import 'utils.dart';


Future<bool> deleteAssignedOrderDocment(http.Client client, AssignedOrderDocument document) async {
  // refresh token
  SlidingToken newToken = await refreshSlidingToken(client);

  if (newToken == null) {
    throw TokenExpiredException('token expired');
  }

  // refresh last position
  // await storeLastPosition(http.Client());

  final url = await getUrl('/mobile/assignedorderdocument/${document.id}/');
  final response = await client.delete(url, headers: getHeaders(newToken.token));

  if (response.statusCode == 204) {
    return true;
  }

  return false;
}

Future<AssignedOrderDocuments> fetchAssignedOrderDocuments(http.Client client) async {
  // refresh token
  SlidingToken newToken = await refreshSlidingToken(client);

  if (newToken == null) {
    throw TokenExpiredException('token expired');
  }

  // refresh last position
  // await storeLastPosition(http.Client());

  SharedPreferences prefs = await SharedPreferences.getInstance();
  final assignedorderPk = prefs.getInt('assignedorder_pk');
  final url = await getUrl('/mobile/assignedorderdocument/?assigned_order=$assignedorderPk');
  final response = await client.get(url, headers: getHeaders(newToken.token));

  if (response.statusCode == 200) {
    return AssignedOrderDocuments.fromJson(json.decode(response.body));
  }

  throw Exception('Failed to load assigned order products');
}

Future<bool> storeAssignedOrderDocument(http.Client client, AssignedOrderDocument document) async {
  // refresh token
  SlidingToken newToken = await refreshSlidingToken(client);

  if (newToken == null) {
    // do nothing
    return false;
  }

  // refresh last position
  // await storeLastPosition(http.Client());

  // store it in the API
  SharedPreferences prefs = await SharedPreferences.getInstance();
  final assignedorderPk = prefs.getInt('assignedorder_pk');
  final String token = newToken.token;
  final url = await getUrl('/mobile/assignedorderdocument/');
  final authHeaders = getHeaders(token);
  final Map<String, String> headers = {"Content-Type": "application/json; charset=UTF-8"};
  Map<String, String> allHeaders = {};
  allHeaders.addAll(authHeaders);
  allHeaders.addAll(headers);

  final Map body = {
    'assigned_order': assignedorderPk,
    'name': document.name,
    'description': document.description,
    'document': document.document,
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

class AssignedOrderDocumentPage extends StatefulWidget {
  @override
  _AssignedOrderDocumentPageState createState() =>
      _AssignedOrderDocumentPageState();
}

class _AssignedOrderDocumentPageState extends State<AssignedOrderDocumentPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  var _nameController = TextEditingController();
  var _descriptionController = TextEditingController();
  var _documentController = TextEditingController();

  File _image;
  final picker = ImagePicker();

  String _filePath;

  AssignedOrderDocuments _assignedOrderDocuments;

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
    return createBlueElevatedButton('Choose file', _openFilePicker);
  }

  Widget _buildTakePictureButton() {
    return createBlueElevatedButton('Take picture', _openImageCamera);
  }

  Widget _buildChooseImageButton() {
    return createBlueElevatedButton('Choose image', _openImagePicker);
  }
  
  _doDelete(AssignedOrderDocument document) async {
    setState(() {
      _saving = true;
    });

    bool result = await deleteAssignedOrderDocment(http.Client(), document);

    // fetch and refresh screen
    if (result) {
      createSnackBar(context, 'Document deleted');

      await fetchAssignedOrderDocuments(http.Client());
      setState(() {
        _saving = false;
      });
    }
  }

  _showDeleteDialog(AssignedOrderDocument document, BuildContext context) {
    showDeleteDialog(
        'Delete document', 'Do you want to delete this document?',
        context, () => _doDelete(document));
  }

  Widget _buildDocumentsTable() {
    List<TableRow> rows = [];

    // header
    rows.add(TableRow(
      children: [
        Column(children: [
          createTableHeaderCell('Name')
        ]),
        Column(children: [
          createTableHeaderCell('Description')
        ]),
        Column(children: [
          createTableHeaderCell('Document')
        ]),
        Column(children: [
          createTableHeaderCell('Delete')
        ])
      ],
    ));

    // documents
    for (int i = 0; i < _assignedOrderDocuments.results.length; ++i) {
      AssignedOrderDocument document = _assignedOrderDocuments.results[i];

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
              createTableColumnCell(document.document.split('/').last)
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
          createHeader('New document'),
          SizedBox(
            height: 10.0,
          ),
          Text('Name'),
          TextFormField(
              controller: _nameController,
              validator: (value) {
                if (value.isEmpty) {
                  return 'Please enter a name';
                }
                return null;
              }),
          SizedBox(
            height: 10.0,
          ),
          Text('Description'),
          TextFormField(
              controller: _descriptionController,
              validator: (value) {
                return null;
              }),
          SizedBox(
            height: 10.0,
          ),
          Text('Document'),
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
            Text("Or:", style: TextStyle(
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
            child: Text('Submit'),
            onPressed: () async {
              if (this._formKey.currentState.validate()) {
                this._formKey.currentState.save();

                File documentFile = _filePath != null ?
                  await _getLocalFile(_filePath) : _image;

                if (documentFile == null) {
                  displayDialog(
                      context,
                      'No document', 'Please choose a document or image');
                  return;
                }

                AssignedOrderDocument document = AssignedOrderDocument(
                    name: _nameController.text,
                    description: _descriptionController.text,
                    document: base64Encode(documentFile.readAsBytesSync()),
                );

                setState(() {
                  _saving = true;
                });

                bool result = await storeAssignedOrderDocument(
                    http.Client(), document);

                if (result) {
                  createSnackBar(context, 'Document saved');

                  // reset fields
                  _nameController.text = '';
                  _descriptionController.text = '';
                  _documentController.text = '';

                  _assignedOrderDocuments = await fetchAssignedOrderDocuments(
                      http.Client());
                  FocusScope.of(context).unfocus();
                  setState(() {
                    _saving = false;
                  });
                } else {
                  displayDialog(context, 'Error', 'Error storing document');
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
          title: Text('Documents'),
        ),
        body: ModalProgressHUD(child: Container(
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
                    FutureBuilder<AssignedOrderDocuments>(
                      future: fetchAssignedOrderDocuments(http.Client()),
                      // ignore: missing_return
                      builder: (context, snapshot) {
                        if (snapshot.data == null) {
                          return Container(
                              child: Center(
                                  child: Text("Loading...")
                              )
                          );
                        } else {
                          _assignedOrderDocuments = snapshot.data;
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
    );
  }
}
