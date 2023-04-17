import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:my24app/core/widgets/widgets.dart';
import 'package:my24app/core/i18n_mixin.dart';
import 'package:my24app/core/models/models.dart';
import 'package:my24app/core/utils.dart';
import 'package:my24app/company/blocs/leavehours_bloc.dart';
import 'package:my24app/company/blocs/leavehours_states.dart';
import 'package:my24app/company/widgets/leavehours/form.dart';
import 'package:my24app/company/widgets/leavehours/list.dart';
import 'package:my24app/company/widgets/leavehours/empty.dart';
import 'package:my24app/company/widgets/leavehours/error.dart';
import 'package:my24app/company/models/leavehours/models.dart';
import 'package:my24app/core/widgets/drawers.dart';

String initialLoadMode;
int loadId;

class UserLeaveHoursPage extends StatelessWidget with i18nMixin {
  final String basePath = "company.leavehours";
  final UserLeaveHoursBloc bloc;
  final Utils utils = Utils();

  Future<UserLeaveHoursPageData> getPageData(BuildContext context) async {
    String memberPicture = await this.utils.getMemberPicture();
    String submodel = await this.utils.getUserSubmodel();

    UserLeaveHoursPageData result = UserLeaveHoursPageData(
        drawer: await getDrawerForUserWithSubmodel(context, submodel),
        memberPicture: memberPicture,
        isPlanning: submodel == 'planning_user'
    );

    return result;
  }

  UserLeaveHoursPage({
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

  UserLeaveHoursBloc _initialBlocCall(bool isPlanning) {
    if (initialLoadMode == null) {
      bloc.add(UserLeaveHoursEvent(status: UserLeaveHoursEventStatus.DO_ASYNC));
      bloc.add(UserLeaveHoursEvent(
          status: UserLeaveHoursEventStatus.FETCH_ALL,
          isPlanning: isPlanning
      ));
    } else if (initialLoadMode == 'form') {
        bloc.add(UserLeaveHoursEvent(status: UserLeaveHoursEventStatus.DO_ASYNC));
        bloc.add(UserLeaveHoursEvent(
            status: UserLeaveHoursEventStatus.FETCH_DETAIL,
            pk: loadId,
            isPlanning: isPlanning
        ));
    } else if (initialLoadMode == 'new') {
      bloc.add(UserLeaveHoursEvent(
          status: UserLeaveHoursEventStatus.NEW,
          isPlanning: isPlanning
      ));
    }

    return bloc;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<UserLeaveHoursPageData>(
        future: getPageData(context),
        builder: (ctx, snapshot) {
          if (snapshot.hasData) {
            UserLeaveHoursPageData pageData = snapshot.data;

            return BlocProvider<UserLeaveHoursBloc>(
                create: (context) => _initialBlocCall(pageData.isPlanning),
                child: BlocConsumer<UserLeaveHoursBloc, UserLeaveHoursState>(
                    listener: (context, state) {
                      _handleListeners(context, state);
                    },
                    builder: (context, state) {
                      return Scaffold(
                          drawer: pageData.drawer,
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
    final bloc = BlocProvider.of<UserLeaveHoursBloc>(context);

    if (state is UserLeaveHoursInsertedState) {
      createSnackBar(context, $trans('snackbar_added'));

      bloc.add(UserLeaveHoursEvent(
          status: UserLeaveHoursEventStatus.FETCH_ALL,
      ));
    }

    if (state is UserLeaveHoursUpdatedState) {
      createSnackBar(context, $trans('snackbar_updated'));

      bloc.add(UserLeaveHoursEvent(
          status: UserLeaveHoursEventStatus.FETCH_ALL,
      ));
    }

    if (state is UserLeaveHoursDeletedState) {
      createSnackBar(context, $trans('snackbar_deleted'));

      bloc.add(UserLeaveHoursEvent(
          status: UserLeaveHoursEventStatus.FETCH_ALL,
      ));
    }
  }

  Widget _getBody(context, state, UserLeaveHoursPageData pageData) {
    if (state is UserLeaveHoursInitialState) {
      return loadingNotice();
    }

    if (state is UserLeaveHoursLoadingState) {
      return loadingNotice();
    }

    if (state is UserLeaveHoursErrorState) {
      return UserLeaveHoursListErrorWidget(
          error: state.message,
          memberPicture: pageData.memberPicture
      );
    }

    if (state is UserLeaveHoursPaginatedLoadedState) {
      if (state.leaveHoursPaginated.results.length == 0) {
        return UserLeaveHoursListEmptyWidget(memberPicture: pageData.memberPicture);
      }

      PaginationInfo paginationInfo = PaginationInfo(
          count: state.leaveHoursPaginated.count,
          next: state.leaveHoursPaginated.next,
          previous: state.leaveHoursPaginated.previous,
          currentPage: state.page != null ? state.page : 1,
          pageSize: 20
      );

      return UserLeaveHoursListWidget(
        leaveHoursPaginated: state.leaveHoursPaginated,
        paginationInfo: paginationInfo,
        memberPicture: pageData.memberPicture,
        searchQuery: state.query,
        startDate: state.startDate,
        isPlanning: pageData.isPlanning,
      );
    }

    if (state is UserLeaveHoursLoadedState) {
      return UserLeaveHoursFormWidget(
        formData: state.formData,
        memberPicture: pageData.memberPicture,
        isPlanning: pageData.isPlanning
      );
    }

    if (state is UserLeaveHoursNewState) {
      return UserLeaveHoursFormWidget(
          formData: state.formData,
          memberPicture: pageData.memberPicture,
          isPlanning: pageData.isPlanning
      );
    }

    return loadingNotice();
  }
}
