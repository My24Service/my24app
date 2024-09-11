import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:my24_flutter_core/widgets/widgets.dart';
import 'package:my24_flutter_core/models/models.dart';

import 'package:my24app/mobile/blocs/material_bloc.dart';

mixin MaterialMixin {
  final int? assignedOrderId = 0;
  late final int? quotationId;
  final PaginationInfo? paginationInfo = null;
  final String? searchQuery = null;
  final TextEditingController searchController = TextEditingController();
  final CoreWidgets widgets = CoreWidgets();

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
    final bloc = BlocProvider.of<AssignedOrderMaterialBloc>(context);

    bloc.add(AssignedOrderMaterialEvent(status: AssignedOrderMaterialEventStatus.DO_ASYNC));
    bloc.add(AssignedOrderMaterialEvent(
        status: AssignedOrderMaterialEventStatus.FETCH_ALL,
        assignedOrderId: assignedOrderId
    ));
  }

  _handleNew(BuildContext context) {
    final bloc = BlocProvider.of<AssignedOrderMaterialBloc>(context);

    bloc.add(AssignedOrderMaterialEvent(
      status: AssignedOrderMaterialEventStatus.NEW,
      assignedOrderId: assignedOrderId,
      quotationId: quotationId
    ));
  }

  _nextPage(BuildContext context) {
    final bloc = BlocProvider.of<AssignedOrderMaterialBloc>(context);

    bloc.add(AssignedOrderMaterialEvent(status: AssignedOrderMaterialEventStatus.DO_ASYNC));
    bloc.add(AssignedOrderMaterialEvent(
      status: AssignedOrderMaterialEventStatus.FETCH_ALL,
      page: paginationInfo!.currentPage! + 1,
      query: searchController.text,
    ));
  }

  _previousPage(BuildContext context) {
    final bloc = BlocProvider.of<AssignedOrderMaterialBloc>(context);

    bloc.add(AssignedOrderMaterialEvent(status: AssignedOrderMaterialEventStatus.DO_ASYNC));
    bloc.add(AssignedOrderMaterialEvent(
      status: AssignedOrderMaterialEventStatus.FETCH_ALL,
      page: paginationInfo!.currentPage! - 1,
      query: searchController.text,
    ));
  }

  _doSearch(BuildContext context) {
    final bloc = BlocProvider.of<AssignedOrderMaterialBloc>(context);

    bloc.add(AssignedOrderMaterialEvent(status: AssignedOrderMaterialEventStatus.DO_ASYNC));
    bloc.add(AssignedOrderMaterialEvent(status: AssignedOrderMaterialEventStatus.DO_SEARCH));
    bloc.add(AssignedOrderMaterialEvent(
        status: AssignedOrderMaterialEventStatus.FETCH_ALL,
        query: searchController.text,
        page: 1
    ));
  }
}
