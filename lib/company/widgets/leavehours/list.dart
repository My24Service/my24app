import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:my24_flutter_core/widgets/widgets.dart';
import 'package:my24_flutter_core/i18n.dart';
import 'package:my24_flutter_core/models/models.dart';
import 'package:my24_flutter_core/widgets/slivers/base_widgets.dart';

import 'package:my24app/company/blocs/leavehours_bloc.dart';
import 'package:my24app/company/models/leavehours/models.dart';
import 'mixins.dart';


class UserLeaveHoursListWidget extends BaseSliverListStatelessWidget with UserLeaveHoursMixin{
  final UserLeaveHoursPaginated? leaveHoursPaginated;
  final PaginationInfo paginationInfo;
  final String? memberPicture;
  final String? searchQuery;
  final bool isPlanning;
  final CoreWidgets widgetsIn;
  final My24i18n i18nIn;
  
  UserLeaveHoursListWidget({
    Key? key,
    required this.leaveHoursPaginated,
    required this.paginationInfo,
    required this.memberPicture,
    required this.searchQuery,
    required this.isPlanning,
    required this.widgetsIn,
    required this.i18nIn,
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
        namedArgs: {'count': "${leaveHoursPaginated!.count}"}
    );
  }

  @override
  SliverList getSliverList(BuildContext context) {
    return SliverList(
        delegate: SliverChildBuilderDelegate(
            (BuildContext context, int index) {
              UserLeaveHours leaveHours = leaveHoursPaginated!.results![index];

              List<Widget> items = [];
              String? leaveType = leaveHours.leaveTypeName;

              if (isPlanning) {
                items.addAll(widgetsIn.buildItemListKeyValueList(
                    i18nIn.$trans('info_user'),
                    "${leaveHours.fullName}"
                ));
              }

              final String totalMinutes = leaveHours.totalMinutes! < 10 ? "0${leaveHours.totalMinutes}" : "${leaveHours.totalMinutes}";
              if (leaveHours.startDate == leaveHours.endDate) {
                items.addAll(widgetsIn.buildItemListKeyValueList(
                    i18nIn.$trans('info_date_hours'),
                    "${leaveHours.startDate} / ${leaveHours.totalHours}:$totalMinutes"
                ));
              } else {
                items.addAll(widgetsIn.buildItemListKeyValueList(
                    i18nIn.$trans('info_date_hours'),
                    "${leaveHours.startDate} - ${leaveHours.endDate} / ${leaveHours.totalHours}:$totalMinutes"
                ));
              }

              items.addAll(widgetsIn.buildItemListKeyValueList(
                  i18nIn.$trans('info_leave_type'),
                  leaveType
              ));

              items.addAll(widgetsIn.buildItemListKeyValueList(
                  i18nIn.$trans('info_last_status'),
                  leaveHours.lastStatusFull
              ));

              return Column(
                children: [
                  ...items,
                  SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: getListButtons(context, leaveHours),
                  ),
                  if (index < leaveHoursPaginated!.results!.length-1)
                    widgetsIn.getMy24Divider(context)
                ],
              );
            },
            childCount: leaveHoursPaginated!.results!.length,
        )
    );
  }

  // private methods
  List<Widget> getListButtons(BuildContext context, UserLeaveHours leaveHours) {
    List<Widget> buttons = [];
    if (isPlanning || (!isPlanning && (!leaveHours.isAccepted! && !leaveHours.isRejected!))) {
      buttons = [
        widgetsIn.createDeleteButton(
            () { _showDeleteDialog(context, leaveHours); }
        ),
        SizedBox(width: 8),
        widgetsIn.createEditButton(
          () => { _doEdit(context, leaveHours) }
        )
      ];
    }

    return buttons;
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
    widgetsIn.showDeleteDialogWrapper(
        i18nIn.$trans('delete_dialog_title'),
        i18nIn.$trans('delete_dialog_content'),
      () => _doDelete(context, workHours),
      context
    );
  }
}
