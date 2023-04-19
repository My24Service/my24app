import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:my24app/core/widgets/widgets.dart';
import 'package:my24app/company/blocs/leavehours_bloc.dart';
import 'package:my24app/core/i18n_mixin.dart';
import 'package:my24app/core/models/models.dart';


mixin UserLeaveHoursMixin {
  final PaginationInfo paginationInfo = null;
  final String searchQuery = null;
  final TextEditingController searchController = TextEditingController();
  final bool isPlanning = false;

  Widget getBottomSection(BuildContext context) {
    return showPaginationSearchNewSection(
        context,
        paginationInfo,
        searchController,
        _nextPage,
        _previousPage,
        _doSearch,
        _handleNew,
        getTranslationTr('company.leavehours.button_add', null)
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

  _handleNew(BuildContext context) {
    final bloc = BlocProvider.of<UserLeaveHoursBloc>(context);

    bloc.add(UserLeaveHoursEvent(status: UserLeaveHoursEventStatus.DO_ASYNC));
    bloc.add(UserLeaveHoursEvent(
        status: UserLeaveHoursEventStatus.NEW,
        isPlanning: isPlanning
    ));
  }

  _nextPage(BuildContext context) {
    final bloc = BlocProvider.of<UserLeaveHoursBloc>(context);

    bloc.add(UserLeaveHoursEvent(status: UserLeaveHoursEventStatus.DO_ASYNC));
    bloc.add(UserLeaveHoursEvent(
      status: UserLeaveHoursEventStatus.FETCH_ALL,
      page: paginationInfo.currentPage + 1,
      query: searchController.text,
      isPlanning: isPlanning
    ));
  }

  _previousPage(BuildContext context) {
    final bloc = BlocProvider.of<UserLeaveHoursBloc>(context);

    bloc.add(UserLeaveHoursEvent(status: UserLeaveHoursEventStatus.DO_ASYNC));
    bloc.add(UserLeaveHoursEvent(
      status: UserLeaveHoursEventStatus.FETCH_ALL,
      page: paginationInfo.currentPage - 1,
      query: searchController.text,
      isPlanning: isPlanning
    ));
  }

  _doSearch(BuildContext context) {
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
