import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:my24_flutter_core/widgets/widgets.dart';
import 'package:my24app/company/blocs/leavehours_bloc.dart';
import 'package:my24_flutter_core/models/models.dart';

mixin UserLeaveHoursMixin {
  final PaginationInfo? paginationInfo = null;
  final String? searchQuery = null;
  final TextEditingController searchController = TextEditingController();
  final bool isPlanning = false;
  final Function transFunction = () {};

  Widget getBottomSection(BuildContext context) {
    return showPaginationSearchNewSection(
        context,
        paginationInfo,
        searchController,
        nextPage,
        previousPage,
        doSearch,
        handleNew,
        transFunction
    );
  }

  doRefresh(BuildContext context) {
    final bloc = BlocProvider.of<UserLeaveHoursBloc>(context);

    bloc.add(UserLeaveHoursEvent(status: UserLeaveHoursEventStatus.DO_ASYNC));
    bloc.add(UserLeaveHoursEvent(
        status: UserLeaveHoursEventStatus.FETCH_ALL,
        isPlanning: isPlanning
    ));
  }

  handleNew(BuildContext context) {
    final bloc = BlocProvider.of<UserLeaveHoursBloc>(context);

    bloc.add(UserLeaveHoursEvent(status: UserLeaveHoursEventStatus.DO_ASYNC));
    bloc.add(UserLeaveHoursEvent(
        status: UserLeaveHoursEventStatus.NEW,
        isPlanning: isPlanning
    ));
  }

  nextPage(BuildContext context) {
    final bloc = BlocProvider.of<UserLeaveHoursBloc>(context);

    bloc.add(UserLeaveHoursEvent(status: UserLeaveHoursEventStatus.DO_ASYNC));
    bloc.add(UserLeaveHoursEvent(
      status: UserLeaveHoursEventStatus.FETCH_ALL,
      page: paginationInfo!.currentPage! + 1,
      query: searchController.text,
      isPlanning: isPlanning
    ));
  }

  previousPage(BuildContext context) {
    final bloc = BlocProvider.of<UserLeaveHoursBloc>(context);

    bloc.add(UserLeaveHoursEvent(status: UserLeaveHoursEventStatus.DO_ASYNC));
    bloc.add(UserLeaveHoursEvent(
      status: UserLeaveHoursEventStatus.FETCH_ALL,
      page: paginationInfo!.currentPage! - 1,
      query: searchController.text,
      isPlanning: isPlanning
    ));
  }

  doSearch(BuildContext context) {
    final bloc = BlocProvider.of<UserLeaveHoursBloc>(context);

    bloc.add(UserLeaveHoursEvent(status: UserLeaveHoursEventStatus.DO_ASYNC));
    bloc.add(UserLeaveHoursEvent(status: UserLeaveHoursEventStatus.DO_SEARCH));
    bloc.add(UserLeaveHoursEvent(
        status: UserLeaveHoursEventStatus.FETCH_ALL,
        query: searchController.text,
        page: 1,
        isPlanning: isPlanning
    ));
  }
}
