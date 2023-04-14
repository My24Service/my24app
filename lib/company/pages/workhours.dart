import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:my24app/core/widgets/widgets.dart';
import 'package:my24app/core/i18n_mixin.dart';
import 'package:my24app/core/models/models.dart';
import 'package:my24app/core/utils.dart';
import 'package:my24app/company/blocs/workhours_bloc.dart';
import 'package:my24app/company/blocs/workhours_states.dart';
import 'package:my24app/company/widgets/workhours/form.dart';
import 'package:my24app/company/widgets/workhours/list.dart';
import 'package:my24app/company/widgets/workhours/empty.dart';
import 'package:my24app/company/widgets/workhours/error.dart';
import 'package:my24app/company/models/workhours/models.dart';

String initialLoadMode;
int loadId;

class UserWorkHoursPage extends StatelessWidget with i18nMixin {
  final String basePath = "company.workhours";
  final UserWorkHoursBloc bloc;
  final Utils utils = Utils();

  Future<UserWorkHoursPageData> getPageData() async {
    String memberPicture = await this.utils.getMemberPicture();
    String submodel = await this.utils.getUserSubmodel();

    UserWorkHoursPageData result = UserWorkHoursPageData(
        memberPicture: memberPicture,
        isPlanning: submodel == 'planning_user'
    );

    return result;
  }

  UserWorkHoursPage({
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
        future: getPageData(),
        builder: (ctx, snapshot) {
          if (snapshot.hasData) {
            UserWorkHoursPageData pageData = snapshot.data;

            return BlocProvider<UserWorkHoursBloc>(
                create: (context) => _initialBlocCall(),
                child: BlocConsumer<UserWorkHoursBloc, UserWorkHoursState>(
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
    final bloc = BlocProvider.of<UserWorkHoursBloc>(context);

    if (state is UserWorkHoursInsertedState) {
      createSnackBar(context, $trans('snackbar_added'));

      bloc.add(UserWorkHoursEvent(
          status: UserWorkHoursEventStatus.FETCH_ALL,
      ));
    }

    if (state is UserWorkHoursUpdatedState) {
      createSnackBar(context, $trans('snackbar_updated'));

      bloc.add(UserWorkHoursEvent(
          status: UserWorkHoursEventStatus.FETCH_ALL,
      ));
    }

    if (state is UserWorkHoursDeletedState) {
      createSnackBar(context, $trans('snackbar_deleted'));

      bloc.add(UserWorkHoursEvent(
          status: UserWorkHoursEventStatus.FETCH_ALL,
      ));
    }
  }

  Widget _getBody(context, state, UserWorkHoursPageData pageData) {
    if (state is UserWorkHoursInitialState) {
      return loadingNotice();
    }

    if (state is UserWorkHoursLoadingState) {
      return loadingNotice();
    }

    if (state is UserWorkHoursErrorState) {
      return UserWorkHoursListErrorWidget(
          error: state.message,
          memberPicture: pageData.memberPicture
      );
    }

    if (state is UserWorkHoursPaginatedLoadedState) {
      if (state.workHoursPaginated.results.length == 0) {
        return UserWorkHoursListEmptyWidget(memberPicture: pageData.memberPicture);
      }

      PaginationInfo paginationInfo = PaginationInfo(
          count: state.workHoursPaginated.count,
          next: state.workHoursPaginated.next,
          previous: state.workHoursPaginated.previous,
          currentPage: state.page != null ? state.page : 1,
          pageSize: 20
      );

      return UserWorkHoursListWidget(
        workHoursPaginated: state.workHoursPaginated,
        paginationInfo: paginationInfo,
        memberPicture: pageData.memberPicture,
        searchQuery: state.query,
        startDate: state.startDate,
        isPlanning: pageData.isPlanning,
      );
    }

    if (state is UserWorkHoursLoadedState) {
      return UserWorkHoursFormWidget(
        formData: state.formData,
        memberPicture: pageData.memberPicture
      );
    }

    if (state is UserWorkHoursNewState) {
      return UserWorkHoursFormWidget(
          formData: state.formData,
          memberPicture: pageData.memberPicture
      );
    }

    return loadingNotice();
  }
}
