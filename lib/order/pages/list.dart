import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:my24app/core/utils.dart';
import 'package:my24app/order/blocs/order_bloc.dart';
import 'package:my24app/order/blocs/order_states.dart';
import 'package:my24app/core/widgets/widgets.dart';
import 'package:my24app/core/models/models.dart';
import 'package:my24app/order/pages/unaccepted.dart';
import 'package:my24app/order/widgets/order/list.dart';
import 'package:my24app/order/widgets/order/error.dart';
import 'package:my24app/order/widgets/order/empty.dart';
import 'package:my24app/order/widgets/order/form.dart';
import 'package:my24app/core/i18n_mixin.dart';
import 'documents.dart';

class OrderListPage extends StatelessWidget with i18nMixin {
  final String basePath = "orders.list";

  OrderBloc _initialCall() {
    OrderBloc bloc = OrderBloc();

    bloc.add(OrderEvent(status: OrderEventStatus.DO_ASYNC));
    bloc.add(OrderEvent(
        status: OrderEventStatus.FETCH_ALL));

    return bloc;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<OrderPageMetaData>(
        future: utils.getOrderPageMetaData(context),
        builder: (ctx, snapshot) {
          if (snapshot.hasData) {
            final OrderPageMetaData orderListData = snapshot.data;
            return BlocProvider(
                create: (context) => _initialCall(),
                child: BlocConsumer<OrderBloc, OrderState>(
                    listener: (context, state) {
                      _handleListener(context, state, orderListData);
                    },
                    builder: (context, state) {
                      return Scaffold(
                          drawer: orderListData.drawer,
                          body: GestureDetector(
                            onTap: () {
                              FocusScope.of(context).requestFocus(FocusNode());
                            },
                            child: _getBody(context, state, orderListData)
                          )
                      );
                    }
                )
            );
          } else if (snapshot.hasError) {
            return Center(
                child: Text("An error occurred (${snapshot.error})"));
          } else {
            return loadingNotice();
          }
        }
    );
  }

  bool _isPlanning(OrderPageMetaData orderListData) {
    return orderListData.submodel == 'planning_user';
  }

  void _handleListener(BuildContext context, state, OrderPageMetaData orderListData) async {
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
                            builder: (context) => OrderDocumentsPage(orderPk: state.order.id)
                        )
                    );
                  },
                ),
                TextButton(
                  child: Text($trans('dialog_add_documents_button_no')),
                  onPressed: () {
                    Navigator.of(context).pop();
                    if (_isPlanning(orderListData)) {
                      bloc.add(OrderEvent(status: OrderEventStatus.DO_ASYNC));
                      bloc.add(OrderEvent(status: OrderEventStatus.FETCH_ALL));
                    } else {
                      Navigator.pushReplacement(context,
                          MaterialPageRoute(builder: (context) => UnacceptedPage())
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

      if (_isPlanning(orderListData)) {
        bloc.add(OrderEvent(status: OrderEventStatus.DO_ASYNC));
        bloc.add(OrderEvent(status: OrderEventStatus.FETCH_ALL));
      } else {
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) => UnacceptedPage())
        );
      }
    }

    if (state is OrderDeletedState) {
      createSnackBar(context, 'orders.snackbar_deleted'.tr());

      bloc.add(OrderEvent(status: OrderEventStatus.DO_ASYNC));
      bloc.add(OrderEvent(status: OrderEventStatus.FETCH_ALL));
    }

    if (state is OrderAcceptedState) {
      createSnackBar(context, 'orders.snackbar_accepted'.tr());

      bloc.add(OrderEvent(status: OrderEventStatus.DO_ASYNC));
      bloc.add(OrderEvent(status: OrderEventStatus.FETCH_ALL));
    }

    if (state is OrderRejectedState) {
      createSnackBar(context, 'orders.snackbar_rejected'.tr());

      bloc.add(OrderEvent(status: OrderEventStatus.DO_ASYNC));
      bloc.add(OrderEvent(status: OrderEventStatus.FETCH_ALL));
    }
  }

  Widget _getBody(context, state, OrderPageMetaData orderPageMetaData) {
    if (state is OrderErrorState) {
      return OrderListErrorWidget(
          error: state.message,
          orderPageMetaData: orderPageMetaData,
      );
    }

    if (state is OrdersLoadedState) {
      if (state.orders.results.length == 0) {
        return OrderListEmptyWidget();
      }

      PaginationInfo paginationInfo = PaginationInfo(
        count: state.orders.count,
        next: state.orders.next,
        previous: state.orders.previous,
        currentPage: state.page != null ? state.page : 1,
        pageSize: orderPageMetaData.pageSize
      );

      return OrderListWidget(
        orderList: state.orders.results,
        orderPageMetaData: orderPageMetaData,
        paginationInfo: paginationInfo,
        fetchEvent: OrderEventStatus.FETCH_ALL,
        searchQuery: state.query
      );
    }

    if (state is OrderNewState) {
      return OrderFormWidget(
        formData: state.formData,
        orderPageMetaData: orderPageMetaData
      );
    }

    if (state is OrderLoadedState) {
      return OrderFormWidget(
          formData: state.formData,
          orderPageMetaData: orderPageMetaData
      );
    }

    return loadingNotice();
  }
}
