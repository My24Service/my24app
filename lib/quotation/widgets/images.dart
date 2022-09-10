import 'dart:convert';
import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

import 'package:my24app/core/widgets/widgets.dart';
import 'package:my24app/quotation/blocs/image_bloc.dart';
import 'package:my24app/quotation/models/models.dart';
import 'package:my24app/quotation/api/quotation_api.dart';


class ImageWidget extends StatefulWidget {
  final QuotationImages images;
  final int quotationPk;

  ImageWidget({
    Key key,
    @required this.images,
    @required this.quotationPk,
  }): super(key: key);

  @override
  State<StatefulWidget> createState() => new _ImageWidgetState();
}

class _ImageWidgetState extends State<ImageWidget> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  var _nameController = TextEditingController();
  var _descriptionController = TextEditingController();
  var _imageController = TextEditingController();

  File _image;
  final picker = ImagePicker();

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
                  createHeader('quotations.images.header_new_image'.tr()),
                  _buildForm(),
                  Divider(),
                  createHeader('quotations.images.header_table'.tr()),
                  _buildImagesTable(),
                ],
              ),
            ),
          ),
        )
    );
  }

  _openImageCamera() async {
    final pickedFile = await picker.getImage(source: ImageSource.camera);

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
        String filename = pickedFile.path.split("/").last;

        _imageController.text = filename;
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
      } else {
        print('No image selected.');
      }
    });
  }

  Widget _buildTakePictureButton() {
    return createElevatedButtonColored(
        'quotations.images.button_take_picture'.tr(), _openImageCamera);
  }

  Widget _buildChooseImageButton() {
    return createElevatedButtonColored(
        'quotations.images.button_choose_image'.tr(), _openImagePicker);
  }

  _doDelete(QuotationImage image) async {
    final bloc = BlocProvider.of<ImageBloc>(context);

    bloc.add(ImageEvent(status: ImageEventStatus.DO_ASYNC));
    bloc.add(ImageEvent(status: ImageEventStatus.DELETE, value: image.id));
  }

  _showDeleteDialog(QuotationImage image) {
    showDeleteDialogWrapper(
        'quotations.images.delete_dialog_title'.tr(),
        'quotations.images.delete_dialog_content'.tr(),
        context, () => _doDelete(image));
  }

  Widget _buildImagesTable() {
    if(widget.images.results.length == 0) {
      return buildEmptyListFeedback();
    }

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
    for (int i = 0; i < widget.images.results.length; ++i) {
      QuotationImage image = widget.images.results[i];

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
                _inAsyncCall = true;
              });

              final QuotationImage newImage = await quotationApi.insertQuotationImage(image, widget.quotationPk);

              setState(() {
                _inAsyncCall = false;
              });

              if (newImage == null) {
                displayDialog(context,
                    'generic.error_dialog_title'.tr(),
                    'quotations.images.error_adding'.tr());

                return;
              }

              final ImageBloc bloc = BlocProvider.of<ImageBloc>(context);
              createSnackBar(context, 'quotations.images.snackbar_added'.tr());

              bloc.add(ImageEvent(
                  status: ImageEventStatus.DO_ASYNC));
              bloc.add(ImageEvent(
                  status: ImageEventStatus.FETCH_ALL,
                  quotationPk: widget.quotationPk));
            }
          },
        ),
      ],
    );
  }

}
