import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:my24_flutter_core/widgets/widgets.dart';
import 'package:my24_flutter_core/models/models.dart';

import 'package:my24app/mobile/blocs/document_bloc.dart';
import 'package:my24app/core/i18n_mixin.dart';

mixin DocumentMixin {
  final int? assignedOrderId = 0;
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
    final bloc = BlocProvider.of<DocumentBloc>(context);

    bloc.add(DocumentEvent(status: DocumentEventStatus.DO_ASYNC));
    bloc.add(DocumentEvent(
        status: DocumentEventStatus.FETCH_ALL,
        assignedOrderId: assignedOrderId
    ));
  }

  _handleNew(BuildContext context) {
    final bloc = BlocProvider.of<DocumentBloc>(context);

    bloc.add(DocumentEvent(
        status: DocumentEventStatus.NEW,
        assignedOrderId: assignedOrderId
    ));
  }

  _nextPage(BuildContext context) {
    final bloc = BlocProvider.of<DocumentBloc>(context);

    bloc.add(DocumentEvent(status: DocumentEventStatus.DO_ASYNC));
    bloc.add(DocumentEvent(
      status: DocumentEventStatus.FETCH_ALL,
      page: paginationInfo!.currentPage! + 1,
      query: searchController.text,
    ));
  }

  _previousPage(BuildContext context) {
    final bloc = BlocProvider.of<DocumentBloc>(context);

    bloc.add(DocumentEvent(status: DocumentEventStatus.DO_ASYNC));
    bloc.add(DocumentEvent(
      status: DocumentEventStatus.FETCH_ALL,
      page: paginationInfo!.currentPage! - 1,
      query: searchController.text,
    ));
  }

  _doSearch(BuildContext context) {
    final bloc = BlocProvider.of<DocumentBloc>(context);

    bloc.add(DocumentEvent(status: DocumentEventStatus.DO_ASYNC));
    bloc.add(DocumentEvent(status: DocumentEventStatus.DO_SEARCH));
    bloc.add(DocumentEvent(
        status: DocumentEventStatus.FETCH_ALL,
        query: searchController.text,
        page: 1
    ));
  }
}
