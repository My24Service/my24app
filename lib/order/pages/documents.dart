import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:my24app/order/blocs/document_bloc.dart';
import 'package:my24app/order/blocs/document_states.dart';
import 'package:my24app/core/widgets/widgets.dart';
import 'package:my24app/core/i18n_mixin.dart';
import 'package:my24app/core/models/models.dart';
import 'package:my24app/order/widgets/document/error.dart';
import 'package:my24app/order/widgets/document/form.dart';
import 'package:my24app/order/widgets/document/list.dart';
import 'package:my24app/core/utils.dart';

String? initialLoadMode;
int? loadId;

class OrderDocumentsPage extends StatelessWidget with i18nMixin {
  final int? orderId;
  final String basePath = "orders.documents";
  final OrderDocumentBloc bloc;
  final Utils utils = Utils();

  OrderDocumentsPage({
    Key? key,
    required this.orderId,
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
    String? memberPicture = await this.utils.getMemberPicture();

    DefaultPageData result = DefaultPageData(
      memberPicture: memberPicture,
    );

    return result;
  }

  OrderDocumentBloc _initialBlocCall() {
    if (initialLoadMode == null) {
      bloc.add(OrderDocumentEvent(status: OrderDocumentEventStatus.DO_ASYNC));
      bloc.add(OrderDocumentEvent(
          status: OrderDocumentEventStatus.FETCH_ALL,
          orderId: orderId
      ));
    } else if (initialLoadMode == 'form') {
      bloc.add(OrderDocumentEvent(status: OrderDocumentEventStatus.DO_ASYNC));
      bloc.add(OrderDocumentEvent(
          status: OrderDocumentEventStatus.FETCH_DETAIL,
          pk: loadId
      ));
    } else if (initialLoadMode == 'new') {
      bloc.add(OrderDocumentEvent(
          status: OrderDocumentEventStatus.NEW,
          orderId: orderId
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
                            child: _getBody(context, state, pageData),
                          )
                      );
                    }
                )
            );
          } else if (snapshot.hasError) {
            return Center(
                child: Text(
                    $trans("error_arg", pathOverride: "generic",
                        namedArgs: {"error": "${snapshot.error}"}
                    )
                )
            );
          } else {
            return Scaffold(
                body: loadingNotice()
            );
          }
        }
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

    if (state is OrderDocumentsLoadedState && state.query == null &&
        state.documents!.results!.length == 0) {
      bloc.add(OrderDocumentEvent(
          status: OrderDocumentEventStatus.NEW_EMPTY,
          orderId: orderId
      ));
    }
  }

  Widget _getBody(context, state, DefaultPageData? pageData) {
    if (state is OrderDocumentInitialState) {
      return loadingNotice();
    }

    if (state is OrderDocumentLoadingState) {
      return loadingNotice();
    }

    if (state is OrderDocumentErrorState) {
      return OrderDocumentListErrorWidget(
        error: state.message,
        orderId: orderId,
        memberPicture: pageData!.memberPicture
      );
    }

    if (state is OrderDocumentsLoadedState) {
      PaginationInfo paginationInfo = PaginationInfo(
          count: state.documents!.count,
          next: state.documents!.next,
          previous: state.documents!.previous,
          currentPage: state.page != null ? state.page : 1,
          pageSize: 20
      );

      return OrderDocumentListWidget(
        orderDocuments: state.documents,
        orderId: orderId,
        paginationInfo: paginationInfo,
        memberPicture: pageData!.memberPicture,
        searchQuery: state.query,
      );
    }

    if (state is OrderDocumentLoadedState) {
      return OrderDocumentFormWidget(
          formData: state.documentFormData,
          orderId: orderId,
          memberPicture: pageData!.memberPicture,
          newFromEmpty: false,
      );
    }

    if (state is OrderDocumentNewState) {
      return OrderDocumentFormWidget(
          formData: state.documentFormData,
          orderId: orderId,
          memberPicture: pageData!.memberPicture,
          newFromEmpty: state.fromEmpty,
      );
    }

    return loadingNotice();
  }
}
