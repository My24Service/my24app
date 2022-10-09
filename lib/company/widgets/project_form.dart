import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

import 'package:my24app/company/models/models.dart';
import 'package:my24app/core/widgets/widgets.dart';
import '../blocs/project_bloc.dart';
import '../pages/project_list.dart';

class ProjectFormWidget extends StatefulWidget {
  final int pk;
  final Project project;

  ProjectFormWidget({
    Key key,
    this.pk,
    this.project,
  }): super(key: key);

  @override
  State<StatefulWidget> createState() => new _ProjectFormWidgetState();
}

class _ProjectFormWidgetState extends State<ProjectFormWidget> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  var _nameController = TextEditingController();

  bool _inAsyncCall = false;

  @override
  void initState() {
    if (widget.project != null) {
      _nameController.text = widget.project.name;
    }
    super.initState();
  }

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
        alignment: Alignment.center,
        child: SingleChildScrollView(
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  createHeader(widget.project != null ? 'company.projects.header_edit'.tr() : 'company.projects.header_add'.tr()),
                  Form(
                      key: _formKey,
                      child: _buildForm()
                  ),
                ]
            )
        )
    );
  }

  void _cancelEdit() {
    final page = ProjectListPage();

    Navigator.pop(context);
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => page)
    );
  }

  Widget _buildForm() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text('company.projects.info_name'.tr()),
        TextFormField(
            controller: _nameController,
            validator: (value) {
              return null;
            }),
        SizedBox(
          height: 10.0,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            createDefaultElevatedButton(
                widget.project == null ? 'company.projects.button_add'.tr() :
                'company.projects.button_edit'.tr(),
                _handleSubmit
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
      final bloc = BlocProvider.of<ProjectBloc>(context);

      Project project = Project(
        name: _nameController.text,
      );

      if (widget.project == null) {
        bloc.add(ProjectEvent(
            status: ProjectEventStatus.INSERT,
            project: project
        ));
      } else {
        bloc.add(ProjectEvent(
            status: ProjectEventStatus.EDIT,
            project: project,
            pk: widget.project.id
        ));
      }
    }
  }

}
