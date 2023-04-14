import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:my24app/core/widgets/widgets.dart';
import 'package:my24app/company/blocs/workhours_bloc.dart';
import 'package:my24app/core/i18n_mixin.dart';
import 'package:my24app/core/models/models.dart';


mixin UserWorkHoursMixin {
  final PaginationInfo paginationInfo = null;
  final String searchQuery = null;
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
        getTranslationTr('company.workhours.button_add', null)
    );
  }

  doRefresh(BuildContext context) {
    final bloc = BlocProvider.of<UserWorkHoursBloc>(context);

    bloc.add(UserWorkHoursEvent(status: UserWorkHoursEventStatus.DO_ASYNC));
    bloc.add(UserWorkHoursEvent(
        status: UserWorkHoursEventStatus.FETCH_ALL,
    ));
  }

  _handleNew(BuildContext context) {
    final bloc = BlocProvider.of<UserWorkHoursBloc>(context);

    bloc.add(UserWorkHoursEvent(
        status: UserWorkHoursEventStatus.NEW,
    ));
  }

  _nextPage(BuildContext context) {
    final bloc = BlocProvider.of<UserWorkHoursBloc>(context);

    bloc.add(UserWorkHoursEvent(status: UserWorkHoursEventStatus.DO_ASYNC));
    bloc.add(UserWorkHoursEvent(
      status: UserWorkHoursEventStatus.FETCH_ALL,
      page: paginationInfo.currentPage + 1,
      query: searchController.text,
    ));
  }

  _previousPage(BuildContext context) {
    final bloc = BlocProvider.of<UserWorkHoursBloc>(context);

    bloc.add(UserWorkHoursEvent(status: UserWorkHoursEventStatus.DO_ASYNC));
    bloc.add(UserWorkHoursEvent(
      status: UserWorkHoursEventStatus.FETCH_ALL,
      page: paginationInfo.currentPage - 1,
      query: searchController.text,
    ));
  }

  _doSearch(BuildContext context) {
    final bloc = BlocProvider.of<UserWorkHoursBloc>(context);

    bloc.add(UserWorkHoursEvent(status: UserWorkHoursEventStatus.DO_ASYNC));
    bloc.add(UserWorkHoursEvent(status: UserWorkHoursEventStatus.DO_SEARCH));
    bloc.add(UserWorkHoursEvent(
        status: UserWorkHoursEventStatus.FETCH_ALL,
        query: searchController.text,
        page: 1
    ));
  }
}
