import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:my24app/order/blocs/order_bloc.dart';
import 'package:my24app/order/blocs/order_states.dart';
import 'package:my24app/core/widgets/widgets.dart';
import 'package:my24app/core/widgets/drawers.dart';
import 'package:my24app/order/models/models.dart';
import 'package:my24app/order/widgets/unassigned.dart';

class OrdersUnAssignedPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new _OrdersUnAssignedPageState();
}

class _OrdersUnAssignedPageState extends State<OrdersUnAssignedPage> {
  bool eventAdded = false;
  ScrollController controller;
  OrderBloc bloc = OrderBloc(OrderInitialState());
  List<Order> orderList = [];
  bool hasNextPage = false;
  int page = 1;

  _scrollListener() {
    // end reached
    if (hasNextPage && controller.position.maxScrollExtent == controller.offset) {
      bloc.add(OrderEvent(status: OrderEventStatus.DO_ASYNC));
      bloc.add(OrderEvent(status: OrderEventStatus.FETCH_UNASSIGNED, page: ++page));
    }
  }

  @override
  void initState() {
    controller = new ScrollController()..addListener(_scrollListener);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
        create: (BuildContext context) => OrderBloc(OrderInitialState()),
        child: FutureBuilder<Widget>(
            future: getDrawerForUser(context),
            builder: (ctx, snapshot) {
              final Widget drawer = snapshot.data;
              final bloc = BlocProvider.of<OrderBloc>(ctx);

              if (!eventAdded) {
                bloc.add(OrderEvent(status: OrderEventStatus.DO_ASYNC));
                bloc.add(OrderEvent(
                    status: OrderEventStatus.FETCH_UNASSIGNED));
                eventAdded = true;
              }

              return Scaffold(
                  appBar: AppBar(title: Text('orders.unassigned.app_bar_title'.tr())),
                  drawer: drawer,
                  body: BlocListener<OrderBloc, OrderState>(
                      listener: (context, state) {
                      },
                      child: BlocBuilder<OrderBloc, OrderState>(
                          builder: (context, state) {
                            if (state is OrderInitialState) {
                              return loadingNotice();
                            }

                            if (state is OrderLoadingState) {
                              return loadingNotice();
                            }

                            if (state is OrderErrorState) {
                              return errorNoticeWithReload(
                                  state.message,
                                  bloc,
                                  OrderEvent(
                                      status: OrderEventStatus.FETCH_UNASSIGNED)
                              );
                            }

                            if (state is OrdersUnassignedLoadedState) {
                              hasNextPage = state.orders.next != null;
                              orderList = new List.from(orderList)..addAll(state.orders.results);

                              return UnAssignedListWidget(
                                  orderList: orderList,
                                  controller: controller
                              );
                            }

                            return loadingNotice();
                          }
                      )
                  )
              );
            }
          )
    );
  }
}
