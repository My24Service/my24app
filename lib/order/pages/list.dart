import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:my24app/core/utils.dart';
import 'package:my24app/order/blocs/order_bloc.dart';
import 'package:my24app/order/blocs/order_states.dart';
import 'package:my24app/order/widgets/list.dart';
import 'package:my24app/core/widgets/widgets.dart';

import '../../core/models/models.dart';

class OrderListPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new _OrderListPageState();
}

class _OrderListPageState extends State<OrderListPage> {
  bool firstTime = true;

  OrderBloc _initialCall() {
    OrderBloc bloc = OrderBloc();

    if (firstTime) {
      bloc.add(OrderEvent(status: OrderEventStatus.DO_ASYNC));
      bloc.add(OrderEvent(
          status: OrderEventStatus.FETCH_ALL));

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
                      _handleListener(context, state);
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

  void _handleListener(BuildContext context, state) async {
    final OrderBloc bloc = BlocProvider.of<OrderBloc>(context);

    if (state is OrderDeletedState) {

      if (state.result == true) {
        createSnackBar(
            context, 'orders.snackbar_deleted'.tr());

        bloc.add(OrderEvent(status: OrderEventStatus
            .DO_ASYNC));
        bloc.add(OrderEvent(
            status: OrderEventStatus.FETCH_ALL));
      } else {
        displayDialog(context,
            'generic.error_dialog_title'.tr(),
            'orders.error_deleting_dialog_content'.tr()
        );
      }
    }
  }

  Widget _getBody(context, state, OrderListData orderListData) {
    if (state is OrderErrorState) {
      return OrderListEmptyErrorWidget(
          orderList: [],
          orderListData: orderListData,
          fetchEvent: OrderEventStatus.FETCH_ALL,
          error: state.message
      );
    }

    if (state is OrdersLoadedState) {
      if (state.orders.results.length == 0) {
        return OrderListEmptyErrorWidget(
            orderList: state.orders.results,
            orderListData: orderListData,
            fetchEvent: OrderEventStatus.FETCH_ALL,
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

      return OrderListWidget(
        orderList: state.orders.results,
        orderListData: orderListData,
        paginationInfo: paginationInfo,
        fetchEvent: OrderEventStatus.FETCH_ALL,
        searchQuery: state.query,
        error: null,
      );
    }

    return loadingNotice();
  }
}
