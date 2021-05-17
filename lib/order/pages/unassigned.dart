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
  final _scrollThreshold = 200.0;
  bool eventAdded = false;
  ScrollController controller;
  OrderBloc bloc = OrderBloc(OrderInitialState());
  List<Order> orderList = [];
  bool hasNextPage = false;
  int page = 1;
  bool inPaging = false;
  String searchQuery = '';

  _scrollListener() {
    // end reached
    final maxScroll = controller.position.maxScrollExtent;
    final currentScroll = controller.position.pixels;
    if (hasNextPage && maxScroll - currentScroll <= _scrollThreshold) {
      bloc.add(OrderEvent(status: OrderEventStatus.DO_ASYNC));
      bloc.add(OrderEvent(
        status: OrderEventStatus.FETCH_UNASSIGNED,
        page: ++page,
        query: searchQuery,
      ));
      inPaging = true;
    }
  }

  @override
  void initState() {
    controller = new ScrollController()..addListener(_scrollListener);
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool rebuild = true;
    List<Order> orderList = [];
    bool inSearch = false;
    inPaging = false;

    _initialCall() {
      OrderBloc bloc = OrderBloc(OrderInitialState());
      bloc.add(OrderEvent(status: OrderEventStatus.DO_ASYNC));
      bloc.add(OrderEvent(
          status: OrderEventStatus.FETCH_UNASSIGNED));

      return bloc;
    }

    return BlocProvider(
        create: (BuildContext context) => _initialCall(),
        child: FutureBuilder<Widget>(
            future: getDrawerForUser(context),
            builder: (ctx, snapshot) {
              final Widget drawer = snapshot.data;
              bloc = BlocProvider.of<OrderBloc>(ctx);

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

                            if (state is OrderSearchState) {
                              // reset vars on search
                              orderList = [];
                              inSearch = true;
                              page = 1;
                              inPaging = false;
                            }

                            if (state is OrdersUnassignedLoadedState) {
                              if (inSearch && !inPaging) {
                                // set search string and orderList
                                searchQuery = state.query;
                                orderList = state.orders.results;
                              } else {
                                // only merge on widget build, paging and search
                                if (rebuild || inPaging || searchQuery != null) {
                                  hasNextPage = state.orders.next != null;
                                  orderList = new List.from(orderList)..addAll(state.orders.results);
                                  rebuild = false;
                                }
                              }

                              return UnAssignedListWidget(
                                  orderList: orderList,
                                  controller: controller,
                                  fetchEvent: OrderEventStatus.FETCH_UNASSIGNED,
                                  searchQuery: searchQuery,
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