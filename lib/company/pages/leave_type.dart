import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:my24app/core/widgets/widgets.dart';
import 'package:my24app/core/i18n_mixin.dart';
import 'package:my24app/core/models/models.dart';
import 'package:my24app/core/utils.dart';
import 'package:my24app/company/blocs/leave_type_bloc.dart';
import 'package:my24app/company/blocs/leave_type_states.dart';
import 'package:my24app/company/widgets/leave_type/form.dart';
import 'package:my24app/company/widgets/leave_type/list.dart';
import 'package:my24app/company/widgets/leave_type/error.dart';
import 'package:my24app/core/widgets/drawers.dart';

String initialLoadMode;
int loadId;

class LeaveTypePage extends StatelessWidget with i18nMixin {
  final String basePath = "company.leave_types";
  final LeaveTypeBloc bloc;
  final Utils utils = Utils();

  Future<DefaultPageData> getPageData(BuildContext context) async {
    String memberPicture = await utils.getMemberPicture();
    String submodel = await this.utils.getUserSubmodel();

    DefaultPageData result = DefaultPageData(
        drawer: await getDrawerForUserWithSubmodel(context, submodel),
        memberPicture: memberPicture,
    );

    return result;
  }

  LeaveTypePage({
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

  LeaveTypeBloc _initialBlocCall() {
    if (initialLoadMode == null) {
      bloc.add(LeaveTypeEvent(status: LeaveTypeEventStatus.DO_ASYNC));
      bloc.add(LeaveTypeEvent(
          status: LeaveTypeEventStatus.FETCH_ALL,
      ));
    } else if (initialLoadMode == 'form') {
        bloc.add(LeaveTypeEvent(status: LeaveTypeEventStatus.DO_ASYNC));
        bloc.add(LeaveTypeEvent(
            status: LeaveTypeEventStatus.FETCH_DETAIL,
            pk: loadId
        ));
    } else if (initialLoadMode == 'new') {
      bloc.add(LeaveTypeEvent(
          status: LeaveTypeEventStatus.NEW,
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
            DefaultPageData pageData = snapshot.data;

            return BlocProvider<LeaveTypeBloc>(
                create: (context) => _initialBlocCall(),
                child: BlocConsumer<LeaveTypeBloc, LeaveTypeState>(
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
            print(snapshot.error);
            return Center(
                child: Text(
                    $trans("error_arg", pathOverride: "generic",
                        namedArgs: {"error": snapshot.error}))
            );
          } else {
            return Scaffold(
                body: loadingNotice()
            );
          }
        }
    );

  }

  void _handleListeners(BuildContext context, state) {
    final bloc = BlocProvider.of<LeaveTypeBloc>(context);

    if (state is LeaveTypeInsertedState) {
      createSnackBar(context, $trans('snackbar_added'));

      bloc.add(LeaveTypeEvent(
        status: LeaveTypeEventStatus.FETCH_ALL,
      ));
    }

    if (state is LeaveTypeUpdatedState) {
      createSnackBar(context, $trans('snackbar_updated'));

      bloc.add(LeaveTypeEvent(
        status: LeaveTypeEventStatus.FETCH_ALL,
      ));
    }

    if (state is LeaveTypeDeletedState) {
      createSnackBar(context, $trans('snackbar_deleted'));

      bloc.add(LeaveTypeEvent(
        status: LeaveTypeEventStatus.FETCH_ALL,
      ));
    }

    if (state is LeaveTypesLoadedState && state.leaveTypes.results.length == 0) {
      bloc.add(LeaveTypeEvent(
        status: LeaveTypeEventStatus.NEW_EMPTY,
      ));
    }
  }

  Widget _getBody(context, state, DefaultPageData pageData) {
    if (state is LeaveTypeInitialState) {
      return loadingNotice();
    }

    if (state is LeaveTypeLoadingState) {
      return loadingNotice();
    }

    if (state is LeaveTypeErrorState) {
      return LeaveTypeListErrorWidget(
          error: state.message,
          memberPicture: pageData.memberPicture
      );
    }

    if (state is LeaveTypesLoadedState) {
      PaginationInfo paginationInfo = PaginationInfo(
          count: state.leaveTypes.count,
          next: state.leaveTypes.next,
          previous: state.leaveTypes.previous,
          currentPage: state.page != null ? state.page : 1,
          pageSize: 20
      );

      return LeaveTypeListWidget(
        leaveTypes: state.leaveTypes,
        paginationInfo: paginationInfo,
        memberPicture: pageData.memberPicture,
        searchQuery: state.query,
      );
    }

    if (state is LeaveTypeLoadedState) {
      return LeaveTypeFormWidget(
        formData: state.formData,
        memberPicture: pageData.memberPicture,
        newFromEmpty: false,
      );
    }

    if (state is LeaveTypeNewState) {
      return LeaveTypeFormWidget(
          formData: state.formData,
          memberPicture: pageData.memberPicture,
          newFromEmpty: state.fromEmpty,
      );
    }

    return loadingNotice();
  }
}
