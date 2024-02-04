import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:my24_flutter_core/widgets/widgets.dart';
import 'package:my24app/core/i18n_mixin.dart';
import 'package:my24_flutter_core/models/models.dart';
import 'package:my24app/core/utils.dart';
import 'package:my24app/company/blocs/project_bloc.dart';
import 'package:my24app/company/blocs/project_states.dart';
import 'package:my24app/company/widgets/project/form.dart';
import 'package:my24app/company/widgets/project/list.dart';
import 'package:my24app/company/widgets/project/error.dart';
import 'package:my24app/core/widgets/drawers.dart';

String? initialLoadMode;
int? loadId;

class ProjectPage extends StatelessWidget with i18nMixin {
  final String basePath = "company.projects";
  final ProjectBloc bloc;
  final Utils utils = Utils();
  final CoreWidgets widgets = CoreWidgets($trans: getTranslationTr);

  Future<DefaultPageData> getPageData(BuildContext context) async {
    String? submodel = await this.utils.getUserSubmodel();
    String? memberPicture = await this.utils.getMemberPicture();

    DefaultPageData result = DefaultPageData(
        drawer: await getDrawerForUserWithSubmodel(context, submodel),
        memberPicture: memberPicture,
    );

    return result;
  }

  ProjectPage({
    Key? key,
    required this.bloc,
    String? initialMode,
    int? pk
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
        future: getPageData(context),
        builder: (ctx, snapshot) {
          if (snapshot.hasData) {
            DefaultPageData? pageData = snapshot.data;

            return BlocProvider<ProjectBloc>(
                create: (context) => _initialBlocCall(),
                child: BlocConsumer<ProjectBloc, ProjectState>(
                    listener: (context, state) {
                      _handleListeners(context, state);
                    },
                    builder: (context, state) {
                      return Scaffold(
                          drawer: pageData!.drawer,
                          body: _getBody(context, state, pageData),
                      );
                    }
                )
            );
          } else if (snapshot.hasError) {
            return Center(
                child: Text(
                    $trans("error_arg", pathOverride: "generic",
                        namedArgs: {"error": "${snapshot.error}"}
                    )
                )
            );
          } else {
            return Scaffold(
                body: widgets.loadingNotice()
            );
          }
        }
    );

  }

  void _handleListeners(BuildContext context, state) {
    final bloc = BlocProvider.of<ProjectBloc>(context);

    if (state is ProjectInsertedState) {
      widgets.createSnackBar(context, $trans('snackbar_added'));

      bloc.add(ProjectEvent(
        status: ProjectEventStatus.FETCH_ALL,
      ));
    }

    if (state is ProjectUpdatedState) {
      widgets.createSnackBar(context, $trans('snackbar_updated'));

      bloc.add(ProjectEvent(
        status: ProjectEventStatus.FETCH_ALL,
      ));
    }

    if (state is ProjectDeletedState) {
      widgets.createSnackBar(context, $trans('snackbar_deleted'));

      bloc.add(ProjectEvent(
        status: ProjectEventStatus.FETCH_ALL,
      ));
    }

    if (state is ProjectsLoadedState && state.projects!.results!.length == 0) {
      bloc.add(ProjectEvent(
        status: ProjectEventStatus.NEW_EMPTY,
      ));
    }
  }

  Widget _getBody(context, state, DefaultPageData? pageData) {
    if (state is ProjectInitialState) {
      return widgets.loadingNotice();
    }

    if (state is ProjectLoadingState) {
      return widgets.loadingNotice();
    }

    if (state is ProjectErrorState) {
      return ProjectListErrorWidget(
          error: state.message,
          memberPicture: pageData!.memberPicture,
          widgetsIn: widgets
      );
    }

    if (state is ProjectsLoadedState) {
      PaginationInfo paginationInfo = PaginationInfo(
          count: state.projects!.count,
          next: state.projects!.next,
          previous: state.projects!.previous,
          currentPage: state.page != null ? state.page : 1,
          pageSize: 20
      );

      return ProjectListWidget(
        projects: state.projects,
        paginationInfo: paginationInfo,
        memberPicture: pageData!.memberPicture,
        searchQuery: state.query,
        widgetsIn: widgets
      );
    }

    if (state is ProjectLoadedState) {
      return ProjectFormWidget(
        formData: state.formData,
        memberPicture: pageData!.memberPicture,
        newFromEmpty: false,
        widgetsIn: widgets
      );
    }

    if (state is ProjectNewState) {
      return ProjectFormWidget(
          formData: state.formData,
          memberPicture: pageData!.memberPicture,
          newFromEmpty: state.fromEmpty,
          widgetsIn: widgets
      );
    }

    return widgets.loadingNotice();
  }
}
