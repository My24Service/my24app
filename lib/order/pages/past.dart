import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:my24app/order/blocs/order_bloc.dart';
import 'package:my24app/order/blocs/order_states.dart';
import 'package:my24app/core/widgets/widgets.dart';
import 'package:my24app/core/widgets/drawers.dart';
import 'package:my24app/order/models/models.dart';
import 'package:my24app/order/widgets/past.dart';

class PastPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new _PastPageState();
}

class _PastPageState extends State<PastPage> {
  final _scrollThreshold = 200.0;
  bool eventAdded = false;
  ScrollController controller;
  OrderBloc bloc = OrderBloc();
  List<Order> orderList = [];
  bool hasNextPage = false;
  int page = 1;
  bool inPaging = false;
  String searchQuery = '';
  bool rebuild = true;
  bool inSearch = false;

  _scrollListener() {
    // end reached
    final maxScroll = controller.position.maxScrollExtent;
    final currentScroll = controller.position.pixels;
    if (hasNextPage && maxScroll - currentScroll <= _scrollThreshold) {
      bloc.add(OrderEvent(status: OrderEventStatus.DO_ASYNC));
      bloc.add(OrderEvent(
          status: OrderEventStatus.FETCH_PAST,
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
    bloc.add(OrderEvent(status: OrderEventStatus.DO_ASYNC));
    bloc.add(OrderEvent(
        status: OrderEventStatus.FETCH_PAST));

    return bloc;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Widget>(
        future: getDrawerForUser(context),
        builder: (ctx, snapshot) {
          final Widget drawer = snapshot.data;

          return BlocConsumer(
            bloc: _initialCall(),
            listener: (context, state) {},
            builder: (context, state) {
              return Scaffold(
                  appBar: AppBar(title: Text(
                      'orders.past.app_bar_title'.tr())
                  ),
                  drawer: drawer,
                  body: _getBody(state)
              );
            }
          );
        }
    );
  }

  Widget _getBody(state) {
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
              status: OrderEventStatus.FETCH_PAST)
      );
    }

    if (state is OrderSearchState) {
      // reset vars on search
      orderList = [];
      inSearch = true;
      page = 1;
      inPaging = false;
    }

    if (state is OrdersPastLoadedState) {
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

      return PastListWidget(
        orderList: orderList,
        controller: controller,
        fetchEvent: OrderEventStatus.FETCH_PAST,
        searchQuery: searchQuery,
      );
    }

    return loadingNotice();
  }
}
