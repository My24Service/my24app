import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:my24app/core/utils.dart';

import 'package:my24app/core/widgets/widgets.dart';
import 'package:my24app/mobile/blocs/activity_bloc.dart';
import 'package:my24app/core/widgets/slivers/base_widgets.dart';
import 'package:my24app/mobile/models/activity/models.dart';
import 'package:my24app/core/models/models.dart';
import 'package:my24app/core/widgets/slivers/app_bars.dart';


class ActivityListWidget extends BaseSliverListStatelessWidget {
  final AssignedOrderActivities activities;
  final int assignedOrderId;
  final PaginationInfo paginationInfo;

  ActivityListWidget({
    Key key,
    @required this.activities,
    @required this.assignedOrderId,
    @required this.paginationInfo
  }) : super(
      key: key,
      modelName: 'assigned_orders.activity.model_name'.tr(),
      paginationInfo: paginationInfo
  );

  @override
  SliverAppBar getAppBar(BuildContext context) {
    String subtitle = activities != null ? "${activities.count} activities" : "";
    GenericAppBarFactory factory = GenericAppBarFactory(
      context: context,
      title: 'assigned_orders.activity.app_bar_title'.tr(),
      subtitle: subtitle,
      onStretch: _doRefresh
    );
    return factory.createAppBar();
  }

  @override
  Widget getBottomSection(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        createButton(
          () { _handleNew(context); },
          title: 'assigned_orders.activity.button_add'.tr(),
        )
      ],
    );
  }

  @override
  SliverList getSliverList(BuildContext context) {
    return SliverList(
        delegate: SliverChildBuilderDelegate(
            (BuildContext context, int index) {
              AssignedOrderActivity activity = activities.results[index];

              return Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _createColumnItem('assigned_orders.activity.label_activity_date'.tr(),
                          activity.activityDate),
                      _createColumnItem('assigned_orders.activity.info_distance_to_back'.tr(),
                          "${activity.distanceTo} - ${activity.distanceBack}")
                    ],
                  ),

                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _createColumnItem('assigned_orders.activity.info_work_start_end'.tr(),
                          "${utils.timeNoSeconds(activity.workStart)} - ${utils.timeNoSeconds(activity.workEnd)}"),
                      _createColumnItem('assigned_orders.activity.info_travel_to_back'.tr(),
                          "${utils.timeNoSeconds(activity.travelTo)} - ${utils.timeNoSeconds(activity.travelBack)}")
                    ],
                  ),

                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _createColumnItem('assigned_orders.activity.label_extra_work'.tr(),
                          activity.extraWorkDescription != null && activity.extraWorkDescription != "" ?
                          "${utils.timeNoSeconds(activity.extraWork)} (${activity.extraWorkDescription})" :
                          utils.timeNoSeconds(activity.extraWork)),
                      _createColumnItem('assigned_orders.activity.label_actual_work'.tr(),
                          utils.timeNoSeconds(activity.actualWork)),
                    ],
                  ),
                  SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      createDeleteButton(
                        "assigned_orders.activity.button_delete_activity".tr(),
                        () { _showDeleteDialog(context, activity); }
                      ),
                      SizedBox(width: 8),
                      createEditButton(
                        () => { _doEdit(context, activity) }
                      )
                    ],
                  )

                ],
              );
            }
        )
    );
  }

  // private methods
  Widget _createColumnItem(String key, String val) {
    double width = 140;
    return Container(
      alignment: AlignmentDirectional.topStart,
      width: width,
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: buildItemListKeyValueList(key, val)
      ),
    );
  }

  _doRefresh(BuildContext context) {
    final bloc = BlocProvider.of<ActivityBloc>(context);

    bloc.add(ActivityEvent(status: ActivityEventStatus.DO_ASYNC));
    bloc.add(ActivityEvent(
        status: ActivityEventStatus.FETCH_ALL,
        assignedOrderId: assignedOrderId
    ));
  }

  _handleNew(BuildContext context) {
    final bloc = BlocProvider.of<ActivityBloc>(context);

    bloc.add(ActivityEvent(
        status: ActivityEventStatus.NEW,
        assignedOrderId: assignedOrderId
    ));
  }

  _doDelete(BuildContext context, AssignedOrderActivity activity) {
    final bloc = BlocProvider.of<ActivityBloc>(context);

    bloc.add(ActivityEvent(status: ActivityEventStatus.DO_ASYNC));
    bloc.add(ActivityEvent(
        status: ActivityEventStatus.DELETE,
        pk: activity.id,
        assignedOrderId: assignedOrderId
    ));
  }

  _doEdit(BuildContext context, AssignedOrderActivity activity) {
    final bloc = BlocProvider.of<ActivityBloc>(context);

    bloc.add(ActivityEvent(status: ActivityEventStatus.DO_ASYNC));
    bloc.add(ActivityEvent(
        status: ActivityEventStatus.FETCH_DETAIL,
        pk: activity.id
    ));
  }

  _showDeleteDialog(BuildContext context, AssignedOrderActivity activity) {
    showDeleteDialogWrapper(
      'assigned_orders.activity.delete_dialog_title'.tr(),
      'assigned_orders.activity.delete_dialog_content'.tr(),
      () => _doDelete(context, activity),
      context
    );
  }
}

class ActivityListEmptyErrorWidget extends BaseSliverPlainStatelessWidget {
  final AssignedOrderActivities activities;
  final int assignedOrderId;
  final String error;

  ActivityListEmptyErrorWidget({
    Key key,
    this.activities,
    this.assignedOrderId,
    this.error
  }) : super(key: key);

  @override
  SliverAppBar getAppBar(BuildContext context) {
    String subtitle = activities != null ? "${activities.count} activities" : "";
    GenericAppBarFactory factory = GenericAppBarFactory(
        context: context,
        title: 'assigned_orders.activity.app_bar_title'.tr(),
        subtitle: subtitle,
        onStretch: _doRefresh
    );
    return factory.createAppBar();
  }

  @override
  Widget getBottomSection(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        createButton(
          () { _handleNew(context); },
          title: 'assigned_orders.activity.button_add_activity'.tr(),
        )
      ],
    );
  }

  @override
  Widget getContentWidget(BuildContext context) {
    if (error != null) {
      return errorNotice(error);
    }

    if (activities.results.length == 0) {
      return Center(
          child: Column(
            children: [
              SizedBox(height: 30),
              Text('assigned_orders.activity.notice_no_results'.tr())
            ],
          )
      );
    }

    return SizedBox(height: 0);
  }

  _doRefresh(BuildContext context) {
    final bloc = BlocProvider.of<ActivityBloc>(context);

    bloc.add(ActivityEvent(status: ActivityEventStatus.DO_ASYNC));
    bloc.add(ActivityEvent(
        status: ActivityEventStatus.FETCH_ALL,
        assignedOrderId: assignedOrderId
    ));
  }

  _handleNew(BuildContext context) {
    final bloc = BlocProvider.of<ActivityBloc>(context);

    bloc.add(ActivityEvent(
        status: ActivityEventStatus.NEW,
        assignedOrderId: assignedOrderId
    ));
  }
}
