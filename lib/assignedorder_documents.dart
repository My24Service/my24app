import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart';
import 'package:file_picker/file_picker.dart';

import 'models.dart';
import 'utils.dart';
import 'assigned_order.dart';


BuildContext localContext;

Future<bool> deleteAssignedOrderDocment(http.Client client, AssignedOrderDocument document) async {
  // refresh token
  SlidingToken newToken = await refreshSlidingToken(client);

  if (newToken == null) {
    throw TokenExpiredException('token expired');
  }

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

  print(response.statusCode);

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

  String _fileName;
  String _path;
  FileType _pickingType = FileType.any;

  AssignedOrderDocuments _assignedOrderDocuments;

  @override
  void initState() {
    super.initState();
  }

  void _openFileExplorer() async {
    try {
      _path = await FilePicker.getFilePath(
        type: _pickingType,
        allowedExtensions: null,
      );
      print(_path);
    } on PlatformException catch (e) {
      print("Unsupported operation" + e.toString());
    }
    if (!mounted) return;
    setState(() {
      _fileName = _path != null ? _path.split('/').last : '';

      _documentController.text = _fileName;
      _nameController.text = _fileName;
    });
  }

  Widget _buildOpenFileButton() {
    return new RaisedButton(
      onPressed: () => _openFileExplorer(),
      child: new Text("Open file picker"),
    );
  }

  showDeleteDialog(AssignedOrderDocument document) {
    // set up the buttons
    Widget cancelButton = FlatButton(
      child: Text("Cancel"),
      onPressed:  () {
        Navigator.pop(context, false);
      },
    );
    Widget deleteButton = FlatButton(
      child: Text("Delete"),
      onPressed:  () async {
        Navigator.pop(context, true);
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("Delete product"),
      content: Text("Do you want to delete this product?"),
      actions: [
        cancelButton,
        deleteButton,
      ],
    );

    // show the dialog
    showDialog(
      context: localContext,
      builder: (BuildContext context) {
        return alert;
      },
    ).then((dialogResult) async {
      if (dialogResult) {
          bool result = await deleteAssignedOrderDocment(http.Client(), document);

          // fetch and refresh screen
          if (result) {
            await fetchAssignedOrderDocuments(http.Client());
            setState(() {});
          }
      }
    });
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
                showDeleteDialog(document);
              },
          )
        ]),
      ]));
    }

    return createTable(rows);
  }

  Widget _buildFormTypeAhead() {
    return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text('New document'),
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
          _buildOpenFileButton(),
          SizedBox(
            height: 10.0,
          ),
          RaisedButton(
            child: Text('Submit'),
            onPressed: () async {
              if (this._formKey.currentState.validate()) {
                this._formKey.currentState.save();

                File documentFile = await _getLocalFile(_path);

                AssignedOrderDocument document = AssignedOrderDocument(
                    name: _nameController.text,
                    description: _descriptionController.text,
                    document: base64Encode(documentFile.readAsBytesSync()),
                );

                bool result = await storeAssignedOrderDocument(http.Client(), document);

                if (result) {
                  // reset fields
                  _nameController.text = '';
                  _descriptionController.text = '';
                  _documentController.text = '';

                  _assignedOrderDocuments = await fetchAssignedOrderDocuments(http.Client());
                  FocusScope.of(context).unfocus();
                  setState(() {});

                } else {
                  displayDialog(context, 'Error', 'Error storing document');
                }
              }
            },
          ),
          SizedBox(
            height: 10.0,
          ),
          RaisedButton(
            child: Text('Back to order'),
            onPressed: () {
              Navigator.push(context,
                  new MaterialPageRoute(
                      builder: (context) => AssignedOrderPage())
              );
            },
          )
        ],
      );
  }

  @override
  Widget build(BuildContext context) {
    localContext = context;
    
    return Scaffold(
        appBar: AppBar(
          title: Text('Documents'),
        ),
        body: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Form(
            key: _formKey,
            child: Container(
              alignment: Alignment.center,
              child: SingleChildScrollView(    // new line
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    _buildFormTypeAhead(),
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
                          return _buildDocumentsTable();
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
        )
    );
  }
}
