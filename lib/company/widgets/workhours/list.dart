import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:my24_flutter_core/utils.dart';
import 'package:my24_flutter_core/widgets/widgets.dart';
import 'package:my24_flutter_core/models/models.dart';
import 'package:my24_flutter_core/widgets/slivers/base_widgets.dart';

import 'package:my24app/core/i18n_mixin.dart';
import 'package:my24app/company/blocs/workhours_bloc.dart';
import 'package:my24app/company/models/workhours/models.dart';
import 'mixins.dart';

class UserWorkHoursListWidget extends BaseSliverListStatelessWidget with UserWorkHoursMixin, i18nMixin {
  final String basePath = "company.workhours";
  final UserWorkHoursPaginated? workHoursPaginated;
  final PaginationInfo paginationInfo;
  final String? memberPicture;
  final String? searchQuery;
  final DateTime? startDate;
  final bool isPlanning;
  final CoreWidgets widgetsIn;

  UserWorkHoursListWidget({
    Key? key,
    required this.workHoursPaginated,
    required this.paginationInfo,
    required this.memberPicture,
    required this.searchQuery,
    required this.startDate,
    required this.isPlanning,
    required this.widgetsIn
  }) : super(
      key: key,
      paginationInfo: paginationInfo,
      memberPicture: memberPicture,
      widgets: widgetsIn
  ) {
    searchController.text = searchQuery?? '';
  }

  @override
  String getAppBarSubtitle(BuildContext context) {
    return $trans('app_bar_subtitle',
      namedArgs: {'count': "${workHoursPaginated!.count}"}
    );
  }

  @override
  SliverList getPreSliverListContent(BuildContext context) {
    return SliverList(
        delegate: SliverChildBuilderDelegate(
          (BuildContext context, int index) {
            return _buildHeaderRow(context);
          },
          childCount: 1,
        )
    );
  }

  @override
  SliverList getSliverList(BuildContext context) {
    return SliverList(
        delegate: SliverChildBuilderDelegate(
            (BuildContext context, int index) {
              UserWorkHours workHours = workHoursPaginated!.results![index];

              List<Widget> items = [];
              String? project = workHours.projectName != null ? workHours.projectName : "-";

              if (isPlanning) {
                items.addAll(widgetsIn.buildItemListKeyValueList(
                    $trans('info_user'),
                    "${workHours.fullName}"
                ));
              }

              items.addAll(widgetsIn.buildItemListKeyValueList(
                  $trans('info_start_date'),
                  "${workHours.startDate}"
              ));
              items.addAll(widgetsIn.buildItemListKeyValueList(
                  $trans('info_project'),
                  project
              ));
              items.addAll(widgetsIn.buildItemListKeyValueList(
                  $trans('info_work_start_end', pathOverride: 'assigned_orders.activity'),
                  "${coreUtils.timeNoSeconds(workHours.workStart)} - ${coreUtils.timeNoSeconds(workHours.workEnd)}"
              ));

              if (workHours.travelTo != null || workHours.travelBack != null) {
                items.addAll(widgetsIn.buildItemListKeyValueList(
                    $trans('info_travel_to_back', pathOverride: 'assigned_orders.activity'),
                    "${coreUtils.timeNoSeconds(workHours.travelTo)} - ${coreUtils.timeNoSeconds(workHours.travelBack)}"
                ));
              }

              if (workHours.distanceTo != 0 || workHours.distanceBack != 0) {
                items.addAll(widgetsIn.buildItemListKeyValueList(
                    $trans('info_distance_to_back', pathOverride: 'assigned_orders.activity'),
                    "${workHours.distanceTo} - ${workHours.distanceBack}"
                ));
              }

              return Column(
                children: [
                  ...items,
                  SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      widgetsIn.createDeleteButton(
                        () { _showDeleteDialog(context, workHours); }
                      ),
                      SizedBox(width: 8),
                      widgetsIn.createEditButton(
                        () => { _doEdit(context, workHours) }
                      )
                    ],
                  ),
                  if (index < workHoursPaginated!.results!.length-1)
                    widgetsIn.getMy24Divider(context)
                ],
              );
            },
            childCount: workHoursPaginated!.results!.length,
        )
    );
  }

  // private methods
  Widget _buildHeaderRow(BuildContext context) {
    DateTime _startDate = startDate == null ? DateTime.now() : startDate!;
    final int week = coreUtils.weekNumber(_startDate);
    final String startDateTxt = coreUtils.formatDateDDMMYYYY(_startDate);
    final String endDateTxt = coreUtils.formatDateDDMMYYYY(_startDate.add(Duration(days: 7)));
    final String header = "Week $week ($startDateTxt - $endDateTxt)";

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        IconButton(
            icon: Icon(
              Icons.arrow_back,
              color: Colors.blue,
              size: 36.0,
              semanticLabel: 'Back',
            ),
            onPressed: () { _navWeekBack(context); }
        ),
        Text(header),
        IconButton(
            icon: Icon(
              Icons.arrow_forward,
              color: Colors.blue,
              size: 36.0,
              semanticLabel: 'Forward',
            ),
            onPressed: () { _navWeekForward(context); }
        ),
      ],
    );
  }

  _navWeekBack(BuildContext context) {
    final bloc = BlocProvider.of<UserWorkHoursBloc>(context);
    final DateTime _startDate = startDate!.subtract(Duration(days: 7));

    bloc.add(UserWorkHoursEvent(status: UserWorkHoursEventStatus.DO_ASYNC));
    bloc.add(UserWorkHoursEvent(
        status: UserWorkHoursEventStatus.FETCH_ALL,
        startDate: _startDate
    ));
  }

  _navWeekForward(BuildContext context) {
    final bloc = BlocProvider.of<UserWorkHoursBloc>(context);
    final DateTime _startDate = startDate!.add(Duration(days: 7));

    bloc.add(UserWorkHoursEvent(status: UserWorkHoursEventStatus.DO_ASYNC));
    bloc.add(UserWorkHoursEvent(
        status: UserWorkHoursEventStatus.FETCH_ALL,
        startDate: _startDate
    ));
  }

  _doDelete(BuildContext context, UserWorkHours workHours) {
    final bloc = BlocProvider.of<UserWorkHoursBloc>(context);

    bloc.add(UserWorkHoursEvent(status: UserWorkHoursEventStatus.DO_ASYNC));
    bloc.add(UserWorkHoursEvent(
        status: UserWorkHoursEventStatus.DELETE,
        pk: workHours.id,
    ));
  }

  _doEdit(BuildContext context, UserWorkHours workHours) {
    final bloc = BlocProvider.of<UserWorkHoursBloc>(context);

    bloc.add(UserWorkHoursEvent(status: UserWorkHoursEventStatus.DO_ASYNC));
    bloc.add(UserWorkHoursEvent(
        status: UserWorkHoursEventStatus.FETCH_DETAIL,
        pk: workHours.id
    ));
  }

  _showDeleteDialog(BuildContext context, UserWorkHours workHours) {
    widgetsIn.showDeleteDialogWrapper(
        $trans('delete_dialog_title'),
        $trans('delete_dialog_content'),
      () => _doDelete(context, workHours),
      context
    );
  }
}
