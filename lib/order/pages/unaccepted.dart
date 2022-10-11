import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:my24app/order/blocs/order_bloc.dart';
import 'package:my24app/order/blocs/order_states.dart';
import 'package:my24app/core/widgets/widgets.dart';
import 'package:my24app/core/widgets/drawers.dart';
import 'package:my24app/order/models/models.dart';
import 'package:my24app/order/widgets/unaccepted.dart';

class UnacceptedPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new _UnacceptedPageState();
}

class _UnacceptedPageState extends State<UnacceptedPage> {
  bool firstTime = true;
  final _scrollThreshold = 200.0;
  bool eventAdded = false;
  ScrollController controller;
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
    final bloc = OrderBloc();

    if (hasNextPage && maxScroll - currentScroll <= _scrollThreshold) {
      bloc.add(OrderEvent(status: OrderEventStatus.DO_ASYNC));
      bloc.add(OrderEvent(
        status: OrderEventStatus.FETCH_UNACCEPTED,
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
          status: OrderEventStatus.FETCH_UNACCEPTED));

      firstTime = false;
    }

    return bloc;
  }

  @override
  Widget build(BuildContext context) {

    return BlocProvider<OrderBloc>(
        create: (context) => _initialCall(),
        child: BlocConsumer<OrderBloc, OrderState>(
          listener: (context, state) {
            _handleListeners(context, state);
          },
          builder: (context, state) {
            return FutureBuilder<Widget>(
                future: getDrawerForUser(context),
                builder: (ctx, snapshot) {
                  final Widget drawer = snapshot.data;

                  return Scaffold(
                      appBar: AppBar(title: Text(
                          'orders.unaccepted.app_bar_title'.tr())),
                      drawer: drawer,
                      body: _getBody(context, state)
                  );
                }
            );
          }
      )
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

  Widget _getBody(context, state) {
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
              status: OrderEventStatus.FETCH_UNACCEPTED)
      );
    }

    if (state is OrderSearchState) {
      // reset vars on search
      orderList = [];
      inSearch = true;
      page = 1;
      inPaging = false;
    }

    if (state is OrdersUnacceptedLoadedState) {
      if (rebuild || (inSearch && !inPaging)) {
        // set search string and orderList
        searchQuery = state.query;
        orderList = state.orders.results;
      } else {
        // only merge on widget build, paging and search
        if (inPaging || searchQuery != null) {
          orderList = [];
          hasNextPage = state.orders.next != null;
          orderList = new List.from(orderList)..addAll(state.orders.results);
          rebuild = false;
        }
      }

      return UnacceptedListWidget(
        orderList: orderList,
        controller: controller,
        fetchEvent: OrderEventStatus.FETCH_UNACCEPTED,
        searchQuery: searchQuery,
      );
    }

    return loadingNotice();
  }
}
