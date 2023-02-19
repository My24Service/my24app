import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:my24app/core/utils.dart';

import 'package:my24app/core/widgets/widgets.dart';
import 'package:my24app/mobile/blocs/activity_bloc.dart';
import 'package:my24app/core/widgets/sliver_classes.dart';
import 'package:my24app/mobile/models/activity/models.dart';

class ActivityListWidget extends BaseSliverStatelessWidget {
  final AssignedOrderActivities activities;
  final int assignedOrderId;

  ActivityListWidget({
    Key key,
    this.activities,
    this.assignedOrderId
  }) : super(key: key);

  @override
  SliverAppBar getAppBar(BuildContext context) {
    GenericAppBarFactory factory = GenericAppBarFactory(
      context: context,
      title: 'assigned_orders.activity.app_bar_title'.tr(),
      subtitle: "${activities.count} activities",
    );
    return factory.createAppBar();
  }

  @override
  Widget getContentWidget(BuildContext context) {
    return _buildList(context);
  }

  @override
  Widget getBottomSection(BuildContext context) {
    return Row(
      children: [
        createDefaultElevatedButton(
          'assigned_orders.activity.button_add_activity'.tr(),
          () { _handleNew(context); }
        )
      ],
    );
  }

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

  Widget _buildList(BuildContext context) {
    return buildItemsSection(
      context,
      null,
      activities.results,
      (AssignedOrderActivity item) {
        return <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _createColumnItem('assigned_orders.activity.label_activity_date'.tr(),
                  item.activityDate),
              _createColumnItem('assigned_orders.activity.info_distance_to_back'.tr(),
                  "${item.distanceTo} - ${item.distanceBack}")
            ],
          ),

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _createColumnItem('assigned_orders.activity.info_work_start_end'.tr(),
                  "${utils.timeNoSeconds(item.workStart)} - ${utils.timeNoSeconds(item.workEnd)}"),
              _createColumnItem('assigned_orders.activity.info_travel_to_back'.tr(),
                "${utils.timeNoSeconds(item.travelTo)} - ${utils.timeNoSeconds(item.travelBack)}")
            ],
          ),

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _createColumnItem('assigned_orders.activity.label_extra_work'.tr(),
                  item.extraWorkDescription != null && item.extraWorkDescription != "" ?
                  "${utils.timeNoSeconds(item.extraWork)} (${item.extraWorkDescription})" :
                  utils.timeNoSeconds(item.extraWork)),
          _createColumnItem('assigned_orders.activity.label_actual_work'.tr(),
              utils.timeNoSeconds(item.actualWork)),
            ],
          ),
        ];
      },
      (AssignedOrderActivity item) {
        return <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              createDeleteButton(
                "assigned_orders.activity.button_delete_activity".tr(),
                () { _showDeleteDialog(context, item); }
              ),
              SizedBox(width: 8),
              createEditButton(
                () => { _doEdit(context, item) }
              )
            ],
          )
        ];
      },
    );
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
        pk: activity.id
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
