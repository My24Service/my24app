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
  bool firstTime = true;
  final _scrollThreshold = 200.0;
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
    return BlocProvider(
        create: (context) => _initialCall(),
        child: FutureBuilder<String>(
            future: utils.getOrderListTitleForUser(),
            builder: (ctx, snapshot) {
              final String title = snapshot.data;

              return FutureBuilder<Widget>(
                  future: getDrawerForUser(context),
                  builder: (ctx, snapshot) {
                    final Widget drawer = snapshot.data;

                    return BlocConsumer<OrderBloc, OrderState>(
                        builder: (context, state) {
                          return Scaffold(
                              appBar: AppBar(
                                title: Text(title ?? ''),
                              ),
                              drawer: drawer,
                              body: _getBody(context, state)
                          );
                        },
                        listener: (context, state) {
                          _handleListener(context, state);
                        }
                    );
                  }
              );
            }
          )
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

  Widget _getBody(context, state) {
    final OrderBloc bloc = BlocProvider.of<OrderBloc>(context);

    if (state is OrderErrorState) {
      return errorNoticeWithReload(
          state.message,
          bloc,
          OrderEvent(
              status: OrderEventStatus.FETCH_ALL)
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

    if (state is OrdersLoadedState) {
      if (rebuild || refresh || (inSearch && !inPaging)) {
        // set search string and orderList
        searchQuery = state.query;
        orderList = state.orders.results;
      } else {
        // only merge on widget build, paging and search
        if (inPaging || searchQuery != null) {
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
}
