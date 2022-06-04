import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:my24app/order/blocs/order_bloc.dart';
import 'package:my24app/order/blocs/order_states.dart';
import 'package:my24app/order/widgets/info.dart';
import 'package:my24app/core/widgets/widgets.dart';

import '../../core/utils.dart';

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
  bool firstTime = true;

  OrderBloc _initialBlocCall(int orderPk) {
    OrderBloc bloc = OrderBloc();

    if (firstTime) {
      bloc.add(OrderEvent(status: OrderEventStatus.DO_ASYNC));
      bloc.add(OrderEvent(
          status: OrderEventStatus.FETCH_DETAIL, value: orderPk));

      firstTime = false;
    }

    return bloc;
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
        create: (context) => _initialBlocCall(widget.orderPk),
        child: FutureBuilder<String>(
          future: utils.getUserSubmodel(),
          builder: (ctx, snapshot) {
            if (snapshot.data == null) {
              return Scaffold(
                  appBar: AppBar(title: Text('')),
                  body: Container()
              );
            }

            final bool _isCustomer = snapshot.data == 'customer_user';

            return FutureBuilder<String>(
                future: utils.getBaseUrl(),
                builder: (ctx, snapshot) {
                  String _baseUrl = snapshot.data;

                  return BlocConsumer<OrderBloc, OrderState>(
                    listener: (context, state) {},
                    builder: (context, state) {
                      return Scaffold(
                          appBar: AppBar(
                              title: Text('orders.detail.app_bar_title'.tr())
                          ),
                          body: _getBody(context, state, _isCustomer, _baseUrl)
                      );
                    }
                  );
                }
              );
          }
      )
    );
  }

  Widget _getBody(context, state, isCustomer, baseUrl) {
    final OrderBloc bloc = BlocProvider.of<OrderBloc>(context);

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
      return OrderInfoWidget(
        order: state.order,
        isCustomer: isCustomer,
        baseUrl: baseUrl,
      );
    }

    return loadingNotice();
  }
}
