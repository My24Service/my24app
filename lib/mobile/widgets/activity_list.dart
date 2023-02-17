import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:my24app/core/utils.dart';

import 'package:my24app/core/widgets/widgets.dart';
import 'package:my24app/mobile/models/models.dart';
import 'package:my24app/mobile/blocs/activity_bloc.dart';
import 'package:my24app/mobile/api/mobile_api.dart';

import '../../core/widgets/sliver_classes.dart';

class ActivityListWidget extends BaseSliverStatelessWidget {
  final AssignedOrderActivities activities;

  ActivityListWidget({
    Key key,
    this.activities,
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
    return Container(
      child: _buildActivitySection(context)
    );
  }

  _doDelete(BuildContext context, AssignedOrderActivity activity) async {
    final bloc = BlocProvider.of<ActivityBloc>(context);

    bloc.add(ActivityEvent(status: ActivityEventStatus.DO_ASYNC));
    bloc.add(ActivityEvent(
        status: ActivityEventStatus.DELETE,
        pk: activity.id
    ));
  }

  _doEdit(BuildContext context, AssignedOrderActivity activity) async {
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

  Widget _buildActivitySection(BuildContext context) {
    return buildItemsSection(
      context,
      'assigned_orders.activity.info_header_table'.tr(),
      activities.results,
      (AssignedOrderActivity item) {
        List<Widget> items = <Widget>[
          ...buildItemListKeyValueList(
              'assigned_orders.activity.info_work_start_end'.tr(),
              "${utils.timeNoSeconds(item.workStart)} - ${utils.timeNoSeconds(item.workEnd)}"
          ),
          ...buildItemListKeyValueList(
              'assigned_orders.activity.info_travel_to_back'.tr(),
              "${utils.timeNoSeconds(item.travelTo)} - ${utils.timeNoSeconds(item.travelBack)}"
          ),
          ...buildItemListKeyValueList(
              'assigned_orders.activity.info_distance_to_back'.tr(),
              "${item.distanceTo} - ${item.distanceBack}"
          ),
          ...buildItemListKeyValueList(
              'assigned_orders.activity.info_distance_to_back'.tr(),
              "${item.distanceTo} - ${item.distanceBack}"
          ),
        ];

        if (item.extraWork != null || item.extraWork != "") {
          items.addAll(buildItemListKeyValueList(
              'assigned_orders.activity.label_extra_work'.tr(),
              utils.timeNoSeconds(item.extraWork)
          ));
        }

        if (item.actualWork != null || item.actualWork != "") {
          items.addAll(buildItemListKeyValueList(
              'assigned_orders.activity.label_actual_work'.tr(),
              utils.timeNoSeconds(item.actualWork)
          ));
        }

        items.addAll(buildItemListKeyValueList(
            'assigned_orders.activity.label_activity_date'.tr(),
            item.activityDate
        ));

        return items;
      },
      (item) {
        return <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              createDeleteButton(
                "assigned_orders.activity.button_delete_activity".tr(),
                () { _showDeleteDialog(context, item); }
              ),
              createEditButton(
                () => { _doEdit(context, item.id) }
              )
            ],
          )
        ];
      },
    );
  }
}
