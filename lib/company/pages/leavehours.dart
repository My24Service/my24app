import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:my24_flutter_core/utils.dart';
import 'package:my24_flutter_core/widgets/widgets.dart';
import 'package:my24_flutter_core/i18n.dart';
import 'package:my24_flutter_core/models/models.dart';

import 'package:my24app/company/blocs/leavehours_bloc.dart';
import 'package:my24app/company/blocs/leavehours_states.dart';
import 'package:my24app/company/widgets/leavehours/form.dart';
import 'package:my24app/company/widgets/leavehours/list.dart';
import 'package:my24app/company/widgets/leavehours/empty.dart';
import 'package:my24app/company/widgets/leavehours/error.dart';
import 'package:my24app/company/models/leavehours/models.dart';
import 'package:my24app/common/widgets/drawers.dart';
import '../widgets/leavehours/unaccepted/empty.dart';
import '../widgets/leavehours/unaccepted/list.dart';

String? initialLoadMode;
int? loadId;

class UserLeaveHoursPage extends StatelessWidget {
  final UserLeaveHoursBloc bloc;
  final i18n = My24i18n(basePath: "company.leavehours");
  final CoreWidgets widgets = CoreWidgets();

  Future<UserLeaveHoursPageData> getPageData(BuildContext context) async {
    String? memberPicture = await coreUtils.getMemberPicture();
    String? submodel = await coreUtils.getUserSubmodel();

    UserLeaveHoursPageData result = UserLeaveHoursPageData(
        drawer: await getDrawerForUserWithSubmodel(context, submodel),
        memberPicture: memberPicture,
        isPlanning: submodel == 'planning_user'
    );

    return result;
  }

  UserLeaveHoursPage({
    Key? key,
    required this.bloc,
    String? initialMode,
    int? pk
  }) : super(key: key) {
    initialLoadMode = initialMode;
    loadId = pk;
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
    } else if (initialLoadMode == 'unaccepted') {
      bloc.add(UserLeaveHoursEvent(
          status: UserLeaveHoursEventStatus.FETCH_UNACCEPTED,
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
            UserLeaveHoursPageData? pageData = snapshot.data;

            return BlocProvider<UserLeaveHoursBloc>(
                create: (context) => _initialBlocCall(pageData!.isPlanning),
                child: BlocConsumer<UserLeaveHoursBloc, UserLeaveHoursState>(
                    listener: (context, state) {
                      _handleListeners(context, state, pageData);
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
            print('snapshot.error ${snapshot.error}');
            return Center(
                child: Text(
                    i18n.$trans("error_arg", pathOverride: "generic",
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

  void _handleListeners(BuildContext context, state, UserLeaveHoursPageData? pageData) {
    final bloc = BlocProvider.of<UserLeaveHoursBloc>(context);

    if (state is UserLeaveHoursInsertedState) {
      widgets.createSnackBar(context, i18n.$trans('snackbar_added'));

      bloc.add(UserLeaveHoursEvent(
          status: UserLeaveHoursEventStatus.FETCH_ALL,
          isPlanning: pageData!.isPlanning
      ));
    }

    if (state is UserLeaveHoursUpdatedState) {
      widgets.createSnackBar(context, i18n.$trans('snackbar_updated'));

      bloc.add(UserLeaveHoursEvent(
          status: UserLeaveHoursEventStatus.FETCH_ALL,
          isPlanning: pageData!.isPlanning
      ));
    }

    if (state is UserLeaveHoursDeletedState) {
      widgets.createSnackBar(context, i18n.$trans('snackbar_deleted'));

      bloc.add(UserLeaveHoursEvent(
          status: UserLeaveHoursEventStatus.FETCH_ALL,
          isPlanning: pageData!.isPlanning
      ));
    }

    if (state is UserLeaveHoursAcceptedState) {
      widgets.createSnackBar(context, i18n.$trans('snackbar_accepted'));

      bloc.add(UserLeaveHoursEvent(
          status: UserLeaveHoursEventStatus.FETCH_UNACCEPTED,
          isPlanning: pageData!.isPlanning
      ));
    }

    if (state is UserLeaveHoursRejectedState) {
      widgets.createSnackBar(context, i18n.$trans('snackbar_rejected'));

      bloc.add(UserLeaveHoursEvent(
          status: UserLeaveHoursEventStatus.FETCH_UNACCEPTED,
          isPlanning: pageData!.isPlanning
      ));
    }
  }

  Widget _getBody(context, state, UserLeaveHoursPageData pageData) {
    if (state is UserLeaveHoursInitialState) {
      return widgets.loadingNotice();
    }

    if (state is UserLeaveHoursLoadingState) {
      return widgets.loadingNotice();
    }

    if (state is UserLeaveHoursErrorState) {
      return UserLeaveHoursListErrorWidget(
          error: state.message,
          memberPicture: pageData.memberPicture,
          widgetsIn: widgets,
          i18nIn: i18n,
      );
    }

    // unaccepted list
    if (state is UserLeaveHoursUnacceptedPaginatedLoadedState) {
      if (state.leaveHoursPaginated!.results!.length == 0) {
        return LeaveHoursUnacceptedListEmptyWidget(
            memberPicture: pageData.memberPicture,
            widgetsIn: widgets
        );
      }

      PaginationInfo paginationInfo = PaginationInfo(
          count: state.leaveHoursPaginated!.count,
          next: state.leaveHoursPaginated!.next,
          previous: state.leaveHoursPaginated!.previous,
          currentPage: state.page != null ? state.page : 1,
          pageSize: 20
      );

      return LeaveHoursUnacceptedListWidget(
        leaveHoursPaginated: state.leaveHoursPaginated,
        paginationInfo: paginationInfo,
        memberPicture: pageData.memberPicture,
        searchQuery: state.query,
        widgetsIn: widgets,
      );
    }

    // normal list
    if (state is UserLeaveHoursPaginatedLoadedState) {
      if (state.leaveHoursPaginated!.results!.length == 0) {
        return UserLeaveHoursListEmptyWidget(
            memberPicture: pageData.memberPicture,
            isPlanning: pageData.isPlanning,
            widgetsIn: widgets,
            i18nIn: i18n,
        );
      }

      PaginationInfo paginationInfo = PaginationInfo(
          count: state.leaveHoursPaginated!.count,
          next: state.leaveHoursPaginated!.next,
          previous: state.leaveHoursPaginated!.previous,
          currentPage: state.page != null ? state.page : 1,
          pageSize: 20
      );

      return UserLeaveHoursListWidget(
        leaveHoursPaginated: state.leaveHoursPaginated,
        paginationInfo: paginationInfo,
        memberPicture: pageData.memberPicture,
        searchQuery: state.query,
        isPlanning: pageData.isPlanning,
        widgetsIn: widgets,
        i18nIn: i18n,
      );
    }

    if (state is UserLeaveHoursLoadedState) {
      return UserLeaveHoursFormWidget(
        formData: state.formData,
        isPlanning: pageData.isPlanning,
        widgetsIn: widgets,
        i18nIn: i18n,
      );
    }

    if (state is UserLeaveHoursNewState) {
      return UserLeaveHoursFormWidget(
          formData: state.formData,
          isPlanning: pageData.isPlanning,
          widgetsIn: widgets,
          i18nIn: i18n,
      );
    }

    return widgets.loadingNotice();
  }
}
