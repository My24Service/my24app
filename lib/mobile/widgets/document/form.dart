import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import 'package:my24_flutter_core/widgets/slivers/base_widgets.dart';
import 'package:my24_flutter_core/widgets/widgets.dart';
import 'package:my24_flutter_core/i18n.dart';

import 'package:my24app/mobile/models/document/form_data.dart';
import 'package:my24app/mobile/blocs/document_bloc.dart';
import 'package:my24app/mobile/models/document/models.dart';
import 'package:my24app/mobile/pages/document.dart';

class DocumentFormWidget extends BaseSliverPlainStatelessWidget{
  final int? assignedOrderId;
  final AssignedOrderDocumentFormData? formData;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final picker = ImagePicker();
  final String? memberPicture;
  final bool? newFromEmpty;
  final CoreWidgets widgetsIn;
  final My24i18n i18nIn;

  DocumentFormWidget({
    Key? key,
    required this.assignedOrderId,
    required this.formData,
    required this.memberPicture,
    required this.newFromEmpty,
    required this.widgetsIn,
    required this.i18nIn,
  }) : super(
      key: key,
      mainMemberPicture: memberPicture,
      widgets: widgetsIn,
      i18n: i18nIn
  );

  @override
  String getAppBarTitle(BuildContext context) {
    return formData!.id == null ?i18nIn.$trans('app_bar_title_new') :i18nIn.$trans('app_bar_title_edit');
  }

  @override
  Widget getBottomSection(BuildContext context) {
    return SizedBox(height: 1);
  }

  @override
  Widget getContentWidget(BuildContext context) {
    return Container(
        decoration: BoxDecoration(
            color: Colors.grey.shade300,
            border: Border.all(
              color: Colors.grey.shade300,
            ),
            borderRadius: const BorderRadius.all(
              Radius.circular(5),
            )
        ),
        padding: const EdgeInsets.all(14),
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
                  widgetsIn.createSubmitSection(_getButtons(context) as Row)
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
          widgetsIn.createCancelButton(() => _navList(context)),
          SizedBox(width: 10),
          widgetsIn.createSubmitButton(context, () => _submitForm(context)),
        ]
    );
  }

  Widget _buildForm(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        widgetsIn.wrapGestureDetector(context, widgetsIn.createHeader(i18n.$trans('header_new_document', pathOverride: 'generic'))),
        widgetsIn.wrapGestureDetector(context, SizedBox(
          height: 10.0,
        )),
        widgetsIn.wrapGestureDetector(context, Text(i18n.$trans('info_name', pathOverride: 'generic'))),
        TextFormField(
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
            ),
            controller: formData!.nameController,
            validator: (value) {
              if (value!.isEmpty) {
                return i18nIn.$trans('validator_name_document', pathOverride: 'generic');
              }
              return null;
            }),
        widgetsIn.wrapGestureDetector(context, SizedBox(
          height: 10.0,
        )),
        widgetsIn.wrapGestureDetector(context, Text(i18n.$trans('info_description', pathOverride: 'generic'))),
        TextFormField(
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
            ),
            controller: formData!.descriptionController,
            validator: (value) {
              return null;
            }),
        widgetsIn.wrapGestureDetector(context, SizedBox(
          height: 10.0,
        )),
        widgetsIn.wrapGestureDetector(context, Text(i18n.$trans('info_document', pathOverride: 'generic'))),
        TextFormField(
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.grey[100],
            ),
            readOnly: true,
            controller: formData!.documentController,
            validator: (value) {
              return null;
            }),
        widgetsIn.wrapGestureDetector(context, SizedBox(
          height: 10.0,
        )),
        Column(children: [
          _buildOpenFileButton(context),
          widgetsIn.wrapGestureDetector(context, SizedBox(
            height: 20.0,
          )),
          _buildChooseImageButton(context),
          widgetsIn.wrapGestureDetector(context, Text(i18n.$trans('info_or', pathOverride: 'generic'), style: TextStyle(
              fontWeight: FontWeight.bold,
              fontStyle: FontStyle.italic
          ))),
          _buildTakePictureButton(context),
        ]),
        widgetsIn.wrapGestureDetector(context, SizedBox(
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
    if (this._formKey.currentState!.validate()) {
      this._formKey.currentState!.save();

      if (!formData!.isValid()) {
        if (formData!.id == null && formData!.documentFile == null) {
          return await widgetsIn.displayDialog(
              context,
             i18nIn.$trans('dialog_no_document_title', pathOverride: 'generic'),
             i18nIn.$trans('dialog_no_document_content', pathOverride: 'generic')
          );
        }

        FocusScope.of(context).unfocus();
        return;
      }

      final bloc = BlocProvider.of<DocumentBloc>(context);
      if (formData!.id != null) {
        AssignedOrderDocument updatedDocument = formData!.toModel();
        bloc.add(DocumentEvent(status: DocumentEventStatus.DO_ASYNC));
        bloc.add(DocumentEvent(
            pk: updatedDocument.id,
            status: DocumentEventStatus.UPDATE,
            document: updatedDocument,
            assignedOrderId: updatedDocument.assignedOrderId
        ));
      } else {
        AssignedOrderDocument newDocument = formData!.toModel();
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
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if(result != null) {
      PlatformFile file = result.files.first;

      formData!.documentFile = await formData!.getLocalFile(file.path!);
      formData!.documentController!.text = file.name;
      formData!.nameController!.text = file.name;

      _updateFormData(context);
    }
  }

  _openImageCamera(BuildContext context) async {
    final pickedFile = await picker.pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      String filename = pickedFile.path.split("/").last;

      formData!.documentFile = await formData!.getLocalFile(pickedFile.path);
      formData!.documentController!.text = filename;
      _updateFormData(context);
    } else {
      print('No image selected.');
    }
  }

  _openImagePicker(BuildContext context) async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      String filename = pickedFile.path.split("/").last;

      formData!.documentFile = await formData!.getLocalFile(pickedFile.path);
      formData!.documentController!.text = filename;
      _updateFormData(context);
    } else {
      print('No image selected.');
    }
  }

  Widget _buildOpenFileButton(BuildContext context) {
    return widgetsIn.createElevatedButtonColored(
       i18nIn.$trans('button_choose_file', pathOverride: 'generic'),
        () => _openFilePicker(context)
    );
  }

  Widget _buildTakePictureButton(BuildContext context) {
    return widgetsIn.createElevatedButtonColored(
       i18nIn.$trans('button_take_picture', pathOverride: 'generic'),
        () => _openImageCamera(context)
    );
  }

  Widget _buildChooseImageButton(BuildContext context) {
    return widgetsIn.createElevatedButtonColored(
       i18nIn.$trans('button_choose_image', pathOverride: 'generic'),
        () => _openImagePicker(context)
    );
  }
}
