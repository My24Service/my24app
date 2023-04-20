import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:my24app/core/widgets/widgets.dart';
import 'package:my24app/core/models/models.dart';
import 'package:my24app/company/models/leavehours/models.dart';
import 'package:my24app/company/blocs/leavehours_bloc.dart';
import '../list.dart';

class LeaveHoursUnacceptedListWidget extends UserLeaveHoursListWidget {
  final String basePath = "company.leavehours.unaccepted";
  final UserLeaveHoursPaginated leaveHoursPaginated;
  final PaginationInfo paginationInfo;
  final String memberPicture;
  final String searchQuery;

  LeaveHoursUnacceptedListWidget({
    Key key,
    @required this.leaveHoursPaginated,
    @required this.searchQuery,
    @required this.paginationInfo,
    @required this.memberPicture,
  }): super(
    key: key,
    leaveHoursPaginated: leaveHoursPaginated,
    paginationInfo: paginationInfo,
    searchQuery: searchQuery,
    isPlanning: true,
    memberPicture: memberPicture
  );

  @override
  List<Widget> getListButtons(BuildContext context, UserLeaveHours leaveHours) {
    List<Widget> buttons = [
      createDefaultElevatedButton(
          $trans('button_accept'),
          () => _showAcceptDialog(context, leaveHours)
      ),
      SizedBox(width: 10),
      createElevatedButtonColored(
          $trans('button_reject'),
          () => _showRejectDialog(context, leaveHours),
          foregroundColor: Colors.white,
          backgroundColor: Colors.red
      )
    ];

    return buttons;
  }

  Widget getBottomSection(BuildContext context) {
    return showPaginationSearchSection(
        context,
        paginationInfo,
        searchController,
        nextPage,
        previousPage,
        doSearch,
    );
  }

  doSearch(BuildContext context) {
    final bloc = BlocProvider.of<UserLeaveHoursBloc>(context);

    bloc.add(UserLeaveHoursEvent(status: UserLeaveHoursEventStatus.DO_ASYNC));
    bloc.add(UserLeaveHoursEvent(status: UserLeaveHoursEventStatus.DO_SEARCH));
    bloc.add(UserLeaveHoursEvent(
        status: UserLeaveHoursEventStatus.FETCH_UNACCEPTED,
        query: searchController.text,
        page: 1,
        isPlanning: isPlanning
    ));
  }

  // private methods
  _showAcceptDialog(BuildContext context, UserLeaveHours workHours) {
    showActionDialogWrapper(
        $trans('accept_dialog_title'),
        $trans('accept_dialog_content'),
        $trans('button_accept'),
        () => _doAccept(context, workHours),
        context
    );
  }

  _showRejectDialog(BuildContext context, UserLeaveHours workHours) {
    showActionDialogWrapper(
        $trans('reject_dialog_title'),
        $trans('reject_dialog_content'),
        $trans('button_reject'),
        () => _doReject(context, workHours),
        context
    );
  }

  void _doAccept(BuildContext context, UserLeaveHours leaveHours) {
    final UserLeaveHoursBloc bloc = BlocProvider.of<UserLeaveHoursBloc>(context);

    bloc.add(UserLeaveHoursEvent(status: UserLeaveHoursEventStatus.DO_ASYNC));
    bloc.add(UserLeaveHoursEvent(
        status: UserLeaveHoursEventStatus.ACCEPT,
        pk: leaveHours.id
    ));
  }

  void _doReject(BuildContext context, UserLeaveHours leaveHours) {
    final UserLeaveHoursBloc bloc = BlocProvider.of<UserLeaveHoursBloc>(context);

    bloc.add(UserLeaveHoursEvent(status: UserLeaveHoursEventStatus.DO_ASYNC));
    bloc.add(UserLeaveHoursEvent(
        status: UserLeaveHoursEventStatus.REJECT,
        pk: leaveHours.id
    ));
  }
}
