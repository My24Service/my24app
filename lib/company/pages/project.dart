import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:my24app/core/widgets/widgets.dart';
import 'package:my24app/core/i18n_mixin.dart';
import 'package:my24app/core/models/models.dart';
import 'package:my24app/core/utils.dart';
import 'package:my24app/company/blocs/project_bloc.dart';
import 'package:my24app/company/blocs/project_states.dart';
import 'package:my24app/company/widgets/project/form.dart';
import 'package:my24app/company/widgets/project/list.dart';
import 'package:my24app/company/widgets/project/empty.dart';
import 'package:my24app/company/widgets/project/error.dart';

String initialLoadMode;
int loadId;

class ProjectPage extends StatelessWidget with i18nMixin {
  final String basePath = "company.projects";
  final ProjectBloc bloc;
  final Utils utils = Utils();

  Future<DefaultPageData> getPageData() async {
    String memberPicture = await this.utils.getMemberPicture();

    DefaultPageData result = DefaultPageData(
        memberPicture: memberPicture,
    );

    return result;
  }

  ProjectPage({
    Key key,
    @required this.bloc,
    String initialMode,
    int pk
  }) : super(key: key) {
    if (initialMode != null) {
      initialLoadMode = initialMode;
      loadId = pk;
    }
  }

  ProjectBloc _initialBlocCall() {
    if (initialLoadMode == null) {
      bloc.add(ProjectEvent(status: ProjectEventStatus.DO_ASYNC));
      bloc.add(ProjectEvent(
          status: ProjectEventStatus.FETCH_ALL,
      ));
    } else if (initialLoadMode == 'form') {
        bloc.add(ProjectEvent(status: ProjectEventStatus.DO_ASYNC));
        bloc.add(ProjectEvent(
            status: ProjectEventStatus.FETCH_DETAIL,
            pk: loadId
        ));
    } else if (initialLoadMode == 'new') {
      bloc.add(ProjectEvent(
          status: ProjectEventStatus.NEW,
      ));
    }

    return bloc;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DefaultPageData>(
        future: getPageData(),
        builder: (ctx, snapshot) {
          if (snapshot.hasData) {
            DefaultPageData pageData = snapshot.data;

            return BlocProvider<ProjectBloc>(
                create: (context) => _initialBlocCall(),
                child: BlocConsumer<ProjectBloc, ProjectState>(
                    listener: (context, state) {
                      _handleListeners(context, state);
                    },
                    builder: (context, state) {
                      return Scaffold(
                          body: GestureDetector(
                              onTap: () {
                                FocusScope.of(context).requestFocus(FocusNode());
                              },
                              child: _getBody(context, state, pageData),
                          )
                      );
                    }
                )
            );
          } else if (snapshot.hasError) {
            return Center(
                child: Text(
                    $trans("error_arg", pathOverride: "generic",
                        namedArgs: {"error": snapshot.error}))
            );
          } else {
            return loadingNotice();
          }
        }
    );

  }

  void _handleListeners(BuildContext context, state) {
    final bloc = BlocProvider.of<ProjectBloc>(context);

    if (state is ProjectInsertedState) {
      createSnackBar(context, $trans('snackbar_added'));

      bloc.add(ProjectEvent(
          status: ProjectEventStatus.FETCH_ALL,
      ));
    }

    if (state is ProjectUpdatedState) {
      createSnackBar(context, $trans('snackbar_updated'));

      bloc.add(ProjectEvent(
          status: ProjectEventStatus.FETCH_ALL,
      ));
    }

    if (state is ProjectDeletedState) {
      createSnackBar(context, $trans('snackbar_deleted'));

      bloc.add(ProjectEvent(
          status: ProjectEventStatus.FETCH_ALL,
      ));
    }
  }

  Widget _getBody(context, state, DefaultPageData pageData) {
    if (state is ProjectInitialState) {
      return loadingNotice();
    }

    if (state is ProjectLoadingState) {
      return loadingNotice();
    }

    if (state is ProjectErrorState) {
      return ProjectListErrorWidget(
          error: state.message,
          memberPicture: pageData.memberPicture
      );
    }

    if (state is ProjectsLoadedState) {
      if (state.projects.results.length == 0) {
        return ProjectListEmptyWidget(memberPicture: pageData.memberPicture);
      }

      PaginationInfo paginationInfo = PaginationInfo(
          count: state.projects.count,
          next: state.projects.next,
          previous: state.projects.previous,
          currentPage: state.page != null ? state.page : 1,
          pageSize: 20
      );

      return ProjectListWidget(
        projects: state.projects,
        paginationInfo: paginationInfo,
        memberPicture: pageData.memberPicture,
        searchQuery: state.query,
      );
    }

    if (state is ProjectLoadedState) {
      return ProjectFormWidget(
        formData: state.formData,
        memberPicture: pageData.memberPicture
      );
    }

    if (state is ProjectNewState) {
      return ProjectFormWidget(
          formData: state.formData,
          memberPicture: pageData.memberPicture
      );
    }

    return loadingNotice();
  }
}
