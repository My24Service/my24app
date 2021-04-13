import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:my24app/core/utils.dart';
import 'package:my24app/order/blocs/order_bloc.dart';
import 'package:my24app/order/blocs/order_states.dart';
import 'package:my24app/order/widgets/order_list.dart';
import 'package:my24app/core/widgets/widgets.dart';
import 'package:my24app/core/widgets/drawers.dart';

class OrderDocumentsPage extends StatefulWidget {
  final dynamic orderPk;

  OrderDocumentsPage({
    Key key,
    @required this.orderPk,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => new _OrderDocumentsPageState();
}

class _OrderDocumentsPageState extends State<OrderDocumentsPage> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
        create: (BuildContext context) => OrderBloc(OrderInitialState()),
        child: FutureBuilder<String>(
            future: utils.getOrderListTitleForUser(),
            builder: (ctx, snapshot) {
              final bloc = BlocProvider.of<OrderBloc>(ctx);
              final String title = snapshot.data;

              bloc.add(OrderEvent(status: OrderEventStatus.DO_FETCH));
              bloc.add(OrderEvent(
                  status: OrderEventStatus.FETCH_ALL));

              return FutureBuilder<Widget>(
                  future: getDrawerForUser(context),
                  builder: (ctx, snapshot) {
                    final Widget drawer = snapshot.data;

                    return Scaffold(
                        appBar: AppBar(title: Text(title?? '')),
                        drawer: drawer,
                        body: BlocListener<OrderBloc, OrderState>(
                            listener: (context, state) {
                              if (state is OrderDeletedState) {
                                if (state.result == true) {
                                  createSnackBar(
                                      context, 'orders.snackbar_deleted'.tr());

                                  bloc.add(OrderEvent(status: OrderEventStatus.DO_FETCH));
                                  bloc.add(OrderEvent(
                                      status: OrderEventStatus.FETCH_ALL));
                                } else {
                                  displayDialog(context,
                                      'generic.error_dialog_title'.tr(),
                                      'orders.error_deleting_dialog_content'.tr()
                                  );
                                }
                              }
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
                                            status: OrderEventStatus.FETCH_ALL)
                                    );
                                  }

                                  if (state is OrdersLoadedState) {
                                    return OrderListWidget(orders: state.orders);
                                  }

                                  return loadingNotice();
                                }
                            )
                        )
                    );
                  }
              );
            }
        )
    );
  }
}
