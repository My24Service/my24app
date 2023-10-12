import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:my24app/core/widgets/widgets.dart';
import 'package:my24app/company/blocs/leave_type_bloc.dart';
import 'package:my24app/core/models/models.dart';

mixin LeaveTypeMixin {
  final PaginationInfo? paginationInfo = null;
  final String? searchQuery = null;
  final TextEditingController searchController = TextEditingController();

  Widget getBottomSection(BuildContext context) {
    return showPaginationSearchNewSection(
        context,
        paginationInfo,
        searchController,
        _nextPage,
        _previousPage,
        _doSearch,
        _handleNew,
    );
  }

  doRefresh(BuildContext context) {
    final bloc = BlocProvider.of<LeaveTypeBloc>(context);

    bloc.add(LeaveTypeEvent(status: LeaveTypeEventStatus.DO_ASYNC));
    bloc.add(LeaveTypeEvent(
        status: LeaveTypeEventStatus.FETCH_ALL,
    ));
  }

  _handleNew(BuildContext context) {
    final bloc = BlocProvider.of<LeaveTypeBloc>(context);

    bloc.add(LeaveTypeEvent(
        status: LeaveTypeEventStatus.NEW,
    ));
  }

  _nextPage(BuildContext context) {
    final bloc = BlocProvider.of<LeaveTypeBloc>(context);

    bloc.add(LeaveTypeEvent(status: LeaveTypeEventStatus.DO_ASYNC));
    bloc.add(LeaveTypeEvent(
      status: LeaveTypeEventStatus.FETCH_ALL,
      page: paginationInfo!.currentPage! + 1,
      query: searchController.text,
    ));
  }

  _previousPage(BuildContext context) {
    final bloc = BlocProvider.of<LeaveTypeBloc>(context);

    bloc.add(LeaveTypeEvent(status: LeaveTypeEventStatus.DO_ASYNC));
    bloc.add(LeaveTypeEvent(
      status: LeaveTypeEventStatus.FETCH_ALL,
      page: paginationInfo!.currentPage! - 1,
      query: searchController.text,
    ));
  }

  _doSearch(BuildContext context) {
    final bloc = BlocProvider.of<LeaveTypeBloc>(context);

    bloc.add(LeaveTypeEvent(status: LeaveTypeEventStatus.DO_ASYNC));
    bloc.add(LeaveTypeEvent(status: LeaveTypeEventStatus.DO_SEARCH));
    bloc.add(LeaveTypeEvent(
        status: LeaveTypeEventStatus.FETCH_ALL,
        query: searchController.text,
        page: 1
    ));
  }
}
