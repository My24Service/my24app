import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:my24app/order/blocs/order_bloc.dart';
import 'package:my24app/order/blocs/order_states.dart';
import 'package:my24app/core/widgets/widgets.dart';
import 'package:my24app/core/widgets/drawers.dart';
import 'package:my24app/order/models/models.dart';
import 'package:my24app/order/widgets/past.dart';

import '../../core/models/models.dart';
import '../../core/utils.dart';

class PastPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new _PastPageState();
}

class _PastPageState extends State<PastPage> {
  bool firstTime = true;
  bool eventAdded = false;
  bool hasNextPage = false;
  int page = 1;
  bool inPaging = false;
  String searchQuery = '';
  bool rebuild = true;
  bool inSearch = false;

  OrderBloc _initialCall() {
    OrderBloc bloc = OrderBloc();

    if (firstTime) {
      bloc.add(OrderEvent(status: OrderEventStatus.DO_ASYNC));
      bloc.add(OrderEvent(
          status: OrderEventStatus.FETCH_PAST));

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
                    },
                    builder: (context, state) {
                      return Scaffold(
                          drawer: orderListData.drawer,
                          body: _getBody(context, state, orderListData)
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

  Widget _getBody(context, state, OrderListData orderListData) {
    final OrderBloc bloc = BlocProvider.of<OrderBloc>(context);

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
      inSearch = true;
      page = 1;
      inPaging = false;
    }

    if (state is OrdersPastLoadedState) {
      return PastListWidget(
        orderList: state.orders.results,
        orderListData: orderListData,
        fetchEvent: OrderEventStatus.FETCH_PAST,
        searchQuery: searchQuery,
      );
    }

    return loadingNotice();
  }
}
