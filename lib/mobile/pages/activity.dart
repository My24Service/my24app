import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:my24app/core/widgets/widgets.dart';
import 'package:my24app/mobile/blocs/activity_bloc.dart';
import 'package:my24app/mobile/blocs/activity_states.dart';
import 'package:my24app/mobile/widgets/activity/form.dart';
import 'package:my24app/mobile/widgets/activity/list.dart';

import '../../core/models/models.dart';
import '../widgets/activity/empty.dart';
import '../widgets/activity/error.dart';


class AssignedOrderActivityPage extends StatelessWidget {
  final int assignedOrderId;

  AssignedOrderActivityPage({
    Key key,
    this.assignedOrderId
  }) : super(key: key);

  ActivityBloc _initialBlocCall() {
    ActivityBloc bloc = ActivityBloc();

    bloc.add(ActivityEvent(status: ActivityEventStatus.DO_ASYNC));
    bloc.add(ActivityEvent(
        status: ActivityEventStatus.FETCH_ALL,
        assignedOrderId: assignedOrderId
    ));

    return bloc;
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ActivityBloc>(
        create: (context) => _initialBlocCall(),
        child: BlocConsumer<ActivityBloc, AssignedOrderActivityState>(
            listener: (context, state) {
              _handleListeners(context, state);
            },
            builder: (context, state) {
              return Scaffold(
                  body: GestureDetector(
                      onTap: () {
                        FocusScope.of(context).requestFocus(FocusNode());
                      },
                      child: _getBody(context, state),
                  )
              );
            }
        )
    );
  }

  void _handleListeners(BuildContext context, state) {
    final bloc = BlocProvider.of<ActivityBloc>(context);

    if (state is ActivityInsertedState) {
      createSnackBar(context, 'assigned_orders.activity.snackbar_added'.tr());

      bloc.add(ActivityEvent(
          status: ActivityEventStatus.FETCH_ALL,
          assignedOrderId: assignedOrderId
      ));
    }

    if (state is ActivityUpdatedState) {
      createSnackBar(context, 'assigned_orders.activity.snackbar_updated'.tr());

      bloc.add(ActivityEvent(
          status: ActivityEventStatus.FETCH_ALL,
          assignedOrderId: assignedOrderId
      ));
    }

    if (state is ActivityDeletedState) {
      createSnackBar(context, 'assigned_orders.activity.snackbar_deleted'.tr());

      bloc.add(ActivityEvent(
          status: ActivityEventStatus.FETCH_ALL,
          assignedOrderId: assignedOrderId
      ));
    }
  }

  Widget _getBody(context, state) {
    if (state is ActivityInitialState) {
      return loadingNotice();
    }

    if (state is ActivityLoadingState) {
      return loadingNotice();
    }

    if (state is ActivityErrorState) {
      return ActivityListErrorWidget(
          error: state.message,
      );
    }

    if (state is ActivitiesLoadedState) {
      if (state.activities.results.length == 0) {
        return ActivityListEmptyWidget();
      }

      PaginationInfo paginationInfo = PaginationInfo(
          count: state.activities.count,
          next: state.activities.next,
          previous: state.activities.previous,
          currentPage: state.page != null ? state.page : 1,
          pageSize: 20
      );

      return ActivityListWidget(
        activities: state.activities,
        assignedOrderId: assignedOrderId,
        paginationInfo: paginationInfo,
      );
    }

    if (state is ActivityLoadedState) {
      return ActivityFormWidget(
        activity: state.activityFormData,
        assignedOrderId: assignedOrderId
      );
    }

    if (state is ActivityNewState) {
      return ActivityFormWidget(
          activity: state.activityFormData,
          assignedOrderId: assignedOrderId
      );
    }

    return loadingNotice();
  }
}
