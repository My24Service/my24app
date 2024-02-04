import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:my24_flutter_core/widgets/widgets.dart';
import 'package:my24_flutter_core/models/models.dart';

import 'package:my24app/order/blocs/document_bloc.dart';
import 'package:my24app/core/i18n_mixin.dart';

mixin OrderDocumentMixin {
  final int? orderId = 0;
  final PaginationInfo? paginationInfo = null;
  final String? searchQuery = null;
  final TextEditingController searchController = TextEditingController();
  final CoreWidgets widgets = CoreWidgets($trans: getTranslationTr);

  Widget getBottomSection(BuildContext context) {
    return widgets.showPaginationSearchNewSection(
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
    final bloc = BlocProvider.of<OrderDocumentBloc>(context);

    bloc.add(OrderDocumentEvent(status: OrderDocumentEventStatus.DO_ASYNC));
    bloc.add(OrderDocumentEvent(
        status: OrderDocumentEventStatus.FETCH_ALL,
        orderId: orderId
    ));
  }

  handleNew(BuildContext context) {
    final bloc = BlocProvider.of<OrderDocumentBloc>(context);

    bloc.add(OrderDocumentEvent(
        status: OrderDocumentEventStatus.NEW,
        orderId: orderId
    ));
  }

  _handleNew(BuildContext context) {
    final bloc = BlocProvider.of<OrderDocumentBloc>(context);

    bloc.add(OrderDocumentEvent(
      status: OrderDocumentEventStatus.NEW,
      orderId: orderId
    ));
  }

  _nextPage(BuildContext context) {
    final bloc = BlocProvider.of<OrderDocumentBloc>(context);

    bloc.add(OrderDocumentEvent(status: OrderDocumentEventStatus.DO_ASYNC));
    bloc.add(OrderDocumentEvent(
      status: OrderDocumentEventStatus.FETCH_ALL,
      page: paginationInfo!.currentPage! + 1,
      query: searchController.text,
    ));
  }

  _previousPage(BuildContext context) {
    final bloc = BlocProvider.of<OrderDocumentBloc>(context);

    bloc.add(OrderDocumentEvent(status: OrderDocumentEventStatus.DO_ASYNC));
    bloc.add(OrderDocumentEvent(
      status: OrderDocumentEventStatus.FETCH_ALL,
      page: paginationInfo!.currentPage! - 1,
      query: searchController.text,
    ));
  }

  _doSearch(BuildContext context) {
    final bloc = BlocProvider.of<OrderDocumentBloc>(context);

    bloc.add(OrderDocumentEvent(status: OrderDocumentEventStatus.DO_ASYNC));
    bloc.add(OrderDocumentEvent(status: OrderDocumentEventStatus.DO_SEARCH));
    bloc.add(OrderDocumentEvent(
        status: OrderDocumentEventStatus.FETCH_ALL,
        query: searchController.text,
        page: 1,
        orderId: orderId
    ));
  }
}
