import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:my24app/order/blocs/order_bloc.dart';
import 'package:my24app/order/blocs/order_states.dart';
import 'package:my24app/core/widgets/widgets.dart';
import 'package:my24app/core/widgets/drawers.dart';
import 'package:my24app/order/models/models.dart';
import 'package:my24app/order/widgets/unassigned.dart';

import '../../core/utils.dart';
import '../../mobile/blocs/assign_bloc.dart';
import '../../mobile/blocs/assign_states.dart';
import '../../mobile/pages/assigned_list.dart';
import 'list.dart';

class OrdersUnAssignedPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new _OrdersUnAssignedPageState();
}

class _OrdersUnAssignedPageState extends State<OrdersUnAssignedPage> {
  bool firstTime = true;
  final _scrollThreshold = 200.0;
  bool eventAdded = false;
  ScrollController controller;
  List<Order> orderList = [];
  bool hasNextPage = false;
  int page = 1;
  bool inPaging = false;
  String searchQuery = '';
  bool refresh = false;
  bool rebuild = true;
  bool inSearch = false;

  _scrollListener() {
    // end reached
    final maxScroll = controller.position.maxScrollExtent;
    final currentScroll = controller.position.pixels;
    final bloc = OrderBloc();

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
    bool isPlanning;

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
                    return FutureBuilder<String>(
                        future: utils.getUserSubmodel(),
                        builder: (ctx, snapshot) {
                          isPlanning = snapshot.data == 'planning_user';

                          return FutureBuilder<Widget>(
                              future: getDrawerForUser(context),
                              builder: (ctx, snapshot) {
                                final Widget drawer = snapshot.data;

                                return Scaffold(
                                    appBar: AppBar(
                                        title: Text(
                                            'orders.unassigned.app_bar_title'
                                                .tr())),
                                    drawer: drawer,
                                    body: _getBody(context, state, isPlanning)
                                );
                              }
                          );
                        }
                    );
                  }
              );
            }
          )
        )
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

    Widget _getBody(context, state, isPlanning) {
    final bloc = BlocProvider.of<OrderBloc>(context);

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

    if (state is OrderRefreshState) {
      // reset vars on refresh
      orderList = [];
      inSearch = false;
      page = 1;
      inPaging = false;
      refresh = true;
    }

    if (state is OrderSearchState) {
      // reset vars on search
      orderList = [];
      inSearch = true;
      page = 1;
      inPaging = false;
      refresh = false;
    }

    if (state is OrdersUnassignedLoadedState) {
      if (refresh || (inSearch && !inPaging)) {
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
        isPlanning: isPlanning
      );
    }

    return loadingNotice();
  }
}
