import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:my24app/core/utils.dart';
import 'package:my24app/order/blocs/order_bloc.dart';
import 'package:my24app/order/blocs/order_states.dart';
import 'package:my24app/order/widgets/list.dart';
import 'package:my24app/core/widgets/widgets.dart';
import 'package:my24app/core/widgets/drawers.dart';
import 'package:my24app/order/models/models.dart';

class OrderListPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new _OrderListPageState();
}

class _OrderListPageState extends State<OrderListPage> {
  final _scrollThreshold = 200.0;
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
        status: OrderEventStatus.FETCH_ALL,
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
        status: OrderEventStatus.FETCH_ALL));

      return bloc;
    }

    return BlocProvider(
        create: (BuildContext context) => _initialCall(),
        child: FutureBuilder<String>(
            future: utils.getOrderListTitleForUser(),
            builder: (ctx, snapshot) {
              final String title = snapshot.data;
              bloc = BlocProvider.of<OrderBloc>(ctx);

              return FutureBuilder<Widget>(
                future: getDrawerForUser(context),
                builder: (ctx, snapshot) {
                  final Widget drawer = snapshot.data;

                  return Scaffold(
                      appBar: AppBar(
                          title: Text(title?? ''),
                      ),
                      drawer: drawer,
                      body: BlocListener<OrderBloc, OrderState>(
                          listener: (context, state) {
                            if (state is OrderDeletedState) {
                              if (state.result == true) {
                                createSnackBar(
                                    context, 'orders.snackbar_deleted'.tr());

                                bloc.add(OrderEvent(status: OrderEventStatus.DO_ASYNC));
                                bloc.add(OrderEvent(
                                    status: OrderEventStatus.FETCH_ALL));
                              } else {
                                displayDialog(context,
                                    'generic.error_dialog_title'.tr(),
                                    'orders.error_deleting_dialog_content'.tr()
                                );
                              }
                            }
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
                                          status: OrderEventStatus.FETCH_ALL)
                                  );
                                }

                                if (state is OrderSearchState) {
                                  // reset vars on search
                                  orderList = [];
                                  inSearch = true;
                                  page = 1;
                                  inPaging = false;
                                }

                                if (state is OrdersLoadedState) {
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

                                  return OrderListWidget(
                                      orderList: orderList,
                                      controller: controller,
                                      fetchEvent: OrderEventStatus.FETCH_ALL,
                                      searchQuery: searchQuery,
                                  );
                                }

                                return loadingNotice();
                              }
                          )
                      )
                  );
                }
              );
            }
        )
    );
  }
}
