import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:my24app/core/widgets/widgets.dart';
import 'package:my24app/mobile/blocs/activity_bloc.dart';
import 'package:my24app/mobile/blocs/activity_states.dart';
import 'package:my24app/mobile/widgets/activity_form.dart';
import 'package:my24app/mobile/widgets/activity_list.dart';


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
      return ActivityListWidget(
          activities: null,
          error: state.message,
          assignedOrderId: assignedOrderId
      );
    }

    if (state is ActivitiesLoadedState) {
      return ActivityListWidget(
        activities: state.activities,
        assignedOrderId: assignedOrderId
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
