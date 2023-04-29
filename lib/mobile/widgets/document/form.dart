import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import 'package:my24app/core/widgets/slivers/base_widgets.dart';
import 'package:my24app/core/widgets/widgets.dart';
import 'package:my24app/mobile/models/document/form_data.dart';
import 'package:my24app/mobile/blocs/document_bloc.dart';
import 'package:my24app/mobile/models/document/models.dart';
import 'package:my24app/mobile/pages/document.dart';
import 'package:my24app/core/i18n_mixin.dart';


class DocumentFormWidget extends BaseSliverPlainStatelessWidget with i18nMixin {
  final String basePath = "assigned_orders.documents";
  final int assignedOrderId;
  final AssignedOrderDocumentFormData formData;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final picker = ImagePicker();
  final String memberPicture;
  final bool newFromEmpty;

  DocumentFormWidget({
    Key key,
    @required this.assignedOrderId,
    @required this.formData,
    @required this.memberPicture,
    @required this.newFromEmpty,
  }) : super(
      key: key,
      memberPicture: memberPicture
  );

  @override
  void doRefresh(BuildContext context) {
  }

  @override
  String getAppBarTitle(BuildContext context) {
    return formData.id == null ? $trans('app_bar_title_new') : $trans('app_bar_title_edit');
  }

  @override
  Widget getBottomSection(BuildContext context) {
    return SizedBox(height: 1);
  }

  @override
  Widget getContentWidget(BuildContext context) {
    return Container(
        child: Form(
          key: _formKey,
          child: Container(
            alignment: Alignment.center,
            child: SingleChildScrollView(    // new line
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Container(
                    alignment: Alignment.center,
                    child: _buildForm(context),
                  ),
                  createSubmitSection(_getButtons(context))
                ]
              )
            )
          )
        )
    );
  }

  // private methods
  Widget _getButtons(BuildContext context) {
    return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          createCancelButton(() => _navList(context)),
          SizedBox(width: 10),
          createDefaultElevatedButton(
              formData.id == null ? $trans('button_add') : $trans('button_edit'),
                  () => { _submitForm(context) }
          ),
        ]
    );
  }

  Widget _buildForm(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        wrapGestureDetector(context, createHeader($trans('header_new_document', pathOverride: 'generic'))),
        wrapGestureDetector(context, SizedBox(
          height: 10.0,
        )),
        wrapGestureDetector(context, Text($trans('info_name', pathOverride: 'generic'))),
        TextFormField(
            controller: formData.nameController,
            validator: (value) {
              if (value.isEmpty) {
                return $trans('validator_name_document', pathOverride: 'generic');
              }
              return null;
            }),
        wrapGestureDetector(context, SizedBox(
          height: 10.0,
        )),
        wrapGestureDetector(context, Text($trans('info_description', pathOverride: 'generic'))),
        TextFormField(
            controller: formData.descriptionController,
            validator: (value) {
              return null;
            }),
        wrapGestureDetector(context, SizedBox(
          height: 10.0,
        )),
        wrapGestureDetector(context, Text($trans('info_document', pathOverride: 'generic'))),
        TextFormField(
            readOnly: true,
            controller: formData.documentController,
            validator: (value) {
              return null;
            }),
        wrapGestureDetector(context, SizedBox(
          height: 10.0,
        )),
        Column(children: [
          _buildOpenFileButton(context),
          wrapGestureDetector(context, SizedBox(
            height: 20.0,
          )),
          _buildChooseImageButton(context),
          wrapGestureDetector(context, Text($trans('info_or', pathOverride: 'generic'), style: TextStyle(
              fontWeight: FontWeight.bold,
              fontStyle: FontStyle.italic
          ))),
          _buildTakePictureButton(context),
        ]),
        wrapGestureDetector(context, SizedBox(
          height: 10.0,
        )),
      ],
    );
  }

  void _navList(BuildContext context) {
    final page = DocumentPage(assignedOrderId: assignedOrderId, bloc: DocumentBloc());
    Navigator.pushReplacement(context,
        MaterialPageRoute(
            builder: (context) => page
        )
    );
  }

  Future<void> _submitForm(BuildContext context) async {
    if (this._formKey.currentState.validate()) {
      this._formKey.currentState.save();

      if (!formData.isValid()) {
        if (formData.id == null && formData.documentFile == null) {
          return await displayDialog(
              context,
              $trans('dialog_no_document_title', pathOverride: 'generic'),
              $trans('dialog_no_document_content', pathOverride: 'generic')
          );
        }

        FocusScope.of(context).unfocus();
        return;
      }

      final bloc = BlocProvider.of<DocumentBloc>(context);
      if (formData.id != null) {
        AssignedOrderDocument updatedDocument = formData.toModel();
        bloc.add(DocumentEvent(status: DocumentEventStatus.DO_ASYNC));
        bloc.add(DocumentEvent(
            pk: updatedDocument.id,
            status: DocumentEventStatus.UPDATE,
            document: updatedDocument,
            assignedOrderId: updatedDocument.assignedOrderId
        ));
      } else {
        AssignedOrderDocument newDocument = formData.toModel();
        bloc.add(DocumentEvent(status: DocumentEventStatus.DO_ASYNC));
        bloc.add(DocumentEvent(
            status: DocumentEventStatus.INSERT,
            document: newDocument,
            assignedOrderId: newDocument.assignedOrderId
        ));
      }
    }
  }

  _updateFormData(BuildContext context) {
    final bloc = BlocProvider.of<DocumentBloc>(context);
    bloc.add(DocumentEvent(status: DocumentEventStatus.DO_ASYNC));
    bloc.add(DocumentEvent(
        status: DocumentEventStatus.UPDATE_FORM_DATA,
        documentFormData: formData
    ));
  }

  _openFilePicker(BuildContext context) async {
    FilePickerResult result = await FilePicker.platform.pickFiles();

    if(result != null) {
      PlatformFile file = result.files.first;

      formData.documentFile = await formData.getLocalFile(file.path);
      formData.documentController.text = file.name;
      formData.nameController.text = file.name;

      _updateFormData(context);
    }
  }

  _openImageCamera(BuildContext context) async {
    final pickedFile = await picker.pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      String filename = pickedFile.path.split("/").last;

      formData.documentFile = await formData.getLocalFile(pickedFile.path);
      formData.documentController.text = filename;
      _updateFormData(context);
    } else {
      print('No image selected.');
    }
  }

  _openImagePicker(BuildContext context) async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      String filename = pickedFile.path.split("/").last;

      formData.documentFile = await formData.getLocalFile(pickedFile.path);
      formData.documentController.text = filename;
      _updateFormData(context);
    } else {
      print('No image selected.');
    }
  }

  Widget _buildOpenFileButton(BuildContext context) {
    return createElevatedButtonColored(
        $trans('button_choose_file', pathOverride: 'generic'),
        () => _openFilePicker(context)
    );
  }

  Widget _buildTakePictureButton(BuildContext context) {
    return createElevatedButtonColored(
        $trans('button_take_picture', pathOverride: 'generic'),
        () => _openImageCamera(context)
    );
  }

  Widget _buildChooseImageButton(BuildContext context) {
    return createElevatedButtonColored(
        $trans('button_choose_image', pathOverride: 'generic'),
        () => _openImagePicker(context)
    );
  }
}
