import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:my24app/company/pages/project_list.dart';
import 'package:my24app/core/utils.dart';
import 'package:my24app/company/blocs/project_bloc.dart';
import 'package:my24app/company/blocs/project_states.dart';
import 'package:my24app/company/widgets/project_form.dart';
import 'package:my24app/core/widgets/widgets.dart';
import 'package:my24app/core/widgets/drawers.dart';

class ProjectFormPage extends StatefulWidget {
  final int pk;

  ProjectFormPage({
    Key key,
    this.pk,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => new _ProjectFormPageState();
}

class _ProjectFormPageState extends State<ProjectFormPage> {
  bool firstTime = true;
  bool isEdit = false;

  ProjectBloc _initialBlocCall(int pk) {
    ProjectBloc bloc = ProjectBloc();

    if (pk != null) {
      bloc.add(ProjectEvent(status: ProjectEventStatus.DO_ASYNC));
      bloc.add(ProjectEvent(
          status: ProjectEventStatus.FETCH_DETAIL, pk: pk));
    } else {
      bloc.add(ProjectEvent(status: ProjectEventStatus.NEW));
    }

    return bloc;
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
        create: (context) => _initialBlocCall(widget.pk),
        child: FutureBuilder<Widget>(
            future: getDrawerForUser(context),
            builder: (ctx, snapshot) {
              final Widget drawer = snapshot.data;

              return FutureBuilder<String>(
                  future: utils.getUserSubmodel(),
                  builder: (ctx, snapshot) {
                    if (!snapshot.hasData) {
                      return Scaffold(
                          appBar: AppBar(title: Text('')),
                          body: Container()
                      );
                    }

                    return BlocConsumer<ProjectBloc, ProjectState>(
                        listener: (context, state) {
                          _listeners(context, state);
                        },
                        builder: (context, state) {
                          return Scaffold(
                            appBar: AppBar(title: Text(
                                'company.projects.app_bar_title_form'.tr())
                            ),
                            drawer: drawer,
                            body: GestureDetector(
                                onTap: () {
                                  FocusScope.of(context).requestFocus(
                                      new FocusNode());
                                },
                                child: _getBody(context, state)
                            )
                        );
                      }
                    );
                  }
              );
            }
        )
    );
  }

  _listeners(BuildContext context, state) {
    if (state is ProjectInsertedState) {
      if (state.project != null) {
        createSnackBar(context, 'company.projects.snackbar_created'.tr());

        final page = ProjectListPage();

        Navigator.pop(context);
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => page)
        );
      } else {
        displayDialog(context,
            'generic.error_dialog_title'.tr(),
            'company.projects.error_inserting_dialog_content'.tr()
        );
      }
    }

    if (state is ProjectEditedState) {
      if (state.result) {
        createSnackBar(context, 'company.projects.snackbar_updated'.tr());

        final page = ProjectListPage();

        Navigator.pop(context);
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => page)
        );
      } else {
        displayDialog(context,
            'generic.error_dialog_title'.tr(),
            'company.projects.error_updating_dialog_content'.tr()
        );
      }
    }

  }

  Widget _getBody(BuildContext context, state) {
    final ProjectBloc bloc = BlocProvider.of<ProjectBloc>(context);

    if (state is ProjectErrorState) {
      return errorNoticeWithReload(
          state.message,
          bloc,
          ProjectEvent(
              status: ProjectEventStatus.FETCH_DETAIL,
              pk: widget.pk
          )
      );
    }

    if (state is ProjectNewState) {
      return ProjectFormWidget(
        pk: widget.pk,
      );
    }

    if (state is ProjectLoadedState) {
      return ProjectFormWidget(
        pk: widget.pk,
      );
    }

    return loadingNotice();
  }
}
