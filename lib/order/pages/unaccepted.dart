import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:my24app/order/blocs/order_bloc.dart';
import 'package:my24app/order/blocs/order_states.dart';
import 'package:my24app/core/widgets/widgets.dart';
import 'package:my24app/order/widgets/unaccepted.dart';
import 'package:my24app/core/models/models.dart';
import 'package:my24app/core/utils.dart';


class UnacceptedPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new _UnacceptedPageState();
}

class _UnacceptedPageState extends State<UnacceptedPage> {
  bool firstTime = true;

  OrderBloc _initialCall() {
    OrderBloc bloc = OrderBloc();

    if (firstTime) {
      bloc.add(OrderEvent(status: OrderEventStatus.DO_ASYNC));
      bloc.add(OrderEvent(
          status: OrderEventStatus.FETCH_UNACCEPTED));

      firstTime = false;
    }

    return bloc;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<OrderListData>(
        future: utils.getOrderListData(context),
        builder: (ctx, snapshot) {
          if (snapshot.hasData) {
            final OrderListData orderListData = snapshot.data;
            return BlocProvider(
                create: (context) => _initialCall(),
                child: BlocConsumer<OrderBloc, OrderState>(
                    listener: (context, state) {
                      _handleListeners(context, state);
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

  void _handleListeners(BuildContext context, state) {
    final bloc = BlocProvider.of<OrderBloc>(context);

    if (state is OrderDeletedState) {
      if (state.result == true) {
        createSnackBar(
            context,
            'orders.snackbar_deleted'.tr());

        bloc.add(OrderEvent(
            status: OrderEventStatus.DO_ASYNC));
        bloc.add(OrderEvent(
            status: OrderEventStatus.FETCH_UNACCEPTED));
      } else {
        displayDialog(context,
            'generic.error_dialog_title'.tr(),
            'orders.error_deleting_dialog_content'.tr()
        );
      }
    }
  }

  Widget _getBody(context, state, OrderListData orderListData) {
    if (state is OrderInitialState) {
      return loadingNotice();
    }

    if (state is OrderLoadingState) {
      return loadingNotice();
    }

    if (state is OrderErrorState) {
      return UnacceptedListEmptyErrorWidget(
        orderList: [],
        orderListData: orderListData,
        fetchEvent: OrderEventStatus.FETCH_UNACCEPTED,
        error: state.message,
      );
    }

    if (state is OrdersUnacceptedLoadedState) {
      if (state.orders.results.length == 0) {
        return UnacceptedListEmptyErrorWidget(
          orderList: state.orders.results,
          orderListData: orderListData,
          fetchEvent: OrderEventStatus.FETCH_UNACCEPTED,
          error: null,
        );
      }

      PaginationInfo paginationInfo = PaginationInfo(
        count: state.orders.count,
        next: state.orders.next,
        previous: state.orders.previous,
        currentPage: state.page != null ? state.page : 1,
        pageSize: orderListData.pageSize
      );

      return UnacceptedListWidget(
        orderList: state.orders.results,
        orderListData: orderListData,
        paginationInfo: paginationInfo,
        fetchEvent: OrderEventStatus.FETCH_UNACCEPTED,
        searchQuery: state.query,
        error: null,
      );
    }

    return loadingNotice();
  }
}
