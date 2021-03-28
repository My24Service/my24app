import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

import 'models.dart';
import 'utils.dart';


Future<bool> deleteQuotationImage(http.Client client, QuotationImage image) async {
  // refresh token
  SlidingToken newToken = await refreshSlidingToken(client);

  final url = await getUrl('/quotation/quotation-image/${image.id}/');
  final response = await client.delete(url, headers: getHeaders(newToken.token));

  if (response.statusCode == 204) {
    return true;
  }

  return false;
}

Future<QuotationImages> fetchQuotationImages(http.Client client) async {
  // refresh token
  SlidingToken newToken = await refreshSlidingToken(client);

  SharedPreferences prefs = await SharedPreferences.getInstance();
  final quotationPk = prefs.getInt('quotation_pk');
  final url = await getUrl('/quotation/quotation-image/?quotation=$quotationPk');
  final response = await client.get(url, headers: getHeaders(newToken.token));

  if (response.statusCode == 200) {
    return QuotationImages.fromJson(json.decode(response.body));
  }

  throw Exception('quotations.images.exception_fetch'.tr());
}

Future<bool> storeQuotationImage(http.Client client, QuotationImage image) async {
  // refresh token
  SlidingToken newToken = await refreshSlidingToken(client);

  // store it in the API
  SharedPreferences prefs = await SharedPreferences.getInstance();
  final quotationPk = prefs.getInt('quotation_pk');
  final String token = newToken.token;
  final url = await getUrl('/quotation/quotation-image/');
  final authHeaders = getHeaders(token);
  final Map<String, String> headers = {"Content-Type": "application/json; charset=UTF-8"};
  Map<String, String> allHeaders = {};
  allHeaders.addAll(authHeaders);
  allHeaders.addAll(headers);

  final Map body = {
    'quotation': quotationPk,
    'image': image.image,
    'description': image.description,
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

class QuotationImagePage extends StatefulWidget {
  @override
  _QuotationImagePageState createState() =>
      _QuotationImagePageState();
}

class _QuotationImagePageState extends State<QuotationImagePage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  var _nameController = TextEditingController();
  var _descriptionController = TextEditingController();
  var _imageController = TextEditingController();

  File _image;
  final picker = ImagePicker();

  String _filePath;

  QuotationImages _images;

  bool _saving = false;

  @override
  void initState() {
    super.initState();
  }

  _openImageCamera() async {
    final pickedFile = await picker.getImage(source: ImageSource.camera);

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
        String filename = pickedFile.path.split("/").last;

        _imageController.text = filename;
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

        _imageController.text = filename;
        _filePath = null;
      } else {
        print('No image selected.');
      }
    });
  }

  Widget _buildTakePictureButton() {
    return createBlueElevatedButton(
      'quotations.images.button_take_picture'.tr(), _openImageCamera);
  }

  Widget _buildChooseImageButton() {
    return createBlueElevatedButton(
      'quotations.images.button_choose_image'.tr(), _openImagePicker);
  }

  _doDelete(QuotationImage image) async {
    setState(() {
      _saving = true;
    });

    bool result = await deleteQuotationImage(http.Client(), image);

    // fetch and refresh screen
    if (result) {
      createSnackBar(context, 'quotations.images.snackbar_deleted'.tr());
      await fetchQuotationImages(http.Client());
      setState(() {
        _saving = false;
      });
    } else {
      displayDialog(context, 'generic.error_dialog_title'.tr(),
        'quotations.images.'.tr());
    }
  }

  _showDeleteDialog(QuotationImage image) {
    showDeleteDialog(
        'quotations.images.delete_dialog_title'.tr(),
        'quotations.images.delete_dialog_content'.tr(),
        context, () => _doDelete(image));
  }

  Widget _buildImagesTable() {
    List<TableRow> rows = [];

    // header
    rows.add(TableRow(
      children: [
        Column(children: [
          createTableHeaderCell('quotations.images.info_image'.tr())
        ]),
        Column(children: [
          createTableHeaderCell('quotations.images.info_description'.tr())
        ]),
        Column(children: [
          createTableHeaderCell('generic.action_delete'.tr())
        ])
      ],
    ));

    // documents
    for (int i = 0; i < _images.results.length; ++i) {
      QuotationImage image = _images.results[i];

      rows.add(TableRow(children: [
        Column(
            children: [
              createTableColumnCell(image.image)
            ]
        ),
        Column(
            children: [
              createTableColumnCell(image.description)
            ]
        ),
        Column(children: [
          IconButton(
              icon: Icon(Icons.delete, color: Colors.red),
              onPressed: () {
                _showDeleteDialog(image);
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
          createHeader('quotations.images.header_new_image'.tr()),
          SizedBox(
            height: 10.0,
          ),
          Text('quotations.images.info_description'.tr()),
          TextFormField(
              controller: _descriptionController,
              validator: (value) {
                return null;
              }),
          SizedBox(
            height: 10.0,
          ),
          Text('quotations.images.info_image'.tr()),
          TextFormField(
              readOnly: true,
              controller: _imageController,
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
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              primary: Colors.blue, // background
              onPrimary: Colors.white, // foreground
            ),
            child: Text('quotations.images.form_button_submit'.tr()),
            onPressed: () async {
              if (this._formKey.currentState.validate()) {
                this._formKey.currentState.save();

                QuotationImage image = QuotationImage(
                    description: _descriptionController.text,
                    image: base64Encode(_image.readAsBytesSync()),
                );

                setState(() {
                  _saving = true;
                });

                bool result = await storeQuotationImage(
                    http.Client(), image);

                if (result) {
                  createSnackBar(context, 'quotations.images.snackbar_added'.tr());

                  // reset fields
                  _descriptionController.text = '';
                  _imageController.text = '';

                  _images = await fetchQuotationImages(
                      http.Client());
                  FocusScope.of(context).unfocus();
                  setState(() {
                    _saving = false;
                  });
                } else {
                  displayDialog(context,
                    'generic.error_dialog_title'.tr(),
                    'quotations.images.error_adding'.tr()
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
          title: Text('quotations.images.app_bar_title'.tr()),
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
                      FutureBuilder<QuotationImages>(
                        future: fetchQuotationImages(http.Client()),
                        // ignore: missing_return
                        builder: (context, snapshot) {
                          if (snapshot.data == null) {
                            return Container(
                                child: Center(
                                    child: Text('generic.loading'.tr())
                                )
                            );
                          } else {
                            _images = snapshot.data;
                            return Container(
                              child: Column(
                                children: [
                                  SizedBox(
                                    height: 10.0,
                                  ),
                                  _buildImagesTable(),
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
