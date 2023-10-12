import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my24app/order/blocs/document_bloc.dart';

import 'package:my24app/order/blocs/order_bloc.dart';
import 'package:my24app/order/blocs/order_states.dart';
import 'package:my24app/core/widgets/widgets.dart';
import 'package:my24app/core/models/models.dart';
import 'package:my24app/order/pages/page_meta_data_mixin.dart';
import 'package:my24app/order/pages/unaccepted.dart';
import 'package:my24app/core/i18n_mixin.dart';
import 'package:my24app/core/widgets/slivers/base_widgets.dart';
import 'package:my24app/order/models/order/models.dart';
import 'package:my24app/order/widgets/order/form.dart';
import 'documents.dart';

String? initialLoadMode;
int? loadId;

abstract class BaseOrderListPage extends StatelessWidget with i18nMixin, PageMetaData {
  final OrderEventStatus fetchMode = OrderEventStatus.FETCH_ALL;
  final String basePath = "orders.list";
  final OrderBloc bloc;

  BaseOrderListPage({
    Key? key,
    required this.bloc,
    String? initialMode,
    int? pk
  }) {
    if (initialMode != null) {
      initialLoadMode = initialMode;
      loadId = pk;
    }
  }

  OrderBloc _initialCall() {
    if (initialLoadMode == null) {
      bloc.add(OrderEvent(status: OrderEventStatus.DO_ASYNC));
      bloc.add(OrderEvent(status: fetchMode));
    } else if (initialLoadMode == 'form') {
      bloc.add(OrderEvent(status: OrderEventStatus.DO_ASYNC));
      bloc.add(OrderEvent(
          status: OrderEventStatus.FETCH_DETAIL,
          pk: loadId
      ));
    } else if (initialLoadMode == 'new') {
      bloc.add(OrderEvent(
          status: OrderEventStatus.NEW,
      ));
    }

    return bloc;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<OrderPageMetaData>(
        future: getOrderPageMetaData(context),
        builder: (ctx, snapshot) {
          if (snapshot.hasData) {
            final OrderPageMetaData? orderListData = snapshot.data;
            return BlocProvider(
                create: (context) => _initialCall(),
                child: BlocConsumer<OrderBloc, OrderState>(
                    listener: (context, state) {
                      _handleListener(context, state, orderListData);
                    },
                    builder: (context, state) {
                      return Scaffold(
                          drawer: orderListData!.drawer,
                          body: getBody(context, state, orderListData)
                      );
                    }
                )
            );
          } else if (snapshot.hasError) {
            return Center(
                child: Text("An error occurred (${snapshot.error})"));
          } else {
            return Scaffold(
                body: loadingNotice()
            );
          }
        }
    );
  }

  bool _isPlanning(OrderPageMetaData orderListData) {
    return orderListData.submodel == 'planning_user';
  }

  void _handleListener(BuildContext context, state, OrderPageMetaData? orderPageMetaData) async {
    final OrderBloc bloc = BlocProvider.of<OrderBloc>(context);

    if (state is OrderInsertedState) {
      createSnackBar(context, $trans('snackbar_added'));

      // ask if we want to add documents after insert
      await showDialog<void>(
          context: context,
          barrierDismissible: false, // user must tap button!
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text($trans('dialog_add_documents_title')),
              content: Text($trans('dialog_add_documents_content')),
              actions: <Widget>[
                TextButton(
                  child: Text($trans('dialog_add_documents_button_yes')),
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.pushReplacement(context,
                        MaterialPageRoute(
                            builder: (context) => OrderDocumentsPage(
                                orderId: state.order!.id,
                                bloc: OrderDocumentBloc(),
                            )
                        )
                    );
                  },
                ),
                TextButton(
                  child: Text($trans('dialog_add_documents_button_no')),
                  onPressed: () {
                    Navigator.of(context).pop();
                    if (_isPlanning(orderPageMetaData!) && !orderPageMetaData.hasBranches!) {
                      bloc.add(OrderEvent(status: OrderEventStatus.DO_ASYNC));
                      bloc.add(OrderEvent(status: OrderEventStatus.FETCH_ALL));
                    } else {
                      Navigator.pushReplacement(context,
                          MaterialPageRoute(builder: (context) => UnacceptedPage(bloc: OrderBloc()))
                      );
                    }
                  },
                ),
              ],
            );
          }
      );
    }

    if (state is OrderUpdatedState) {
      createSnackBar(context, $trans('snackbar_updated'));

      if (_isPlanning(orderPageMetaData!)) {
        bloc.add(OrderEvent(status: OrderEventStatus.DO_ASYNC));
        bloc.add(OrderEvent(status: OrderEventStatus.FETCH_ALL));
      } else {
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) => UnacceptedPage(bloc: OrderBloc()))
        );
      }
    }

    if (state is OrderErrorSnackbarState) {
      createSnackBar(context, $trans(
          'error_arg', pathOverride: 'generic', namedArgs: {'error': "${state.message}"}
      ));
    }

    if (state is OrderDeletedState) {
      createSnackBar(context, $trans('snackbar_deleted'));

      bloc.add(OrderEvent(status: OrderEventStatus.DO_ASYNC));
      bloc.add(OrderEvent(status: OrderEventStatus.FETCH_ALL));
    }

    if (state is OrderAcceptedState) {
      createSnackBar(context, $trans('snackbar_accepted'));

      bloc.add(OrderEvent(status: OrderEventStatus.DO_ASYNC));
      bloc.add(OrderEvent(status: OrderEventStatus.FETCH_ALL));
    }

    if (state is OrderRejectedState) {
      createSnackBar(context, $trans('snackbar_rejected'));

      bloc.add(OrderEvent(status: OrderEventStatus.DO_ASYNC));
      bloc.add(OrderEvent(status: OrderEventStatus.FETCH_ALL));
    }

    // if (state is AssignedMeState) {
    //   createSnackBar(context, $trans('snackbar_assigned'));
    //
    //   bloc.add(OrderEvent(status: OrderEventStatus.DO_ASYNC));
    //   bloc.add(OrderEvent(status: OrderEventStatus.FETCH_ALL));
    // }
  }

  BaseErrorWidget getErrorWidget(String? error, OrderPageMetaData? orderPageMetaData);
  BaseEmptyWidget getEmptyWidget(OrderPageMetaData? orderPageMetaData);
  BaseSliverListStatelessWidget getListWidget(
      List<Order>? orderList,
      OrderPageMetaData orderPageMetaData,
      PaginationInfo paginationInfo,
      OrderEventStatus fetchEvent,
      String? searchQuery
  );

  Widget getBody(context, state, OrderPageMetaData? orderPageMetaData) {
    if (state is OrderErrorState) {
      return getErrorWidget(state.message, orderPageMetaData);
    }

    if (state is OrdersLoadedState || state is OrdersUnassignedLoadedState || state is OrdersPastLoadedState ||
      state is OrdersSalesLoadedState || state is OrdersUnacceptedLoadedState) {
      if (state.orders.results.length == 0) {
        return getEmptyWidget(orderPageMetaData);
      }

      PaginationInfo paginationInfo = PaginationInfo(
          count: state.orders.count,
          next: state.orders.next,
          previous: state.orders.previous,
          currentPage: state.page != null ? state.page : 1,
          pageSize: orderPageMetaData!.pageSize
      );

      return getListWidget(state.orders.results, orderPageMetaData, paginationInfo, fetchMode, state.query);
    }

    if (state is OrderNewState) {
      return OrderFormWidget(
          formData: state.formData,
          orderPageMetaData: orderPageMetaData!,
          fetchEvent: fetchMode,
      );
    }

    if (state is OrderNewEquipmentCreatedState) {
      return OrderFormWidget(
        formData: state.formData,
        orderPageMetaData: orderPageMetaData!,
        fetchEvent: fetchMode,
      );
    }

    if (state is OrderNewLocationCreatedState) {
      return OrderFormWidget(
        formData: state.formData,
        orderPageMetaData: orderPageMetaData!,
        fetchEvent: fetchMode,
      );
    }

    if (state is OrderLoadedState) {
      return OrderFormWidget(
          formData: state.formData,
          orderPageMetaData: orderPageMetaData!,
          fetchEvent: fetchMode,
      );
    }

    return loadingNotice();
  }
}
