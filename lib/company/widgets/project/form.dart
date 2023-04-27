import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:my24app/core/widgets/slivers/base_widgets.dart';
import 'package:my24app/core/widgets/widgets.dart';
import 'package:my24app/company/models/project/form_data.dart';
import 'package:my24app/company/blocs/project_bloc.dart';
import 'package:my24app/company/models/project/models.dart';
import 'package:my24app/core/i18n_mixin.dart';

class ProjectFormWidget extends BaseSliverPlainStatelessWidget with i18nMixin {
  final String basePath = "company.projects";
  final ProjectFormData formData;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final String memberPicture;

  ProjectFormWidget({
    Key key,
    @required this.memberPicture,
    @required this.formData
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
    return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          createElevatedButtonColored(
              $trans('action_cancel', pathOverride: 'generic'),
              () => { _navList(context) }
          ),
          SizedBox(width: 10),
          createDefaultElevatedButton(
              formData.id == null ? $trans('button_add') : $trans('button_edit'),
              () => { _submitForm(context) }
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
            child: SingleChildScrollView(    // new line
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

  // private methods
  Widget _buildForm(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text($trans('info_name')),
        TextFormField(
            controller: formData.nameController,
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
    if (this._formKey.currentState.validate()) {
      this._formKey.currentState.save();

      if (!formData.isValid()) {
        FocusScope.of(context).unfocus();
        return;
      }

      final bloc = BlocProvider.of<ProjectBloc>(context);
      if (formData.id != null) {
        Project updatedProject = formData.toModel();
        bloc.add(ProjectEvent(status: ProjectEventStatus.DO_ASYNC));
        bloc.add(ProjectEvent(
            pk: updatedProject.id,
            status: ProjectEventStatus.UPDATE,
            project: updatedProject,
        ));
      } else {
        Project newProject = formData.toModel();
        bloc.add(ProjectEvent(status: ProjectEventStatus.DO_ASYNC));
        bloc.add(ProjectEvent(
            status: ProjectEventStatus.INSERT,
            project: newProject,
        ));
      }
    }
  }
}