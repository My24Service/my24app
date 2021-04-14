import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:my24app/order/blocs/order_bloc.dart';
import 'package:my24app/order/blocs/order_states.dart';
import 'package:my24app/core/widgets/widgets.dart';
import 'package:my24app/core/widgets/drawers.dart';
import 'package:my24app/order/widgets/past.dart';

class PastPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new _PastPageState();
}

class _PastPageState extends State<PastPage> {
  bool eventAdded = false;

  @override
  Widget build(BuildContext context) {
      return BlocProvider(
          create: (BuildContext context) => OrderBloc(OrderInitialState()),
          child: FutureBuilder<Widget>(
                  future: getDrawerForUser(context),
                  builder: (ctx, snapshot) {
                    final Widget drawer = snapshot.data;
                    final bloc = BlocProvider.of<OrderBloc>(ctx);

                    if (!eventAdded) {
                      bloc.add(OrderEvent(status: OrderEventStatus.DO_ASYNC));
                      bloc.add(OrderEvent(status: OrderEventStatus.FETCH_PAST));
                      eventAdded = true;
                    }

                    return Scaffold(
                        appBar: AppBar(title: Text(
                            'orders.past.app_bar_title'.tr())
                        ),
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
                                            status: OrderEventStatus
                                                .FETCH_PAST)
                                    );
                                  }

                                  if (state is OrdersUnacceptedLoadedState) {
                                    return PastListWidget(
                                        orders: state.orders);
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
