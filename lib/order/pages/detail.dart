import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:my24app/order/blocs/order_bloc.dart';
import 'package:my24app/order/blocs/order_states.dart';
import 'package:my24app/core/widgets/widgets.dart';
import 'package:my24app/core/i18n_mixin.dart';
import 'package:my24app/order/pages/page_meta_data_mixin.dart';
import 'package:my24app/order/widgets/order/detail.dart';
import 'package:my24app/order/widgets/order/error.dart';
import 'package:my24app/order/models/order/models.dart';


class OrderDetailPage extends StatelessWidget with i18nMixin, PageMetaData {
  final int orderId;
  final String basePath = "orders";
  final OrderBloc bloc;

  OrderDetailPage({
    Key key,
    @required this.orderId,
    @required this.bloc,
  }) : super(key: key);

  OrderBloc _initialBlocCall() {
    bloc.add(OrderEvent(status: OrderEventStatus.DO_ASYNC));
    bloc.add(OrderEvent(status: OrderEventStatus.FETCH_DETAIL_VIEW, pk: orderId));

    return bloc;
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<OrderBloc>(
        create: (context) => _initialBlocCall(),
        child: BlocConsumer<OrderBloc, OrderState>(
            listener: (context, state) {
            },
            builder: (context, state) {
              return FutureBuilder<OrderPageMetaData>(
                  future: getOrderPageMetaData(context),
                  builder: (ctx, snapshot) {
                    if (snapshot.hasData) {
                      final OrderPageMetaData orderListData = snapshot.data;

                      return _getBody(context, state, orderListData);
                    } else if (snapshot.hasError) {
                      print(snapshot.error);
                      return Center(
                          child: Text("An error occurred (${snapshot.error})"));
                    } else {
                      return loadingNotice();
                    }
                  }
              );
            }
        )
    );
  }

  Widget _getBody(context, state, OrderPageMetaData orderPageMetaData) {
    if (state is OrderErrorState) {
      return OrderListErrorWidget(
        error: state.message,
        orderPageMetaData: orderPageMetaData,
      );
    }

    if (state is OrderLoadedViewState) {
      return OrderDetailWidget(
        order: state.order,
        orderPageMetaData: orderPageMetaData,
      );
    }

    return loadingNotice();
  }
}
