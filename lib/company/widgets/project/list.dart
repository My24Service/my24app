import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:my24_flutter_core/widgets/widgets.dart';
import 'package:my24_flutter_core/i18n.dart';
import 'package:my24_flutter_core/models/models.dart';
import 'package:my24_flutter_core/widgets/slivers/base_widgets.dart';

import 'package:my24app/company/blocs/project_bloc.dart';
import 'package:my24app/company/models/project/models.dart';

import 'mixins.dart';


class ProjectListWidget extends BaseSliverListStatelessWidget with ProjectMixin{
  final Projects? projects;
  final PaginationInfo paginationInfo;
  final String? memberPicture;
  final String? searchQuery;
  final CoreWidgets widgetsIn;
  final My24i18n i18nIn;
  
  ProjectListWidget({
    Key? key,
    required this.projects,
    required this.paginationInfo,
    required this.memberPicture,
    required this.searchQuery,
    required this.widgetsIn,
    required this.i18nIn,
  }) : super(
      key: key,
      paginationInfo: paginationInfo,
      memberPicture: memberPicture,
      widgets: widgetsIn,
      i18n: i18nIn
  ) {
    searchController.text = searchQuery?? '';
  }

  @override
  String getAppBarSubtitle(BuildContext context) {
    return i18nIn.$trans('app_bar_subtitle',
      namedArgs: {'count': "${projects!.count}"}
    );
  }

  @override
  SliverList getSliverList(BuildContext context) {
    return SliverList(
        delegate: SliverChildBuilderDelegate(
            (BuildContext context, int index) {
              Project project = projects!.results![index];

              return Column(
                children: [
                  SizedBox(height: 10),
                  ...widgetsIn.buildItemListKeyValueList(
                      i18nIn.$trans('info_name'),
                      "${project.name}"
                  ),
                  SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      widgetsIn.createDeleteButton(
                        () { _showDeleteDialog(context, project); }
                      ),
                      SizedBox(width: 8),
                      widgetsIn.createEditButton(
                        () { _doEdit(context, project); }
                      )
                    ],
                  ),
                  if (index < projects!.results!.length-1)
                    widgetsIn.getMy24Divider(context)
                ],
              );
            },
            childCount: projects!.results!.length,
        )
    );
  }

  // private methods
  _doDelete(BuildContext context, Project project) {
    final bloc = BlocProvider.of<ProjectBloc>(context);

    bloc.add(ProjectEvent(status: ProjectEventStatus.DO_ASYNC));
    bloc.add(ProjectEvent(
        status: ProjectEventStatus.DELETE,
        pk: project.id,
    ));
  }

  _doEdit(BuildContext context, Project project) {
    final bloc = BlocProvider.of<ProjectBloc>(context);

    bloc.add(ProjectEvent(status: ProjectEventStatus.DO_ASYNC));
    bloc.add(ProjectEvent(
        status: ProjectEventStatus.FETCH_DETAIL,
        pk: project.id
    ));
  }

  _showDeleteDialog(BuildContext context, Project project) {
    widgetsIn.showDeleteDialogWrapper(
        i18nIn.$trans('delete_dialog_title'),
        i18nIn.$trans('delete_dialog_content'),
      () => _doDelete(context, project),
      context
    );
  }
}
