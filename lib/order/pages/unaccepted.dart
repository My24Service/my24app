import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:my24app/order/blocs/order_bloc.dart';
import 'package:my24app/order/blocs/order_states.dart';
import 'package:my24app/core/widgets/widgets.dart';
import 'package:my24app/core/widgets/drawers.dart';
import 'package:my24app/order/models/models.dart';
import 'package:my24app/order/widgets/unaccepted.dart';

class UnacceptedPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new _UnacceptedPageState();
}

class _UnacceptedPageState extends State<UnacceptedPage> {
  bool eventAdded = false;
  ScrollController controller;
  OrderBloc bloc = OrderBloc(OrderInitialState());
  List<Order> orderList = [];
  bool hasNextPage = false;
  int page = 1;

  _scrollListener() {
    // end reached
    if (hasNextPage && controller.position.maxScrollExtent == controller.offset) {
      bloc.add(OrderEvent(status: OrderEventStatus.DO_ASYNC));
      bloc.add(OrderEvent(status: OrderEventStatus.FETCH_UNACCEPTED, page: ++page));
    }
  }

  @override
  void initState() {
    controller = new ScrollController()..addListener(_scrollListener);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
      return BlocProvider(
          create: (BuildContext context) => OrderBloc(OrderInitialState()),
          child: FutureBuilder<Widget>(
                  future: getDrawerForUser(context),
                  builder: (ctx, snapshot) {
                    final Widget drawer = snapshot.data;
                    bloc = BlocProvider.of<OrderBloc>(ctx);

                    if (!eventAdded) {
                      bloc.add(OrderEvent(status: OrderEventStatus.DO_ASYNC));
                      bloc.add(OrderEvent(
                          status: OrderEventStatus.FETCH_UNACCEPTED));
                      eventAdded = true;
                    }

                    return Scaffold(
                        appBar: AppBar(title: Text(
                            'orders.unaccepted.app_bar_title'.tr())),
                        drawer: drawer,
                        body: BlocListener<OrderBloc, OrderState>(
                            listener: (context, state) {
                              if (state is OrderAcceptedState) {
                                if (state.result == true) {
                                  createSnackBar(
                                      context,
                                      'orders.unaccepted.snackbar_accepted'.tr());

                                  bloc.add(OrderEvent(
                                      status: OrderEventStatus.DO_ASYNC));
                                  bloc.add(OrderEvent(
                                      status: OrderEventStatus.FETCH_UNACCEPTED));
                                } else {
                                  displayDialog(context,
                                      'generic.error_dialog_title'.tr(),
                                      'orders.unaccepted.error_accepting_dialog_content'.tr());
                                }
                              }
                              if (state is OrderDeletedState) {
                                if (state.result == true) {
                                  createSnackBar(
                                      context,
                                      'orders.snackbar_deleted'.tr());

                                  bloc.add(OrderEvent(
                                      status: OrderEventStatus.DO_ASYNC));
                                  bloc.add(OrderEvent(
                                      status: OrderEventStatus.FETCH_UNACCEPTED));
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
                                            status: OrderEventStatus
                                                .FETCH_UNACCEPTED)
                                    );
                                  }

                                  if (state is OrdersUnacceptedLoadedState) {
                                    hasNextPage = state.orders.next != null;
                                    orderList = new List.from(orderList)..addAll(state.orders.results);

                                    return UnacceptedListWidget(
                                        orderList: orderList,
                                        controller: controller
                                    );
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
