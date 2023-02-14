import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:my24app/order/blocs/order_bloc.dart';
import 'package:my24app/order/blocs/order_states.dart';
import 'package:my24app/core/widgets/widgets.dart';
import 'package:my24app/core/widgets/drawers.dart';
import 'package:my24app/order/models/models.dart';
import 'package:my24app/order/widgets/unassigned.dart';

import '../../core/models/models.dart';
import '../../core/utils.dart';
import '../../mobile/blocs/assign_bloc.dart';
import '../../mobile/blocs/assign_states.dart';
import '../../mobile/pages/assigned_list.dart';

class OrdersUnAssignedPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new _OrdersUnAssignedPageState();
}

class _OrdersUnAssignedPageState extends State<OrdersUnAssignedPage> {
  bool firstTime = true;
  int page = 1;
  String searchQuery = '';
  bool refresh = false;
  bool inSearch = false;

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
                            body: _getBody(context, state, orderListData)
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
      inSearch = false;
      page = 1;
      refresh = true;
    }

    if (state is OrderSearchState) {
      // reset vars on search
      inSearch = true;
      page = 1;
    }

    if (state is OrdersUnassignedLoadedState) {
      return UnAssignedListWidget(
        orderList: state.orders.results,
        orderListData: orderListData,
        fetchEvent: OrderEventStatus.FETCH_UNASSIGNED,
        searchQuery: searchQuery,
      );
    }

    return loadingNotice();
  }
}
