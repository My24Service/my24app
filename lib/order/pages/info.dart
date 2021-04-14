import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:my24app/order/blocs/order_bloc.dart';
import 'package:my24app/order/blocs/order_states.dart';
import 'package:my24app/order/widgets/info.dart';
import 'package:my24app/core/widgets/widgets.dart';

class OrderInfoPage extends StatefulWidget {
  final int orderPk;

  OrderInfoPage({
    Key key,
    @required this.orderPk,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => new _OrderInfoPageState();
}

class _OrderInfoPageState extends State<OrderInfoPage> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
        create: (BuildContext context) => OrderBloc(OrderInitialState()),
        child: Builder(
          builder: (BuildContext context) {
            final bloc = BlocProvider.of<OrderBloc>(context);

            bloc.add(OrderEvent(status: OrderEventStatus.DO_FETCH));
            bloc.add(OrderEvent(
              status: OrderEventStatus.FETCH_DETAIL,
              value: widget.orderPk
            ));

            return Scaffold(
              appBar: AppBar(title: Text('orders.detail.app_bar_title'.tr())),
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
                                  status: OrderEventStatus.FETCH_DETAIL,
                                  value: widget.orderPk
                              )
                          );
                        }

                        if (state is OrderLoadedState) {
                          return OrderInfoWidget(order: state.order);
                        }

                        return loadingNotice();
                      }
                  )
              )
            ); // Scaffold
          } // builder
        ) // Builder
      ); // BlocProvider
  }
}
