import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:my24_flutter_core/widgets/widgets.dart';
import 'package:my24_flutter_core/i18n.dart';

import 'package:my24app/order/blocs/order_bloc.dart';
import 'package:my24app/order/blocs/order_states.dart';
import 'package:my24app/order/pages/page_meta_data_mixin.dart';
import 'package:my24app/order/widgets/order/detail.dart';
import 'package:my24app/order/widgets/order/error.dart';
import 'package:my24app/order/models/order/models.dart';


class OrderDetailPage extends StatelessWidget with i18nMixin, PageMetaData {
  final int? orderId;
  final String basePath = "orders";
  final OrderBloc bloc;
  final CoreWidgets widgets = CoreWidgets();

  OrderDetailPage({
    Key? key,
    required this.orderId,
    required this.bloc,
  }) : super(key: key);

  OrderBloc _initialBlocCall() {
    bloc.add(OrderEvent(status: OrderEventStatus.DO_ASYNC));
    bloc.add(OrderEvent(status: OrderEventStatus.FETCH_DETAIL_VIEW, pk: orderId));

    return bloc;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<OrderPageMetaData>(
        future: getOrderPageMetaData(context),
        builder: (ctx, snapshot) {
          if (snapshot.hasData) {
            final OrderPageMetaData? orderListData = snapshot.data;

            return BlocProvider<OrderBloc>(
                create: (context) => _initialBlocCall(),
                child: BlocConsumer<OrderBloc, OrderState>(
                    listener: (context, state) {
                    },
                    builder: (context, state) {
                      return Scaffold(
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
            return Scaffold(
                body: widgets.loadingNotice()
            );
          }
        }
    );
  }

  Widget _getBody(context, state, OrderPageMetaData? orderPageMetaData) {
    if (state is OrderErrorState) {
      return OrderListErrorWidget(
        error: state.message,
        orderPageMetaData: orderPageMetaData!,
        widgetsIn: widgets,
      );
    }

    if (state is OrderLoadedViewState) {
      return OrderDetailWidget(
        order: state.order,
        orderPageMetaData: orderPageMetaData!,
        widgetsIn: widgets,
      );
    }

    return widgets.loadingNotice();
  }
}
