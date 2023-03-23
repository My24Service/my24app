import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:my24app/order/blocs/document_bloc.dart';
import 'package:my24app/order/blocs/document_states.dart';
import 'package:my24app/core/widgets/widgets.dart';

import 'package:my24app/core/i18n_mixin.dart';
import 'package:my24app/core/models/models.dart';
import 'package:my24app/order/widgets/document/empty.dart';
import 'package:my24app/order/widgets/document/error.dart';
import 'package:my24app/order/widgets/document/form.dart';
import 'package:my24app/order/widgets/document/list.dart';


class OrderDocumentsPage extends StatelessWidget with i18nMixin {
  final int orderId;
  final String basePath = "orders.documents";

  OrderDocumentsPage({
    Key key,
    this.orderId
  }) : super(key: key);

  OrderDocumentBloc _initialBlocCall() {
    OrderDocumentBloc bloc = OrderDocumentBloc();

    bloc.add(OrderDocumentEvent(status: OrderDocumentEventStatus.DO_ASYNC));
    bloc.add(OrderDocumentEvent(
        status: OrderDocumentEventStatus.FETCH_ALL,
        orderId: orderId
    ));

    return bloc;
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<OrderDocumentBloc>(
        create: (context) => _initialBlocCall(),
        child: BlocConsumer<OrderDocumentBloc, OrderDocumentState>(
            listener: (context, state) {
              _handleListeners(context, state);
            },
            builder: (context, state) {
              return Scaffold(
                  body: GestureDetector(
                    onTap: () {
                      FocusScope.of(context).requestFocus(FocusNode());
                    },
                    child: _getBody(context, state),
                  )
              );
            }
        )
    );
  }

  void _handleListeners(BuildContext context, state) {
    final bloc = BlocProvider.of<OrderDocumentBloc>(context);

    if (state is OrderDocumentInsertedState) {
      createSnackBar(context, $trans('snackbar_added'));

      bloc.add(OrderDocumentEvent(
          status: OrderDocumentEventStatus.FETCH_ALL,
          orderId: orderId
      ));
    }

    if (state is OrderDocumentUpdatedState) {
      createSnackBar(context, $trans('snackbar_updated'));

      bloc.add(OrderDocumentEvent(
          status: OrderDocumentEventStatus.FETCH_ALL,
          orderId: orderId
      ));
    }

    if (state is OrderDocumentDeletedState) {
      createSnackBar(context, $trans('snackbar_deleted'));

      bloc.add(OrderDocumentEvent(
          status: OrderDocumentEventStatus.FETCH_ALL,
          orderId: orderId
      ));
    }
  }

  Widget _getBody(context, state) {
    if (state is OrderDocumentInitialState) {
      return loadingNotice();
    }

    if (state is OrderDocumentLoadingState) {
      return loadingNotice();
    }

    if (state is OrderDocumentErrorState) {
      return OrderDocumentListErrorWidget(
        error: state.message,
      );
    }

    if (state is OrderDocumentsLoadedState) {
      if (state.documents.results.length == 0) {
        return OrderDocumentListEmptyWidget();
      }

      PaginationInfo paginationInfo = PaginationInfo(
          count: state.documents.count,
          next: state.documents.next,
          previous: state.documents.previous,
          currentPage: state.page != null ? state.page : 1,
          pageSize: 20
      );

      return OrderDocumentListWidget(
        orderDocuments: state.documents,
        orderId: orderId,
        paginationInfo: paginationInfo,
      );
    }

    if (state is OrderDocumentLoadedState) {
      return OrderDocumentFormWidget(
          formData: state.documentFormData,
          orderId: orderId
      );
    }

    if (state is OrderDocumentNewState) {
      return OrderDocumentFormWidget(
          formData: state.documentFormData,
          orderId: orderId
      );
    }

    return loadingNotice();
  }
}
