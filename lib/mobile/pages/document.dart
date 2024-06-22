import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my24_flutter_core/utils.dart';

import 'package:my24_flutter_core/widgets/widgets.dart';
import 'package:my24_flutter_core/i18n.dart';
import 'package:my24_flutter_core/models/models.dart';

import 'package:my24app/mobile/blocs/document_bloc.dart';
import 'package:my24app/mobile/blocs/document_states.dart';
import 'package:my24app/mobile/widgets/document/form.dart';
import 'package:my24app/mobile/widgets/document/list.dart';
import 'package:my24app/mobile/widgets/document/error.dart';

String? initialLoadMode;
int? loadId;

class DocumentPage extends StatelessWidget{
  final int? assignedOrderId;
  final i18n = My24i18n(basePath: "assigned_orders.documents");
  final DocumentBloc bloc;
  final CoreWidgets widgets = CoreWidgets();

  DocumentPage({
    Key? key,
    required this.assignedOrderId,
    required this.bloc,
    String? initialMode,
    int? pk
  }) : super(key: key) {
    if (initialMode != null) {
      initialLoadMode = initialMode;
      loadId = pk;
    }
  }

  Future<DefaultPageData> getPageData() async {
    String? memberPicture = await coreUtils.getMemberPicture();

    DefaultPageData result = DefaultPageData(
      memberPicture: memberPicture,
    );

    return result;
  }

  DocumentBloc _initialBlocCall() {
    if (initialLoadMode == null) {
      bloc.add(DocumentEvent(status: DocumentEventStatus.DO_ASYNC));
      bloc.add(DocumentEvent(
          status: DocumentEventStatus.FETCH_ALL,
          assignedOrderId: assignedOrderId
      ));
    } else if (initialLoadMode == 'form') {
      bloc.add(DocumentEvent(status: DocumentEventStatus.DO_ASYNC));
      bloc.add(DocumentEvent(
          status: DocumentEventStatus.FETCH_DETAIL,
          pk: loadId
      ));
    } else if (initialLoadMode == 'new') {
      bloc.add(DocumentEvent(
          status: DocumentEventStatus.NEW,
          assignedOrderId: assignedOrderId
      ));
    }

    return bloc;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DefaultPageData>(
        future: getPageData(),
        builder: (ctx, snapshot) {
          if (snapshot.hasData) {
            DefaultPageData? pageData = snapshot.data;

            return BlocProvider<DocumentBloc>(
              create: (context) => _initialBlocCall(),
              child: BlocConsumer<DocumentBloc, DocumentState>(
                  listener: (context, state) {
                    _handleListeners(context, state);
                  },
                  builder: (context, state) {
                    return Scaffold(
                        body: _getBody(context, state, pageData),
                    );
                  }
              )
          );
          } else if (snapshot.hasError) {
            return Center(
                child: Text(
                    i18n.$trans("error_arg", pathOverride: "generic",
                        namedArgs: {"error": "${snapshot.error}"}
                    )
                )
            );
          } else {
            return Scaffold(
                body: widgets.loadingNotice()
            );
          }
        }
    );
  }

  void _handleListeners(BuildContext context, state) {
    final bloc = BlocProvider.of<DocumentBloc>(context);

    if (state is DocumentInsertedState) {
      widgets.createSnackBar(context, i18n.$trans('snackbar_added'));

      bloc.add(DocumentEvent(
          status: DocumentEventStatus.FETCH_ALL,
          assignedOrderId: assignedOrderId
      ));
    }

    if (state is DocumentUpdatedState) {
      widgets.createSnackBar(context, i18n.$trans('snackbar_updated'));

      bloc.add(DocumentEvent(
          status: DocumentEventStatus.FETCH_ALL,
          assignedOrderId: assignedOrderId
      ));
    }

    if (state is DocumentDeletedState) {
      widgets.createSnackBar(context, i18n.$trans('snackbar_deleted'));

      bloc.add(DocumentEvent(
          status: DocumentEventStatus.FETCH_ALL,
          assignedOrderId: assignedOrderId
      ));
    }

    if (state is DocumentsLoadedState && state.query == null &&
        state.documents!.results!.length == 0) {
      bloc.add(DocumentEvent(
          status: DocumentEventStatus.NEW_EMPTY,
          assignedOrderId: assignedOrderId
      ));
    }
  }

  Widget _getBody(context, state, DefaultPageData? pageData) {
    if (state is DocumentInitialState) {
      return widgets.loadingNotice();
    }

    if (state is DocumentLoadingState) {
      return widgets.loadingNotice();
    }

    if (state is DocumentErrorState) {
      return DocumentListErrorWidget(
        error: state.message,
        memberPicture: pageData!.memberPicture,
        widgetsIn: widgets,
        i18nIn: i18n,
      );
    }

    if (state is DocumentsLoadedState) {
      PaginationInfo paginationInfo = PaginationInfo(
          count: state.documents!.count,
          next: state.documents!.next,
          previous: state.documents!.previous,
          currentPage: state.page != null ? state.page : 1,
          pageSize: 20
      );

      return DocumentListWidget(
        documents: state.documents,
        assignedOrderId: assignedOrderId,
        paginationInfo: paginationInfo,
        memberPicture: pageData!.memberPicture,
        searchQuery: state.query,
        widgetsIn: widgets,
        i18nIn: i18n,
      );
    }

    if (state is DocumentLoadedState) {
      return DocumentFormWidget(
        formData: state.documentFormData,
        assignedOrderId: assignedOrderId,
        memberPicture: pageData!.memberPicture,
        newFromEmpty: false,
        widgetsIn: widgets,
        i18nIn: i18n,
      );
    }

    if (state is DocumentNewState) {
      return DocumentFormWidget(
        formData: state.documentFormData,
        assignedOrderId: assignedOrderId,
        memberPicture: pageData!.memberPicture,
        newFromEmpty: state.fromEmpty,
        widgetsIn: widgets,
        i18nIn: i18n,
      );
    }

    return widgets.loadingNotice();
  }
}
