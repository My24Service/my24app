import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:my24_flutter_core/widgets/widgets.dart';
import 'package:my24_flutter_core/models/models.dart';
import 'package:my24_flutter_core/widgets/slivers/base_widgets.dart';

import 'package:my24app/company/blocs/leave_type_bloc.dart';
import 'package:my24app/company/models/leave_type/models.dart';
import 'package:my24app/core/i18n_mixin.dart';
import 'mixins.dart';


class LeaveTypeListWidget extends BaseSliverListStatelessWidget with LeaveTypeMixin, i18nMixin {
  final String basePath = "company.leave_types";
  final LeaveTypes? leaveTypes;
  final PaginationInfo paginationInfo;
  final String? memberPicture;
  final String? searchQuery;
  final CoreWidgets widgetsIn;

  LeaveTypeListWidget({
    Key? key,
    required this.leaveTypes,
    required this.paginationInfo,
    required this.memberPicture,
    required this.searchQuery,
    required this.widgetsIn,
  }) : super(
      key: key,
      paginationInfo: paginationInfo,
      memberPicture: memberPicture,
      widgets: widgetsIn,
  ) {
    searchController.text = searchQuery?? '';
  }

  @override
  String getAppBarSubtitle(BuildContext context) {
    return $trans('app_bar_subtitle',
        namedArgs: {'count': "${leaveTypes!.count}"}
    );
  }

  @override
  SliverList getSliverList(BuildContext context) {
    return SliverList(
        delegate: SliverChildBuilderDelegate(
            (BuildContext context, int index) {
              LeaveType leaveType = leaveTypes!.results![index];

              final String nameString = leaveType.countsAsLeave! ? "${leaveType.name} ${$trans('info_counts_as_leave_list')}" : "${leaveType.name}";

              return Column(
                children: [
                  SizedBox(height: 10),
                  ...widgetsIn.buildItemListKeyValueList(
                      $trans('info_name'),
                      nameString
                  ),
                  SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      widgetsIn.createDeleteButton(
                        () { _showDeleteDialog(context, leaveType); }
                      ),
                      SizedBox(width: 8),
                      widgetsIn.createEditButton(
                        () { _doEdit(context, leaveType); }
                      )
                    ],
                  ),
                  if (index < leaveTypes!.results!.length-1)
                    widgetsIn.getMy24Divider(context)
                ],
              );
            },
            childCount: leaveTypes!.results!.length,
        )
    );
  }

  // private methods
  _doDelete(BuildContext context, LeaveType leaveType) {
    final bloc = BlocProvider.of<LeaveTypeBloc>(context);

    bloc.add(LeaveTypeEvent(status: LeaveTypeEventStatus.DO_ASYNC));
    bloc.add(LeaveTypeEvent(
        status: LeaveTypeEventStatus.DELETE,
        pk: leaveType.id,
    ));
  }

  _doEdit(BuildContext context, LeaveType leaveType) {
    final bloc = BlocProvider.of<LeaveTypeBloc>(context);

    bloc.add(LeaveTypeEvent(status: LeaveTypeEventStatus.DO_ASYNC));
    bloc.add(LeaveTypeEvent(
        status: LeaveTypeEventStatus.FETCH_DETAIL,
        pk: leaveType.id
    ));
  }

  _showDeleteDialog(BuildContext context, LeaveType leaveType) {
    widgetsIn.showDeleteDialogWrapper(
        $trans('delete_dialog_title'),
        $trans('delete_dialog_content'),
      () => _doDelete(context, leaveType),
      context
    );
  }
}
