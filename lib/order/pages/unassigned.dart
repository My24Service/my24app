import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:my24app/order/blocs/order_bloc.dart';
import 'package:my24app/order/blocs/order_states.dart';
import 'package:my24app/core/widgets/widgets.dart';
import 'package:my24app/order/widgets/unassigned.dart';
import 'package:my24app/core/models/models.dart';
import 'package:my24app/core/utils.dart';
import 'package:my24app/mobile/blocs/assign_bloc.dart';
import 'package:my24app/mobile/blocs/assign_states.dart';
import 'package:my24app/mobile/pages/assigned_list.dart';


class OrdersUnAssignedPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new _OrdersUnAssignedPageState();
}

class _OrdersUnAssignedPageState extends State<OrdersUnAssignedPage> {
  bool firstTime = true;

  OrderBloc _initialCall() {
    OrderBloc bloc = OrderBloc();

    if (firstTime) {
      bloc.add(OrderEvent(status: OrderEventStatus.DO_ASYNC));
      bloc.add(OrderEvent(
          status: OrderEventStatus.FETCH_UNASSIGNED));

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
              child: BlocProvider(
                create: (context) => AssignBloc(),
                child: BlocConsumer<AssignBloc, AssignState>(
                  listener: (context, state) {
                    _handleListenerAssign(context, state);
                  },
                  builder: (context, state) {
                    return BlocConsumer<OrderBloc, OrderState>(
                      listener: (context, state) {
                        _handleListenerOrder(context, state);
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
                    );
                  }
                )
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

  void _handleListenerOrder(BuildContext context, state) async {
  }

  void _handleListenerAssign(BuildContext context, state) async {
    if (state is AssignedMeState) {
      createSnackBar(
          context, 'orders.assign.snackbar_assigned'.tr());

      await Future.delayed(Duration(seconds: 1));

      Navigator.pushReplacement(context,
          MaterialPageRoute(
              builder: (context) => AssignedOrderListPage())
      );
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
      return UnAssignedListEmptyErrorWidget(
        orderList: [],
        orderListData: orderListData,
        fetchEvent: OrderEventStatus.FETCH_UNASSIGNED,
        error: state.message,
      );
    }

    if (state is OrdersUnassignedLoadedState) {
      if (state.orders.results.length == 0) {
        return UnAssignedListEmptyErrorWidget(
          orderList: state.orders.results,
          orderListData: orderListData,
          fetchEvent: OrderEventStatus.FETCH_UNASSIGNED,
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

      return UnAssignedListWidget(
        orderList: state.orders.results,
        orderListData: orderListData,
        paginationInfo: paginationInfo,
        fetchEvent: OrderEventStatus.FETCH_UNASSIGNED,
        searchQuery: state.query,
        error: null,
      );
    }

    return loadingNotice();
  }
}
