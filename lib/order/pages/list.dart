import 'package:flutter/material.dart';

import 'my24app:order/blocs/order_bloc.dart';
import 'my24app:order/blocs/order_states.dart';
import 'my24app:order/widgets/order_list.dart';


class OrderListPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new _OrderListPageState();
}

class _OrderListPageState extends State<OrderListPage> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (BuildContext context) => OrderBloc(),
      child:  BlocBuilder<OrderBloc, OrderState>(
        builder: (context, state) {
          final bloc = BlocProvider.of<OrderBloc>(context);
          bloc.add(OrderEvent(
              status: OrderEventStatus.FETCH_ALL));

          if (state is OrderInitialState) {
            return loadingNotice();
          }

          if (state is OrderLoadingState) {
            return loadingNotice();
          }

          if (state is OrderErrorState) {
            return errorNotice();
          }

          if (state is OrdersLoadedState) {
            return OrderListWidget(state.orders);
          }

          return errorNotice();
        }
      )
    );
  }
}
