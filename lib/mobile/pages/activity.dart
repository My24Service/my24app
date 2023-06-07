import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:my24app/core/widgets/widgets.dart';
import 'package:my24app/mobile/blocs/activity_bloc.dart';
import 'package:my24app/mobile/blocs/activity_states.dart';
import 'package:my24app/mobile/widgets/activity/form.dart';
import 'package:my24app/mobile/widgets/activity/list.dart';
import 'package:my24app/core/i18n_mixin.dart';
import 'package:my24app/core/models/models.dart';
import 'package:my24app/mobile/widgets/activity/error.dart';
import 'package:my24app/core/utils.dart';

String? initialLoadMode;
int? loadId;

class AssignedOrderActivityPage extends StatelessWidget with i18nMixin {
  final int? assignedOrderId;
  final String basePath = "assigned_orders.activity";
  final ActivityBloc bloc;
  final Utils utils = Utils();

  Future<DefaultPageData> getPageData() async {
    String? memberPicture = await this.utils.getMemberPicture();

    DefaultPageData result = DefaultPageData(
        memberPicture: memberPicture,
    );

    return result;
  }

  AssignedOrderActivityPage({
    Key? key,
    required this.assignedOrderId,
    required this.bloc,
    String? initialMode,
    int? pk
  }) : super(key: key) {
    if (initialMode != null) {
      initialLoadMode = initialMode;
      loadId = pk;
    }
  }

  ActivityBloc _initialBlocCall() {
    if (initialLoadMode == null) {
      bloc.add(ActivityEvent(status: ActivityEventStatus.DO_ASYNC));
      bloc.add(ActivityEvent(
          status: ActivityEventStatus.FETCH_ALL,
          assignedOrderId: assignedOrderId
      ));
    } else if (initialLoadMode == 'form') {
        bloc.add(ActivityEvent(status: ActivityEventStatus.DO_ASYNC));
        bloc.add(ActivityEvent(
            status: ActivityEventStatus.FETCH_DETAIL,
            pk: loadId
        ));
    } else if (initialLoadMode == 'new') {
      bloc.add(ActivityEvent(
          status: ActivityEventStatus.NEW,
          assignedOrderId: assignedOrderId
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
            DefaultPageData? pageData = snapshot.data;

            return BlocProvider<ActivityBloc>(
                create: (context) => _initialBlocCall(),
                child: BlocConsumer<ActivityBloc, AssignedOrderActivityState>(
                    listener: (context, state) {
                      _handleListeners(context, state);
                    },
                    builder: (context, state) {
                      return Scaffold(
                          body: _getBody(context, state, pageData),
                      );
                    }
                )
            );
          } else if (snapshot.hasError) {
            return Center(
                child: Text(
                    $trans("error_arg", pathOverride: "generic",
                        namedArgs: {"error": snapshot.error as String?}))
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
    final bloc = BlocProvider.of<ActivityBloc>(context);

    if (state is ActivityInsertedState) {
      createSnackBar(context, $trans('snackbar_added'));

      bloc.add(ActivityEvent(
          status: ActivityEventStatus.FETCH_ALL,
          assignedOrderId: assignedOrderId
      ));
    }

    if (state is ActivityUpdatedState) {
      createSnackBar(context, $trans('snackbar_updated'));

      bloc.add(ActivityEvent(
          status: ActivityEventStatus.FETCH_ALL,
          assignedOrderId: assignedOrderId
      ));
    }

    if (state is ActivityDeletedState) {
      createSnackBar(context, $trans('snackbar_deleted'));

      bloc.add(ActivityEvent(
          status: ActivityEventStatus.FETCH_ALL,
          assignedOrderId: assignedOrderId
      ));
    }

    if (state is ActivitiesLoadedState && state.query == null &&
        state.activities!.results!.length == 0) {
      bloc.add(ActivityEvent(
          status: ActivityEventStatus.NEW_EMPTY,
          assignedOrderId: assignedOrderId
      ));
    }
  }

  Widget _getBody(context, state, DefaultPageData? pageData) {
    if (state is ActivityInitialState) {
      return loadingNotice();
    }

    if (state is ActivityLoadingState) {
      return loadingNotice();
    }

    if (state is ActivityErrorState) {
      return ActivityListErrorWidget(
          error: state.message,
          memberPicture: pageData!.memberPicture
      );
    }

    if (state is ActivitiesLoadedState) {
      PaginationInfo paginationInfo = PaginationInfo(
          count: state.activities!.count,
          next: state.activities!.next,
          previous: state.activities!.previous,
          currentPage: state.page != null ? state.page : 1,
          pageSize: 20
      );

      return ActivityListWidget(
        activities: state.activities,
        assignedOrderId: assignedOrderId,
        paginationInfo: paginationInfo,
        memberPicture: pageData!.memberPicture,
        searchQuery: state.query,
      );
    }

    if (state is ActivityLoadedState) {
      return ActivityFormWidget(
        formData: state.activityFormData,
        assignedOrderId: assignedOrderId,
        memberPicture: pageData!.memberPicture,
        newFromEmpty: false,
      );
    }

    if (state is ActivityNewState) {
      return ActivityFormWidget(
          formData: state.activityFormData,
          assignedOrderId: assignedOrderId,
          memberPicture: pageData!.memberPicture,
          newFromEmpty: state.fromEmpty,
      );
    }

    return loadingNotice();
  }
}
