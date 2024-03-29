import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:my24_flutter_core/widgets/slivers/base_widgets.dart';
import 'package:my24_flutter_core/widgets/widgets.dart';
import 'package:my24_flutter_core/i18n.dart';

import 'package:my24app/company/models/project/form_data.dart';
import 'package:my24app/company/blocs/project_bloc.dart';
import 'package:my24app/company/models/project/models.dart';

class ProjectFormWidget extends BaseSliverPlainStatelessWidget {
  final ProjectFormData? formData;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final String? memberPicture;
  final bool? newFromEmpty;
  final CoreWidgets widgetsIn;
  final My24i18n i18nIn;
  
  ProjectFormWidget({
    Key? key,
    required this.memberPicture,
    required this.formData,
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
    return formData!.id == null ? i18nIn.$trans('app_bar_title_new') : i18nIn.$trans('app_bar_title_edit');
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
        widgetsIn.wrapGestureDetector(context, Text(i18nIn.$trans('info_name'))),
        TextFormField(
            controller: formData!.nameController,
            validator: (value) {
              return null;
            }
        ),
      ],
    );
  }

  void _navList(BuildContext context) {
    final bloc = BlocProvider.of<ProjectBloc>(context);
    bloc.add(ProjectEvent(status: ProjectEventStatus.DO_ASYNC));
    bloc.add(ProjectEvent(
        status: ProjectEventStatus.FETCH_ALL
    ));
  }

  Future<void> _submitForm(BuildContext context) async {
    if (this._formKey.currentState!.validate()) {
      this._formKey.currentState!.save();

      if (!formData!.isValid()) {
        FocusScope.of(context).unfocus();
        return;
      }

      final bloc = BlocProvider.of<ProjectBloc>(context);
      if (formData!.id != null) {
        Project updatedProject = formData!.toModel();
        bloc.add(ProjectEvent(status: ProjectEventStatus.DO_ASYNC));
        bloc.add(ProjectEvent(
            pk: updatedProject.id,
            status: ProjectEventStatus.UPDATE,
            project: updatedProject,
        ));
      } else {
        Project newProject = formData!.toModel();
        bloc.add(ProjectEvent(status: ProjectEventStatus.DO_ASYNC));
        bloc.add(ProjectEvent(
            status: ProjectEventStatus.INSERT,
            project: newProject,
        ));
      }
    }
  }
}
