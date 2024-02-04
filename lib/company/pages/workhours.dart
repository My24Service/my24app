import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:my24_flutter_core/widgets/widgets.dart';
import 'package:my24_flutter_core/models/models.dart';

import 'package:my24app/core/i18n_mixin.dart';
import 'package:my24app/core/utils.dart';
import 'package:my24app/company/blocs/workhours_bloc.dart';
import 'package:my24app/company/blocs/workhours_states.dart';
import 'package:my24app/company/widgets/workhours/form.dart';
import 'package:my24app/company/widgets/workhours/list.dart';
import 'package:my24app/company/widgets/workhours/empty.dart';
import 'package:my24app/company/widgets/workhours/error.dart';
import 'package:my24app/company/models/workhours/models.dart';
import 'package:my24app/core/widgets/drawers.dart';

String? initialLoadMode;
int? loadId;

class UserWorkHoursPage extends StatelessWidget with i18nMixin {
  final String basePath = "company.workhours";
  final UserWorkHoursBloc bloc;
  final Utils utils = Utils();
  final CoreWidgets widgets = CoreWidgets($trans: getTranslationTr);

  Future<UserWorkHoursPageData> getPageData(BuildContext context) async {
    String? memberPicture = await this.utils.getMemberPicture();
    String? submodel = await this.utils.getUserSubmodel();

    UserWorkHoursPageData result = UserWorkHoursPageData(
        drawer: await getDrawerForUserWithSubmodel(context, submodel),
        memberPicture: memberPicture,
        isPlanning: submodel == 'planning_user'
    );

    return result;
  }

  UserWorkHoursPage({
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

  UserWorkHoursBloc _initialBlocCall() {
    if (initialLoadMode == null) {
      bloc.add(UserWorkHoursEvent(status: UserWorkHoursEventStatus.DO_ASYNC));
      bloc.add(UserWorkHoursEvent(
          status: UserWorkHoursEventStatus.FETCH_ALL,
      ));
    } else if (initialLoadMode == 'form') {
        bloc.add(UserWorkHoursEvent(status: UserWorkHoursEventStatus.DO_ASYNC));
        bloc.add(UserWorkHoursEvent(
            status: UserWorkHoursEventStatus.FETCH_DETAIL,
            pk: loadId
        ));
    } else if (initialLoadMode == 'new') {
      bloc.add(UserWorkHoursEvent(
          status: UserWorkHoursEventStatus.NEW,
      ));
    }

    return bloc;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<UserWorkHoursPageData>(
        future: getPageData(context),
        builder: (ctx, snapshot) {
          if (snapshot.hasData) {
            UserWorkHoursPageData? pageData = snapshot.data;

            return BlocProvider<UserWorkHoursBloc>(
                create: (context) => _initialBlocCall(),
                child: BlocConsumer<UserWorkHoursBloc, UserWorkHoursState>(
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
    final bloc = BlocProvider.of<UserWorkHoursBloc>(context);

    if (state is UserWorkHoursInsertedState) {
      widgets.createSnackBar(context, $trans('snackbar_added'));

      bloc.add(UserWorkHoursEvent(
          status: UserWorkHoursEventStatus.FETCH_ALL,
      ));
    }

    if (state is UserWorkHoursUpdatedState) {
      widgets.createSnackBar(context, $trans('snackbar_updated'));

      bloc.add(UserWorkHoursEvent(
          status: UserWorkHoursEventStatus.FETCH_ALL,
      ));
    }

    if (state is UserWorkHoursDeletedState) {
      widgets.createSnackBar(context, $trans('snackbar_deleted'));

      bloc.add(UserWorkHoursEvent(
          status: UserWorkHoursEventStatus.FETCH_ALL,
      ));
    }
  }

  Widget _getBody(context, state, UserWorkHoursPageData? pageData) {
    if (state is UserWorkHoursInitialState) {
      return widgets.loadingNotice();
    }

    if (state is UserWorkHoursLoadingState) {
      return widgets.loadingNotice();
    }

    if (state is UserWorkHoursErrorState) {
      return UserWorkHoursListErrorWidget(
          error: state.message,
          memberPicture: pageData!.memberPicture,
          widgetsIn: widgets
      );
    }

    if (state is UserWorkHoursPaginatedLoadedState) {
      if (state.workHoursPaginated!.results!.length == 0) {
        return UserWorkHoursListEmptyWidget(
            memberPicture: pageData!.memberPicture,
            widgetsIn: widgets
        );
      }

      PaginationInfo paginationInfo = PaginationInfo(
          count: state.workHoursPaginated!.count,
          next: state.workHoursPaginated!.next,
          previous: state.workHoursPaginated!.previous,
          currentPage: state.page != null ? state.page : 1,
          pageSize: 20
      );

      return UserWorkHoursListWidget(
        workHoursPaginated: state.workHoursPaginated,
        paginationInfo: paginationInfo,
        memberPicture: pageData!.memberPicture,
        searchQuery: state.query,
        startDate: state.startDate,
        isPlanning: pageData.isPlanning,
        widgetsIn: widgets
      );
    }

    if (state is UserWorkHoursLoadedState) {
      return UserWorkHoursFormWidget(
        formData: state.formData,
        memberPicture: pageData!.memberPicture,
        widgetsIn: widgets
      );
    }

    if (state is UserWorkHoursNewState) {
      return UserWorkHoursFormWidget(
          formData: state.formData,
          memberPicture: pageData!.memberPicture,
          widgetsIn: widgets
      );
    }

    return widgets.loadingNotice();
  }
}
