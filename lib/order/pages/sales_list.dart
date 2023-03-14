import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:my24app/order/blocs/order_bloc.dart';
import 'package:my24app/order/blocs/order_states.dart';
import 'package:my24app/core/widgets/widgets.dart';
import 'package:my24app/order/widgets/sales_list.dart';
import 'package:my24app/core/models/models.dart';
import 'package:my24app/core/utils.dart';

class SalesPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new _SalesPageState();
}

class _SalesPageState extends State<SalesPage> {
  bool firstTime = true;

  OrderBloc _initialCall() {
    OrderBloc bloc = OrderBloc();

    if (firstTime) {
      bloc.add(OrderEvent(status: OrderEventStatus.DO_ASYNC));
      bloc.add(OrderEvent(
          status: OrderEventStatus.FETCH_SALES));

      firstTime = false;
    }

    return bloc;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<OrderPageMetaData>(
        future: utils.getOrderPageMetaData(context),
        builder: (ctx, snapshot) {
          if (snapshot.hasData) {
            final OrderPageMetaData orderListData = snapshot.data;
            return BlocProvider(
                create: (context) => _initialCall(),
                child: BlocConsumer<OrderBloc, OrderState>(
                    listener: (context, state) {},
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

  Widget _getBody(context, state, OrderPageMetaData orderListData) {
    if (state is OrderInitialState) {
      return loadingNotice();
    }

    if (state is OrderLoadingState) {
      return loadingNotice();
    }

    if (state is OrderErrorState) {
      return SalesListEmptyErrorWidget(
        orderList: [],
        orderListData: orderListData,
        fetchEvent: OrderEventStatus.FETCH_SALES,
        error: state.message,
      );
    }

    if (state is OrdersSalesLoadedState) {
      if (state.orders.results.length == 0) {
        return SalesListEmptyErrorWidget(
          orderList: state.orders.results,
          orderListData: orderListData,
          fetchEvent: OrderEventStatus.FETCH_SALES,
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

      return SalesListWidget(
        orderList: state.orders.results,
        orderListData: orderListData,
        paginationInfo: paginationInfo,
        fetchEvent: OrderEventStatus.FETCH_SALES,
        searchQuery: state.query,
        error: null,
      );
    }

    return loadingNotice();
  }
}
