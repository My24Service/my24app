import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:my24app/core/widgets/widgets.dart';
import 'package:my24app/core/models/models.dart';
import 'package:my24app/core/i18n_mixin.dart';
import 'package:my24app/core/utils.dart';
import 'package:my24app/core/widgets/slivers/base_widgets.dart';
import 'package:my24app/company/blocs/leavehours_bloc.dart';
import 'package:my24app/company/models/leavehours/models.dart';
import 'mixins.dart';

class UserLeaveHoursListWidget extends BaseSliverListStatelessWidget with UserLeaveHoursMixin, i18nMixin {
  final String basePath = "company.leavehours";
  final UserLeaveHoursPaginated leaveHoursPaginated;
  final PaginationInfo paginationInfo;
  final String memberPicture;
  final String searchQuery;
  final DateTime startDate;
  final bool isPlanning;

  UserLeaveHoursListWidget({
    Key key,
    @required this.leaveHoursPaginated,
    @required this.paginationInfo,
    @required this.memberPicture,
    @required this.searchQuery,
    @required this.startDate,
    @required this.isPlanning,
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
      namedArgs: {'count': "${leaveHoursPaginated.count}"}
    );
  }

  @override
  SliverList getSliverList(BuildContext context) {
    return SliverList(
        delegate: SliverChildBuilderDelegate(
            (BuildContext context, int index) {
              UserLeaveHours leaveHours = leaveHoursPaginated.results[index];

              List<Widget> items = [];
              String leaveType = leaveHours.leaveTypeName;

              if (isPlanning) {
                items.addAll(buildItemListKeyValueList(
                    $trans('info_user'),
                    "${leaveHours.fullName}"
                ));
              }

              items.addAll(buildItemListKeyValueList(
                  $trans('info_start_date'),
                  "${leaveHours.startDate}"
              ));
              items.addAll(buildItemListKeyValueList(
                  $trans('info_leave_type'),
                  leaveType
              ));

              List<Widget> buttons = [];
              if (isPlanning || (!isPlanning && (!leaveHours.isAccepted && !leaveHours.isRejected))) {
                buttons = [
                  createDeleteButton(
                      $trans("button_delete"),
                      () { _showDeleteDialog(context, leaveHours); }
                  ),
                  SizedBox(width: 8),
                  createEditButton(
                      () => { _doEdit(context, leaveHours) }
                  )
                ];
              }

              return Column(
                children: [
                  _buildHeaderRow(context),
                  SizedBox(height: 10),
                  ...items,
                  SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: buttons,
                  ),
                  if (index < leaveHoursPaginated.results.length-1)
                    getMy24Divider(context)
                ],
              );
            },
            childCount: leaveHoursPaginated.results.length,
        )
    );
  }

  // private methods
  Widget _buildHeaderRow(BuildContext context) {
    DateTime _startDate = startDate == null ? DateTime.now() : startDate;
    final int week = utils.weekNumber(_startDate);
    final String startDateTxt = utils.formatDate(_startDate);
    final String endDateTxt = utils.formatDate(_startDate.add(Duration(days: 7)));
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
    final bloc = BlocProvider.of<UserLeaveHoursBloc>(context);
    final DateTime _startDate = startDate.subtract(Duration(days: 7));

    bloc.add(UserLeaveHoursEvent(status: UserLeaveHoursEventStatus.DO_ASYNC));
    bloc.add(UserLeaveHoursEvent(
        status: UserLeaveHoursEventStatus.FETCH_ALL,
        startDate: _startDate,
        isPlanning: isPlanning
    ));
  }

  _navWeekForward(BuildContext context) {
    final bloc = BlocProvider.of<UserLeaveHoursBloc>(context);
    final DateTime _startDate = startDate.add(Duration(days: 7));

    bloc.add(UserLeaveHoursEvent(status: UserLeaveHoursEventStatus.DO_ASYNC));
    bloc.add(UserLeaveHoursEvent(
        status: UserLeaveHoursEventStatus.FETCH_ALL,
        startDate: _startDate,
        isPlanning: isPlanning
    ));
  }

  _doDelete(BuildContext context, UserLeaveHours workHours) {
    final bloc = BlocProvider.of<UserLeaveHoursBloc>(context);

    bloc.add(UserLeaveHoursEvent(status: UserLeaveHoursEventStatus.DO_ASYNC));
    bloc.add(UserLeaveHoursEvent(
        status: UserLeaveHoursEventStatus.DELETE,
        pk: workHours.id,
        isPlanning: isPlanning
    ));
  }

  _doEdit(BuildContext context, UserLeaveHours workHours) {
    final bloc = BlocProvider.of<UserLeaveHoursBloc>(context);

    bloc.add(UserLeaveHoursEvent(status: UserLeaveHoursEventStatus.DO_ASYNC));
    bloc.add(UserLeaveHoursEvent(
        status: UserLeaveHoursEventStatus.FETCH_DETAIL,
        pk: workHours.id,
        isPlanning: isPlanning
    ));
  }

  _showDeleteDialog(BuildContext context, UserLeaveHours workHours) {
    showDeleteDialogWrapper(
        $trans('delete_dialog_title'),
        $trans('delete_dialog_content'),
      () => _doDelete(context, workHours),
      context
    );
  }
}
