import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import 'package:my24app/core/widgets/slivers/base_widgets.dart';
import 'package:my24app/core/widgets/widgets.dart';
import 'package:my24app/core/i18n_mixin.dart';
import 'package:my24app/order/blocs/document_bloc.dart';
import 'package:my24app/order/models/document/form_data.dart';
import 'package:my24app/order/models/document/models.dart';

class OrderDocumentFormWidget extends BaseSliverPlainStatelessWidget with i18nMixin {
  final String basePath = "orders.documents";
  final int orderId;
  final OrderDocumentFormData formData;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final picker = ImagePicker();
  final String memberPicture;

  OrderDocumentFormWidget({
    Key key,
    this.orderId,
    this.formData,
    @required this.memberPicture,
  }) : super(
      key: key,
      memberPicture: memberPicture
  );

  @override
  void doRefresh(BuildContext context) {
  }

  @override
  String getAppBarTitle(BuildContext context) {
    return formData.id == null ? $trans('app_bar_title_new') : $trans(
        'app_bar_title_edit');
  }

  @override
  Widget getBottomSection(BuildContext context) {
    return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          createElevatedButtonColored(
              $trans('action_cancel', pathOverride: 'generic'),
              () => { _navList(context)}
          ),
          SizedBox(width: 10),
          createDefaultElevatedButton(
              formData.id == null ? $trans('button_add') : $trans('button_edit'),
              () => { _handleSubmit(context)}
          ),
        ]
    );
  }

  @override
  Widget getContentWidget(BuildContext context) {
    return Container(
        child: Form(
            key: _formKey,
            child: Container(
                alignment: Alignment.center,
                child: SingleChildScrollView( // new line
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Container(
                            alignment: Alignment.center,
                            child: _buildForm(context),
                          ),
                        ]
                    )
                )
            )
        )
    );
  }

  void _navList(BuildContext context) {
    final bloc = BlocProvider.of<OrderDocumentBloc>(context);

    bloc.add(OrderDocumentEvent(status: OrderDocumentEventStatus.DO_ASYNC));
    bloc.add(OrderDocumentEvent(
        status: OrderDocumentEventStatus.FETCH_ALL,
        orderId: orderId
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
        () => _openFilePicker(context) );
  }

  Widget _buildTakePictureButton(BuildContext context) {
    return createElevatedButtonColored(
        $trans('button_take_picture', pathOverride: 'generic'),
        () => _openImageCamera(context) );
  }

  Widget _buildChooseImageButton(BuildContext context) {
    return createElevatedButtonColored(
        $trans('button_choose_image', pathOverride: 'generic'),
        () => _openImagePicker(context) );
  }

  Widget _buildForm(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text($trans('name')),
        TextFormField(
            controller: formData.nameController,
            validator: (value) {
              if (value.isEmpty) {
                return $trans('validator_name_document', pathOverride: 'generic');
              }
              return null;
            }),
        SizedBox(
          height: 10.0,
        ),
        Text($trans('info_description', pathOverride: 'generic')),
        TextFormField(
            controller: formData.descriptionController,
            keyboardType: TextInputType.multiline,
            maxLines: null,
            validator: (value) {
              return null;
            }),
        SizedBox(
          height: 10.0,
        ),
        Text($trans('info_photo')),
        TextFormField(
            readOnly: true,
            controller: formData.documentController,
            validator: (value) {
              return null;
            }),
        SizedBox(
          height: 10.0,
        ),
        Column(children: [
          _buildOpenFileButton(context),
          SizedBox(
            height: 20.0,
          ),
          _buildChooseImageButton(context),
          Text($trans('info_or', pathOverride: 'generic'), style: TextStyle(
              fontWeight: FontWeight.bold,
              fontStyle: FontStyle.italic
          )),
          _buildTakePictureButton(context),
        ]),
        Divider(),
        SizedBox(
          height: 10.0,
        ),
        createDefaultElevatedButton(
           $trans('form_button_submit_document', pathOverride: 'generic'),
            () => _handleSubmit(context)
        )
      ],
    );
  }

  Future<void> _handleSubmit(BuildContext context) async {
    if (this._formKey.currentState.validate()) {
      this._formKey.currentState.save();

      if (!formData.isValid()) {
        if (formData.documentFile == null) {
          displayDialog(context,
              $trans('dialog_no_document_title', pathOverride: 'generic'),
              $trans('dialog_no_document_content', pathOverride: 'generic')
          );
          return;
        }
      }

      final bloc = BlocProvider.of<OrderDocumentBloc>(context);
      if (formData.id != null) {
        OrderDocument updatedDocument = formData.toModel();
        bloc.add(OrderDocumentEvent(status: OrderDocumentEventStatus.DO_ASYNC));
        bloc.add(OrderDocumentEvent(
            pk: updatedDocument.id,
            status: OrderDocumentEventStatus.UPDATE,
            document: updatedDocument,
            orderId: updatedDocument.orderId
        ));
      } else {
        OrderDocument newDocument = formData.toModel();
        bloc.add(OrderDocumentEvent(status: OrderDocumentEventStatus.DO_ASYNC));
        bloc.add(OrderDocumentEvent(
            status: OrderDocumentEventStatus.INSERT,
            document: newDocument,
            orderId: newDocument.orderId
        ));
      }
    }
  }

  _updateFormData(BuildContext context) {
    final bloc = BlocProvider.of<OrderDocumentBloc>(context);
    bloc.add(OrderDocumentEvent(status: OrderDocumentEventStatus.DO_ASYNC));
    bloc.add(OrderDocumentEvent(
        status: OrderDocumentEventStatus.UPDATE_FORM_DATA,
        documentFormData: formData
    ));
  }
}
