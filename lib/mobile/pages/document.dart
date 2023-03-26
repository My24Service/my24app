import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:my24app/core/widgets/widgets.dart';
import 'package:my24app/mobile/blocs/document_bloc.dart';
import 'package:my24app/mobile/blocs/document_states.dart';
import 'package:my24app/mobile/widgets/document/form.dart';
import 'package:my24app/mobile/widgets/document/list.dart';
import 'package:my24app/core/i18n_mixin.dart';
import 'package:my24app/core/models/models.dart';
import 'package:my24app/mobile/widgets/document/empty.dart';
import 'package:my24app/mobile/widgets/document/error.dart';


class DocumentPage extends StatelessWidget with i18nMixin {
  final int assignedOrderId;
  final String basePath = "assigned_orders.documents";

  DocumentPage({
    Key key,
    this.assignedOrderId
  }) : super(key: key);

  DocumentBloc _initialBlocCall() {
    DocumentBloc bloc = DocumentBloc();

    bloc.add(DocumentEvent(status: DocumentEventStatus.DO_ASYNC));
    bloc.add(DocumentEvent(
        status: DocumentEventStatus.FETCH_ALL,
        assignedOrderId: assignedOrderId
    ));

    return bloc;
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<DocumentBloc>(
        create: (context) => _initialBlocCall(),
        child: BlocConsumer<DocumentBloc, DocumentState>(
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
    final bloc = BlocProvider.of<DocumentBloc>(context);

    if (state is DocumentInsertedState) {
      createSnackBar(context, $trans('snackbar_added'));

      bloc.add(DocumentEvent(
          status: DocumentEventStatus.FETCH_ALL,
          assignedOrderId: assignedOrderId
      ));
    }

    if (state is DocumentUpdatedState) {
      createSnackBar(context, $trans('snackbar_updated'));

      bloc.add(DocumentEvent(
          status: DocumentEventStatus.FETCH_ALL,
          assignedOrderId: assignedOrderId
      ));
    }

    if (state is DocumentDeletedState) {
      createSnackBar(context, $trans('snackbar_deleted'));

      bloc.add(DocumentEvent(
          status: DocumentEventStatus.FETCH_ALL,
          assignedOrderId: assignedOrderId
      ));
    }
  }

  Widget _getBody(context, state) {
    if (state is DocumentInitialState) {
      return loadingNotice();
    }

    if (state is DocumentLoadingState) {
      return loadingNotice();
    }

    if (state is DocumentErrorState) {
      return DocumentListErrorWidget(
        error: state.message,
      );
    }

    if (state is DocumentsLoadedState) {
      if (state.documents.results.length == 0) {
        return DocumentListEmptyWidget();
      }

      PaginationInfo paginationInfo = PaginationInfo(
          count: state.documents.count,
          next: state.documents.next,
          previous: state.documents.previous,
          currentPage: state.page != null ? state.page : 1,
          pageSize: 20
      );

      return DocumentListWidget(
        documents: state.documents,
        assignedOrderId: assignedOrderId,
        paginationInfo: paginationInfo,
      );
    }

    if (state is DocumentLoadedState) {
      return DocumentFormWidget(
          formData: state.documentFormData,
          assignedOrderId: assignedOrderId
      );
    }

    if (state is DocumentNewState) {
      return DocumentFormWidget(
          formData: state.documentFormData,
          assignedOrderId: assignedOrderId
      );
    }

    return loadingNotice();
  }
}
