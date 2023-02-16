import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

import 'package:my24app/company/models/models.dart';
import 'package:my24app/company/pages/project_form.dart';
import 'package:my24app/core/widgets/widgets.dart';
import '../blocs/project_bloc.dart';

class ProjectListWidget extends StatefulWidget {
  final ProjectsPaginated results;
  final DateTime startDate;

  ProjectListWidget({
    Key key,
    this.results,
    this.startDate,
  }): super(key: key);

  @override
  State<StatefulWidget> createState() => new _ProjectListWidgetState();
}

class _ProjectListWidgetState extends State<ProjectListWidget> {
  bool _inAsyncCall = false;
  BuildContext _context;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return _showMainView(context);
  }

  Widget _showMainView(BuildContext context) {
    return Container(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: SingleChildScrollView(
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  createDefaultElevatedButton(
                      'company.projects.header_add'.tr(),
                      () { _handleNew(context); }
                  ),
                  _buildProjectsSection(context)
                ]
            )
        )
    );
  }

  void _handleNew(BuildContext context) {
    final page = ProjectFormPage();

    Navigator.push(
        context, MaterialPageRoute(builder: (context) => page)
    );
  }

  Widget _buildProjectsSection(BuildContext context) {
    return buildItemsSection(
      context,
      'company.projects.info_header_table'.tr(),
      widget.results.results,
      (Project item) {
        return buildItemListKeyValueList(
            'company.projects.info_name'.tr(),
            "${item.name}"
        );
      },
      (Project item) {
        return [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              createEditButton(
                () { _handleEdit(item, context); }
              ),
              SizedBox(width: 10),
              createDeleteButton(
                "company.projects.button_delete".tr(),
                () { _showDeleteDialog(item); }
              ),
            ],
          )
        ];
      },
    );
  }

  void _handleEdit(Project project, BuildContext context) {
    final page = ProjectFormPage(pk: project.id);

    Navigator.pop(context);
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => page)
    );
  }

  _showDeleteDialog(Project hours) {
    showDeleteDialogWrapper(
        'generic.delete_dialog_title_document'.tr(),
        'company.projects.delete_dialog_content'.tr(),
        () => _doDelete(hours.id),
        _context
    );
  }

  _doDelete(int pk) async {
    final bloc = BlocProvider.of<ProjectBloc>(context);

    bloc.add(ProjectEvent(
        status: ProjectEventStatus.DELETE, pk: pk));
  }

}
