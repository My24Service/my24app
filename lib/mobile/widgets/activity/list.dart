import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:my24_flutter_core/utils.dart';
import 'package:my24_flutter_core/widgets/widgets.dart';
import 'package:my24_flutter_core/i18n.dart';
import 'package:my24_flutter_core/widgets/slivers/base_widgets.dart';
import 'package:my24_flutter_core/models/models.dart';

import 'package:my24app/mobile/blocs/activity_bloc.dart';
import 'package:my24app/mobile/models/activity/models.dart';
import 'mixins.dart';

class ActivityListWidget extends BaseSliverListStatelessWidget with ActivityMixin {
  final AssignedOrderActivities? activities;
  final int? assignedOrderId;
  final PaginationInfo paginationInfo;
  final String? memberPicture;
  final String? searchQuery;
  final CoreWidgets widgetsIn;
  final My24i18n i18nIn;

  ActivityListWidget({
    Key? key,
    required this.activities,
    required this.assignedOrderId,
    required this.paginationInfo,
    required this.memberPicture,
    required this.searchQuery,
    required this.widgetsIn,
    required this.i18nIn
  }) : super(
      key: key,
      paginationInfo: paginationInfo,
      memberPicture: memberPicture,
      widgets: widgetsIn,
      i18n: i18nIn
  ) {
    searchController.text = searchQuery?? '';
  }

  @override
  String getAppBarSubtitle(BuildContext context) {
    return i18nIn.$trans('app_bar_subtitle',
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
                      _createColumnItem(i18nIn.$trans('label_activity_date'),
                          activity.activityDate),
                      _createColumnItem(i18nIn.$trans('info_distance_to_back'),
                          "${activity.distanceTo} - ${activity.distanceBack}")
                    ],
                  ),

                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _createColumnItem(i18nIn.$trans('info_work_start_end'),
                          "${coreUtils.timeNoSeconds(activity.workStart)} - ${coreUtils.timeNoSeconds(activity.workEnd)}"),
                      _createColumnItem(i18nIn.$trans('info_travel_to_back'),
                          "${coreUtils.timeNoSeconds(activity.travelTo)} - ${coreUtils.timeNoSeconds(activity.travelBack)}")
                    ],
                  ),

                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _createColumnItem(i18nIn.$trans('label_extra_work'),
                          activity.extraWorkDescription != null && activity.extraWorkDescription != "" ?
                          "${coreUtils.timeNoSeconds(activity.extraWork)} (${activity.extraWorkDescription})" :
                          coreUtils.timeNoSeconds(activity.extraWork)),
                      _createColumnItem(i18nIn.$trans('label_actual_work'),
                          coreUtils.timeNoSeconds(activity.actualWork)),
                    ],
                  ),
                  SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      widgetsIn.createDeleteButton(
                        () { _showDeleteDialog(context, activity); }
                      ),
                      SizedBox(width: 8),
                      widgetsIn.createEditButton(
                        () => { _doEdit(context, activity) }
                      )
                    ],
                  ),
                  if (index < activities!.results!.length-1)
                    widgetsIn.getMy24Divider(context)
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
          children: widgetsIn.buildItemListKeyValueList(key, val)
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
    widgetsIn.showDeleteDialogWrapper(
        i18nIn.$trans('delete_dialog_title'),
        i18nIn.$trans('delete_dialog_content'),
      () => _doDelete(context, activity),
      context
    );
  }
}
