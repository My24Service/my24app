import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:my24app/core/widgets/widgets.dart';
import 'package:my24app/mobile/blocs/activity_bloc.dart';
import 'package:my24app/mobile/blocs/activity_states.dart';
import 'package:my24app/mobile/widgets/activity.dart';


class AssignedOrderActivityPage extends StatefulWidget {
  final int assignedOrderPk;

  AssignedOrderActivityPage({
    Key key,
    this.assignedOrderPk
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => new _AssignedOrderActivityPageState();
}

class _AssignedOrderActivityPageState extends State<AssignedOrderActivityPage> {
  bool firstTime = true;

  ActivityBloc _initalBlocCall() {
    ActivityBloc bloc = ActivityBloc();

    if (firstTime) {
      bloc.add(ActivityEvent(status: ActivityEventStatus.DO_ASYNC));
      bloc.add(ActivityEvent(
          status: ActivityEventStatus.FETCH_ALL,
          value: widget.assignedOrderPk
      ));

      firstTime = false;
    }

    return bloc;
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ActivityBloc>(
        create: (context) => _initalBlocCall(),
        child: BlocConsumer<ActivityBloc, AssignedOrderActivityState>(
            listener: (context, state) {
              _handleListeners(context, state);
            },
            builder: (context, state) {
              return Scaffold(
                  appBar: AppBar(
                    title: new Text('assigned_orders.activity.app_bar_title'.tr()),
                  ),
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
          value: widget.assignedOrderPk
      ));
    }
    if (state is ActivityDeletedState) {
      if (state.result == true) {
        createSnackBar(context, 'assigned_orders.activity.snackbar_deleted'.tr());

        bloc.add(ActivityEvent(
            status: ActivityEventStatus.FETCH_ALL,
            value: widget.assignedOrderPk
        ));
      } else {
        displayDialog(context,
            'generic.error_dialog_title'.tr(),
            'assigned_orders.activity.error_deleting_dialog_content'.tr()
        );
      }
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
      return errorNotice(state.message);
    }

    if (state is ActivitiesLoadedState) {
      return ActivityWidget(
        activities: state.activities,
        assignedOrderPk: widget.assignedOrderPk,
      );
    }

    return loadingNotice();
  }
}
