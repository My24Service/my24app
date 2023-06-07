import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my24app/core/utils.dart';

import 'package:my24app/core/widgets/widgets.dart';
import 'package:my24app/mobile/blocs/activity_bloc.dart';
import 'package:my24app/core/widgets/slivers/base_widgets.dart';
import 'package:my24app/mobile/models/activity/models.dart';
import 'package:my24app/core/models/models.dart';
import 'package:my24app/core/i18n_mixin.dart';
import 'mixins.dart';


class ActivityListWidget extends BaseSliverListStatelessWidget with ActivityMixin, i18nMixin {
  final String basePath = "assigned_orders.activity";
  final AssignedOrderActivities? activities;
  final int? assignedOrderId;
  final PaginationInfo paginationInfo;
  final String? memberPicture;
  final String? searchQuery;

  ActivityListWidget({
    Key? key,
    required this.activities,
    required this.assignedOrderId,
    required this.paginationInfo,
    required this.memberPicture,
    required this.searchQuery
  }) : super(
      key: key,
      paginationInfo: paginationInfo,
      memberPicture: memberPicture
  ) {
    searchController.text = searchQuery?? '';
  }

  @override
  String getAppBarSubtitle(BuildContext context) {
    return $trans('app_bar_subtitle',
      namedArgs: {'count': "${activities!.count}"}
    );
  }

  @override
  SliverList getSliverList(BuildContext context) {
    return SliverList(
        delegate: SliverChildBuilderDelegate(
            (BuildContext context, int index) {
              AssignedOrderActivity activity = activities!.results![index];

              return Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _createColumnItem($trans('label_activity_date'),
                          activity.activityDate),
                      _createColumnItem($trans('info_distance_to_back'),
                          "${activity.distanceTo} - ${activity.distanceBack}")
                    ],
                  ),

                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _createColumnItem($trans('info_work_start_end'),
                          "${utils.timeNoSeconds(activity.workStart)} - ${utils.timeNoSeconds(activity.workEnd)}"),
                      _createColumnItem($trans('info_travel_to_back'),
                          "${utils.timeNoSeconds(activity.travelTo)} - ${utils.timeNoSeconds(activity.travelBack)}")
                    ],
                  ),

                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _createColumnItem($trans('label_extra_work'),
                          activity.extraWorkDescription != null && activity.extraWorkDescription != "" ?
                          "${utils.timeNoSeconds(activity.extraWork)} (${activity.extraWorkDescription})" :
                          utils.timeNoSeconds(activity.extraWork)),
                      _createColumnItem($trans('label_actual_work'),
                          utils.timeNoSeconds(activity.actualWork)),
                    ],
                  ),
                  SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      createDeleteButton(
                        $trans("button_delete"),
                        () { _showDeleteDialog(context, activity); }
                      ),
                      SizedBox(width: 8),
                      createEditButton(
                        () => { _doEdit(context, activity) }
                      )
                    ],
                  ),
                  if (index < activities!.results!.length-1)
                    getMy24Divider(context)
                ],
              );
            },
            childCount: activities!.results!.length,
        )
    );
  }

  // private methods
  Widget _createColumnItem(String key, String? val) {
    double width = 160;
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
        $trans('delete_dialog_title'),
        $trans('delete_dialog_content'),
      () => _doDelete(context, activity),
      context
    );
  }
}
