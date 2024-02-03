import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:my24_flutter_core/widgets/widgets.dart';
import 'package:my24app/customer/blocs/customer_bloc.dart';
import 'package:my24_flutter_core/models/models.dart';

mixin CustomerMixin {
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
    final bloc = BlocProvider.of<CustomerBloc>(context);

    bloc.add(CustomerEvent(status: CustomerEventStatus.DO_ASYNC));
    bloc.add(CustomerEvent(
        status: CustomerEventStatus.FETCH_ALL,
    ));
  }

  _handleNew(BuildContext context) {
    final bloc = BlocProvider.of<CustomerBloc>(context);

    bloc.add(CustomerEvent(
        status: CustomerEventStatus.NEW,
    ));
  }

  _nextPage(BuildContext context) {
    final bloc = BlocProvider.of<CustomerBloc>(context);

    bloc.add(CustomerEvent(status: CustomerEventStatus.DO_ASYNC));
    bloc.add(CustomerEvent(
      status: CustomerEventStatus.FETCH_ALL,
      page: paginationInfo!.currentPage! + 1,
      query: searchController.text,
    ));
  }

  _previousPage(BuildContext context) {
    final bloc = BlocProvider.of<CustomerBloc>(context);

    bloc.add(CustomerEvent(status: CustomerEventStatus.DO_ASYNC));
    bloc.add(CustomerEvent(
      status: CustomerEventStatus.FETCH_ALL,
      page: paginationInfo!.currentPage! - 1,
      query: searchController.text,
    ));
  }

  _doSearch(BuildContext context) {
    final bloc = BlocProvider.of<CustomerBloc>(context);

    bloc.add(CustomerEvent(status: CustomerEventStatus.DO_ASYNC));
    bloc.add(CustomerEvent(status: CustomerEventStatus.DO_SEARCH));
    bloc.add(CustomerEvent(
        status: CustomerEventStatus.FETCH_ALL,
        query: searchController.text,
        page: 1
    ));
  }
}
