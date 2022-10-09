import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:my24app/core/utils.dart';
import 'package:my24app/company/blocs/project_bloc.dart';
import 'package:my24app/company/blocs/project_states.dart';
import 'package:my24app/core/widgets/widgets.dart';
import 'package:my24app/core/widgets/drawers.dart';
import '../widgets/project_list.dart';

class ProjectListPage extends StatefulWidget {
  ProjectListPage({
    Key key,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => new _ProjectListPageState();
}

class _ProjectListPageState extends State<ProjectListPage> {
  bool firstTime = true;

  ProjectBloc _initialBlocCall() {
    ProjectBloc bloc = ProjectBloc();

    bloc.add(ProjectEvent(status: ProjectEventStatus.DO_ASYNC));
    bloc.add(ProjectEvent(
        status: ProjectEventStatus.FETCH_ALL,
    ));

    return bloc;
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
        create: (context) => _initialBlocCall(),
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
                                'company.projects.app_bar_title_list'.tr())
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
    final ProjectBloc bloc = BlocProvider.of<ProjectBloc>(context);

    if (state is ProjectDeletedState) {
      if (state.result) {
        createSnackBar(context, 'company.projects.snackbar_deleted'.tr());

        bloc.add(ProjectEvent(status: ProjectEventStatus.DO_ASYNC));
        bloc.add(ProjectEvent(
            status: ProjectEventStatus.FETCH_ALL));
      } else {
        displayDialog(context,
            'generic.error_dialog_title'.tr(),
            'company.projects.error_deleting_dialog_content'.tr()
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
              status: ProjectEventStatus.FETCH_ALL,
          )
      );
    }

    if (state is ProjectsLoadedState) {
      return ProjectListWidget(
        results: state.result,
      );
    }

    return loadingNotice();
  }
}
