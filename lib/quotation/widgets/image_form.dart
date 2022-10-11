import 'dart:convert';
import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:my24app/quotation/models/models.dart';

import 'package:my24app/core/widgets/widgets.dart';

import '../blocs/image_bloc.dart';
import '../pages/part_form.dart';


class PartImageFormWidget extends StatefulWidget {
  final int quotationPk;
  final int quotatonPartId;
  final QuotationPartImage image;

  PartImageFormWidget({
    Key key,
    this.quotationPk,
    this.quotatonPartId,
    this.image,
  }): super(key: key);

  @override
  State<StatefulWidget> createState() => new _PartImageFormWidgetState();
}

class _PartImageFormWidgetState extends State<PartImageFormWidget> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  var _imageDescriptionController = TextEditingController();
  var _imageController = TextEditingController();

  File _image;
  final picker = ImagePicker();

  String _filePath;

  bool _inAsyncCall = false;

  @override
  void initState() {
    if (widget.image != null) {
      _filePath = widget.image.image;
      _imageDescriptionController.text = widget.image.description;
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
                  createHeader(widget.image != null ? 'quotations.part_images.header_edit'.tr() : 'quotations.part_images.header_add'.tr()),
                  Form(
                      key: _formKey,
                      child: _buildForm(context)
                  ),
                ]
            )
        )
    );
  }

  _openImageCamera() async {
    final pickedFile = await picker.pickImage(source: ImageSource.camera);

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
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

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
        'generic.button_take_picture'.tr(), _openImageCamera);
  }

  Widget _buildChooseImageButton() {
    return createElevatedButtonColored(
        'generic.button_choose_image'.tr(), _openImagePicker);
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
        Text('generic.info_description'.tr()),
        TextFormField(
            controller: _imageDescriptionController,
            validator: (value) {
              return null;
            }),
        SizedBox(
          height: 10.0,
        ),
        Text('quotations.info_image'.tr()),
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
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            createDefaultElevatedButton(
                widget.image == null ? 'quotations.part_images.button_add'.tr() :
                'quotations.part_images.button_edit'.tr(),
                _handleSubmit
            ),
            if (widget.image != null)
              SizedBox(width: 10),
            if (widget.image != null)
              createDeleteButton(
                  'quotations.part_images.button_delete'.tr(),
                  () { _showDeleteDialog(widget.image, context); }
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
      final bloc = BlocProvider.of<PartImageBloc>(context);

      File imageFile = _image;

      if (widget.image == null && imageFile == null) {
        displayDialog(context,
            'generic.dialog_no_image_title'.tr(),
            'generic.dialog_no_image_content'.tr()
        );
        return;
      }

      QuotationPartImage image = QuotationPartImage(
        quotatonPartId: widget.quotatonPartId,
        description: _imageDescriptionController.text,
        image: imageFile != null ? base64Encode(imageFile.readAsBytesSync()) : null,
      );

      if (widget.image == null) {
        bloc.add(PartImageEvent(
            status: PartImageEventStatus.INSERT,
            image: image
        ));
      } else {
        bloc.add(PartImageEvent(
            status: PartImageEventStatus.EDIT,
            image: image,
            pk: widget.image.id
        ));
      }
    }
  }

  _showDeleteDialog(QuotationPartImage image, BuildContext context) {
    assert(context != null);
    showDeleteDialogWrapper(
        'generic.delete_dialog_title_document'.tr(),
        'generic.delete_dialog_content_document'.tr(),
        context, () => _doDelete(image.id)
    );
  }

  _doDelete(int pk) async {
    final bloc = BlocProvider.of<PartImageBloc>(context);

    bloc.add(PartImageEvent(
        status: PartImageEventStatus.DELETE,
        pk: pk
    ));
  }



}
